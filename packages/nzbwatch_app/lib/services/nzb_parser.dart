import 'package:xml/xml.dart';

import '../models/nzb_models.dart';

/// Parser for NZB files
class NzbParser {
  /// Parse NZB XML string into NzbFile model
  static NzbFile? parse(String xml) {
    try {
      // Remove BOM if present
      xml = xml.replaceAll(RegExp(r'^\uFEFF'), '');
      
      // Trim whitespace
      xml = xml.trim();
      
      // Check if it looks like XML
      if (!xml.startsWith('<')) {
        print('NZB Parse Error: Content does not start with <');
        return null;
      }
      
      final document = XmlDocument.parse(xml);
      final nzbElement = document.getElement('nzb');
      if (nzbElement == null) {
        print('NZB Parse Error: No <nzb> element found');
        return null;
      }
      
      // Parse metadata
      String filename = '';
      String? subject;
      String? poster;
      
      final headElement = nzbElement.getElement('head');
      if (headElement != null) {
        for (final meta in headElement.findElements('meta')) {
          final type = meta.getAttribute('type');
          if (type == 'name') {
            filename = meta.innerText.trim();
          }
        }
      }
      
      // Parse files
      final files = nzbElement.findElements('file').toList();
      if (files.isEmpty) {
        print('NZB Parse Error: No <file> elements found');
        return null;
      }
      
      print('NZB Parse: Found ${files.length} file(s)');
      
      // Collect all groups
      final allGroups = <String>{};
      
      // Collect file entries
      final fileEntries = <NzbFileEntry>[];
      int totalSize = 0;
      
      for (final fileElement in files) {
        final fileSubject = fileElement.getAttribute('subject') ?? 'unknown';
        final filePoster = fileElement.getAttribute('poster');
        if (poster == null) poster = filePoster;
        
        // Parse groups
        final groupsElement = fileElement.getElement('groups');
        if (groupsElement != null) {
          for (final group in groupsElement.findElements('group')) {
            allGroups.add(group.innerText.trim());
          }
        }
        
        // Parse segments from this file
        final segmentsElement = fileElement.getElement('segments');
        final fileSegments = <NzbSegment>[];
        int fileSize = 0;
        
        if (segmentsElement != null) {
          for (final segElement in segmentsElement.findElements('segment')) {
            final numberStr = segElement.getAttribute('number');
            final bytesStr = segElement.getAttribute('bytes');
            final messageId = segElement.innerText.trim();
            
            if (numberStr == null || bytesStr == null) continue;
            
            final number = int.tryParse(numberStr);
            final size = int.tryParse(bytesStr);
            
            if (number == null || size == null) continue;
            
            fileSegments.add(NzbSegment(
              number: number,
              messageId: messageId,
              size: size,
            ));
            fileSize += size;
          }
        }
        
        fileSegments.sort((a, b) => a.number.compareTo(b.number));
        
        final fileFilename = _extractFilenameFromSubject(fileSubject);
        
        fileEntries.add(NzbFileEntry(
          filename: fileFilename,
          subject: fileSubject,
          segments: fileSegments,
          size: fileSize,
        ));
        
        totalSize += fileSize;
      }
      
      if (fileEntries.isEmpty) {
        print('NZB Parse Error: No valid files found');
        return null;
      }
      
      // Extract NZB name from metadata or first file
      if (filename.isEmpty) {
        filename = fileEntries[0].filename;
      }
      
      return NzbFile(
        name: filename,
        poster: poster,
        groups: allGroups.toList(),
        files: fileEntries,
        totalSize: totalSize,
      );
    } catch (e, stackTrace) {
      print('NZB Parse Exception: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
  
  /// Extract filename from NZB subject line
  static String _extractFilenameFromSubject(String subject) {
    // Common patterns:
    // "[12345] - "filename.mkv" yEnc (1/100)"
    // "filename.mkv" [1/100] yEnc
    // filename.mkv yEnc (1/100)
    
    // Try quoted filename first
    final quoteRegex = RegExp(r'"([^"]+\.(?:mkv|mp4|avi|mov|wmv|m4v|webm))"', caseSensitive: false);
    var match = quoteRegex.firstMatch(subject);
    if (match != null) {
      return match.group(1) ?? 'unknown';
    }
    
    // Try unquoted filename with extension
    final extRegex = RegExp(
      r'(\S+\.(?:mkv|mp4|avi|mov|wmv|m4v|webm))',
      caseSensitive: false,
    );
    match = extRegex.firstMatch(subject);
    if (match != null) {
      return match.group(1) ?? 'unknown';
    }
    
    return 'unknown';
  }
}
