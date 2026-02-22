//! C-compatible FFI exports for Dart interop

use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};
use std::sync::{Arc, Mutex};
use std::collections::HashMap;

use crate::{
    NzbFile, ServerConfig,
};

// Global API instance
lazy_static::lazy_static! {
    static ref API_INSTANCE: Mutex<Option<Arc<NzbWatchApi>>> = Mutex::new(None);
}

use crate::cache::server::StreamServer;

pub struct ActiveDownload {
    pub storage: Arc<crate::cache::Storage>,
    pub server: Option<Arc<Mutex<StreamServer>>>,
}

pub struct NzbWatchApi {
    pub runtime: tokio::runtime::Runtime,
    // Track active downloads for cancellation and deletion
    pub active_downloads: Arc<dashmap::DashMap<String, ActiveDownload>>,
}

impl NzbWatchApi {
    fn new() -> Self {
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .worker_threads(4)
            .enable_all()
            .build()
            .expect("Failed to create Tokio runtime");
        
        Self { 
            runtime,
            active_downloads: Arc::new(dashmap::DashMap::new()),
        }
    }
}

/// Ping the API to verify connectivity
#[no_mangle]
pub extern "C" fn core_ping() -> c_int {
    42
}

/// Initialize the API
#[no_mangle]
pub extern "C" fn core_init() -> *mut NzbWatchApi {
    let api = NzbWatchApi::new();
    Box::into_raw(Box::new(api))
}

/// Destroy the API
#[no_mangle]
pub extern "C" fn core_destroy(api: *mut NzbWatchApi) {
    if !api.is_null() {
        unsafe {
            let _ = Box::from_raw(api);
        }
    }
}

/// Parse NZB XML
#[no_mangle]
pub extern "C" fn core_parse_nzb(api_ptr: *mut NzbWatchApi, xml: *const c_char) -> *mut c_char {
    if api_ptr.is_null() || xml.is_null() {
        return std::ptr::null_mut();
    }
    
    let xml_str = unsafe {
        match CStr::from_ptr(xml).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        }
    };
    
    match NzbFile::from_xml(xml_str) {
        Ok(nzb) => {
            let json = match serde_json::to_string(&nzb) {
                Ok(j) => j,
                Err(_) => return std::ptr::null_mut(),
            };
            
            match CString::new(json) {
                Ok(cstr) => cstr.into_raw(),
                Err(_) => std::ptr::null_mut(),
            }
        }
        Err(e) => {
            eprintln!("Parse error: {:?}", e);
            std::ptr::null_mut()
        }
    }
}

/// Check segment availability (Pre-check)
#[no_mangle]
pub extern "C" fn core_check_availability(api_ptr: *mut NzbWatchApi, config_json: *const c_char) -> f64 {
    if api_ptr.is_null() || config_json.is_null() {
        return 0.0;
    }
    
    let api = unsafe { &*api_ptr };
    let config_str = unsafe {
        match CStr::from_ptr(config_json).to_str() {
            Ok(s) => s,
            Err(_) => return 0.0,
        }
    };
    
    let config: DownloadConfig = match serde_json::from_str(config_str) {
        Ok(c) => c,
        Err(_) => return 0.0,
    };

    api.runtime.block_on(async {
        use crate::nntp::NntpClient;
        use futures::StreamExt;
        
        let clients: Vec<NntpClient> = config.servers
            .iter()
            .map(|s| NntpClient::new(s.clone()))
            .collect();
        
        if clients.is_empty() {
            return 0.0;
        }

        let mut all_segments: Vec<String> = config.nzb.files.iter()
            .flat_map(|f| f.segments.iter().map(|s| s.message_id.clone()))
            .collect();
        
        // Sampling: If more than 100 segments, pick 100 distributed segments
        // to get a fast but accurate health estimate.
        if all_segments.len() > 100 {
            let total = all_segments.len();
            let step = total / 100;
            all_segments = (0..100).map(|i| all_segments[i * step].clone()).collect();
        }

        let total = all_segments.len();
        if total == 0 { return 100.0; }

        let clients_arc = Arc::new(clients);
        
        // Check segments in parallel (up to 10 at a time)
        let results = futures::stream::iter(all_segments)
            .map(|msg_id| {
                let clients = clients_arc.clone();
                async move {
                    for client in clients.iter() {
                        if let Ok(mut conn) = client.get_connection().await {
                            if let Ok(exists) = conn.check_article(&msg_id).await {
                                let _ = conn.quit().await;
                                if exists { return true; }
                            } else {
                                let _ = conn.quit().await;
                            }
                        }
                    }
                    false
                }
            })
            .buffer_unordered(10) // 10 parallel checks
            .collect::<Vec<bool>>()
            .await;

        let found_count = results.iter().filter(|&&r| r).count();
        (found_count as f64 / total as f64) * 100.0
    })
}

