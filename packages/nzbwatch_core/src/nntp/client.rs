use super::{Article, NntpResponse, NntpStream};
use crate::{NzbError, Result, ServerConfig};
use bytes::BytesMut;
use std::sync::Arc;
use std::time::Duration;
use tokio::net::TcpStream;
use tokio::sync::Semaphore;
use tokio::time::timeout;
use tokio_rustls::rustls::{ClientConfig, RootCertStore, OwnedTrustAnchor, Certificate};
use tokio_rustls::TlsConnector;

const CONNECTION_TIMEOUT: Duration = Duration::from_secs(10);
const READ_TIMEOUT: Duration = Duration::from_secs(30);

lazy_static::lazy_static! {
    static ref ROOT_CERT_STORE: RootCertStore = {
        let mut root_store = RootCertStore::empty();
        
        // Try native certs first
        if let Ok(certs) = rustls_native_certs::load_native_certs() {
            for cert in certs {
                let _ = root_store.add(&Certificate(cert.0));
            }
        }
        
        // Add webpki roots as fallback/addition
        root_store.add_trust_anchors(
            webpki_roots::TLS_SERVER_ROOTS.iter().map(|ta| {
                OwnedTrustAnchor::from_subject_spki_name_constraints(
                    ta.subject.as_ref().to_vec(),
                    ta.spki.as_ref().to_vec(),
                    ta.name_constraints.as_ref().map(|nc| nc.as_ref().to_vec()),
                )
            })
        );
        root_store
    };

    static ref TLS_CONFIG: Arc<ClientConfig> = Arc::new(
        ClientConfig::builder()
            .with_safe_defaults()
            .with_root_certificates(ROOT_CERT_STORE.clone())
            .with_no_client_auth()
    );
}

pub struct NntpConnection {
    stream: NntpStream,
    config: ServerConfig,
}

impl NntpConnection {
    pub async fn connect(config: &ServerConfig) -> Result<Self> {
        let addr = format!("{}:{}", config.host, config.port);
        
        // Connect with timeout
        let tcp_stream = timeout(
            CONNECTION_TIMEOUT,
            TcpStream::connect(&addr)
        )
        .await
        .map_err(|_| NzbError::Connection(format!("Connection to {} timed out after {}s", addr, CONNECTION_TIMEOUT.as_secs())))?
        .map_err(|e| NzbError::Connection(format!("Failed to connect to {}: {}", addr, e)))?;

        let stream = if config.use_ssl {
            let connector = TlsConnector::from(TLS_CONFIG.clone());
            let domain = tokio_rustls::rustls::ServerName::try_from(config.host.as_str())
                .map_err(|e| NzbError::Connection(format!("Invalid hostname: {}", e)))?;
            
            let tls_stream = timeout(
                CONNECTION_TIMEOUT,
                connector.connect(domain, tcp_stream)
            )
            .await
            .map_err(|_| NzbError::Connection(format!("TLS handshake timed out after {}s", CONNECTION_TIMEOUT.as_secs())))?
            .map_err(|e| NzbError::Connection(format!("TLS handshake failed: {}", e)))?;
            
            NntpStream::Tls(tokio_rustls::TlsStream::Client(tls_stream))
        } else {
            NntpStream::Plain(tcp_stream)
        };

        let mut conn = Self {
            stream,
            config: config.clone(),
        };

        // Read greeting with timeout
        let response = timeout(READ_TIMEOUT, conn.read_response())
            .await
            .map_err(|_| NzbError::Connection("Timeout reading server greeting".to_string()))??;
            
        if !response.is_success() {
            return Err(NzbError::Nntp(format!(
                "Server rejected connection: {}",
                response.message
            )));
        }

        // Authenticate if needed
        if !config.username.is_empty() {
            timeout(READ_TIMEOUT, conn.authenticate())
                .await
                .map_err(|_| NzbError::Connection("Authentication timed out".to_string()))??;
        }

        Ok(conn)
    }

    async fn authenticate(&mut self) -> Result<()> {
        self.send_command(&format!("AUTHINFO USER {}", self.config.username))
            .await?;
        let response = self.read_response().await?;

        if response.code == 381 {
            // Password required
            self.send_command(&format!("AUTHINFO PASS {}", self.config.password))
                .await?;
            let response = self.read_response().await?;
            if !response.is_success() {
                return Err(NzbError::Nntp(format!(
                    "Authentication failed: {}",
                    response.message
                )));
            }
        } else if !response.is_success() {
            return Err(NzbError::Nntp(format!(
                "Authentication failed: {}",
                response.message
            )));
        }

        Ok(())
    }

    pub async fn check_article(&mut self, message_id: &str) -> Result<bool> {
        let msg_id = message_id.trim_matches(|c| c == '<' || c == '>');
        let cmd = format!("STAT <{}>", msg_id);
        self.send_command(&cmd).await?;
        let response = self.read_response().await?;
        
        // 223 is the success code for STAT (Article found and exists)
        Ok(response.code == 223)
    }

