import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/nzb_models.dart';
import '../services/server_service.dart';
import '../providers/settings_provider.dart';
import 'indexer_settings_screen.dart';
import 'server_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFF0F0F0F),
            title: const Text('Settings'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // General Settings section
              const _SectionHeader('General'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  color: Colors.white.withOpacity(0.05),
                  child: SwitchListTile(
                    title: const Text('Rename to Movie Name'),
                    subtitle: const Text('Rename entry to the main movie file name after download'),
                    value: settings.renameToMovieName,
                    onChanged: (value) => ref.read(settingsProvider.notifier).setRenameToMovieName(value),
                  ),
                ),
              ),

              // Servers section
              const _SectionHeader('Usenet Servers'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  color: Colors.white.withOpacity(0.05),
                  child: ListTile(
                    leading: const Icon(Icons.dns_outlined, color: Color(0xFF6366F1)),
                    title: const Text('Usenet Servers'),
                    subtitle: const Text('Configure hosts, ports and credentials'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ServerSettingsScreen()),
                    ),
                  ),
                ),
              ),

              // Indexers section
              const _SectionHeader('Search Indexers'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  color: Colors.white.withOpacity(0.05),
                  child: ListTile(
                    leading: const Icon(Icons.manage_search, color: Color(0xFF6366F1)),
                    title: const Text('Newznab Indexers'),
                    subtitle: const Text('Configure NZBGeek, DogNZB, etc.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IndexerSettingsScreen()),
                    ),
                  ),
                ),
              ),

              // About section
              const _SectionHeader('About'),
              _AboutCard(),

              const SizedBox(height: 40),
            ]),
          ),
        ],
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

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NZBWatch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Version 0.1.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'A cross-platform NZB downloader and media streamer.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServerFormSheet extends StatefulWidget {
  final ServerConfig? server;
  final Function(ServerConfig) onSave;

  const ServerFormSheet({
    super.key,
    this.server,
    required this.onSave,
  });

  @override
  State<ServerFormSheet> createState() => _ServerFormSheetState();
}

class _ServerFormSheetState extends State<ServerFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _connectionsController;
  late bool _useSsl;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final server = widget.server;
    _nameController = TextEditingController(text: server?.name ?? '');
    _hostController = TextEditingController(text: server?.host ?? '');
    _portController = TextEditingController(text: (server?.port ?? 563).toString());
    _usernameController = TextEditingController(text: server?.username ?? '');
    _passwordController = TextEditingController(text: server?.password ?? '');
    _connectionsController = TextEditingController(text: (server?.maxConnections ?? 4).toString());
    _useSsl = server?.useSsl ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _connectionsController.dispose();
    super.dispose();
  }

  void _save() {
    final server = ServerConfig(
      id: widget.server?.id ?? '',
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text) ?? 563,
      useSsl: _useSsl,
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      maxConnections: int.tryParse(_connectionsController.text) ?? 4,
      priority: widget.server?.priority ?? 0,
    );
    widget.onSave(server);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.server != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
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

              Text(
                isEditing ? 'Edit Server' : 'Add Server',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Server Name',
                  hintText: 'e.g., UsenetServer',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Host
              TextField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Hostname',
                  hintText: 'news.example.com',
                  prefixIcon: Icon(Icons.dns),
                ),
              ),
              const SizedBox(height: 16),

              // Port and SSL
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        hintText: '563',
                        prefixIcon: Icon(Icons.settings_ethernet),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: SwitchListTile(
                      title: const Text('Use SSL'),
                      value: _useSsl,
                      onChanged: (v) => setState(() => _useSsl = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Max connections
              TextField(
                controller: _connectionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Connections',
                  hintText: '4',
                  prefixIcon: Icon(Icons.multiple_stop),
                  helperText: 'Number of simultaneous connections',
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF6366F1),
                ),
                child: Text(isEditing ? 'Save Changes' : 'Add Server'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
