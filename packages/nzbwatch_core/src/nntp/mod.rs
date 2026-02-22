pub mod client;
pub mod nzb;

use bytes::{BufMut, BytesMut};
use std::io;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;
use tokio_rustls::TlsStream;

pub use client::{NntpClient, NntpConnection};

#[derive(Debug)]
pub enum NntpStream {
    Plain(TcpStream),
    Tls(TlsStream<TcpStream>),
}

impl NntpStream {
    pub async fn read_line(&mut self, buf: &mut BytesMut) -> io::Result<usize> {
        let mut total = 0;
        loop {
            let byte = match self {
                NntpStream::Plain(s) => {
                    let mut b = [0u8; 1];
                    s.read_exact(&mut b).await?;
                    b[0]
                }
                NntpStream::Tls(s) => {
                    let mut b = [0u8; 1];
                    s.read_exact(&mut b).await?;
                    b[0]
                }
            };
            buf.put_u8(byte);
            total += 1;
            if buf.len() >= 2 {
                let last_two = &buf[buf.len() - 2..];
                if last_two == b"\r\n" {
                    break;
                }
            }
        }
        Ok(total)
    }

    pub async fn read_exact(&mut self, buf: &mut [u8]) -> io::Result<()> {
        match self {
            NntpStream::Plain(s) => s.read_exact(buf).await.map(|_| ()),
            NntpStream::Tls(s) => s.read_exact(buf).await.map(|_| ()),
        }
    }

    pub async fn write_all(&mut self, buf: &[u8]) -> io::Result<()> {
        match self {
            NntpStream::Plain(s) => s.write_all(buf).await,
            NntpStream::Tls(s) => s.write_all(buf).await,
        }
    }

    pub async fn flush(&mut self) -> io::Result<()> {
        match self {
            NntpStream::Plain(s) => s.flush().await,
            NntpStream::Tls(s) => s.flush().await,
        }
    }
}

#[derive(Debug, Clone)]
pub struct NntpResponse {
    pub code: u16,
    pub message: String,
}

impl NntpResponse {
    pub fn is_success(&self) -> bool {
        matches!(self.code, 200..=299)
    }

    pub fn is_transient_failure(&self) -> bool {
        matches!(self.code, 400..=499)
    }

    pub fn is_permanent_failure(&self) -> bool {
        matches!(self.code, 500..=599)
    }
}

#[derive(Debug)]
pub struct Article {
    pub headers: Vec<(String, String)>,
    pub body: Vec<u8>,
}
