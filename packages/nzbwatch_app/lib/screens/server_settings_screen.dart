import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nzb_models.dart';
import '../services/server_service.dart';
import 'settings_screen.dart'; // For ServerFormSheet if we want to reuse, but it's private there.
// Actually ServerFormSheet is public in settings_screen.dart, so we can import it.

class ServerSettingsScreen extends ConsumerWidget {
  const ServerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversAsync = ref.watch(serversProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text('Usenet Servers'),
        elevation: 0,
      ),
      body: serversAsync.when(
        data: (servers) {
          if (servers.isEmpty) {
            return _EmptyServersCard(
              onAdd: () => _showAddServerDialog(context, ref),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: servers.length,
            itemBuilder: (context, index) {
              final server = servers[index];
              return _ServerCard(
                server: server,
                onEdit: () => _showEditServerDialog(context, ref, server),
                onDelete: () => _confirmDeleteServer(context, ref, server),
                onTest: () => _testServer(context, ref, server),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServerDialog(context, ref),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddServerDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServerFormSheet(
        onSave: (server) async {
          await ref.read(serverServiceProvider).addServer(
                name: server.name,
                host: server.host,
                port: server.port,
                useSsl: server.useSsl,
                username: server.username,
                password: server.password,
                maxConnections: server.maxConnections,
                priority: server.priority,
              );
          ref.invalidate(serversProvider);
        },
      ),
    );
  }

  void _showEditServerDialog(BuildContext context, WidgetRef ref, ServerConfig server) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServerFormSheet(
        server: server,
        onSave: (updated) async {
          await ref.read(serverServiceProvider).updateServer(updated);
          ref.invalidate(serversProvider);
        },
      ),
    );
  }

  void _confirmDeleteServer(BuildContext context, WidgetRef ref, ServerConfig server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Server?'),
        content: Text('Are you sure you want to delete "${server.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(serverServiceProvider).deleteServer(server.id);
              ref.invalidate(serversProvider);
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _testServer(BuildContext context, WidgetRef ref, ServerConfig server) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Testing connection...'),
          ],
        ),
      ),
    );

    final result = await ref.read(serverServiceProvider).testServer(server);

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result ? 'Connection Successful' : 'Connection Failed'),
          content: Text(result
              ? 'Successfully connected to ${server.host}'
              : 'Could not connect to ${server.host}. Please check your settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class _EmptyServersCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyServersCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              'No servers configured',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a Usenet server to start downloading',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white38,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  final ServerConfig server;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTest;

  const _ServerCard({
    required this.server,
    required this.onEdit,
    required this.onDelete,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      color: Colors.white.withOpacity(0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: server.useSsl
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            server.useSsl ? Icons.lock : Icons.lock_open,
            color: server.useSsl ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          server.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${server.host}:${server.port}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'test', child: Text('Test Connection')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            switch (value) {
              case 'test':
                onTest();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
      ),
    );
  }
}
