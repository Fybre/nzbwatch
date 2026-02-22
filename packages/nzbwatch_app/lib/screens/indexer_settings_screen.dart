import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nzb_models.dart' as models;
import '../services/newznab_service.dart';

class IndexerSettingsScreen extends ConsumerStatefulWidget {
  const IndexerSettingsScreen({super.key});

  @override
  ConsumerState<IndexerSettingsScreen> createState() => _IndexerSettingsScreenState();
}

class _IndexerSettingsScreenState extends ConsumerState<IndexerSettingsScreen> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _showIndexerDialog([models.NewznabIndexer? indexer]) {
    final isEditing = indexer != null;
    _nameController.text = indexer?.name ?? '';
    _hostController.text = indexer?.host ?? '';
    _apiKeyController.text = indexer?.apiKey ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Indexer' : 'Add Indexer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Indexer Name (e.g. NZBGeek)'),
            ),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(labelText: 'API Host (e.g. https://api.nzbgeek.info)'),
            ),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(labelText: 'API Key'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty &&
                  _hostController.text.isNotEmpty &&
                  _apiKeyController.text.isNotEmpty) {
                final service = ref.read(newznabServiceProvider);
                if (isEditing) {
                  await service.updateIndexer(indexer.copyWith(
                    name: _nameController.text.trim(),
                    host: _hostController.text.trim(),
                    apiKey: _apiKeyController.text.trim(),
                  ));
                } else {
                  await service.addIndexer(
                    name: _nameController.text.trim(),
                    host: _hostController.text.trim(),
                    apiKey: _apiKeyController.text.trim(),
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final indexersAsync = ref.watch(watchIndexersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text('Newznab Indexers'),
        elevation: 0,
      ),
      body: indexersAsync.when(
        data: (indexers) {
          if (indexers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hub_outlined, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('No indexers added yet', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: indexers.length,
            itemBuilder: (context, index) {
              final indexer = indexers[index];
              return ListTile(
                title: Text(indexer.name),
                subtitle: Text(indexer.host),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showIndexerDialog(indexer),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await ref.read(newznabServiceProvider).deleteIndexer(indexer.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showIndexerDialog(),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
