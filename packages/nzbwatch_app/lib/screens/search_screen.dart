import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/nzb_models.dart';
import '../services/download_service.dart';
import '../services/ffi_bridge.dart';
import '../services/newznab_service.dart';
import '../services/server_service.dart';
import 'indexer_settings_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _loadingMessage = '';
  List<SearchResult> _results = [];
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Searching...';
      _error = null;
    });

    try {
      final results = await ref.read(newznabServiceProvider).search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Search failed: $e';
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  Future<void> _downloadResult(SearchResult result) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Downloading NZB...';
    });
    
    try {
      final service = ref.read(newznabServiceProvider);
      final downloadService = ref.read(downloadServiceProvider);
      
      // 1. Download NZB content
      final nzbXml = await service.downloadNzb(result);
      
      if (mounted) setState(() => _loadingMessage = 'Parsing NZB...');
      
      // 2. Parse NZB
      final nzb = await downloadService.importNzbXml(nzbXml);
      if (nzb == null) throw Exception('Failed to parse NZB');
      
      if (mounted) setState(() => _loadingMessage = 'Checking availability...');
      
      // 3. Health check
      final servers = await ref.read(serversProvider.future);
      final health = await ffiBridgeProvider.checkAvailability(nzb: nzb, servers: servers);
      
      bool shouldContinue = true;
      if (health < 100.0 && mounted) {
        shouldContinue = await _showHealthWarningDialog(nzb, health);
      }
      
      if (shouldContinue) {
        if (mounted) {
          setState(() => _loadingMessage = 'Starting download...');
        }
        
        // 4. Create and start download
        final download = await downloadService.createDownload(
          nzb: nzb,
          nzbPath: 'api://${result.guid}', // Dummy path for indexer downloads
        );
        
        if (download != null) {
          await downloadService.startDownload(download.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Started downloading ${nzb.name}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
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
    final indexersAsync = ref.watch(watchIndexersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text('Search Newsgroups'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Search for movies, TV, etc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _performSearch,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Indexer Warning
          indexersAsync.when(
            data: (indexers) {
              if (indexers.isEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No indexers configured. Add one in settings to search.',
                          style: TextStyle(color: Colors.orange, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const IndexerSettingsScreen()),
                          );
                        },
                        child: const Text('Configure'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF6366F1)),
                        if (_loadingMessage.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _loadingMessage,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  )
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    : _results.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, size: 64, color: Colors.white24),
                                SizedBox(height: 16),
                                Text("Find what you're looking for", style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final result = _results[index];
                              return _SearchResultTile(
                                result: result,
                                onDownload: () => _downloadResult(result),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onDownload;

  const _SearchResultTile({
    required this.result,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  result.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.formattedSize,
                  style: const TextStyle(
                    color: Color(0xFF818CF8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.hub_outlined, size: 14, color: Colors.white.withOpacity(0.4)),
              const SizedBox(width: 4),
              Text(
                result.indexerName,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white.withOpacity(0.4)),
              const SizedBox(width: 4),
              Text(
                result.pubDate != null ? DateFormat.yMMMd().format(result.pubDate!) : 'Unknown date',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