/// Start a download
#[no_mangle]
pub extern "C" fn core_start_download(api_ptr: *mut NzbWatchApi, config_json: *const c_char) -> *mut c_char {
    if api_ptr.is_null() || config_json.is_null() {
        return std::ptr::null_mut();
    }
    
    let api = unsafe { &*api_ptr };
    
    let config_str = unsafe {
        match CStr::from_ptr(config_json).to_str() {
            Ok(s) => s,
            Err(_) => return std::ptr::null_mut(),
        }
    };
    
    // Parse config
    let config: DownloadConfig = match serde_json::from_str(config_str) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("Config parse error: {:?}", e);
            return std::ptr::null_mut();
        }
    };
    
    let download_id = config.download_id.clone();
    let download_id_for_error = config.download_id.clone();
    let output_dir_for_error = config.output_dir.clone();
    
    let active_downloads = api.active_downloads.clone();
    
    // Spawn download in background
    std::thread::spawn(move || {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            match run_real_download(config, active_downloads.clone()).await {
                Ok(_) => {
                    active_downloads.remove(&download_id_for_error);
                }
                Err(e) => {
                    eprintln!("Download error: {:?}", e);
                    active_downloads.remove(&download_id_for_error);
                    // Write error status file
                    let status_path = std::path::PathBuf::from(&output_dir_for_error)
                        .join(format!("{}.status.json", download_id_for_error));
                    let error_msg = format!("{}", e);
                    let status_json = format!(
                        r#"{{"status":"error","error":"{}","timestamp":{}}}"#,
                        error_msg.replace('"', "\\\""),
                        std::time::SystemTime::now()
                            .duration_since(std::time::UNIX_EPOCH)
                            .unwrap_or_default()
                            .as_secs()
                    );
                    let _ = std::fs::write(&status_path, status_json);
                }
            }
        });
    });
    
    match CString::new(download_id) {
        Ok(cstr) => cstr.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Delete a download and all its files
#[no_mangle]
pub extern "C" fn core_delete_download(api_ptr: *mut NzbWatchApi, download_id_ptr: *const c_char, config_json: *const c_char) -> c_int {
    if api_ptr.is_null() || download_id_ptr.is_null() {
        return 0;
    }
    
    let api = unsafe { &*api_ptr };
    let download_id = unsafe { CStr::from_ptr(download_id_ptr).to_str().unwrap_or("") };
    
    // If it's active, remove it and get the storage instance to delete files
    if let Some((_, active)) = api.active_downloads.remove(download_id) {
        if let Some(server) = active.server {
            let mut server = server.lock().unwrap();
            server.stop();
        }
        let _ = api.runtime.block_on(async {
            active.storage.delete_all_files().await
        });
        return 1;
    }

    // If it's not active, we might need the config to know what files to delete
    if !config_json.is_null() {
        let config_str = unsafe { CStr::from_ptr(config_json).to_str().unwrap_or("") };
        if let Ok(config) = serde_json::from_str::<DownloadConfig>(config_str) {
            let _ = api.runtime.block_on(async {
                let storage = crate::cache::Storage::new(crate::DownloadConfig {
                    download_id: download_id.to_string(),
                    nzb: config.nzb,
                    servers: config.servers,
                    output_dir: std::path::PathBuf::from(config.output_dir),
                    temp_dir: std::path::PathBuf::from(config.temp_dir),
                }).await?;
                storage.delete_all_files().await
            });
            return 1;
        }
    }

    0
}

/// Cancel a download
#[no_mangle]
pub extern "C" fn core_cancel_download(api_ptr: *mut NzbWatchApi, download_id_ptr: *const c_char) {
    if api_ptr.is_null() || download_id_ptr.is_null() {
        return;
    }
    let api = unsafe { &*api_ptr };
    let download_id = unsafe { CStr::from_ptr(download_id_ptr).to_str().unwrap_or("") };
    if let Some((_, active)) = api.active_downloads.remove(download_id) {
        if let Some(server) = active.server {
            let mut server = server.lock().unwrap();
            server.stop();
        }
    }
}

/// Test server connection
#[no_mangle]
pub extern "C" fn core_test_server(api_ptr: *mut NzbWatchApi, server_json: *const c_char) -> c_int {
    if api_ptr.is_null() || server_json.is_null() {
        return 0;
    }
    let api = unsafe { &*api_ptr };
    let server_str = unsafe { CStr::from_ptr(server_json).to_str().unwrap_or("") };
    let server: ServerConfig = match serde_json::from_str(server_str) {
        Ok(s) => s,
        Err(_) => return 0,
    };
    
    let result = api.runtime.block_on(async {
        match crate::nntp::NntpConnection::connect(&server).await {
            Ok(conn) => {
                let _ = conn.quit().await;
                true
            }
            Err(_) => false,
        }
    });
    
    if result { 1 } else { 0 }
}

/// Free a string returned by the API
#[no_mangle]
pub extern "C" fn core_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe { let _ = CString::from_raw(s); }
    }
}

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
struct DownloadConfig {
    pub download_id: String,
    pub nzb: NzbFile,
    pub servers: Vec<ServerConfig>,
    pub output_dir: String,
    pub temp_dir: String,
}

