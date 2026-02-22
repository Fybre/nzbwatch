import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/nzb_models.dart' as models;
import 'database.dart';
import 'ffi_bridge.dart';

/// Service for managing server configurations
class ServerService {
  final AppDatabase _db;
  final _uuid = const Uuid();
  
  ServerService(this._db);
  
  /// Get all configured servers
  Future<List<models.ServerConfig>> getAllServers() async {
    final configs = await _db.getAllServers();
    return configs.map(_dbToModel).toList();
  }
  
  /// Get a single server
  Future<models.ServerConfig?> getServer(String id) async {
    final config = await _db.getServer(id);
    if (config == null) return null;
    return _dbToModel(config);
  }
  
  /// Add a new server
  Future<models.ServerConfig> addServer({
    required String name,
    required String host,
    required int port,
    required bool useSsl,
    required String username,
    required String password,
    int maxConnections = 4,
    int priority = 0,
  }) async {
    final id = _uuid.v4();
    
    await _db.insertServer(ServerConfigsCompanion.insert(
      id: id,
      name: name,
      host: host,
      port: port,
      useSsl: useSsl,
      username: username,
      password: password,
      maxConnections: maxConnections,
      priority: priority,
      createdAt: DateTime.now(),
    ));
    
    return models.ServerConfig(
      id: id,
      name: name,
      host: host,
      port: port,
      useSsl: useSsl,
      username: username,
      password: password,
      maxConnections: maxConnections,
      priority: priority,
    );
  }
  
  /// Update an existing server
  Future<bool> updateServer(models.ServerConfig config) async {
    return _db.updateServer(ServerConfigsCompanion(
      id: Value(config.id),
      name: Value(config.name),
      host: Value(config.host),
      port: Value(config.port),
      useSsl: Value(config.useSsl),
      username: Value(config.username),
      password: Value(config.password),
      maxConnections: Value(config.maxConnections),
      priority: Value(config.priority),
      createdAt: Value.absent(),
    ));
  }
  
  /// Delete a server
  Future<void> deleteServer(String id) async {
    await _db.deleteServer(id);
  }
  
  /// Test server connection using direct FFI
  Future<bool> testServer(models.ServerConfig server) async {
    print('ServerService: Testing connection to ${server.host}:${server.port}');
    
    try {
      final result = await FfiBridge().testServer(server);
      print('ServerService: Test result: $result');
      return result;
    } catch (e, stackTrace) {
      print('ServerService: Test error: $e');
      print('ServerService: Stack: $stackTrace');
      return false;
    }
  }
  
  /// Create default server config
  models.ServerConfig createDefault() {
    return const models.ServerConfig(
      id: '',
      name: 'New Server',
      host: '',
      port: 563,
      useSsl: true,
      username: '',
      password: '',
      maxConnections: 4,
      priority: 0,
    );
  }
  
  models.ServerConfig _dbToModel(ServerConfig config) {
    return models.ServerConfig(
      id: config.id,
      name: config.name,
      host: config.host,
      port: config.port,
      useSsl: config.useSsl,
      username: config.username,
      password: config.password,
      maxConnections: config.maxConnections,
      priority: config.priority,
    );
  }
}

/// Server service provider
final serverServiceProvider = Provider<ServerService>((ref) {
  final db = ref.watch(databaseProvider);
  return ServerService(db);
});

/// Provider for all servers
final serversProvider = FutureProvider<List<models.ServerConfig>>((ref) async {
  final service = ref.watch(serverServiceProvider);
  return service.getAllServers();
});

/// Provider for a single server
final serverProvider = FutureProvider.family<models.ServerConfig?, String>((ref, id) async {
  final service = ref.watch(serverServiceProvider);
  return service.getServer(id);
});
