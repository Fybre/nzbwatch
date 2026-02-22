use crate::{NzbError, NzbFile, NzbFileEntry, NzbSegment, Result};
use regex::Regex;

pub fn parse_nzb(xml: &str) -> Result<NzbFile> {
    let mut nzb_name = String::new();
    let mut poster = None;
    let mut groups = Vec::new();
    let mut files = Vec::new();
    let mut total_size = 0u64;

    // Parse overall NZB name from meta tags
    let name_re = Regex::new(r#"<meta type="name">\s*(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?\s*</meta>"#)
        .map_err(|e| NzbError::Parse(e.to_string()))?;
    if let Some(cap) = name_re.captures(xml) {
        nzb_name = sanitize_filename(cap.get(1).map(|m| m.as_str()).unwrap_or_default());
    }

    // Parse each <file> element
    let file_re = Regex::new(r#"(?s)<file[^>]*>(.*?)</file>"#)
        .map_err(|e| NzbError::Parse(e.to_string()))?;
    
    // Regex for file attributes (subject, poster)
    let file_attr_re = Regex::new(r#"<file[^>]*poster="([^"]*)"[^>]*subject="([^"]*)""#)
        .map_err(|e| NzbError::Parse(e.to_string()))?;
    
    // Regex for groups within a file
    let group_re = Regex::new(r#"<group>([^<]+)</group>"#)
        .map_err(|e| NzbError::Parse(e.to_string()))?;
    
    // Regex for segments within a file
    let segment_re = Regex::new(
        r#"<segment[^>]*bytes="(\d+)"[^>]*number="(\d+)"[^>]*>([^<]+)</segment>"#
    ).map_err(|e| NzbError::Parse(e.to_string()))?;

    for cap in file_re.captures_iter(xml) {
        let file_content = cap.get(1).unwrap().as_str();
        let file_tag = cap.get(0).unwrap().as_str();
        
        let mut file_subject = String::new();
        let mut file_poster = None;
        
        if let Some(attr_cap) = file_attr_re.captures(file_tag) {
            file_poster = Some(attr_cap.get(1).unwrap().as_str().to_string());
            file_subject = attr_cap.get(2).unwrap().as_str().to_string();
        }
        
        if poster.is_none() {
            poster = file_poster;
        }
        
        // Parse groups (only need them once globally for the NZB usually)
        if groups.is_empty() {
            for g_cap in group_re.captures_iter(file_content) {
                groups.push(g_cap.get(1).unwrap().as_str().trim().to_string());
            }
        }
        
        let mut segments = Vec::new();
        let mut file_size = 0u64;
        
        for s_cap in segment_re.captures_iter(file_content) {
            let size: u64 = s_cap.get(1).unwrap().as_str().parse().unwrap_or(0);
            let number: u32 = s_cap.get(2).unwrap().as_str().parse().unwrap_or(0);
            let message_id = s_cap.get(3).unwrap().as_str().trim().to_string();
            
            segments.push(NzbSegment {
                number,
                message_id,
                size,
            });
            file_size += size;
        }
        
        segments.sort_by_key(|s| s.number);
        
        let filename = extract_filename_from_subject(&file_subject);
        
        files.push(NzbFileEntry {
            filename,
            subject: file_subject,
            segments,
            size: file_size,
        });
        
        total_size += file_size;
    }

    if files.is_empty() {
        return Err(NzbError::Parse("No files found in NZB".to_string()));
    }

    if nzb_name.is_empty() {
        nzb_name = files[0].filename.clone();
    }

    Ok(NzbFile {
        name: nzb_name,
        poster,
        groups,
        files,
        total_size,
    })
}

fn decode_xml_entities(s: &str) -> String {
    s.replace("&quot;", "\"")
     .replace("&amp;", "&")
     .replace("&lt;", "<")
     .replace("&gt;", ">")
     .replace("&apos;", "'")
}

fn sanitize_filename(filename: &str) -> String {
    let decoded = decode_xml_entities(filename);
    // Remove characters that are illegal or problematic in filenames
    decoded.chars()
        .filter(|&c| !r#"\/:*?"<>|"#.contains(c))
        .collect::<String>()
        .trim()
        .to_string()
}

fn extract_filename_from_subject(subject: &str) -> String {
    let decoded_subject = decode_xml_entities(subject);
    
    // Common patterns: "[12345] - "filename.mkv" yEnc (1/100)"
    // or "filename.mkv" [1/100] yEnc
    let re = Regex::new(r#""([^"]+)"|(\S+\.\w{3,4})"#).unwrap();
    
    for cap in re.captures_iter(&decoded_subject) {
        if let Some(m) = cap.get(1) {
            return sanitize_filename(m.as_str());
        }
        if let Some(m) = cap.get(2) {
            let name = m.as_str();
            if is_video_extension(name) {
                return sanitize_filename(name);
            }
        }
    }
    
    // Fallback: use first word with extension
    let fallback = decoded_subject
        .split_whitespace()
        .find(|s| s.contains('.'))
        .unwrap_or("unknown")
        .trim_matches(|c| c == '"' || c == '[' || c == ']' || c == '(' || c == ')');
    
    sanitize_filename(fallback)
}

fn is_video_extension(filename: &str) -> bool {
    let ext = filename.to_lowercase();
    ext.ends_with(".mkv")
        || ext.ends_with(".mp4")
        || ext.ends_with(".avi")
        || ext.ends_with(".mov")
        || ext.ends_with(".wmv")
        || ext.ends_with(".m4v")
        || ext.ends_with(".webm")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_simple_nzb() {
        let nzb_xml = r#"<?xml version="1.0" encoding="UTF-8"?>
        <nzb xmlns="http://www.newzbin.com/DTD/2003/nzb">
            <head>
                <meta type="name">Test.Movie.2024.1080p.mkv</meta>
            </head>
            <file poster="poster@example.com" subject="[12345] - &quot;Test.Movie.2024.1080p.mkv&quot; yEnc (1/2)">
                <groups>
                    <group>alt.binaries.movies</group>
                </groups>
                <segments>
                    <segment bytes="1000" number="1">message-id-1@example.com</segment>
                    <segment bytes="2000" number="2">message-id-2@example.com</segment>
                </segments>
            </file>
        </nzb>"#;

        let result = parse_nzb(nzb_xml).unwrap();
        assert_eq!(result.name, "Test.Movie.2024.1080p.mkv");
        assert_eq!(result.files.len(), 1);
        assert_eq!(result.files[0].filename, "Test.Movie.2024.1080p.mkv");
        assert_eq!(result.files[0].segments.len(), 2);
        assert_eq!(result.total_size, 3000);
        assert_eq!(result.files[0].segments[0].number, 1);
        assert_eq!(result.files[0].segments[0].size, 1000);
    }
}