async fn run_real_download(
    config: DownloadConfig, 
    active_downloads: Arc<dashmap::DashMap<String, ActiveDownload>>
) -> crate::Result<()> {
    use crate::cache::Storage;
    use crate::nntp::NntpClient;
    use crate::yenc::YencDecoder;
    use crate::DownloadConfig as CoreDownloadConfig;
    
    let download_id = config.download_id.clone();
    let core_config = CoreDownloadConfig {
        download_id: download_id.clone(),
        nzb: config.nzb,
        servers: config.servers,
        output_dir: std::path::PathBuf::from(config.output_dir),
        temp_dir: std::path::PathBuf::from(config.temp_dir),
    };
    
    let storage = Arc::new(Storage::new(core_config.clone()).await?);
    
    // Setup streaming server if it looks like a video
    let mut server = None;
    let mut streaming_url = None;
    
    // Find the largest video file
    let video_file = core_config.nzb.files.iter()
        .filter(|f| is_video_file(&f.filename))
        .max_by_key(|f| f.size);
        
    if let Some(f) = video_file {
        let mut s = StreamServer::new(storage.clone());
        match s.start().await {
            Ok(_) => {
                streaming_url = Some(s.get_url(&f.filename));
                server = Some(Arc::new(Mutex::new(s)));
                println!("[DownloadManager] Streaming started: {:?}", streaming_url);
            }
            Err(e) => eprintln!("[DownloadManager] Failed to start stream server: {}", e),
        }
    }

    active_downloads.insert(download_id.clone(), ActiveDownload {
        storage: storage.clone(),
        server: server.clone(),
    });
    
    // Helper to write status file
    let write_status = |status: &str, error: Option<&str>| {
        let status_path = core_config.output_dir.join(format!("{}.status.json", download_id));
        let status_json = match error {
            Some(err) => format!(
                r#"{{"status":"{}","error":"{}","timestamp":{}}}"#,
                status,
                err.replace('"', "\\\""),
                std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap_or_default()
                    .as_secs()
            ),
            None => format!(
                r#"{{"status":"{}","timestamp":{}}}"#,
                status,
                std::time::SystemTime::now()
                    .duration_since(std::time::UNIX_EPOCH)
                    .unwrap_or_default()
                    .as_secs()
            ),
        };
        let _ = std::fs::write(&status_path, status_json);
    };
    
    let clients: Vec<NntpClient> = core_config
        .servers
        .iter()
        .map(|s| NntpClient::new(s.clone()))
        .collect();
    
    if clients.is_empty() {
        return Err(crate::NzbError::Connection("No servers configured".to_string()));
    }
    
    // Maintain a connection for each client to reuse
    let mut active_conns: Vec<Option<crate::nntp::NntpConnection>> = (0..clients.len()).map(|_| None).collect();
    let mut current_client_idx = 0;
    
    let mut last_speed_check = std::time::Instant::now();
    let mut last_bytes = 0;
    
    // LOOP OVER FILES
    for file_entry in &core_config.nzb.files {
        storage.set_current_file(Some(file_entry.filename.clone())).await;
        for segment in &file_entry.segments {
            // Check for cancellation
            if !active_downloads.contains_key(&download_id) {
                // Close all active connections before returning
                for conn in active_conns.into_iter().flatten() {
                    let _ = conn.quit().await;
                }
                return Err(crate::NzbError::Cancelled);
            }

            if storage.is_segment_complete(&file_entry.filename, segment.number).await {
                continue;
            }
            
            let mut success = false;
            let mut attempts = 0;
            
            while !success && attempts < clients.len() * 2 {
                let idx = (current_client_idx + attempts) % clients.len();
                let client = &clients[idx];
                attempts += 1;
                
                // Get or create connection
                let conn = if let Some(c) = active_conns[idx].take() {
                    c
                } else {
                    match client.get_connection().await {
                        Ok(c) => c,
                        Err(e) => {
                            eprintln!("Failed to connect to {}: {}", client.config().host, e);
                            continue;
                        }
                    }
                };

                // Try to fetch
                let mut conn = conn;
                match conn.fetch_article(&segment.message_id).await {
                    Ok(article) => {
                        match YencDecoder::decode(&article.body) {
                            Ok((decoded_data, header)) => {
                                                                        let offset = header.begin.map(|b| b.saturating_sub(1)).unwrap_or(0);
                                                                        storage.write_segment(&file_entry.filename, segment.number, offset, &decoded_data).await?;
                                                                        
                                                                        // Update speed calculation
                                                                        let now = std::time::Instant::now();
                                                                        let elapsed = now.duration_since(last_speed_check);
                                                                        if elapsed.as_millis() >= 1000 {
                                                                            let current_bytes = storage.downloaded_byte_count();
                                                                            let diff = current_bytes.saturating_sub(last_bytes);
                                                                            let bps = (diff as f64 / elapsed.as_secs_f64()) as u64;
                                                                            storage.set_speed(bps);
                                                                            last_bytes = current_bytes;
                                                                            last_speed_check = now;
                                                                        }
                                
                                                                        // Update progress file
                                                                        let mut progress = storage.get_progress().await;
                                                                        progress.streaming_url = streaming_url.clone();
                                                                        
                                                                        let progress_path = core_config.output_dir.join(format!("{}.progress.json", download_id));
                                                                        let progress_json = serde_json::to_string(&progress).unwrap_or_default();
                                                                        let _ = std::fs::write(&progress_path, progress_json);

                                success = true;
                                current_client_idx = idx; // Stick with this client for next segment
                                active_conns[idx] = Some(conn); // Save for reuse
                            }
                            Err(_) => {
                                // Potentially bad article, let's not reuse connection just in case
                                let _ = conn.quit().await;
                            }
                        }
                    }
                    Err(crate::NzbError::SegmentNotFound(_)) => {
                        active_conns[idx] = Some(conn); // Article not found is not a connection error
                    }
                    Err(e) => {
                        eprintln!("Fetch error on {}: {}", client.config().host, e);
                        let _ = conn.quit().await; // Connection error, drop it
                    }
                }
            }
            
            if !success {
                // If segment not found on any server, mark as failed but continue
                storage.mark_segment_failed(&file_entry.filename, segment.number).await;
                
                // Update progress file even on failure
                let mut progress = storage.get_progress().await;
                progress.streaming_url = streaming_url.clone();
                let progress_path = core_config.output_dir.join(format!("{}.progress.json", download_id));
                let progress_json = serde_json::to_string(&progress).unwrap_or_default();
                let _ = std::fs::write(&progress_path, progress_json);
            }
        }
    }
    
    // Close all connections when finished
    for conn in active_conns.into_iter().flatten() {
        let _ = conn.quit().await;
    }
    
    // Stop server if finished
    if let Some(s) = server {
        s.lock().unwrap().stop();
    }
    
    // POST PROCESSING
    let _ = tokio::task::spawn_blocking(move || {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async {
            match crate::post_processor::PostProcessor::process(&core_config.output_dir).await {
                Ok(video_path) => {
                    // Update status file with final playable path and SUCCESS status
                    let status_path = core_config.output_dir.join(format!("{}.status.json", download_id));
                    let status_json = format!(
                        r#"{{"status":"complete","video_path":"{}","timestamp":{}}}"#,
                        video_path.to_str().unwrap_or("").replace('\\', "\\\\").replace('"', "\\\""),
                        std::time::SystemTime::now()
                            .duration_since(std::time::UNIX_EPOCH)
                            .unwrap_or_default()
                            .as_secs()
                    );
                    let _ = std::fs::write(&status_path, status_json);
                }
                Err(e) => {
                    eprintln!("Post-processing error: {:?}", e);
                    // Update status file with ERROR status so UI marks it as failed
                    let status_path = core_config.output_dir.join(format!("{}.status.json", download_id));
                    let error_msg = format!("Post-processing failed: {}", e);
                    let status_json = format!(
                        r#"{{"status":"error","error":"{}","timestamp":{}}}"#,
                        error_msg.replace('"', "\\\""),
                        std::time::SystemTime::now()
                            .duration_since(std::time::UNIX_EPOCH)
                            .unwrap_or_default()
                            .as_secs()
                    );
                    let _ = std::fs::write(&status_path, status_json);
                }
            }
        });
    });

    Ok(())
}

fn is_video_file(filename: &str) -> bool {
    let ext = filename.split('.').last().unwrap_or("").to_lowercase();
    matches!(ext.as_str(), "mkv" | "mp4" | "avi" | "mov" | "wmv" | "m4v" | "webm" | "flv" | "ts")
}
