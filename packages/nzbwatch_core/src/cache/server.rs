use std::net::SocketAddr;
use std::sync::Arc;
use axum::{
    extract::{Path, State},
    http::{header, StatusCode, Response, HeaderMap},
    response::IntoResponse,
    routing::get,
    Router,
    body::Body,
};
use crate::cache::Storage;
use crate::Result;
use tokio::sync::oneshot;

pub struct StreamServer {
    storage: Arc<Storage>,
    port: u16,
    stop_tx: Option<oneshot::Sender<()>>,
}

impl StreamServer {
    pub fn new(storage: Arc<Storage>) -> Self {
        Self {
            storage,
            port: 0, // Assigned later
            stop_tx: None,
        }
    }

    pub async fn start(&mut self) -> Result<u16> {
        let (stop_tx, stop_rx) = oneshot::channel();
        self.stop_tx = Some(stop_tx);
        
        let storage = self.storage.clone();
        
        let app = Router::new()
            .route("/stream/:filename", get(handle_stream))
            .with_state(storage);

        // Bind to a random port
        let addr = SocketAddr::from(([127, 0, 0, 1], 0));
        let listener = tokio::net::TcpListener::bind(addr).await?;
        let port = listener.local_addr()?.port();
        self.port = port;

        println!("[StreamServer] Listening on http://127.0.0.1:{}", port);

        tokio::spawn(async move {
            axum::serve(listener, app)
                .with_graceful_shutdown(async {
                    let _ = stop_rx.await;
                    println!("[StreamServer] Shutting down");
                })
                .await
                .unwrap();
        });

        Ok(port)
    }

    pub fn stop(&mut self) {
        if let Some(tx) = self.stop_tx.take() {
            let _ = tx.send(());
        }
    }

    pub fn get_url(&self, filename: &str) -> String {
        format!("http://127.0.0.1:{}/stream/{}", self.port, urlencoding::encode(filename))
    }
}

async fn handle_stream(
    Path(filename): Path<String>,
    State(storage): State<Arc<Storage>>,
    headers: HeaderMap,
) -> impl IntoResponse {
    let filename = match urlencoding::decode(&filename) {
        Ok(f) => f.into_owned(),
        Err(_) => return (StatusCode::BAD_REQUEST, "Invalid filename").into_response(),
    };

    // Find file metadata
    let file_info = storage.get_file_size(&filename).await;

    let total_size = match file_info {
        Some(s) => s,
        None => return (StatusCode::NOT_FOUND, "File not found").into_response(),
    };

    let range_header = headers.get(header::RANGE).and_then(|v| v.to_str().ok());
    
    let (start, end) = if let Some(range_str) = range_header {
        // Very basic manual parsing of "bytes=start-end"
        if let Some(stripped) = range_str.strip_prefix("bytes=") {
            let parts: Vec<&str> = stripped.split('-').collect();
            if parts.len() >= 2 {
                let s = parts[0].parse::<u64>().unwrap_or(0);
                let e = parts[1].parse::<u64>().unwrap_or(total_size - 1);
                (s, e)
            } else {
                (0, total_size - 1)
            }
        } else {
            (0, total_size - 1)
        }
    } else {
        (0, total_size - 1)
    };

    if start >= total_size {
        return (StatusCode::RANGE_NOT_SATISFIABLE, "Range out of bounds").into_response();
    }

    let length = (end.saturating_sub(start) + 1).min(total_size.saturating_sub(start));
    
    // WAIT for data to be available if it's a streaming download
    if let Err(e) = storage.wait_for_range(&filename, start, length).await {
        return (StatusCode::INTERNAL_SERVER_ERROR, format!("Wait error: {}", e)).into_response();
    }

    // Read the actual data
    match storage.read_range(&filename, start, length as usize).await {
        Ok(data) => {
            Response::builder()
                .status(StatusCode::PARTIAL_CONTENT)
                .header(header::CONTENT_TYPE, "video/x-matroska") // Fallback
                .header(header::ACCEPT_RANGES, "bytes")
                .header(header::CONTENT_RANGE, format!("bytes {}-{}/{}", start, start + data.len() as u64 - 1, total_size))
                .header(header::CONTENT_LENGTH, data.len())
                .body(Body::from(data))
                .unwrap()
                .into_response()
        }
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, format!("Read error: {}", e)).into_response(),
    }
}
