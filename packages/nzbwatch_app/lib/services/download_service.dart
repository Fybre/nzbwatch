import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import '../models/nzb_models.dart' as models;
import '../providers/settings_provider.dart';
import 'database.dart';
import 'ffi_bridge.dart';

/// Service for managing downloads
class DownloadService {
  final AppDatabase _db;
  final Ref _ref;
  final _uuid = const Uuid();

  final Map<String, StreamController<models.DownloadProgress>> _progressControllers = {};
  final Map<String, Timer> _progressTimers = {};

  DownloadService(this._db, this._ref);
  /// Import and parse an NZB file
  Future<models.NzbFile?> importNzbFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    
    final xml = await file.readAsString();
    return FfiBridge().parseNzb(xml);
  }
  
  /// Import and parse NZB from XML string
  Future<models.NzbFile?> importNzbXml(String xml) async {
    return FfiBridge().parseNzb(xml);
  }
  
  /// Create a new download from an NZB file
  Future<models.DownloadItem?> createDownload({
    required models.NzbFile nzb,
    required String nzbPath,
  }) async {
    final id = _uuid.v4();
    final downloadsDir = await _getDownloadsDirectory();
    
    // Use the actual NZB filename as the display name
    final displayName = p.basenameWithoutExtension(nzbPath);

    // CREATE A DEDICATED SUBFOLDER FOR THIS DOWNLOAD
    final outputDir = p.join(downloadsDir, id);
    final outputPath = p.join(outputDir, displayName);
    
    final now = DateTime.now();
    
    // Insert download record
    await _db.insertDownload(DownloadsCompanion.insert(
      id: id,
      nzbPath: nzbPath,
      filename: displayName,
      poster: Value(nzb.poster),
      status: DownloadStatus.queued,
      totalBytes: nzb.totalSize,
      downloadedBytes: 0,
      totalSegments: nzb.totalSegments,
      completedSegments: 0,
      outputPath: outputPath,
      createdAt: now,
    ));
    
    // Batch-insert all files
    final fileRows = <DownloadFilesCompanion>[];
    for (var i = 0; i < nzb.files.length; i++) {
      final f = nzb.files[i];
      fileRows.add(DownloadFilesCompanion.insert(
        id: '${id}_file_${i}',
        downloadId: id,
        filename: f.filename,
        subject: f.subject,
        size: f.size,
      ));
    }
    await _db.insertFilesBatch(fileRows);
    
    // Batch-insert all segments from all files
    final segmentRows = <SegmentsCompanion>[];
    for (var fileIdx = 0; fileIdx < nzb.files.length; fileIdx++) {
      final file = nzb.files[fileIdx];
      final fileId = '${id}_file_${fileIdx}';
      for (var segIdx = 0; segIdx < file.segments.length; segIdx++) {
        final segment = file.segments[segIdx];
        segmentRows.add(SegmentsCompanion.insert(
          id: '${fileId}_seg_${segIdx}',
          downloadId: id,
          fileId: Value(fileId),
          number: segment.number,
          messageId: segment.messageId,
          size: segment.size,
          isDownloaded: false,
          retries: 0,
        ));
      }
    }
    await _db.insertSegmentsBatch(segmentRows);

    // Batch-insert unique groups
    final uniqueGroups = nzb.groups.toSet().toList();
    final groupRows = <DownloadGroupsCompanion>[];
    for (var i = 0; i < uniqueGroups.length; i++) {
      final group = uniqueGroups[i];
      groupRows.add(DownloadGroupsCompanion.insert(
        id: '${id}_grp_${i}',
        downloadId: id,
        name: group,
      ));
    }
    if (groupRows.isNotEmpty) {
      await _db.insertGroupsBatch(groupRows);
    }
    
    return models.DownloadItem(
      id: id,
      nzbPath: nzbPath,
      filename: nzb.name,
      poster: nzb.poster,
      state: models.DownloadState.queued,
      totalBytes: nzb.totalSize,
      downloadedBytes: 0,
      totalSegments: nzb.totalSegments,
      completedSegments: 0,
      outputPath: outputPath,
      createdAt: now,
      groups: nzb.groups,
    );
  }
  
  /// Start a real download via FFI
  Future<bool> startDownload(String downloadId) async {
    print('[DownloadService] Starting download: $downloadId');
    
    final download = await _db.getDownload(downloadId);
    if (download == null) {
      print('[DownloadService] Download not found: $downloadId');
      return false;
    }
    
    // Get servers
    final servers = await _db.getAllServers();
    if (servers.isEmpty) {
      print('[DownloadService] No servers configured');
      return false;
    }
    
    // Get segments, groups, and files
    final dbFiles = await _db.getFilesForDownload(downloadId);
    final groups = await _db.getGroupsForDownload(downloadId);
    
    final nzbFiles = <models.NzbFileEntry>[];
    for (final dbFile in dbFiles) {
      final dbSegments = await _db.getSegmentsForFile(dbFile.id);
      nzbFiles.add(models.NzbFileEntry(
        filename: dbFile.filename,
        subject: dbFile.subject,
        size: dbFile.size,
        segments: dbSegments.map((s) => models.NzbSegment(
          number: s.number,
          messageId: s.messageId,
          size: s.size,
        )).toList(),
      ));
    }
    
    // Build multi-file NZB model for Rust
    final nzb = models.NzbFile(
      name: download.filename,
      groups: groups.map((g) => g.name).toList(),
      files: nzbFiles,
      totalSize: download.totalBytes,
    );
    
    // Get directories
    final outputDir = p.dirname(download.outputPath);
    final tempDir = await _getTempDirectory();
    
    // Convert server configs
    final serverConfigs = servers.map((s) => models.ServerConfig(
      id: s.id,
      name: s.name,
      host: s.host,
      port: s.port,
      useSsl: s.useSsl,
      username: s.username,
      password: s.password,
      maxConnections: s.maxConnections,
      priority: s.priority,
    )).toList();
    
    // Clear any existing partial download and status/progress files
    try {
      final outputFile = File(download.outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
      final statusFile = File('$outputDir/$downloadId.status.json');
      if (await statusFile.exists()) {
        await statusFile.delete();
      }
      final progressFile = File('$outputDir/$downloadId.progress.json');
      if (await progressFile.exists()) {
        await progressFile.delete();
      }
    } catch (e) {
      print('[DownloadService] Warning: could not clear files: $e');
    }
    
    // Update status to downloading
    await _db.updateDownload(DownloadsCompanion(
      id: Value(downloadId),
      status: Value(DownloadStatus.downloading),
      downloadedBytes: const Value(0),
      completedSegments: const Value(0),
    ));
    
    print('[DownloadService] Calling Rust FFI via FfiBridge...');
    
    try {
      // Use FfiBridge directly instead of an isolate worker.
      // nzbwatch_start_download is non-blocking on the Rust side (it spawns a thread).
      final result = await FfiBridge().startDownload(
        downloadId: downloadId,
        nzb: nzb,
        servers: serverConfigs,
        outputDir: outputDir,
        tempDir: tempDir,
      );
      
      print('[DownloadService] Rust FFI result: $result');
      
      if (result != null) {
        _startProgressPolling(downloadId);
        return true;
      }
      
      await _db.updateDownload(DownloadsCompanion(
        id: Value(downloadId),
        status: Value(DownloadStatus.error),
        errorMessage: const Value('Failed to start download'),
      ));
      return false;
    } catch (e, stackTrace) {
      print('[DownloadService] FFI error: $e');
      print('[DownloadService] Stack: $stackTrace');
      
      await _db.updateDownload(DownloadsCompanion(
        id: Value(downloadId),
        status: Value(DownloadStatus.error),
        errorMessage: Value('FFI error: $e'),
      ));
      return false;
    }
  }
  
  /// Poll for download progress
  void _startProgressPolling(String downloadId) {
    print('[DownloadService] Starting progress polling for: $downloadId');
    
    // Cancel any existing timer
    _stopProgressPolling(downloadId);
    
    // Track consecutive errors to detect failed downloads
    int consecutiveErrors = 0;
    int lastDownloadedBytes = 0;
    int stallCounter = 0;
    
    // Track when download actually started making progress
    int zeroProgressCount = 0;
    
    _progressTimers[downloadId] = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final download = await _db.getDownload(downloadId);
      if (download == null) {
        print('[DownloadService] Download not found, stopping poll');
        timer.cancel();
        return;
      }
      
      if (download.status == DownloadStatus.complete ||
          download.status == DownloadStatus.error ||
          download.status == DownloadStatus.paused) {
        print('[DownloadService] Download ${download.status.name}, stopping poll');
        timer.cancel();
        return;
      }
      
      // Read progress from Rust-written files
      try {
        final outputDir = p.dirname(download.outputPath);

        // Check for status file (written by Rust on completion or error)
        final statusFile = File('$outputDir/${download.id}.status.json');
        if (await statusFile.exists()) {
          try {
            final statusContent = await statusFile.readAsString();
            final status = jsonDecode(statusContent) as Map<String, dynamic>;
            final statusStr = status['status'] as String?;

            if (statusStr == 'complete') {
              print('[DownloadService] Rust signaled completion');
              final videoPath = status['video_path'] as String?;
              await markComplete(downloadId, videoPath: videoPath);
              timer.cancel();
              _progressTimers.remove(downloadId);
              return;
            } else if (statusStr == 'error') {
              final errorMsg = status['error'] as String? ?? 'Unknown error';
              print('[DownloadService] Rust signaled error: $errorMsg');
              await markError(downloadId, errorMsg);
              timer.cancel();
              _progressTimers.remove(downloadId);
              return;
            }
          } catch (e) {
            print('[DownloadService] Error reading status file: $e');
          }
        }

        // Read actual progress from progress.json written by Rust after each segment.
        // Do NOT use file.stat().size — the file is pre-allocated to total size,
        // so stat().size is always total_size regardless of how much was downloaded.
        int downloaded = lastDownloadedBytes;
        int completedSegs = download.completedSegments;
        int speed = 0;
        int? eta;
        String? currentFile;
        double health = 100.0;
        String? streamingUrl;
        List<(double, double)> ranges = [];

        final progressFile = File('$outputDir/${download.id}.progress.json');
        if (await progressFile.exists()) {
          try {
            final content = await progressFile.readAsString();
            final progress = jsonDecode(content) as Map<String, dynamic>;
            final newDownloaded = (progress['downloaded_bytes'] as num?)?.toInt();
            final newCompleted = (progress['completed_segments'] as num?)?.toInt();
            if (newDownloaded != null) downloaded = newDownloaded;
            if (newCompleted != null) completedSegs = newCompleted;
            speed = (progress['speed_bytes_per_sec'] as num?)?.toInt() ?? 0;
            eta = (progress['eta_seconds'] as num?)?.toInt();
            currentFile = progress['current_file'] as String?;
            health = (progress['health'] as num?)?.toDouble() ?? 100.0;
            streamingUrl = progress['streaming_url'] as String?;
            
            final jsonRanges = progress['downloaded_ranges'] as List?;
            if (jsonRanges != null) {
              ranges = jsonRanges.map((r) {
                final list = r as List;
                return ( (list[0] as num).toDouble(), (list[1] as num).toDouble() );
              }).toList();
            }
          } catch (e) {
            print('[DownloadService] Error reading progress file: $e');
          }
        }

        // Stall detection: flag if downloaded bytes haven't changed for 90 seconds.
        // Only count as stalled after progress has started (downloaded > 0),
        // because the very first segment may take a while to connect and download.
        if (downloaded > 0 && downloaded == lastDownloadedBytes) {
          stallCounter++;
          if (stallCounter > 10) {
            print('[DownloadService] Download appears stalled (no progress for ${stallCounter * 3}s)');
          }
          if (stallCounter > 30) {
            print('[DownloadService] Download failed - stalled for too long');
            await markError(downloadId, 'Download stalled - check server connection and NZB validity');
            timer.cancel();
            _progressTimers.remove(downloadId);
            return;
          }
        } else if (downloaded > lastDownloadedBytes) {
          stallCounter = 0;
          lastDownloadedBytes = downloaded;
          consecutiveErrors = 0;
        }

        // Track if nothing has started after 60 seconds
        if (downloaded == 0) {
          zeroProgressCount++;
          if (zeroProgressCount > 20) {
            print('[DownloadService] Download never started (0 bytes for 60s)');
            await markError(downloadId, 'Download failed to start - check server connection');
            timer.cancel();
            _progressTimers.remove(downloadId);
            return;
          }
        } else {
          zeroProgressCount = 0;
        }

        final percent = download.totalBytes > 0
            ? (downloaded / download.totalBytes * 100).toStringAsFixed(1)
            : '0.0';
        print('[DownloadService] Progress: $completedSegs/${download.totalSegments} segs, $downloaded/${download.totalBytes} bytes ($percent%)');

        // Emit progress event
        final controller = _progressControllers[downloadId];
        if (controller != null && !controller.isClosed) {
          controller.add(models.DownloadProgress(
            downloadId: downloadId,
            state: models.DownloadState.downloading,
            totalBytes: download.totalBytes,
            downloadedBytes: downloaded,
            totalSegments: download.totalSegments,
            completedSegments: completedSegs,
            speedBytesPerSec: speed,
            etaSeconds: eta,
            currentFile: currentFile,
            health: health,
            streamingUrl: streamingUrl,
            downloadedRanges: ranges,
            percentComplete: download.totalBytes > 0
                ? (downloaded / download.totalBytes * 100)
                : 0,
          ));
        }

        // Update database
        await _db.updateDownload(DownloadsCompanion(
          id: Value(downloadId),
          downloadedBytes: Value(downloaded),
          completedSegments: Value(completedSegs),
          health: Value(health),
        ));
      } catch (e) {
        print('[DownloadService] Error checking progress: $e');
        consecutiveErrors++;
        
        // If we get too many consecutive errors, mark as error
        if (consecutiveErrors > 5) {
          print('[DownloadService] Too many errors, marking as failed');
          await markError(downloadId, 'Download monitoring failed: $e');
          timer.cancel();
          _progressTimers.remove(downloadId);
        }
      }
    });
  }
  
  /// Cancel a download
  Future<void> cancelDownload(String downloadId) async {
    _stopProgressPolling(downloadId);
    FfiBridge().cancelDownload(downloadId);
    
    await _db.updateDownload(DownloadsCompanion(
      id: Value(downloadId),
      status: Value(DownloadStatus.paused),
    ));
  }

  /// Get real-time progress stream for a download
  Stream<models.DownloadProgress> getProgressStream(String downloadId) {
    if (!_progressControllers.containsKey(downloadId)) {
      _progressControllers[downloadId] = StreamController<models.DownloadProgress>.broadcast();
    }
    return _progressControllers[downloadId]!.stream;
  }
  
  /// Delete a download
  Future<void> deleteDownload(String downloadId) async {
    await cancelDownload(downloadId);
    
    final download = await _db.getDownload(downloadId);
    if (download != null) {
      // Get files, segments and groups to rebuild NzbFile for the delete call
      final dbFiles = await _db.getFilesForDownload(downloadId);
      final groups = await _db.getGroupsForDownload(downloadId);
      final servers = await _db.getAllServers();

      final nzbFiles = <models.NzbFileEntry>[];
      for (final dbFile in dbFiles) {
        final dbSegments = await _db.getSegmentsForFile(dbFile.id);
        nzbFiles.add(models.NzbFileEntry(
          filename: dbFile.filename,
          subject: dbFile.subject,
          size: dbFile.size,
          segments: dbSegments.map((s) => models.NzbSegment(
            number: s.number,
            messageId: s.messageId,
            size: s.size,
          )).toList(),
        ));
      }

      final nzb = models.NzbFile(
        name: download.filename,
        groups: groups.map((g) => g.name).toList(),
        files: nzbFiles,
        totalSize: download.totalBytes,
      );

      final serverConfigs = servers.map((s) => models.ServerConfig(
        id: s.id,
        name: s.name,
        host: s.host,
        port: s.port,
        useSsl: s.useSsl,
        username: s.username,
        password: s.password,
        maxConnections: s.maxConnections,
        priority: s.priority,
      )).toList();

      final outputDir = p.dirname(download.outputPath);
      
      // Use FFI bridge to delete all associated files
      FfiBridge().deleteDownload(downloadId, nzb, serverConfigs, outputDir);
    }
    
    await _db.deleteDownload(downloadId);
  }
  
  /// Update playback position for a download
  Future<void> updatePlaybackPosition(String downloadId, Duration position) async {
    await _db.updateDownload(DownloadsCompanion(
      id: Value(downloadId),
      lastPosition: Value(position.inMilliseconds),
    ));
  }

  /// Retry a failed or partially complete download
  Future<bool> retryDownload(String downloadId) async {
    print('[DownloadService] Retrying download: $downloadId');
    
    // Stop any existing polling
    _stopProgressPolling(downloadId);
    
    // Cancel in Rust if active
    FfiBridge().cancelDownload(downloadId);
    
    // Update status to queued to show immediate feedback in UI
    await _db.updateDownload(DownloadsCompanion(
      id: Value(downloadId),
      status: const Value(DownloadStatus.queued),
      errorMessage: const Value(null),
      downloadedBytes: const Value(0),
      completedSegments: const Value(0),
    ));
    
    // Small delay to ensure Rust thread has released file handles
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Start it again
    return startDownload(downloadId);
  }

  /// Reveal file in Finder (macOS)
  Future<void> revealInFinder(String downloadId) async {
    final download = await _db.getDownload(downloadId);
    if (download == null) return;
    
    final file = File(download.outputPath);
    if (await file.exists()) {
      // macOS: open -R reveals file in Finder
      await Process.run('open', ['-R', download.outputPath]);
    } else {
      // If file doesn't exist, open the downloads folder
      final dir = Directory(p.dirname(download.outputPath));
      if (await dir.exists()) {
        await Process.run('open', [dir.path]);
      }
    }
  }
  
  /// Get all downloads
  Future<List<models.DownloadItem>> getAllDownloads() async {
    final downloads = await _db.getAllDownloads();
    return Future.wait(downloads.map(dbDownloadToItem));
  }
  
  /// Get downloads by status
  Future<List<models.DownloadItem>> getDownloadsByStatus(models.DownloadState state) async {
    final status = _mapStateToDb(state);
    final downloads = await _db.getDownloadsByStatus(status);
    return Future.wait(downloads.map(dbDownloadToItem));
  }
  
  /// Get a single download
  Future<models.DownloadItem?> getDownload(String id) async {
    final download = await _db.getDownload(id);
    if (download == null) return null;
    return dbDownloadToItem(download);
  }
  
  /// Stream of progress updates for a download
  Stream<models.DownloadProgress>? watchProgress(String downloadId) {
    if (!_progressControllers.containsKey(downloadId)) {
      _progressControllers[downloadId] = StreamController<models.DownloadProgress>.broadcast();
    }
    return _progressControllers[downloadId]!.stream;
  }
  
  /// Mark download as complete
  Future<void> markComplete(String downloadId, {String? videoPath}) async {
    _stopProgressPolling(downloadId);
    final row = await _db.getDownload(downloadId);
    
    // Update output path if we have a specific video file from extraction
    final finalPath = videoPath ?? row?.outputPath ?? '';
    
    // Determine the filename (display name)
    String finalFilename = row?.filename ?? 'Unknown';
    
    final settings = _ref.read(settingsProvider);
    if (settings.renameToMovieName && videoPath != null) {
      // Extract filename without extension
      String movieName = p.basenameWithoutExtension(videoPath);
      
      // Sanitise: remove full stops (replace with space)
      movieName = movieName.replaceAll('.', ' ');
      
      // Clean up extra spaces
      movieName = movieName.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      if (movieName.isNotEmpty) {
        finalFilename = movieName;
        print('[DownloadService] Renamed library entry to: $finalFilename');
      }
    }

    await _db.updateDownload(DownloadsCompanion(
      id: Value(downloadId),
      filename: Value(finalFilename),
      status: Value(DownloadStatus.complete),
      completedAt: Value(DateTime.now()),
      downloadedBytes: Value(row?.totalBytes ?? 0),
      completedSegments: Value(row?.totalSegments ?? 0),
      outputPath: Value(finalPath),
    ));
    // Push terminal state into the progress stream so DownloadCard updates immediately.
    _emitProgressState(downloadId, models.DownloadState.complete,
        totalBytes: row?.totalBytes ?? 0,
        downloadedBytes: row?.totalBytes ?? 0,
        totalSegments: row?.totalSegments ?? 0,
        completedSegments: row?.totalSegments ?? 0,
        health: row?.health ?? 100.0,
        downloadedRanges: [(0.0, 100.0)]);
  }

  /// Mark download as error
  Future<void> markError(String downloadId, String error) async {
    _stopProgressPolling(downloadId);
    await _db.updateDownload(DownloadsCompanion(
      id: Value(downloadId),
      status: Value(DownloadStatus.error),
      errorMessage: Value(error),
    ));
    // Push terminal state into the progress stream so DownloadCard updates immediately.
    final row = await _db.getDownload(downloadId);
    _emitProgressState(downloadId, models.DownloadState.error,
        totalBytes: row?.totalBytes ?? 0,
        downloadedBytes: row?.downloadedBytes ?? 0,
        totalSegments: row?.totalSegments ?? 0,
        completedSegments: row?.completedSegments ?? 0,
        health: row?.health ?? 100.0);
  }

  void _emitProgressState(
    String downloadId,
    models.DownloadState state, {
    required int totalBytes,
    required int downloadedBytes,
    required int totalSegments,
    required int completedSegments,
    required double health,
    String? streamingUrl,
    List<(double, double)> downloadedRanges = const [],
  }) {
    final controller = _progressControllers[downloadId];
    if (controller != null && !controller.isClosed) {
      controller.add(models.DownloadProgress(
        downloadId: downloadId,
        state: state,
        totalBytes: totalBytes,
        downloadedBytes: downloadedBytes,
        totalSegments: totalSegments,
        completedSegments: completedSegments,
        health: health,
        streamingUrl: streamingUrl,
        downloadedRanges: downloadedRanges,
        percentComplete: totalBytes > 0
            ? (downloadedBytes / totalBytes * 100)
            : 0,
      ));
    }
  }
  
  // Helper methods
  Future<models.DownloadItem> dbDownloadToItem(Download download) async {
    final groups = await _db.getGroupsForDownload(download.id);
    
    return models.DownloadItem(
      id: download.id,
      nzbPath: download.nzbPath,
      filename: download.filename,
      subject: download.subject,
      poster: download.poster,
      state: _mapDbToState(download.status),
      totalBytes: download.totalBytes,
      downloadedBytes: download.downloadedBytes,
      totalSegments: download.totalSegments,
      completedSegments: download.completedSegments,
      outputPath: download.outputPath,
      errorMessage: download.errorMessage,
      health: download.health,
      lastPosition: download.lastPosition,
      createdAt: download.createdAt,
      completedAt: download.completedAt,
      groups: groups.map((g) => g.name).toList(),
    );
  }
  
  models.DownloadState _mapDbToState(DownloadStatus status) {
    return switch (status) {
      DownloadStatus.queued => models.DownloadState.queued,
      DownloadStatus.downloading => models.DownloadState.downloading,
      DownloadStatus.paused => models.DownloadState.paused,
      DownloadStatus.complete => models.DownloadState.complete,
      DownloadStatus.error => models.DownloadState.error,
    };
  }
  
  DownloadStatus _mapStateToDb(models.DownloadState state) {
    return switch (state) {
      models.DownloadState.queued => DownloadStatus.queued,
      models.DownloadState.downloading => DownloadStatus.downloading,
      models.DownloadState.paused => DownloadStatus.paused,
      models.DownloadState.complete => DownloadStatus.complete,
      models.DownloadState.error => DownloadStatus.error,
    };
  }
  
  Future<String> _getDownloadsDirectory() async {
    final appDir = await getApplicationSupportDirectory();
    print('[DownloadService] App directory: ${appDir.path}');
    final downloadsDir = Directory(p.join(appDir.path, 'downloads'));
    if (!await downloadsDir.exists()) {
      print('[DownloadService] Creating downloads directory: ${downloadsDir.path}');
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir.path;
  }
  
  Future<String> _getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final nzbTemp = Directory(p.join(tempDir.path, 'nzbwatch'));
    if (!await nzbTemp.exists()) {
      await nzbTemp.create(recursive: true);
    }
    return nzbTemp.path;
  }
  
  void _stopProgressPolling(String downloadId) {
    _progressTimers[downloadId]?.cancel();
    _progressTimers.remove(downloadId);
  }
  
  void dispose() {
    for (final timer in _progressTimers.values) {
      timer.cancel();
    }
    _progressTimers.clear();
    
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
  }
}

