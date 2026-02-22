use crate::{NzbError, Result};

#[derive(Debug)]
pub struct YencHeader {
    pub name: String,
    pub size: u64,
    pub line: u32,
    pub part: Option<u32>,
    pub total: Option<u32>,
    pub begin: Option<u64>,
    pub end: Option<u64>,
    pub crc32: Option<String>,
    pub part_crc32: Option<String>,
}

pub struct YencDecoder;

impl YencDecoder {
    /// Decode a yEnc-encoded NNTP article body.
    /// Returns (decoded_bytes, header).
    pub fn decode(article_body: &[u8]) -> Result<(Vec<u8>, YencHeader)> {
        // Find =ybegin line anywhere in the body (NNTP headers may precede it)
        let ybegin_start = find_bytes(article_body, b"=ybegin")
            .ok_or_else(|| NzbError::Yenc("Missing =ybegin header".to_string()))?;

        let (ybegin_content_len, ybegin_eol_len) = line_end(&article_body[ybegin_start..]);
        let ybegin_line = ascii_str(&article_body[ybegin_start..ybegin_start + ybegin_content_len]);

        // Parse =ybegin fields (order-independent: real headers often put part= before line=)
        let line_count = parse_u32(&ybegin_line, "line=")
            .ok_or_else(|| NzbError::Yenc("Missing line= in =ybegin".to_string()))?;
        let size = parse_u64(&ybegin_line, "size=")
            .ok_or_else(|| NzbError::Yenc("Missing size= in =ybegin".to_string()))?;
        let name = parse_name(&ybegin_line)
            .ok_or_else(|| NzbError::Yenc("Missing name= in =ybegin".to_string()))?;
        let part = parse_u32(&ybegin_line, "part=");

        // Data starts after the =ybegin line
        let mut data_start = ybegin_start + ybegin_content_len + ybegin_eol_len;
        let mut begin: Option<u64> = None;
        let mut end_val: Option<u64> = None;

        // Check for optional =ypart line (contains file offsets for multipart yEnc)
        if article_body.len() > data_start && article_body[data_start..].starts_with(b"=ypart") {
            let (ypart_content_len, ypart_eol_len) = line_end(&article_body[data_start..]);
            let ypart_line = ascii_str(&article_body[data_start..data_start + ypart_content_len]);
            begin = parse_u64(&ypart_line, "begin=");
            end_val = parse_u64(&ypart_line, "end=");
            data_start += ypart_content_len + ypart_eol_len;
        }

        // Find =yend marker (look for newline + =yend to avoid false matches in encoded data)
        let yend_relative = find_bytes(&article_body[data_start..], b"\n=yend")
            .map(|p| p + 1) // point to '=' of =yend, skip the preceding \n
            .or_else(|| {
                // =yend at the very start of the data section (no preceding newline)
                if article_body[data_start..].starts_with(b"=yend") {
                    Some(0)
                } else {
                    None
                }
            })
            .unwrap_or(article_body.len() - data_start);
        let yend_start = data_start + yend_relative;

        // Parse =yend line for CRC values
        let (yend_content_len, _) = line_end(&article_body[yend_start..]);
        let yend_line = ascii_str(&article_body[yend_start..yend_start + yend_content_len]);

        let total = parse_u32(&yend_line, "total=");
        let crc32 = parse_hex(&yend_line, "crc32=");
        let part_crc32 = parse_hex(&yend_line, "pcrc32=");

        let header = YencHeader {
            name,
            size,
            line: line_count,
            part,
            total,
            begin,
            end: end_val,
            crc32,
            part_crc32,
        };

        // Decode raw data bytes directly — no UTF-8 conversion, which would corrupt binary data
        let encoded_data = &article_body[data_start..yend_start];
        let decoded = decode_bytes(encoded_data);

        // Verify CRC32 if present
        if let Some(ref expected_crc) = header.part_crc32 {
            let computed_crc = format!("{:08x}", crc32fast::hash(&decoded));
            if computed_crc != *expected_crc {
                return Err(NzbError::Yenc(format!(
                    "CRC mismatch: expected {}, got {}",
                    expected_crc, computed_crc
                )));
            }
        }

        Ok((decoded, header))
    }
}

/// Decode yEnc-encoded bytes to original bytes.
/// Each byte is decoded as: regular = byte - 42, escaped (=X) = X - 64.
/// Line endings (\r, \n) are skipped.
fn decode_bytes(encoded: &[u8]) -> Vec<u8> {
    let mut decoded = Vec::with_capacity(encoded.len());
    let mut i = 0;
    while i < encoded.len() {
        match encoded[i] {
            b'\r' | b'\n' => {
                i += 1;
            }
            b'=' => {
                i += 1;
                if i < encoded.len() {
                    // yEnc escape: encoder did (B + 42 + 64) mod 256, so undo both steps.
                    // wrapping_sub(64) alone is wrong — must also subtract 42.
                    decoded.push(encoded[i].wrapping_sub(64).wrapping_sub(42));
                    i += 1;
                }
            }
            b => {
                decoded.push(b.wrapping_sub(42));
                i += 1;
            }
        }
    }
    decoded
}