    pub async fn fetch_article(&mut self, message_id: &str) -> Result<Article> {
        // Strip angle brackets if the NZB already includes them (XML &lt;...&gt; decoded),
        // then wrap properly for the BODY command.
        let msg_id = message_id.trim_matches(|c| c == '<' || c == '>');
        let cmd = format!("BODY <{}>", msg_id);
        self.send_command(&cmd).await?;
        let response = self.read_response().await?;

        if response.code == 430 || response.code == 423 {
            return Err(NzbError::SegmentNotFound(msg_id.to_string()));
        }

        if !response.is_success() {
            return Err(NzbError::Nntp(format!(
                "Failed to fetch article {}: {} {}",
                msg_id, response.code, response.message
            )));
        }

        let body = self.read_multiline_response().await?;

        Ok(Article {
            headers: vec![],
            body,
        })
    }

    async fn send_command(&mut self, cmd: &str) -> Result<()> {
        let command = format!("{}\r\n", cmd);
        self.stream
            .write_all(command.as_bytes())
            .await
            .map_err(|e| NzbError::Io(e))?;
        self.stream.flush().await.map_err(|e| NzbError::Io(e))?;
        Ok(())
    }

    async fn read_response(&mut self) -> Result<NntpResponse> {
        let mut buf = BytesMut::new();
        self.stream.read_line(&mut buf).await.map_err(|e| NzbError::Io(e))?;
        
        let line = String::from_utf8_lossy(&buf);
        let line = line.trim();
        
        if line.len() < 3 {
            return Err(NzbError::Nntp("Invalid response from server".to_string()));
        }

        let code: u16 = line[..3]
            .parse()
            .map_err(|_| NzbError::Nntp("Invalid response code".to_string()))?;
        
        let message = line[3..].trim().to_string();

        Ok(NntpResponse { code, message })
    }

    async fn read_multiline_response(&mut self) -> Result<Vec<u8>> {
        let mut result = BytesMut::new();
        let mut buf = BytesMut::new();

        loop {
            buf.clear();
            self.stream.read_line(&mut buf).await.map_err(|e| NzbError::Io(e))?;
            
            // Check for end of response (line starting with ".")
            if buf.starts_with(b".") {
                if buf.len() >= 3 && &buf[0..3] == b".\r\n" {
                    break;
                }
                // Byte-stuffed line starting with "..", keep one "."
                result.extend_from_slice(&buf[1..]);
            } else {
                result.extend_from_slice(&buf);
            }
        }

        Ok(result.to_vec())
    }

    pub async fn quit(mut self) -> Result<()> {
        let _ = self.send_command("QUIT").await;
        Ok(())
    }
}

pub struct NntpClient {
    config: ServerConfig,
    connection_pool: Arc<Semaphore>,
}

impl NntpClient {
    pub fn new(config: ServerConfig) -> Self {
        let max_connections = config.max_connections as usize;
        Self {
            config,
            connection_pool: Arc::new(Semaphore::new(max_connections)),
        }
    }

    pub async fn get_connection(&self) -> Result<NntpConnection> {
        let _permit = self
            .connection_pool
            .acquire()
            .await
            .map_err(|e| NzbError::Connection(e.to_string()))?;
        
        NntpConnection::connect(&self.config).await
    }

    pub fn config(&self) -> &ServerConfig {
        &self.config
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tokio::io::{AsyncReadExt, AsyncWriteExt};
    use tokio::net::TcpListener;
    use tokio::sync::oneshot;

    fn test_config(port: u16) -> ServerConfig {
        ServerConfig {
            id: "test".to_string(),
            name: "Test".to_string(),
            host: "127.0.0.1".to_string(),
            port,
            use_ssl: false,
            username: String::new(),
            password: String::new(),
            max_connections: 1,
            priority: 0,
        }
    }

    /// Read one CRLF-terminated line from a raw TcpStream (mock server side).
    async fn read_crlf_line(stream: &mut tokio::net::TcpStream) -> String {
        let mut buf = Vec::new();
        let mut b = [0u8; 1];
        loop {
            stream.read_exact(&mut b).await.unwrap();
            buf.push(b[0]);
            if buf.ends_with(b"\r\n") {
                break;
            }
        }
        // Return without the trailing CRLF
        String::from_utf8_lossy(&buf[..buf.len() - 2]).to_string()
    }

    // -----------------------------------------------------------------------
    // Test: bare message ID (no angle brackets) → BODY <id>
    // -----------------------------------------------------------------------
    #[tokio::test]
    async fn test_body_wraps_bare_message_id() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let port = listener.local_addr().unwrap().port();
        let (tx, rx) = oneshot::channel::<String>();

        tokio::spawn(async move {
            let (mut stream, _) = listener.accept().await.unwrap();
            // Greeting
            stream.write_all(b"200 Welcome\r\n").await.unwrap();
            // Capture the BODY command
            let cmd = read_crlf_line(&mut stream).await;
            // Reply with a valid single-line article body
            stream.write_all(b"222 0 <id> article\r\n").await.unwrap();
            stream.write_all(b"content\r\n").await.unwrap();
            stream.write_all(b".\r\n").await.unwrap();
            let _ = tx.send(cmd);
        });

        let config = test_config(port);
        let mut conn = NntpConnection::connect(&config).await.unwrap();
        conn.fetch_article("msgid@server.com").await.unwrap();

        let received = rx.await.unwrap();
        assert_eq!(received, "BODY <msgid@server.com>");
    }

