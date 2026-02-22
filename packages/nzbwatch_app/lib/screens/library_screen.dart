import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nzb_models.dart';
import '../services/download_service.dart';
import '../services/ffi_bridge.dart';
import '../services/server_service.dart';
import 'player_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'widgets/download_card.dart';
import 'widgets/empty_state.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isDragging = false;
  bool _isProcessingDrop = false;
  String _importStatus = '';

  @override
  void initState() {
    super.initState();
    // Check if servers are configured
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServersConfigured();
    });
  }

  Future<void> _checkServersConfigured() async {
    final servers = await ref.read(serversProvider.future);
    if (servers.isEmpty && mounted) {
      _showNoServersDialog();
    }
  }

  void _showNoServersDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to NZBWatch'),
        content: const Text(
          'You need to configure at least one Usenet server before you can download files.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openSettings();
            },
            child: const Text('Configure Server'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _showAddDownloadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddDownloadSheet(),
    );
  }

  void _playDownload(DownloadItem download) {
    if (download.isComplete) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerScreen(
            downloadId: download.id,
            filePath: download.outputPath,
            title: download.filename,
          ),
        ),
      );
    }
  }

  Future<void> _deleteDownload(String downloadId) async {
    try {
      await ref.read(downloadsProvider.notifier).delete(downloadId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDroppedFiles(List<dynamic> files) async {
    if (_isProcessingDrop) return;
    
    setState(() {
      _isProcessingDrop = true;
      _isDragging = false;
      _importStatus = 'Reading file...';
    });

    final service = ref.read(downloadServiceProvider);
    int successCount = 0;
    int failCount = 0;
    String? lastError;

    for (final file in files) {
      final path = file.path as String;

      // Check if it's an NZB file
      if (!path.toLowerCase().endsWith('.nzb')) {
        failCount++;
        lastError = 'Not an NZB file';
        continue;
      }

      try {
        // Check if file exists and is readable
        final fileObj = File(path);
        if (!await fileObj.exists()) {
          failCount++;
          lastError = 'File does not exist';
          continue;
        }

        // Try to read first few bytes to check if it's valid
        final bytes = await fileObj.readAsBytes();
        if (bytes.isEmpty) {
          failCount++;
          lastError = 'File is empty';
          continue;
        }

        // Check if it looks like XML
        final content = String.fromCharCodes(bytes.take(100));
        if (!content.trim().startsWith('<')) {
          failCount++;
          lastError = 'File does not appear to be XML';
          continue;
        }

        setState(() => _importStatus = 'Parsing NZB…');
        final nzb = await service.importNzbFile(path);
        if (nzb != null) {
          setState(() => _importStatus =
              'Saving ${nzb.totalSegments.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]},',
                  )} segments…');
          final download = await service.createDownload(
            nzb: nzb,
            nzbPath: path,
          );
          if (download != null) {
            setState(() => _importStatus = 'Checking availability…');
            
            // PERFORM PRE-CHECK
            final servers = await ref.read(serversProvider.future);
            final health = await ffiBridgeProvider.checkAvailability(nzb: nzb, servers: servers);
            
            bool shouldContinue = true;
            if (health < 100.0 && mounted) {
              shouldContinue = await _showHealthWarningDialog(nzb, health);
            }

            if (shouldContinue) {
              setState(() => _importStatus = 'Starting download…');
              final started = await service.startDownload(download.id);
              if (started) {
                successCount++;
              } else {
                failCount++;
                lastError = 'Download failed to start';
              }
            } else {
              // User cancelled due to poor health
              await service.deleteDownload(download.id);
              failCount++;
              lastError = 'Cancelled due to poor health (${health.toStringAsFixed(1)}%)';
            }
          } else {
            failCount++;
            lastError = 'Failed to create download';
          }
        } else {
          failCount++;
          lastError = 'Failed to parse NZB (check Debug Console for details)';
        }
      } catch (e) {
        failCount++;
        final errorMsg = e.toString();
        // Extract the main error message
        if (errorMsg.contains('UNIQUE constraint failed')) {
          lastError = 'Duplicate segment ID - NZB may contain duplicate files';
        } else if (errorMsg.contains('SqliteException')) {
          lastError = 'Database error: ${errorMsg.split(':').last.trim()}';
        } else {
          lastError = errorMsg.length > 100 ? '${errorMsg.substring(0, 100)}...' : errorMsg;
        }
        print('Drop error for $path: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isProcessingDrop = false;
        _importStatus = '';
      });
      
      // Refresh the downloads list
      ref.read(downloadsProvider.notifier).refresh();
      
      // Show result
      if (successCount > 0 || failCount > 0) {
        String message;
        if (successCount > 0 && failCount == 0) {
          message = 'Added $successCount NZB(s)';
        } else if (successCount > 0 && failCount > 0) {
          message = 'Added $successCount NZB(s), $failCount failed\n$lastError';
        } else {
          message = 'Failed to add NZB: $lastError';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: failCount > 0 
                ? (successCount > 0 ? Colors.orange : Colors.red)
                : Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<bool> _showHealthWarningDialog(NzbFile nzb, double health) async {
    final isRar = nzb.containsRars;
    final message = isRar
        ? 'This download is only ${health.toStringAsFixed(1)}% available on your servers. '
          'Since it contains compressed RAR files, it WILL fail to decompress once finished.'
        : 'This download is only ${health.toStringAsFixed(1)}% available on your servers. '
          'Since it is a raw video file, it will have visual glitches and macro-blocking.';

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Incomplete Download'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final downloadsAsync = ref.watch(downloadsProvider);

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (detail) => _handleDroppedFiles(detail.files),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // App bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: const Color(0xFF0F0F0F),
                  elevation: 0,
                  title: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'NZBWatch',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: _openSettings,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Content
                downloadsAsync.when(
                  data: (downloads) {
                    if (downloads.isEmpty) {
                      return const SliverFillRemaining(
                        child: EmptyState(
                          icon: Icons.movie_outlined,
                          title: 'No downloads yet',
                          subtitle: 'Drag & drop NZB files here or tap + to add',
                        ),
                      );
                    }

                    // Separate active and completed downloads
                    final active = downloads.where((d) => !d.isComplete).toList();
                    final completed = downloads.where((d) => d.isComplete).toList();

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // Active downloads section
                        if (active.isNotEmpty) ...[
                          const _SectionHeader('Downloading'),
                          ...active.map((d) => DownloadCard(
                                download: d,
                                onTap: () {},
                                onCancel: () => ref
                                    .read(downloadServiceProvider)
                                    .cancelDownload(d.id),
                                onDelete: () => _deleteDownload(d.id),
                                onResume: d.state == DownloadState.paused || d.state == DownloadState.error
                                    ? () => ref
                                        .read(downloadServiceProvider)
                                        .startDownload(d.id)
                                    : null,
                                onRetry: () => ref
                                    .read(downloadServiceProvider)
                                    .retryDownload(d.id),
                                onReveal: () => ref
                                    .read(downloadServiceProvider)
                                    .revealInFinder(d.id),
                              )),
                        ],

                        // Completed downloads section
                        if (completed.isNotEmpty) ...[
                          const _SectionHeader('Library'),
                          ...completed.map((d) => DownloadCard(
                                download: d,
                                onTap: () => _playDownload(d),
                                onDelete: () => _deleteDownload(d.id),
                                onRetry: () => ref
                                    .read(downloadServiceProvider)
                                    .retryDownload(d.id),
                                onReveal: () => ref
                                    .read(downloadServiceProvider)
                                    .revealInFinder(d.id),
                              )),
                        ],
                        const SizedBox(height: 100),
                      ]),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => SliverFillRemaining(
                    child: Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            ),

            // Drag overlay
            if (_isDragging)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.file_download_outlined,
                          size: 64,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Drop NZB files here',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Processing indicator with status message
            if (_isProcessingDrop)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                        if (_importStatus.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _importStatus,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddDownloadDialog,
          backgroundColor: const Color(0xFF6366F1),
          icon: const Icon(Icons.add),
          label: const Text('Add NZB'),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class AddDownloadSheet extends ConsumerStatefulWidget {
  const AddDownloadSheet({super.key});

  @override
  ConsumerState<AddDownloadSheet> createState() => _AddDownloadSheetState();
}

class _AddDownloadSheetState extends ConsumerState<AddDownloadSheet> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _importFromFile() async {
    // File picker would go here
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File picker not implemented in MVP')),
    );
  }

  Future<void> _importFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For MVP, assume URL is a local file path or raw XML
      final service = ref.read(downloadServiceProvider);
      final nzb = await service.importNzbXml(url);

      if (nzb == null) {
        setState(() {
          _error = 'Failed to parse NZB';
          _isLoading = false;
        });
        return;
      }

      // Create download
      final download = await service.createDownload(
        nzb: nzb,
        nzbPath: url,
      );

      if (download != null) {
        // Start downloading
        await service.startDownload(download.id);

        // Refresh the downloads list
        ref.read(downloadsProvider.notifier).refresh();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Started downloading ${nzb.name}')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Add Download',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paste NZB XML or import from file',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),

              // File import button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _importFromFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Import from File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // URL/XML input
              TextField(
                controller: _urlController,
                maxLines: 5,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Paste NZB XML here...',
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 20),

              // Submit button
              FilledButton(
                onPressed: _isLoading ? null : _importFromUrl,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF6366F1),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Start Download'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
