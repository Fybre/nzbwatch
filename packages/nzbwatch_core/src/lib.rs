pub mod cache;
pub mod ffi;
pub mod nntp;
pub mod yenc;
pub mod post_processor;

// Re-export FFI functions for C interop
pub use ffi::exports::*;

use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum NzbError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("NNTP error: {0}")]
    Nntp(String),
    
    #[error("yEnc decode error: {0}")]
    Yenc(String),
    
    #[error("Parse error: {0}")]
    Parse(String),
    
    #[error("Connection error: {0}")]
    Connection(String),
    
    #[error("Segment not found: {0}")]
    SegmentNotFound(String),
    
    #[error("Download cancelled")]
    Cancelled,
}

pub type Result<T> = std::result::Result<T, NzbError>;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServerConfig {
    pub id: String,
    pub name: String,
    pub host: String,
    pub port: u16,
    pub use_ssl: bool,
    pub username: String,
    pub password: String,
    pub max_connections: u32,
    pub priority: i32,
}

impl Default for ServerConfig {
    fn default() -> Self {
        Self {
            id: uuid::Uuid::new_v4().to_string(),
            name: "New Server".to_string(),
            host: "news.example.com".to_string(),
            port: 563,
            use_ssl: true,
            username: String::new(),
            password: String::new(),
            max_connections: 4,
            priority: 0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NzbFile {
    pub name: String,
    pub poster: Option<String>,
    pub groups: Vec<String>,
    pub files: Vec<NzbFileEntry>,
    pub total_size: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NzbFileEntry {
    pub filename: String,
    pub subject: String,
    pub segments: Vec<NzbSegment>,
    pub size: u64,
}

impl NzbFile {
    pub fn from_xml(xml: &str) -> Result<Self> {
        crate::nntp::nzb::parse_nzb(xml)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NzbSegment {
    pub number: u32,
    pub message_id: String,
    pub size: u64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum DownloadState {
    Queued,
    Downloading,
    Paused,
    Complete,
    Error,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DownloadProgress {
    pub download_id: String,
    pub state: DownloadState,
    pub total_bytes: u64,
    pub downloaded_bytes: u64,
    pub total_segments: u32,
    pub completed_segments: u32,
    pub speed_bytes_per_sec: u64,
    pub eta_seconds: Option<u64>,
    pub current_file: Option<String>,
    pub health: f64,
    /// List of (start_percent, end_percent) for downloaded parts
    pub downloaded_ranges: Vec<(f64, f64)>,
    pub error_message: Option<String>,
}

impl DownloadProgress {
    pub fn percent_complete(&self) -> f64 {
        if self.total_bytes == 0 {
            0.0
        } else {
            (self.downloaded_bytes as f64 / self.total_bytes as f64) * 100.0
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DownloadConfig {
    pub download_id: String,
    pub nzb: NzbFile,
    pub servers: Vec<ServerConfig>,
    #[serde(with = "pathbuf_serde")]
    pub output_dir: PathBuf,
    #[serde(with = "pathbuf_serde")]
    pub temp_dir: PathBuf,
}

mod pathbuf_serde {
    use std::path::PathBuf;
    use serde::{self, Deserialize, Serializer, Deserializer};
    
    pub fn serialize<S>(path: &PathBuf, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(path.to_str().unwrap_or(""))
    }
    
    pub fn deserialize<'de, D>(deserializer: D) -> Result<PathBuf, D::Error>
    where
        D: Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        Ok(PathBuf::from(s))
    }
}

pub struct NzbWatchCore {
    runtime: tokio::runtime::Runtime,
}

impl NzbWatchCore {
    pub fn new() -> Result<Self> {
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .worker_threads(4)
            .enable_all()
            .build()?;
            
        tracing_subscriber::fmt()
            .with_env_filter("info")
            .init();
            
        Ok(Self { runtime })
    }
}

impl Default for NzbWatchCore {
    fn default() -> Self {
        Self::new().expect("Failed to initialize NzbWatchCore")
    }
}