    // -----------------------------------------------------------------------
    // Test: message ID WITH angle brackets (as Dart decodes from XML)
    //       → must still produce BODY <id>, NOT BODY <<id>>
    // -----------------------------------------------------------------------
    #[tokio::test]
    async fn test_body_strips_existing_angle_brackets() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let port = listener.local_addr().unwrap().port();
        let (tx, rx) = oneshot::channel::<String>();

        tokio::spawn(async move {
            let (mut stream, _) = listener.accept().await.unwrap();
            stream.write_all(b"200 Welcome\r\n").await.unwrap();
            let cmd = read_crlf_line(&mut stream).await;
            stream.write_all(b"222 0 <id> article\r\n").await.unwrap();
            stream.write_all(b"content\r\n").await.unwrap();
            stream.write_all(b".\r\n").await.unwrap();
            let _ = tx.send(cmd);
        });

        let config = test_config(port);
        let mut conn = NntpConnection::connect(&config).await.unwrap();
        // Pass the ID WITH angle brackets — the way Dart hands it over after
        // decoding &lt;...&gt; entities from the NZB XML.
        conn.fetch_article("<msgid@server.com>").await.unwrap();

        let received = rx.await.unwrap();
        assert_eq!(
            received, "BODY <msgid@server.com>",
            "angle brackets were doubled: got '{}'", received
        );
        assert!(!received.contains("<<"), "Double angle brackets in BODY command!");
    }

    // -----------------------------------------------------------------------
    // Test: 430 response → NzbError::SegmentNotFound
    // -----------------------------------------------------------------------
    #[tokio::test]
    async fn test_fetch_430_returns_segment_not_found() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let port = listener.local_addr().unwrap().port();

        tokio::spawn(async move {
            let (mut stream, _) = listener.accept().await.unwrap();
            stream.write_all(b"200 Welcome\r\n").await.unwrap();
            read_crlf_line(&mut stream).await; // consume BODY command
            stream.write_all(b"430 No such article\r\n").await.unwrap();
        });

        let config = test_config(port);
        let mut conn = NntpConnection::connect(&config).await.unwrap();
        let result = conn.fetch_article("<missing@server.com>").await;

        assert!(
            matches!(result, Err(NzbError::SegmentNotFound(_))),
            "expected SegmentNotFound, got {:?}", result
        );
    }

    // -----------------------------------------------------------------------
    // Test: 423 response (invalid article number) → NzbError::SegmentNotFound
    // -----------------------------------------------------------------------
    #[tokio::test]
    async fn test_fetch_423_returns_segment_not_found() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let port = listener.local_addr().unwrap().port();

        tokio::spawn(async move {
            let (mut stream, _) = listener.accept().await.unwrap();
            stream.write_all(b"200 Welcome\r\n").await.unwrap();
            read_crlf_line(&mut stream).await;
            stream.write_all(b"423 No article with that number\r\n").await.unwrap();
        });

        let config = test_config(port);
        let mut conn = NntpConnection::connect(&config).await.unwrap();
        let result = conn.fetch_article("article@host.com").await;

        assert!(matches!(result, Err(NzbError::SegmentNotFound(_))));
    }

    // -----------------------------------------------------------------------
    // Test: successful fetch returns the article body bytes
    // -----------------------------------------------------------------------
    #[tokio::test]
    async fn test_fetch_article_returns_body_bytes() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let port = listener.local_addr().unwrap().port();

        tokio::spawn(async move {
            let (mut stream, _) = listener.accept().await.unwrap();
            stream.write_all(b"200 Welcome\r\n").await.unwrap();
            read_crlf_line(&mut stream).await;
            stream.write_all(b"222 0 <test> article\r\n").await.unwrap();
            stream.write_all(b"line one\r\n").await.unwrap();
            stream.write_all(b"line two\r\n").await.unwrap();
            // dot-stuffed line (starts with "..")
            stream.write_all(b"..dotted line\r\n").await.unwrap();
            // terminator
            stream.write_all(b".\r\n").await.unwrap();
        });

        let config = test_config(port);
        let mut conn = NntpConnection::connect(&config).await.unwrap();
        let article = conn.fetch_article("test@host.com").await.unwrap();

        let body = String::from_utf8_lossy(&article.body);
        assert!(body.contains("line one"), "body missing 'line one'");
        assert!(body.contains("line two"), "body missing 'line two'");
        // dot-stuffing: the leading "." should have been stripped → ".dotted line"
        assert!(body.contains(".dotted line"), "dot-unstuffing failed");
        assert!(!body.contains("..dotted"), "dot-stuffed line was not un-stuffed");
    }
}