/// Find first occurrence of needle in haystack, returns byte index.
fn find_bytes(haystack: &[u8], needle: &[u8]) -> Option<usize> {
    haystack.windows(needle.len()).position(|w| w == needle)
}

/// Find the end of the current line.
/// Returns (content_len, eol_len) where content_len is the length before the EOL
/// and eol_len is 2 for \r\n, 1 for \n, 0 if no newline found.
fn line_end(data: &[u8]) -> (usize, usize) {
    for i in 0..data.len() {
        if data[i] == b'\r' && i + 1 < data.len() && data[i + 1] == b'\n' {
            return (i, 2);
        }
        if data[i] == b'\n' {
            return (i, 1);
        }
    }
    (data.len(), 0)
}

/// Convert a byte slice to a trimmed ASCII string (non-ASCII bytes become '?').
fn ascii_str(bytes: &[u8]) -> String {
    String::from_utf8_lossy(bytes).trim_end().to_string()
}

/// Parse "key=<decimal>" from a header line (order-independent).
fn parse_u32(line: &str, key: &str) -> Option<u32> {
    let pos = line.find(key)?;
    let rest = &line[pos + key.len()..];
    let end = rest.find(|c: char| !c.is_ascii_digit()).unwrap_or(rest.len());
    if end == 0 {
        return None;
    }
    rest[..end].parse().ok()
}

fn parse_u64(line: &str, key: &str) -> Option<u64> {
    let pos = line.find(key)?;
    let rest = &line[pos + key.len()..];
    let end = rest.find(|c: char| !c.is_ascii_digit()).unwrap_or(rest.len());
    if end == 0 {
        return None;
    }
    rest[..end].parse().ok()
}

/// Parse the name= field. By yEnc convention, name= is always the LAST field on the =ybegin line.
fn parse_name(line: &str) -> Option<String> {
    let pos = line.find("name=")?;
    Some(line[pos + 5..].trim_end().to_string())
}

/// Parse a hex field like "crc32=AABBCCDD" or "pcrc32=AABBCCDD".
fn parse_hex(line: &str, key: &str) -> Option<String> {
    let pos = line.find(key)?;
    let rest = &line[pos + key.len()..];
    let end = rest
        .find(|c: char| !c.is_ascii_hexdigit())
        .unwrap_or(rest.len());
    if end == 0 {
        None
    } else {
        Some(rest[..end].to_lowercase())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_decode_simple_yenc() {
        // "ABC" in yEnc: A=65→107='k', B=66→108='l', C=67→109='m'
        let article = b"=ybegin line=128 size=3 name=test.txt\r\nklm\r\n=yend size=3\r\n";

        let (decoded, header) = YencDecoder::decode(article).unwrap();

        assert_eq!(header.name, "test.txt");
        assert_eq!(header.size, 3);
        assert_eq!(decoded, b"ABC");
    }

    #[test]
    fn test_parse_ybegin_part_before_line() {
        // Real-world format: part= and total= come before line= and size=
        // "ABC" in yEnc
        let article = b"=ybegin part=1 total=2 line=128 size=3 name=test.txt\r\n\
=ypart begin=1 end=3\r\n\
klm\r\n\
=yend size=3\r\n";

        let (decoded, header) = YencDecoder::decode(article).unwrap();

        assert_eq!(header.name, "test.txt");
        assert_eq!(header.size, 3);
        assert_eq!(header.part, Some(1));
        assert_eq!(header.begin, Some(1));
        assert_eq!(header.end, Some(3));
        assert_eq!(decoded, b"ABC");
    }

    #[test]
    fn test_decode_escaped_bytes() {
        // yEnc escape: encoder does (B + 42) for non-critical, or '=' + (B + 42 + 64) for critical.
        // Decoder for escaped byte X (after '='): B = X - 64 - 42 = X - 106.
        //
        // Byte 214: (214 + 42) mod 256 = 0 (NULL, critical) → escaped as '=' + (0+64)='@'
        let decoded = decode_bytes(b"=@");
        assert_eq!(decoded, vec![214u8], "escape decode wrong: got {:?}", decoded);

        // Byte 224: (224 + 42) mod 256 = 10 (LF, critical) → escaped as '=' + (10+64)='J'
        let decoded = decode_bytes(b"=J");
        assert_eq!(decoded, vec![224u8], "escape decode wrong: got {:?}", decoded);

        // Byte 19: (19 + 42) = 61 = '=' (critical) → escaped as '=' + (61+64)='}'
        let decoded = decode_bytes(b"=}");
        assert_eq!(decoded, vec![19u8], "escape decode wrong: got {:?}", decoded);
    }

    #[test]
    fn test_decode_preserves_high_bytes() {
        // Ensure bytes > 127 are not mangled by UTF-8 conversion.
        // Encode byte value 200 (0xC8): yEnc = (200 + 42) % 256 = 242 = 0xF2
        // Decode: 0xF2 - 42 = 200 ✓
        let encoded: Vec<u8> = vec![0xF2_u8]; // encoded form of byte 200
        let decoded = decode_bytes(&encoded);
        assert_eq!(decoded, vec![200u8]);
    }
}
