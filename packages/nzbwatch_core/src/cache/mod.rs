use crate::{DownloadConfig, DownloadProgress, DownloadState, Result};
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use tokio::fs::{File, OpenOptions};
use tokio::io::{AsyncSeekExt, AsyncWriteExt};
use tokio::sync::{Mutex, RwLock, Notify};

pub mod server;

/// Manages the storage of downloaded segments to disk across multiple files
pub struct SequentialStorage {
    config: DownloadConfig,
    // Map of filename -> Mutex-protected File
    open_files: Arc<RwLock<HashMap<String, Arc<Mutex<File>>>>>,
    downloaded_bytes: Arc<AtomicU64>,
    // Map of (filename, segment_number) -> completion status
    completed_segments: Arc<RwLock<HashMap<(String, u32), bool>>>,
    // Map of (filename, segment_number) -> failure status
    failed_segments: Arc<RwLock<HashMap<(String, u32), bool>>>,
    // Status tracking
    current_file: Arc<RwLock<Option<String>>>,
    speed_bps: Arc<AtomicU64>,
    // Notify when a segment is written
    segment_written: Arc<Notify>,
}

impl SequentialStorage {
    pub async fn new(config: DownloadConfig) -> Result<Self> {
        // Ensure output directory exists
        tokio::fs::create_dir_all(&config.output_dir).await?;

        Ok(Self {
            config,
            open_files: Arc::new(RwLock::new(HashMap::new())),
            downloaded_bytes: Arc::new(AtomicU64::new(0)),
            completed_segments: Arc::new(RwLock::new(HashMap::new())),
            failed_segments: Arc::new(RwLock::new(HashMap::new())),
            current_file: Arc::new(RwLock::new(None)),
            speed_bps: Arc::new(AtomicU64::new(0)),
            segment_written: Arc::new(Notify::new()),
        })
    }

    pub fn get_config(&self) -> &DownloadConfig {
        &self.config
    }

    pub async fn get_file_size(&self, filename: &str) -> Option<u64> {
        self.config.nzb.files.iter()
            .find(|f| f.filename == filename)
            .map(|f| f.size)
    }

    pub async fn mark_segment_failed(&self, filename: &str, segment_number: u32) {
        self.failed_segments.write().await.insert((filename.to_string(), segment_number), true);
    }

    pub async fn set_current_file(&self, filename: Option<String>) {
        *self.current_file.write().await = filename;
    }

    pub fn set_speed(&self, bps: u64) {
        self.speed_bps.store(bps, Ordering::Relaxed);
    }

    /// Get or open a file for writing
    async fn get_file(&self, filename: &str) -> Result<Arc<Mutex<File>>> {
        {
            let files = self.open_files.read().await;
            if let Some(file) = files.get(filename) {
                return Ok(file.clone());
            }
        }

        let mut files = self.open_files.write().await;
        // Double check after acquiring write lock
        if let Some(file) = files.get(filename) {
            return Ok(file.clone());
        }

        let file_path = self.config.output_dir.join(filename);
        let file = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open(&file_path)
            .await?;

        let arc_file = Arc::new(Mutex::new(file));
        files.insert(filename.to_string(), arc_file.clone());
        Ok(arc_file)
    }

    /// Write a decoded segment to disk at the given byte offset for a specific file.
    pub async fn write_segment(&self, filename: &str, segment_number: u32, offset: u64, data: &[u8]) -> Result<()> {
        let file_mutex = self.get_file(filename).await?;
        let mut file = file_mutex.lock().await;
        
        file.seek(std::io::SeekFrom::Start(offset)).await?;
        file.write_all(data).await?;
        file.flush().await?;

        self.downloaded_bytes
            .fetch_add(data.len() as u64, Ordering::SeqCst);
        
        self.completed_segments
            .write()
            .await
            .insert((filename.to_string(), segment_number), true);

        // Notify any pending readers
        self.segment_written.notify_waiters();

        Ok(())
    }

    /// Read a range of bytes from a file.
    /// This does NOT wait for the data to be available.
    pub async fn read_range(&self, filename: &str, offset: u64, length: usize) -> Result<Vec<u8>> {
        let file_mutex = self.get_file(filename).await?;
        let mut file = file_mutex.lock().await;
        
        file.seek(std::io::SeekFrom::Start(offset)).await?;
        let mut buffer = vec![0u8; length];
        
        use tokio::io::AsyncReadExt;
        let n = file.read_exact(&mut buffer).await?;
        if n < length {
            buffer.truncate(n);
        }
        
        Ok(buffer)
    }

