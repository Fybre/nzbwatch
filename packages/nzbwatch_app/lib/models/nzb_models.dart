import 'package:equatable/equatable.dart';

/// Server configuration model
class ServerConfig extends Equatable {
  final String id;
  final String name;
  final String host;
  final int port;
  final bool useSsl;
  final String username;
  final String password;
  final int maxConnections;
  final int priority;

  const ServerConfig({
    required this.id,
    required this.name,
    required this.host,
    this.port = 563,
    this.useSsl = true,
    this.username = '',
    this.password = '',
    this.maxConnections = 4,
    this.priority = 0,
  });

  ServerConfig copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    bool? useSsl,
    String? username,
    String? password,
    int? maxConnections,
    int? priority,
  }) {
    return ServerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      useSsl: useSsl ?? this.useSsl,
      username: username ?? this.username,
      password: password ?? this.password,
      maxConnections: maxConnections ?? this.maxConnections,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'host': host,
        'port': port,
        'use_ssl': useSsl,
        'username': username,
        'password': password,
        'max_connections': maxConnections,
        'priority': priority,
      };

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      host: json['host'] as String,
      port: json['port'] as int? ?? 563,
      useSsl: (json['use_ssl'] ?? json['useSsl'] ?? true) as bool,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      maxConnections: (json['max_connections'] ?? json['maxConnections'] ?? 4) as int,
      priority: json['priority'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        host,
        port,
        useSsl,
        username,
        password,
        maxConnections,
        priority,
      ];
}

/// NZB segment model
class NzbSegment extends Equatable {
  final int number;
  final String messageId;
  final int size;

  const NzbSegment({
    required this.number,
    required this.messageId,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'message_id': messageId,
        'size': size,
      };

  @override
  List<Object?> get props => [number, messageId, size];
}

/// NZB file model
class NzbFile extends Equatable {
  final String name;
  final String? poster;
  final List<String> groups;
  final List<NzbFileEntry> files;
  final int totalSize;

  const NzbFile({
    required this.name,
    this.poster,
    required this.groups,
    required this.files,
    required this.totalSize,
  });

  int get totalSegments => files.fold(0, (sum, file) => sum + file.segments.length);

  bool get containsRars => files.any((f) => f.filename.toLowerCase().contains('.rar'));

  Map<String, dynamic> toJson() => {
        'name': name,
        'poster': poster,
        'groups': groups,
        'files': files.map((f) => f.toJson()).toList(),
        'total_size': totalSize,
      };

  @override
  List<Object?> get props => [name, poster, groups, files, totalSize];
}

/// NZB file entry model (one file within an NZB)
class NzbFileEntry extends Equatable {
  final String filename;
  final String subject;
  final List<NzbSegment> segments;
  final int size;

  const NzbFileEntry({
    required this.filename,
    required this.subject,
    required this.segments,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'subject': subject,
        'segments': segments.map((s) => s.toJson()).toList(),
        'size': size,
      };

  @override
  List<Object?> get props => [filename, subject, segments, size];
}

/// Download state enum
enum DownloadState {
  queued,
  downloading,
  paused,
  complete,
  error,
}

/// Download progress model
class DownloadProgress extends Equatable {
  final String downloadId;
  final DownloadState state;
  final int totalBytes;
  final int downloadedBytes;
  final int totalSegments;
  final int completedSegments;
  final int speedBytesPerSec;
  final int? etaSeconds;
  final String? currentFile;
  final double health;
  final double percentComplete;
  final String? errorMessage;

  const DownloadProgress({
    required this.downloadId,
    required this.state,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.totalSegments,
    required this.completedSegments,
    this.speedBytesPerSec = 0,
    this.etaSeconds,
    this.currentFile,
    this.health = 100.0,
    this.percentComplete = 0.0,
    this.errorMessage,
  });

  String get formattedSpeed {
    if (speedBytesPerSec < 1024) {
      return '${speedBytesPerSec}B/s';
    } else if (speedBytesPerSec < 1024 * 1024) {
      return '${(speedBytesPerSec / 1024).toStringAsFixed(1)}KB/s';
    } else {
      return '${(speedBytesPerSec / (1024 * 1024)).toStringAsFixed(1)}MB/s';
    }
  }

  String get formattedSize {
    final size = totalBytes;
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
  }

  String get formattedDownloaded {
    final size = downloadedBytes;
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
  }

  @override
  List<Object?> get props => [
        downloadId,
        state,
        totalBytes,
        downloadedBytes,
        totalSegments,
        completedSegments,
        speedBytesPerSec,
        etaSeconds,
        currentFile,
        percentComplete,
        errorMessage,
      ];
}

/// Download item model
class DownloadItem extends Equatable {
  final String id;
  final String nzbPath;
  final String filename;
  final String? subject;
  final String? poster;
  final DownloadState state;
  final int totalBytes;
  final int downloadedBytes;
  final int totalSegments;
  final int completedSegments;
  final String outputPath;
  final String? errorMessage;
  final double health;
  final int lastPosition;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> groups;

  const DownloadItem({
    required this.id,
    required this.nzbPath,
    required this.filename,
    this.subject,
    this.poster,
    required this.state,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.totalSegments,
    required this.completedSegments,
    required this.outputPath,
    this.errorMessage,
    this.health = 100.0,
    this.lastPosition = 0,
    required this.createdAt,
    this.completedAt,
    this.groups = const [],
  });

  bool get isComplete => state == DownloadState.complete;
  bool get isDownloading => state == DownloadState.downloading;
  bool get hasError => state == DownloadState.error;

  double get percentComplete {
    if (totalBytes == 0) return 0.0;
    return (downloadedBytes / totalBytes) * 100;
  }

  DownloadItem copyWith({
    String? id,
    String? nzbPath,
    String? filename,
    String? subject,
    String? poster,
    DownloadState? state,
    int? totalBytes,
    int? downloadedBytes,
    int? totalSegments,
    int? completedSegments,
    String? outputPath,
    String? errorMessage,
    double? health,
    int? lastPosition,
    DateTime? createdAt,
    DateTime? completedAt,
    List<String>? groups,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      nzbPath: nzbPath ?? this.nzbPath,
      filename: filename ?? this.filename,
      subject: subject ?? this.subject,
      poster: poster ?? this.poster,
      state: state ?? this.state,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalSegments: totalSegments ?? this.totalSegments,
      completedSegments: completedSegments ?? this.completedSegments,
      outputPath: outputPath ?? this.outputPath,
      errorMessage: errorMessage ?? this.errorMessage,
      health: health ?? this.health,
      lastPosition: lastPosition ?? this.lastPosition,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      groups: groups ?? this.groups,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nzbPath,
        filename,
        subject,
        poster,
        state,
        totalBytes,
        downloadedBytes,
        totalSegments,
        completedSegments,
        outputPath,
        errorMessage,
        health,
        lastPosition,
        createdAt,
        completedAt,
        groups,
      ];
}
