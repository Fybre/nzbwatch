use std::path::{Path, PathBuf};
use std::fs;
use unrar::Archive;
use crate::{Result, NzbError};

pub struct PostProcessor;

impl PostProcessor {
    /// Analyzes the downloaded files, extracts RARs if present, and returns the path to the main video file.
    pub async fn process(download_dir: &Path) -> Result<PathBuf> {
        // 1. Check and repair files with PAR2 if needed
        // (Placeholder: Logic for identifying PAR2 files and calling system par2 or internal lib)
        if let Err(e) = Self::repair_files(download_dir) {
            eprintln!("[PostProcessor] PAR2 Repair warning: {:?}", e);
        }

        // 2. Find and extract RAR archives
        if let Err(e) = Self::extract_rars(download_dir) {
            eprintln!("[PostProcessor] Extraction warning: {:?}", e);
        }

        // 3. Find the best video file to play
        Self::find_main_video_file(download_dir)
    }

    fn repair_files(dir: &Path) -> Result<()> {
        let entries = fs::read_dir(dir).map_err(|e| NzbError::Io(e))?;
        let par2_files: Vec<PathBuf> = entries
            .filter_map(|e| e.ok())
            .map(|e| e.path())
            .filter(|p| p.extension().map_or(false, |ext| ext.to_str().unwrap_or("").to_lowercase() == "par2"))
            .collect();

        if !par2_files.is_empty() {
            println!("[PostProcessor] Found {} PAR2 files. Automated repair is pending implementation.", par2_files.len());
            // In a future update, we can integrate a PAR2 library or use std::process::Command 
            // to call a system 'par2' binary if available.
        }
        Ok(())
    }

    fn extract_rars(dir: &Path) -> Result<()> {
        let entries = fs::read_dir(dir).map_err(|e| NzbError::Io(e))?;
        let mut rar_files: Vec<PathBuf> = entries
            .filter_map(|e| e.ok())
            .map(|e| e.path())
            .filter(|p| {
                let ext = p.extension().map_or("", |ext| ext.to_str().unwrap_or("")).to_lowercase();
                ext == "rar" || (ext.starts_with('r') && ext.len() == 3 && ext[1..].chars().all(|c| c.is_ascii_digit()))
            })
            .collect();

        rar_files.sort();

        if let Some(first_rar) = rar_files.first() {
            println!("[PostProcessor] Extracting archive set starting with: {:?}", first_rar);
            
            let archive = Archive::new(first_rar.to_str().unwrap())
                .open_for_processing()
                .map_err(|e| NzbError::Parse(format!("Rar open failed: {}", e)))?;
            
            let mut open_archive = archive;
            while let Some(header) = open_archive.read_header()
                .map_err(|e| NzbError::Parse(format!("Rar header read failed: {}", e)))? 
            {
                let is_file = header.entry().is_file();
                let filename = header.entry().filename.clone();
                
                if is_file {
                    let out_path = dir.join(&filename);
                    if let Some(parent) = out_path.parent() {
                        let _ = fs::create_dir_all(parent);
                    }
                    open_archive = header.extract_to(out_path.to_str().unwrap())
                        .map_err(|e| NzbError::Parse(format!("Extraction failed for {:?}: {}", filename, e)))?;
                } else {
                    open_archive = header.skip()
                        .map_err(|e| NzbError::Parse(format!("Skip failed: {}", e)))?
                };
            }
            println!("[PostProcessor] Extraction complete.");
        }
        Ok(())
    }

    pub fn find_main_video_file(dir: &Path) -> Result<PathBuf> {
        let mut videos = Self::find_videos_recursive(dir);
        videos.sort_by(|a, b| b.1.cmp(&a.1));

        let main_video = if videos.len() > 1 {
            videos.iter()
                .find(|(_, size)| *size > 100 * 1024 * 1024)
                .map(|(p, _)| p.clone())
                .or_else(|| videos.first().map(|(p, _)| p.clone()))
        } else {
            videos.first().map(|(p, _)| p.clone())
        };

        main_video.ok_or_else(|| NzbError::Parse("No playable video file found".to_string()))
    }

    fn find_videos_recursive(dir: &Path) -> Vec<(PathBuf, u64)> {
        let mut results = Vec::new();
        if let Ok(entries) = fs::read_dir(dir) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.is_dir() {
                    results.extend(Self::find_videos_recursive(&path));
                } else if Self::is_video(&path) {
                    if let Ok(meta) = fs::metadata(&path) {
                        results.push((path, meta.len()));
                    }
                }
            }
        }
        results
    }

    fn is_video(path: &Path) -> bool {
        let ext = path.extension().and_then(|s| s.to_str()).unwrap_or("").to_lowercase();
        matches!(ext.as_str(), "mkv" | "mp4" | "avi" | "mov" | "wmv" | "m4v" | "webm")
    }
}
