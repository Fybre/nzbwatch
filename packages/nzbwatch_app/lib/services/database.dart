import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

// Download states
enum DownloadStatus {
  queued,
  downloading,
  paused,
  complete,
  error,
}

// Server configurations
class ServerConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get host => text()();
  IntColumn get port => integer()();
  BoolColumn get useSsl => boolean()();
  TextColumn get username => text()();
  TextColumn get password => text()();
  IntColumn get maxConnections => integer()();
  IntColumn get priority => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Downloads
class Downloads extends Table {
  TextColumn get id => text()();
  TextColumn get nzbPath => text()();
  TextColumn get filename => text()();
  TextColumn get subject => text().nullable()();
  TextColumn get poster => text().nullable()();
  IntColumn get status => intEnum<DownloadStatus>()();
  IntColumn get totalBytes => integer()();
  IntColumn get downloadedBytes => integer()();
  IntColumn get totalSegments => integer()();
  IntColumn get completedSegments => integer()();
  TextColumn get outputPath => text()();
  TextColumn get errorMessage => text().nullable()();
  IntColumn get lastPosition => integer().withDefault(const Constant(0))();
  RealColumn get health => real().withDefault(const Constant(100.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// NZB Files within a download
class DownloadFiles extends Table {
  TextColumn get id => text()();
  TextColumn get downloadId => text().references(Downloads, #id, onDelete: KeyAction.cascade)();
  TextColumn get filename => text()();
  TextColumn get subject => text()();
  IntColumn get size => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// NZB Segments
class Segments extends Table {
  TextColumn get id => text()();
  TextColumn get downloadId => text().references(Downloads, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileId => text().nullable().references(DownloadFiles, #id, onDelete: KeyAction.cascade)();
  IntColumn get number => integer()();
  TextColumn get messageId => text()();
  IntColumn get size => integer()();
  BoolColumn get isDownloaded => boolean()();
  IntColumn get retries => integer()();
  DateTimeColumn get downloadedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Download groups from NZB
class DownloadGroups extends Table {
  TextColumn get id => text()();
  TextColumn get downloadId => text().references(Downloads, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ServerConfigs, Downloads, DownloadFiles, Segments, DownloadGroups])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.deleteTable('segments');
            await m.deleteTable('download_groups');
            await m.createAll();
          } else if (from < 3) {
            await m.createTable(downloadFiles);
            await m.addColumn(segments, segments.fileId);
          } else if (from < 4) {
            await m.addColumn(downloads, downloads.lastPosition);
          } else if (from < 5) {
            await m.addColumn(downloads, downloads.health);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // Truncate all tables
  Future<void> truncateAll() async {
    return transaction(() async {
      await delete(segments).go();
      await delete(downloadFiles).go();
      await delete(downloadGroups).go();
      await delete(downloads).go();
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'nzbwatch');
  }

  // Server Config CRUD
  Future<List<ServerConfig>> getAllServers() => select(serverConfigs).get();
  
  Future<ServerConfig?> getServer(String id) {
    return (select(serverConfigs)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertServer(ServerConfigsCompanion server) => into(serverConfigs).insert(server);

  Future<bool> updateServer(ServerConfigsCompanion server) {
    return (update(serverConfigs)..where((s) => s.id.equals(server.id.value))).write(server).then((rows) => rows > 0);
  }

  Future<int> deleteServer(String id) {
    return (delete(serverConfigs)..where((s) => s.id.equals(id))).go();
  }

  // Download CRUD
  Future<List<Download>> getAllDownloads() {
    return (select(downloads)
      ..orderBy([(d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Reactive stream — emits a new list whenever any download row changes.
  Stream<List<Download>> watchAllDownloads() {
    return (select(downloads)
      ..orderBy([(d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<Download?> getDownload(String id) {
    return (select(downloads)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertDownload(DownloadsCompanion download) => into(downloads).insert(download);

  Future<bool> updateDownload(DownloadsCompanion download) {
    return (update(downloads)..where((d) => d.id.equals(download.id.value))).write(download).then((rows) => rows > 0);
  }

  Future<int> deleteDownload(String id) {
    return transaction(() async {
      // Manually delete related records first as a safety measure
      await (delete(segments)..where((s) => s.downloadId.equals(id))).go();
      await (delete(downloadFiles)..where((f) => f.downloadId.equals(id))).go();
      await (delete(downloadGroups)..where((g) => g.downloadId.equals(id))).go();
      
      // Then delete the download itself
      return await (delete(downloads)..where((d) => d.id.equals(id))).go();
    });
  }

  // Get downloads by status
  Future<List<Download>> getDownloadsByStatus(DownloadStatus status) {
    return (select(downloads)..where((d) => d.status.equals(status.index))).get();
  }

  // File operations
  Future<void> insertFilesBatch(List<DownloadFilesCompanion> files) =>
      batch((b) => b.insertAll(downloadFiles, files));

  Future<List<DownloadFile>> getFilesForDownload(String downloadId) {
    return (select(downloadFiles)..where((f) => f.downloadId.equals(downloadId))).get();
  }

  // Segment operations
  Future<List<Segment>> getSegmentsForDownload(String downloadId) {
    return (select(segments)
      ..where((s) => s.downloadId.equals(downloadId))
      ..orderBy([(s) => OrderingTerm(expression: s.number)]))
        .get();
  }

  Future<List<Segment>> getSegmentsForFile(String fileId) {
    return (select(segments)
      ..where((s) => s.fileId.equals(fileId))
      ..orderBy([(s) => OrderingTerm(expression: s.number)]))
        .get();
  }

  Future<int> insertSegment(SegmentsCompanion segment) => into(segments).insert(segment);

  /// Bulk-insert segments in a single transaction — dramatically faster than
  /// calling insertSegment() in a loop (e.g. 41,000 segments in ~100ms vs 30s).
  Future<void> insertSegmentsBatch(List<SegmentsCompanion> segs) =>
      batch((b) => b.insertAll(segments, segs));

  Future<bool> markSegmentDownloaded(String segmentId) {
    return (update(segments)..where((s) => s.id.equals(segmentId)))
        .write(SegmentsCompanion(
          isDownloaded: const Value(true),
          downloadedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
  }

  // Group operations
  Future<int> insertGroup(DownloadGroupsCompanion group) => into(downloadGroups).insert(group);

  Future<void> insertGroupsBatch(List<DownloadGroupsCompanion> groups) =>
      batch((b) => b.insertAll(downloadGroups, groups));

  Future<List<DownloadGroup>> getGroupsForDownload(String downloadId) {
    return (select(downloadGroups)..where((g) => g.downloadId.equals(downloadId))).get();
  }
}

// Riverpod provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database not initialized');
});