/// Download service provider
final downloadServiceProvider = Provider<DownloadService>((ref) {
  final db = ref.watch(databaseProvider);
  return DownloadService(db, ref);
});

/// Provider for all downloads — backed by Drift's reactive watch() query so the
/// UI automatically rebuilds whenever any download row is inserted or updated.
final downloadsProvider = StreamNotifierProvider<DownloadsNotifier, List<models.DownloadItem>>(
  DownloadsNotifier.new,
);

class DownloadsNotifier extends StreamNotifier<List<models.DownloadItem>> {
  @override
  Stream<List<models.DownloadItem>> build() {
    final service = ref.read(downloadServiceProvider);
    final db = ref.read(databaseProvider);
    // Drift's watch() emits a new list every time any download row changes.
    return db.watchAllDownloads().asyncMap((rows) async {
      return Future.wait(rows.map(service.dbDownloadToItem));
    });
  }

  Future<void> refresh() async {
    // No-op: the stream already handles this automatically.
    // Kept for call-site compatibility.
  }

  Future<void> delete(String downloadId) async {
    final service = ref.read(downloadServiceProvider);
    await service.deleteDownload(downloadId);
  }
}

/// Provider for a single download
final downloadProvider = FutureProvider.family<models.DownloadItem?, String>((ref, id) async {
  final service = ref.read(downloadServiceProvider);
  return service.getDownload(id);
});

/// Provider for progress stream
final downloadProgressProvider = StreamProvider.family<models.DownloadProgress?, String>((ref, id) {
  final service = ref.read(downloadServiceProvider);
  return service.watchProgress(id) ?? const Stream.empty();
});