    /// Wait until a range of bytes is available in the given file.
    /// It checks which segments cover this range and waits for them to be completed.
    pub async fn wait_for_range(&self, filename: &str, offset: u64, length: u64) -> Result<()> {
        let file_entry = self.config.nzb.files.iter()
            .find(|f| f.filename == filename)
            .ok_or_else(|| crate::NzbError::Parse(format!("File not found: {}", filename)))?;

        // Find segments that overlap with the requested [offset, offset + length)
        let requested_end = offset + length;
        let mut required_segments: Vec<u32> = file_entry.segments.iter()
            .filter(|s| {
                // Approximate segment byte range
                // Note: This assumes segments are contiguous and we know their sizes.
                // In Usenet, we know the size of each segment from the NZB.
                // We need to calculate the cumulative offset.
                let mut seg_offset = 0u64;
                for i in 0..s.number.saturating_sub(1) {
                    seg_offset += file_entry.segments[i as usize].size;
                }
                let seg_end = seg_offset + s.size;
                
                // Check for overlap between [offset, requested_end) and [seg_offset, seg_end)
                offset < seg_end && seg_offset < requested_end
            })
            .map(|s| s.number)
            .collect();

        while !required_segments.is_empty() {
            // Check which are done
            {
                let completed = self.completed_segments.read().await;
                required_segments.retain(|&seg_num| {
                    !completed.contains_key(&(filename.to_string(), seg_num))
                });
            }

            if !required_segments.is_empty() {
                // Wait for a new segment to be written
                self.segment_written.notified().await;
            }
        }

        Ok(())
    }

    /// Check if a segment has been downloaded
    pub async fn is_segment_complete(&self, filename: &str, segment_number: u32) -> bool {
        self.completed_segments
            .read()
            .await
            .get(&(filename.to_string(), segment_number))
            .copied()
            .unwrap_or(false)
    }

    /// Number of segments written so far
    pub async fn completed_segment_count(&self) -> usize {
        self.completed_segments.read().await.len()
    }

    /// Total decoded bytes written so far
    pub fn downloaded_byte_count(&self) -> u64 {
        self.downloaded_bytes.load(Ordering::Relaxed)
    }

    /// Get current download progress
    pub async fn get_progress(&self) -> DownloadProgress {
        let completed_map = self.completed_segments.read().await;
        let completed = completed_map.len() as u32;
        let failed = self.failed_segments.read().await.len() as u32;
        
        // Flatten all segments from all files into a single ordered list for the buffer bar
        let all_segments: Vec<(&String, u32)> = self.config.nzb.files.iter()
            .flat_map(|f| f.segments.iter().map(move |s| (&f.filename, s.number)))
            .collect();
            
        let total_segments = all_segments.len() as u32;
        
        // Calculate ranges (simple bucketed approach for the UI)
        let mut downloaded_ranges = Vec::new();
        if total_segments > 0 {
            let bucket_count = 100;
            let segments_per_bucket = (total_segments as f64 / bucket_count as f64).max(1.0);
            
            let mut current_start = -1.0;
            for i in 0..bucket_count {
                let start_idx = (i as f64 * segments_per_bucket) as usize;
                let end_idx = (((i + 1) as f64 * segments_per_bucket) as usize).min(all_segments.len());
                
                if start_idx >= all_segments.len() { break; }
                
                // A bucket is "done" if all segments in it are completed
                let bucket_done = all_segments[start_idx..end_idx].iter()
                    .all(|(fname, num)| completed_map.contains_key(&((*fname).clone(), *num)));
                
                let bucket_percent = i as f64;
                if bucket_done {
                    if current_start < 0.0 {
                        current_start = bucket_percent;
                    }
                } else {
                    if current_start >= 0.0 {
                        downloaded_ranges.push((current_start, bucket_percent));
                        current_start = -1.0;
                    }
                }
            }
            if current_start >= 0.0 {
                downloaded_ranges.push((current_start, 100.0));
            }
        }

        let downloaded = self.downloaded_bytes.load(Ordering::Relaxed);
        let speed = self.speed_bps.load(Ordering::Relaxed);
        let current_file = self.current_file.read().await.clone();

        let health = if total_segments > 0 {
            (total_segments.saturating_sub(failed) as f64 / total_segments as f64) * 100.0
        } else {
            100.0
        };

        DownloadProgress {
            download_id: self.config.download_id.clone(),
            state: if completed + failed >= total_segments {
                DownloadState::Complete
            } else if downloaded > 0 {
                DownloadState::Downloading
            } else {
                DownloadState::Queued
            },
            total_bytes: self.config.nzb.total_size,
            downloaded_bytes: downloaded,
            total_segments,
            completed_segments: completed,
            speed_bytes_per_sec: speed,
            eta_seconds: if speed > 0 {
                Some((self.config.nzb.total_size.saturating_sub(downloaded)) / speed)
            } else {
                None
            },
            current_file,
            health,
            streaming_url: None,
            downloaded_ranges,
            error_message: None,
        }
    }

    /// Deletes all files associated with this download by removing the directory
    pub async fn delete_all_files(&self) -> Result<()> {
        // Close all open files first
        {
            let mut files = self.open_files.write().await;
            files.clear();
        }

        // Delete the entire output directory
        if self.config.output_dir.exists() {
            tokio::fs::remove_dir_all(&self.config.output_dir).await?;
        }

        Ok(())
    }
}

pub use SequentialStorage as Storage;
