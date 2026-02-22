import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/nzb_models.dart';
import '../../services/download_service.dart';

class DownloadCard extends ConsumerWidget {
  final DownloadItem download;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onResume;
  final VoidCallback? onRetry;
  final VoidCallback? onReveal;
  final Function(String)? onStream;

  const DownloadCard({
    super.key,
    required this.download,
    required this.onTap,
    this.onCancel,
    this.onDelete,
    this.onResume,
    this.onRetry,
    this.onReveal,
    this.onStream,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressStream = ref.watch(downloadProgressProvider(download.id));

    return progressStream.when(
      data: (progress) {
        final displayProgress = progress ?? _createProgressFromDownload(download);
        return _buildCard(context, displayProgress);
      },
      loading: () => _buildCard(context, _createProgressFromDownload(download)),
      error: (_, __) => _buildCard(context, _createProgressFromDownload(download)),
    );
  }

  DownloadProgress _createProgressFromDownload(DownloadItem download) {
    return DownloadProgress(
      downloadId: download.id,
      state: download.state,
      totalBytes: download.totalBytes,
      downloadedBytes: download.downloadedBytes,
      totalSegments: download.totalSegments,
      completedSegments: download.completedSegments,
      percentComplete: download.percentComplete,
    );
  }

  Widget _buildCard(BuildContext context, DownloadProgress progress) {
    final isDownloading = progress.state == DownloadState.downloading;
    final isComplete = progress.state == DownloadState.complete;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      color: Colors.white.withOpacity(0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isComplete ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status icon
                  _StatusIcon(
                    state: progress.state,
                    percentComplete: progress.percentComplete,
                  ),
                  const SizedBox(width: 12),

                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          download.filename,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _buildSubtitle(progress),
                      ],
                    ),
                  ),

                  if (isDownloading && progress.streamingUrl != null && onStream != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton.icon(
                        onPressed: () => onStream!(progress.streamingUrl!),
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: const Text('Stream Now'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),

                  // Action menu
                  _buildActionMenu(context, progress.state),
                ],
              ),

              // Progress bar for active downloads
              if (isDownloading) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.percentComplete / 100,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress.percentComplete),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, DownloadState state) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.white.withOpacity(0.6),
      ),
      onSelected: (value) {
        switch (value) {
          case 'cancel':
            onCancel?.call();
            break;
          case 'resume':
            onResume?.call();
            break;
          case 'retry':
            onRetry?.call();
            break;
          case 'reveal':
            onReveal?.call();
            break;
          case 'delete':
            _showDeleteConfirmation(context);
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];
        
        if (state == DownloadState.downloading && onCancel != null) {
          items.add(
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.pause, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Pause'),
                ],
              ),
            ),
          );
        }
        
        if ((state == DownloadState.paused || state == DownloadState.error) && onResume != null) {
          items.add(
            const PopupMenuItem(
              value: 'resume',
              child: Row(
                children: [
                  Icon(Icons.play_arrow, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Resume'),
                ],
              ),
            ),
          );
        }

        if ((state == DownloadState.error || state == DownloadState.complete) && onRetry != null) {
          items.add(
            const PopupMenuItem(
              value: 'retry',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Retry Download'),
                ],
              ),
            ),
          );
        }
        
        // Reveal in Finder (macOS)
        if (onReveal != null) {
          if (items.isNotEmpty) {
            items.add(const PopupMenuDivider());
          }
          items.add(
            const PopupMenuItem(
              value: 'reveal',
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Reveal in Finder'),
                ],
              ),
            ),
          );
        }
        
        if (onDelete != null) {
          if (items.isNotEmpty) {
            items.add(const PopupMenuDivider());
          }
          items.add(
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red.shade300),
                  const SizedBox(width: 8),
                  const Text('Delete'),
                ],
              ),
            ),
          );
        }
        
        return items;
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download?'),
        content: Text(
          'Are you sure you want to delete "${download.filename}"?\n\n'
          'This will remove the download from the queue and delete the downloaded file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(DownloadProgress progress) {
    if (progress.state == DownloadState.error) {
      return Text(
        'Error: ${download.errorMessage ?? 'Unknown error'}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red.shade300,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (progress.state == DownloadState.complete) {
      return Text(
        '${progress.formattedSize} • Complete',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.5),
        ),
      );
    }

    if (progress.state == DownloadState.downloading) {
      final etaStr = progress.etaSeconds != null
          ? ' • ${_formatDuration(progress.etaSeconds!)} left'
          : '';
      final healthStr = progress.health < 100.0
          ? ' • Health: ${progress.health.toStringAsFixed(1)}%'
          : '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${progress.formattedDownloaded} / ${progress.formattedSize} • ${progress.formattedSpeed}$etaStr$healthStr',
            style: TextStyle(
              fontSize: 12,
              color: progress.health < 90 ? Colors.orange.shade300 : Colors.white.withOpacity(0.5),
            ),
          ),
          if (progress.currentFile != null) ...[
            const SizedBox(height: 2),
            Text(
              'Current: ${progress.currentFile}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.3),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    return Text(
      progress.state.toString().split('.').last,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).floor()}m ${seconds % 60}s';
    return '${(seconds / 3600).floor()}h ${((seconds % 3600) / 60).floor()}m';
  }

  Color _getProgressColor(double percent) {
    if (percent < 30) return Colors.red.shade400;
    if (percent < 70) return Colors.orange.shade400;
    return Colors.green.shade400;
  }
}

class _StatusIcon extends StatelessWidget {
  final DownloadState state;
  final double percentComplete;

  const _StatusIcon({
    required this.state,
    required this.percentComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getBackgroundColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: _buildIcon(),
      ),
    );
  }

  Widget _buildIcon() {
    switch (state) {
      case DownloadState.queued:
        return Icon(
          Icons.schedule,
          color: Colors.grey.shade400,
        );
      case DownloadState.downloading:
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: percentComplete / 100,
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(),
              ),
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
            Text(
              '${percentComplete.round()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getForegroundColor(),
              ),
            ),
          ],
        );
      case DownloadState.paused:
        return Icon(
          Icons.pause_circle_filled,
          color: Colors.orange.shade400,
        );
      case DownloadState.complete:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
        );
      case DownloadState.error:
        return Icon(
          Icons.error,
          color: Colors.red.shade400,
        );
    }
  }

  Color _getBackgroundColor() {
    switch (state) {
      case DownloadState.queued:
        return Colors.grey;
      case DownloadState.downloading:
        return const Color(0xFF6366F1);
      case DownloadState.paused:
        return Colors.orange;
      case DownloadState.complete:
        return Colors.green;
      case DownloadState.error:
        return Colors.red;
    }
  }

  Color _getForegroundColor() {
    switch (state) {
      case DownloadState.queued:
        return Colors.grey.shade400;
      case DownloadState.downloading:
        return const Color(0xFF6366F1);
      case DownloadState.paused:
        return Colors.orange.shade400;
      case DownloadState.complete:
        return Colors.green.shade400;
      case DownloadState.error:
        return Colors.red.shade400;
    }
  }
}
