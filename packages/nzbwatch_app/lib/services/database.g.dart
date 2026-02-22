// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ServerConfigsTable extends ServerConfigs
    with TableInfo<$ServerConfigsTable, ServerConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
      'host', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
      'port', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _useSslMeta = const VerificationMeta('useSsl');
  @override
  late final GeneratedColumn<bool> useSsl = GeneratedColumn<bool>(
      'use_ssl', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("use_ssl" IN (0, 1))'));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _maxConnectionsMeta =
      const VerificationMeta('maxConnections');
  @override
  late final GeneratedColumn<int> maxConnections = GeneratedColumn<int>(
      'max_connections', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        host,
        port,
        useSsl,
        username,
        password,
        maxConnections,
        priority,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_configs';
  @override
  VerificationContext validateIntegrity(Insertable<ServerConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
          _hostMeta, host.isAcceptableOrUnknown(data['host']!, _hostMeta));
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
          _portMeta, port.isAcceptableOrUnknown(data['port']!, _portMeta));
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('use_ssl')) {
      context.handle(_useSslMeta,
          useSsl.isAcceptableOrUnknown(data['use_ssl']!, _useSslMeta));
    } else if (isInserting) {
      context.missing(_useSslMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('max_connections')) {
      context.handle(
          _maxConnectionsMeta,
          maxConnections.isAcceptableOrUnknown(
              data['max_connections']!, _maxConnectionsMeta));
    } else if (isInserting) {
      context.missing(_maxConnectionsMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServerConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerConfig(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      host: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host'])!,
      port: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}port'])!,
      useSsl: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}use_ssl'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      maxConnections: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_connections'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ServerConfigsTable createAlias(String alias) {
    return $ServerConfigsTable(attachedDatabase, alias);
  }
}

class ServerConfig extends DataClass implements Insertable<ServerConfig> {
  final String id;
  final String name;
  final String host;
  final int port;
  final bool useSsl;
  final String username;
  final String password;
  final int maxConnections;
  final int priority;
  final DateTime createdAt;
  const ServerConfig(
      {required this.id,
      required this.name,
      required this.host,
      required this.port,
      required this.useSsl,
      required this.username,
      required this.password,
      required this.maxConnections,
      required this.priority,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    map['use_ssl'] = Variable<bool>(useSsl);
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    map['max_connections'] = Variable<int>(maxConnections);
    map['priority'] = Variable<int>(priority);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServerConfigsCompanion toCompanion(bool nullToAbsent) {
    return ServerConfigsCompanion(
      id: Value(id),
      name: Value(name),
      host: Value(host),
      port: Value(port),
      useSsl: Value(useSsl),
      username: Value(username),
      password: Value(password),
      maxConnections: Value(maxConnections),
      priority: Value(priority),
      createdAt: Value(createdAt),
    );
  }

  factory ServerConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerConfig(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      useSsl: serializer.fromJson<bool>(json['useSsl']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      maxConnections: serializer.fromJson<int>(json['maxConnections']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'useSsl': serializer.toJson<bool>(useSsl),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'maxConnections': serializer.toJson<int>(maxConnections),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServerConfig copyWith(
          {String? id,
          String? name,
          String? host,
          int? port,
          bool? useSsl,
          String? username,
          String? password,
          int? maxConnections,
          int? priority,
          DateTime? createdAt}) =>
      ServerConfig(
        id: id ?? this.id,
        name: name ?? this.name,
        host: host ?? this.host,
        port: port ?? this.port,
        useSsl: useSsl ?? this.useSsl,
        username: username ?? this.username,
        password: password ?? this.password,
        maxConnections: maxConnections ?? this.maxConnections,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
      );
  ServerConfig copyWithCompanion(ServerConfigsCompanion data) {
    return ServerConfig(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      useSsl: data.useSsl.present ? data.useSsl.value : this.useSsl,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      maxConnections: data.maxConnections.present
          ? data.maxConnections.value
          : this.maxConnections,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerConfig(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('useSsl: $useSsl, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('maxConnections: $maxConnections, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, host, port, useSsl, username,
      password, maxConnections, priority, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerConfig &&
          other.id == this.id &&
          other.name == this.name &&
          other.host == this.host &&
          other.port == this.port &&
          other.useSsl == this.useSsl &&
          other.username == this.username &&
          other.password == this.password &&
          other.maxConnections == this.maxConnections &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt);
}

class ServerConfigsCompanion extends UpdateCompanion<ServerConfig> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> host;
  final Value<int> port;
  final Value<bool> useSsl;
  final Value<String> username;
  final Value<String> password;
  final Value<int> maxConnections;
  final Value<int> priority;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ServerConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.useSsl = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.maxConnections = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerConfigsCompanion.insert({
    required String id,
    required String name,
    required String host,
    required int port,
    required bool useSsl,
    required String username,
    required String password,
    required int maxConnections,
    required int priority,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        host = Value(host),
        port = Value(port),
        useSsl = Value(useSsl),
        username = Value(username),
        password = Value(password),
        maxConnections = Value(maxConnections),
        priority = Value(priority),
        createdAt = Value(createdAt);
  static Insertable<ServerConfig> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? host,
    Expression<int>? port,
    Expression<bool>? useSsl,
    Expression<String>? username,
    Expression<String>? password,
    Expression<int>? maxConnections,
    Expression<int>? priority,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (useSsl != null) 'use_ssl': useSsl,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (maxConnections != null) 'max_connections': maxConnections,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerConfigsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? host,
      Value<int>? port,
      Value<bool>? useSsl,
      Value<String>? username,
      Value<String>? password,
      Value<int>? maxConnections,
      Value<int>? priority,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ServerConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      useSsl: useSsl ?? this.useSsl,
      username: username ?? this.username,
      password: password ?? this.password,
      maxConnections: maxConnections ?? this.maxConnections,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (useSsl.present) {
      map['use_ssl'] = Variable<bool>(useSsl.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (maxConnections.present) {
      map['max_connections'] = Variable<int>(maxConnections.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerConfigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('useSsl: $useSsl, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('maxConnections: $maxConnections, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nzbPathMeta =
      const VerificationMeta('nzbPath');
  @override
  late final GeneratedColumn<String> nzbPath = GeneratedColumn<String>(
      'nzb_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filenameMeta =
      const VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _posterMeta = const VerificationMeta('poster');
  @override
  late final GeneratedColumn<String> poster = GeneratedColumn<String>(
      'poster', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DownloadStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DownloadStatus>($DownloadsTable.$converterstatus);
  static const VerificationMeta _totalBytesMeta =
      const VerificationMeta('totalBytes');
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
      'total_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _downloadedBytesMeta =
      const VerificationMeta('downloadedBytes');
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
      'downloaded_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalSegmentsMeta =
      const VerificationMeta('totalSegments');
  @override
  late final GeneratedColumn<int> totalSegments = GeneratedColumn<int>(
      'total_segments', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedSegmentsMeta =
      const VerificationMeta('completedSegments');
  @override
  late final GeneratedColumn<int> completedSegments = GeneratedColumn<int>(
      'completed_segments', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _outputPathMeta =
      const VerificationMeta('outputPath');
  @override
  late final GeneratedColumn<String> outputPath = GeneratedColumn<String>(
      'output_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastPositionMeta =
      const VerificationMeta('lastPosition');
  @override
  late final GeneratedColumn<int> lastPosition = GeneratedColumn<int>(
      'last_position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _healthMeta = const VerificationMeta('health');
  @override
  late final GeneratedColumn<double> health = GeneratedColumn<double>(
      'health', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(100.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nzbPath,
        filename,
        subject,
        poster,
        status,
        totalBytes,
        downloadedBytes,
        totalSegments,
        completedSegments,
        outputPath,
        errorMessage,
        lastPosition,
        health,
        createdAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(Insertable<Download> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nzb_path')) {
      context.handle(_nzbPathMeta,
          nzbPath.isAcceptableOrUnknown(data['nzb_path']!, _nzbPathMeta));
    } else if (isInserting) {
      context.missing(_nzbPathMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    }
    if (data.containsKey('poster')) {
      context.handle(_posterMeta,
          poster.isAcceptableOrUnknown(data['poster']!, _posterMeta));
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
          _totalBytesMeta,
          totalBytes.isAcceptableOrUnknown(
              data['total_bytes']!, _totalBytesMeta));
    } else if (isInserting) {
      context.missing(_totalBytesMeta);
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
          _downloadedBytesMeta,
          downloadedBytes.isAcceptableOrUnknown(
              data['downloaded_bytes']!, _downloadedBytesMeta));
    } else if (isInserting) {
      context.missing(_downloadedBytesMeta);
    }
    if (data.containsKey('total_segments')) {
      context.handle(
          _totalSegmentsMeta,
          totalSegments.isAcceptableOrUnknown(
              data['total_segments']!, _totalSegmentsMeta));
    } else if (isInserting) {
      context.missing(_totalSegmentsMeta);
    }
    if (data.containsKey('completed_segments')) {
      context.handle(
          _completedSegmentsMeta,
          completedSegments.isAcceptableOrUnknown(
              data['completed_segments']!, _completedSegmentsMeta));
    } else if (isInserting) {
      context.missing(_completedSegmentsMeta);
    }
    if (data.containsKey('output_path')) {
      context.handle(
          _outputPathMeta,
          outputPath.isAcceptableOrUnknown(
              data['output_path']!, _outputPathMeta));
    } else if (isInserting) {
      context.missing(_outputPathMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('last_position')) {
      context.handle(
          _lastPositionMeta,
          lastPosition.isAcceptableOrUnknown(
              data['last_position']!, _lastPositionMeta));
    }
    if (data.containsKey('health')) {
      context.handle(_healthMeta,
          health.isAcceptableOrUnknown(data['health']!, _healthMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Download map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Download(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nzbPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nzb_path'])!,
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject']),
      poster: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poster']),
      status: $DownloadsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      totalBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_bytes'])!,
      downloadedBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}downloaded_bytes'])!,
      totalSegments: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_segments'])!,
      completedSegments: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}completed_segments'])!,
      outputPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}output_path'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      lastPosition: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_position'])!,
      health: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}health'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DownloadStatus, int, int> $converterstatus =
      const EnumIndexConverter<DownloadStatus>(DownloadStatus.values);
}

class Download extends DataClass implements Insertable<Download> {
  final String id;
  final String nzbPath;
  final String filename;
  final String? subject;
  final String? poster;
  final DownloadStatus status;
  final int totalBytes;
  final int downloadedBytes;
  final int totalSegments;
  final int completedSegments;
  final String outputPath;
  final String? errorMessage;
  final int lastPosition;
  final double health;
  final DateTime createdAt;
  final DateTime? completedAt;
  const Download(
      {required this.id,
      required this.nzbPath,
      required this.filename,
      this.subject,
      this.poster,
      required this.status,
      required this.totalBytes,
      required this.downloadedBytes,
      required this.totalSegments,
      required this.completedSegments,
      required this.outputPath,
      this.errorMessage,
      required this.lastPosition,
      required this.health,
      required this.createdAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nzb_path'] = Variable<String>(nzbPath);
    map['filename'] = Variable<String>(filename);
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || poster != null) {
      map['poster'] = Variable<String>(poster);
    }
    {
      map['status'] =
          Variable<int>($DownloadsTable.$converterstatus.toSql(status));
    }
    map['total_bytes'] = Variable<int>(totalBytes);
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['total_segments'] = Variable<int>(totalSegments);
    map['completed_segments'] = Variable<int>(completedSegments);
    map['output_path'] = Variable<String>(outputPath);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['last_position'] = Variable<int>(lastPosition);
    map['health'] = Variable<double>(health);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      id: Value(id),
      nzbPath: Value(nzbPath),
      filename: Value(filename),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      poster:
          poster == null && nullToAbsent ? const Value.absent() : Value(poster),
      status: Value(status),
      totalBytes: Value(totalBytes),
      downloadedBytes: Value(downloadedBytes),
      totalSegments: Value(totalSegments),
      completedSegments: Value(completedSegments),
      outputPath: Value(outputPath),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      lastPosition: Value(lastPosition),
      health: Value(health),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Download.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Download(
      id: serializer.fromJson<String>(json['id']),
      nzbPath: serializer.fromJson<String>(json['nzbPath']),
      filename: serializer.fromJson<String>(json['filename']),
      subject: serializer.fromJson<String?>(json['subject']),
      poster: serializer.fromJson<String?>(json['poster']),
      status: $DownloadsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      totalSegments: serializer.fromJson<int>(json['totalSegments']),
      completedSegments: serializer.fromJson<int>(json['completedSegments']),
      outputPath: serializer.fromJson<String>(json['outputPath']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      lastPosition: serializer.fromJson<int>(json['lastPosition']),
      health: serializer.fromJson<double>(json['health']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nzbPath': serializer.toJson<String>(nzbPath),
      'filename': serializer.toJson<String>(filename),
      'subject': serializer.toJson<String?>(subject),
      'poster': serializer.toJson<String?>(poster),
      'status': serializer
          .toJson<int>($DownloadsTable.$converterstatus.toJson(status)),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'totalSegments': serializer.toJson<int>(totalSegments),
      'completedSegments': serializer.toJson<int>(completedSegments),
      'outputPath': serializer.toJson<String>(outputPath),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'lastPosition': serializer.toJson<int>(lastPosition),
      'health': serializer.toJson<double>(health),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Download copyWith(
          {String? id,
          String? nzbPath,
          String? filename,
          Value<String?> subject = const Value.absent(),
          Value<String?> poster = const Value.absent(),
          DownloadStatus? status,
          int? totalBytes,
          int? downloadedBytes,
          int? totalSegments,
          int? completedSegments,
          String? outputPath,
          Value<String?> errorMessage = const Value.absent(),
          int? lastPosition,
          double? health,
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      Download(
        id: id ?? this.id,
        nzbPath: nzbPath ?? this.nzbPath,
        filename: filename ?? this.filename,
        subject: subject.present ? subject.value : this.subject,
        poster: poster.present ? poster.value : this.poster,
        status: status ?? this.status,
        totalBytes: totalBytes ?? this.totalBytes,
        downloadedBytes: downloadedBytes ?? this.downloadedBytes,
        totalSegments: totalSegments ?? this.totalSegments,
        completedSegments: completedSegments ?? this.completedSegments,
        outputPath: outputPath ?? this.outputPath,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        lastPosition: lastPosition ?? this.lastPosition,
        health: health ?? this.health,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  Download copyWithCompanion(DownloadsCompanion data) {
    return Download(
      id: data.id.present ? data.id.value : this.id,
      nzbPath: data.nzbPath.present ? data.nzbPath.value : this.nzbPath,
      filename: data.filename.present ? data.filename.value : this.filename,
      subject: data.subject.present ? data.subject.value : this.subject,
      poster: data.poster.present ? data.poster.value : this.poster,
      status: data.status.present ? data.status.value : this.status,
      totalBytes:
          data.totalBytes.present ? data.totalBytes.value : this.totalBytes,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      totalSegments: data.totalSegments.present
          ? data.totalSegments.value
          : this.totalSegments,
      completedSegments: data.completedSegments.present
          ? data.completedSegments.value
          : this.completedSegments,
      outputPath:
          data.outputPath.present ? data.outputPath.value : this.outputPath,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      lastPosition: data.lastPosition.present
          ? data.lastPosition.value
          : this.lastPosition,
      health: data.health.present ? data.health.value : this.health,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('id: $id, ')
          ..write('nzbPath: $nzbPath, ')
          ..write('filename: $filename, ')
          ..write('subject: $subject, ')
          ..write('poster: $poster, ')
          ..write('status: $status, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('totalSegments: $totalSegments, ')
          ..write('completedSegments: $completedSegments, ')
          ..write('outputPath: $outputPath, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('health: $health, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nzbPath,
      filename,
      subject,
      poster,
      status,
      totalBytes,
      downloadedBytes,
      totalSegments,
      completedSegments,
      outputPath,
      errorMessage,
      lastPosition,
      health,
      createdAt,
      completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Download &&
          other.id == this.id &&
          other.nzbPath == this.nzbPath &&
          other.filename == this.filename &&
          other.subject == this.subject &&
          other.poster == this.poster &&
          other.status == this.status &&
          other.totalBytes == this.totalBytes &&
          other.downloadedBytes == this.downloadedBytes &&
          other.totalSegments == this.totalSegments &&
          other.completedSegments == this.completedSegments &&
          other.outputPath == this.outputPath &&
          other.errorMessage == this.errorMessage &&
          other.lastPosition == this.lastPosition &&
          other.health == this.health &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<String> id;
  final Value<String> nzbPath;
  final Value<String> filename;
  final Value<String?> subject;
  final Value<String?> poster;
  final Value<DownloadStatus> status;
  final Value<int> totalBytes;
  final Value<int> downloadedBytes;
  final Value<int> totalSegments;
  final Value<int> completedSegments;
  final Value<String> outputPath;
  final Value<String?> errorMessage;
  final Value<int> lastPosition;
  final Value<double> health;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const DownloadsCompanion({
    this.id = const Value.absent(),
    this.nzbPath = const Value.absent(),
    this.filename = const Value.absent(),
    this.subject = const Value.absent(),
    this.poster = const Value.absent(),
    this.status = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.totalSegments = const Value.absent(),
    this.completedSegments = const Value.absent(),
    this.outputPath = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.health = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadsCompanion.insert({
    required String id,
    required String nzbPath,
    required String filename,
    this.subject = const Value.absent(),
    this.poster = const Value.absent(),
    required DownloadStatus status,
    required int totalBytes,
    required int downloadedBytes,
    required int totalSegments,
    required int completedSegments,
    required String outputPath,
    this.errorMessage = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.health = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nzbPath = Value(nzbPath),
        filename = Value(filename),
        status = Value(status),
        totalBytes = Value(totalBytes),
        downloadedBytes = Value(downloadedBytes),
        totalSegments = Value(totalSegments),
        completedSegments = Value(completedSegments),
        outputPath = Value(outputPath),
        createdAt = Value(createdAt);
  static Insertable<Download> custom({
    Expression<String>? id,
    Expression<String>? nzbPath,
    Expression<String>? filename,
    Expression<String>? subject,
    Expression<String>? poster,
    Expression<int>? status,
    Expression<int>? totalBytes,
    Expression<int>? downloadedBytes,
    Expression<int>? totalSegments,
    Expression<int>? completedSegments,
    Expression<String>? outputPath,
    Expression<String>? errorMessage,
    Expression<int>? lastPosition,
    Expression<double>? health,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nzbPath != null) 'nzb_path': nzbPath,
      if (filename != null) 'filename': filename,
      if (subject != null) 'subject': subject,
      if (poster != null) 'poster': poster,
      if (status != null) 'status': status,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (totalSegments != null) 'total_segments': totalSegments,
      if (completedSegments != null) 'completed_segments': completedSegments,
      if (outputPath != null) 'output_path': outputPath,
      if (errorMessage != null) 'error_message': errorMessage,
      if (lastPosition != null) 'last_position': lastPosition,
      if (health != null) 'health': health,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadsCompanion copyWith(
      {Value<String>? id,
      Value<String>? nzbPath,
      Value<String>? filename,
      Value<String?>? subject,
      Value<String?>? poster,
      Value<DownloadStatus>? status,
      Value<int>? totalBytes,
      Value<int>? downloadedBytes,
      Value<int>? totalSegments,
      Value<int>? completedSegments,
      Value<String>? outputPath,
      Value<String?>? errorMessage,
      Value<int>? lastPosition,
      Value<double>? health,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return DownloadsCompanion(
      id: id ?? this.id,
      nzbPath: nzbPath ?? this.nzbPath,
      filename: filename ?? this.filename,
      subject: subject ?? this.subject,
      poster: poster ?? this.poster,
      status: status ?? this.status,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalSegments: totalSegments ?? this.totalSegments,
      completedSegments: completedSegments ?? this.completedSegments,
      outputPath: outputPath ?? this.outputPath,
      errorMessage: errorMessage ?? this.errorMessage,
      lastPosition: lastPosition ?? this.lastPosition,
      health: health ?? this.health,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nzbPath.present) {
      map['nzb_path'] = Variable<String>(nzbPath.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (poster.present) {
      map['poster'] = Variable<String>(poster.value);
    }
    if (status.present) {
      map['status'] =
          Variable<int>($DownloadsTable.$converterstatus.toSql(status.value));
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (totalSegments.present) {
      map['total_segments'] = Variable<int>(totalSegments.value);
    }
    if (completedSegments.present) {
      map['completed_segments'] = Variable<int>(completedSegments.value);
    }
    if (outputPath.present) {
      map['output_path'] = Variable<String>(outputPath.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (lastPosition.present) {
      map['last_position'] = Variable<int>(lastPosition.value);
    }
    if (health.present) {
      map['health'] = Variable<double>(health.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('id: $id, ')
          ..write('nzbPath: $nzbPath, ')
          ..write('filename: $filename, ')
          ..write('subject: $subject, ')
          ..write('poster: $poster, ')
          ..write('status: $status, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('totalSegments: $totalSegments, ')
          ..write('completedSegments: $completedSegments, ')
          ..write('outputPath: $outputPath, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('health: $health, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadFilesTable extends DownloadFiles
    with TableInfo<$DownloadFilesTable, DownloadFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downloadIdMeta =
      const VerificationMeta('downloadId');
  @override
  late final GeneratedColumn<String> downloadId = GeneratedColumn<String>(
      'download_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES downloads (id) ON DELETE CASCADE'));
  static const VerificationMeta _filenameMeta =
      const VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, downloadId, filename, subject, size];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_files';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('download_id')) {
      context.handle(
          _downloadIdMeta,
          downloadId.isAcceptableOrUnknown(
              data['download_id']!, _downloadIdMeta));
    } else if (isInserting) {
      context.missing(_downloadIdMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadFile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      downloadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}download_id'])!,
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size'])!,
    );
  }

  @override
  $DownloadFilesTable createAlias(String alias) {
    return $DownloadFilesTable(attachedDatabase, alias);
  }
}

class DownloadFile extends DataClass implements Insertable<DownloadFile> {
  final String id;
  final String downloadId;
  final String filename;
  final String subject;
  final int size;
  const DownloadFile(
      {required this.id,
      required this.downloadId,
      required this.filename,
      required this.subject,
      required this.size});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['download_id'] = Variable<String>(downloadId);
    map['filename'] = Variable<String>(filename);
    map['subject'] = Variable<String>(subject);
    map['size'] = Variable<int>(size);
    return map;
  }

  DownloadFilesCompanion toCompanion(bool nullToAbsent) {
    return DownloadFilesCompanion(
      id: Value(id),
      downloadId: Value(downloadId),
      filename: Value(filename),
      subject: Value(subject),
      size: Value(size),
    );
  }

  factory DownloadFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadFile(
      id: serializer.fromJson<String>(json['id']),
      downloadId: serializer.fromJson<String>(json['downloadId']),
      filename: serializer.fromJson<String>(json['filename']),
      subject: serializer.fromJson<String>(json['subject']),
      size: serializer.fromJson<int>(json['size']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'downloadId': serializer.toJson<String>(downloadId),
      'filename': serializer.toJson<String>(filename),
      'subject': serializer.toJson<String>(subject),
      'size': serializer.toJson<int>(size),
    };
  }

  DownloadFile copyWith(
          {String? id,
          String? downloadId,
          String? filename,
          String? subject,
          int? size}) =>
      DownloadFile(
        id: id ?? this.id,
        downloadId: downloadId ?? this.downloadId,
        filename: filename ?? this.filename,
        subject: subject ?? this.subject,
        size: size ?? this.size,
      );
  DownloadFile copyWithCompanion(DownloadFilesCompanion data) {
    return DownloadFile(
      id: data.id.present ? data.id.value : this.id,
      downloadId:
          data.downloadId.present ? data.downloadId.value : this.downloadId,
      filename: data.filename.present ? data.filename.value : this.filename,
      subject: data.subject.present ? data.subject.value : this.subject,
      size: data.size.present ? data.size.value : this.size,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadFile(')
          ..write('id: $id, ')
          ..write('downloadId: $downloadId, ')
          ..write('filename: $filename, ')
          ..write('subject: $subject, ')
          ..write('size: $size')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, downloadId, filename, subject, size);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadFile &&
          other.id == this.id &&
          other.downloadId == this.downloadId &&
          other.filename == this.filename &&
          other.subject == this.subject &&
          other.size == this.size);
}

class DownloadFilesCompanion extends UpdateCompanion<DownloadFile> {
  final Value<String> id;
  final Value<String> downloadId;
  final Value<String> filename;
  final Value<String> subject;
  final Value<int> size;
  final Value<int> rowid;
  const DownloadFilesCompanion({
    this.id = const Value.absent(),
    this.downloadId = const Value.absent(),
    this.filename = const Value.absent(),
    this.subject = const Value.absent(),
    this.size = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadFilesCompanion.insert({
    required String id,
    required String downloadId,
    required String filename,
    required String subject,
    required int size,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        downloadId = Value(downloadId),
        filename = Value(filename),
        subject = Value(subject),
        size = Value(size);
  static Insertable<DownloadFile> custom({
    Expression<String>? id,
    Expression<String>? downloadId,
    Expression<String>? filename,
    Expression<String>? subject,
    Expression<int>? size,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (downloadId != null) 'download_id': downloadId,
      if (filename != null) 'filename': filename,
      if (subject != null) 'subject': subject,
      if (size != null) 'size': size,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadFilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? downloadId,
      Value<String>? filename,
      Value<String>? subject,
      Value<int>? size,
      Value<int>? rowid}) {
    return DownloadFilesCompanion(
      id: id ?? this.id,
      downloadId: downloadId ?? this.downloadId,
      filename: filename ?? this.filename,
      subject: subject ?? this.subject,
      size: size ?? this.size,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (downloadId.present) {
      map['download_id'] = Variable<String>(downloadId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadFilesCompanion(')
          ..write('id: $id, ')
          ..write('downloadId: $downloadId, ')
          ..write('filename: $filename, ')
          ..write('subject: $subject, ')
          ..write('size: $size, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SegmentsTable extends Segments with TableInfo<$SegmentsTable, Segment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downloadIdMeta =
      const VerificationMeta('downloadId');
  @override
  late final GeneratedColumn<String> downloadId = GeneratedColumn<String>(
      'download_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES downloads (id) ON DELETE CASCADE'));
  static const VerificationMeta _fileIdMeta = const VerificationMeta('fileId');
  @override
  late final GeneratedColumn<String> fileId = GeneratedColumn<String>(
      'file_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES download_files (id) ON DELETE CASCADE'));
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isDownloadedMeta =
      const VerificationMeta('isDownloaded');
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
      'is_downloaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_downloaded" IN (0, 1))'));
  static const VerificationMeta _retriesMeta =
      const VerificationMeta('retries');
  @override
  late final GeneratedColumn<int> retries = GeneratedColumn<int>(
      'retries', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
      'downloaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        downloadId,
        fileId,
        number,
        messageId,
        size,
        isDownloaded,
        retries,
        downloadedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'segments';
  @override
  VerificationContext validateIntegrity(Insertable<Segment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('download_id')) {
      context.handle(
          _downloadIdMeta,
          downloadId.isAcceptableOrUnknown(
              data['download_id']!, _downloadIdMeta));
    } else if (isInserting) {
      context.missing(_downloadIdMeta);
    }
    if (data.containsKey('file_id')) {
      context.handle(_fileIdMeta,
          fileId.isAcceptableOrUnknown(data['file_id']!, _fileIdMeta));
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
          _isDownloadedMeta,
          isDownloaded.isAcceptableOrUnknown(
              data['is_downloaded']!, _isDownloadedMeta));
    } else if (isInserting) {
      context.missing(_isDownloadedMeta);
    }
    if (data.containsKey('retries')) {
      context.handle(_retriesMeta,
          retries.isAcceptableOrUnknown(data['retries']!, _retriesMeta));
    } else if (isInserting) {
      context.missing(_retriesMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Segment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Segment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      downloadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}download_id'])!,
      fileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_id']),
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number'])!,
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size'])!,
      isDownloaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_downloaded'])!,
      retries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retries'])!,
      downloadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}downloaded_at']),
    );
  }

  @override
  $SegmentsTable createAlias(String alias) {
    return $SegmentsTable(attachedDatabase, alias);
  }
}

class Segment extends DataClass implements Insertable<Segment> {
  final String id;
  final String downloadId;
  final String? fileId;
  final int number;
  final String messageId;
  final int size;
  final bool isDownloaded;
  final int retries;
  final DateTime? downloadedAt;
  const Segment(
      {required this.id,
      required this.downloadId,
      this.fileId,
      required this.number,
      required this.messageId,
      required this.size,
      required this.isDownloaded,
      required this.retries,
      this.downloadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['download_id'] = Variable<String>(downloadId);
    if (!nullToAbsent || fileId != null) {
      map['file_id'] = Variable<String>(fileId);
    }
    map['number'] = Variable<int>(number);
    map['message_id'] = Variable<String>(messageId);
    map['size'] = Variable<int>(size);
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    map['retries'] = Variable<int>(retries);
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    return map;
  }

  SegmentsCompanion toCompanion(bool nullToAbsent) {
    return SegmentsCompanion(
      id: Value(id),
      downloadId: Value(downloadId),
      fileId:
          fileId == null && nullToAbsent ? const Value.absent() : Value(fileId),
      number: Value(number),
      messageId: Value(messageId),
      size: Value(size),
      isDownloaded: Value(isDownloaded),
      retries: Value(retries),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
    );
  }

  factory Segment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Segment(
      id: serializer.fromJson<String>(json['id']),
      downloadId: serializer.fromJson<String>(json['downloadId']),
      fileId: serializer.fromJson<String?>(json['fileId']),
      number: serializer.fromJson<int>(json['number']),
      messageId: serializer.fromJson<String>(json['messageId']),
      size: serializer.fromJson<int>(json['size']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
      retries: serializer.fromJson<int>(json['retries']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'downloadId': serializer.toJson<String>(downloadId),
      'fileId': serializer.toJson<String?>(fileId),
      'number': serializer.toJson<int>(number),
      'messageId': serializer.toJson<String>(messageId),
      'size': serializer.toJson<int>(size),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
      'retries': serializer.toJson<int>(retries),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
    };
  }

  Segment copyWith(
          {String? id,
          String? downloadId,
          Value<String?> fileId = const Value.absent(),
          int? number,
          String? messageId,
          int? size,
          bool? isDownloaded,
          int? retries,
          Value<DateTime?> downloadedAt = const Value.absent()}) =>
      Segment(
        id: id ?? this.id,
        downloadId: downloadId ?? this.downloadId,
        fileId: fileId.present ? fileId.value : this.fileId,
        number: number ?? this.number,
        messageId: messageId ?? this.messageId,
        size: size ?? this.size,
        isDownloaded: isDownloaded ?? this.isDownloaded,
        retries: retries ?? this.retries,
        downloadedAt:
            downloadedAt.present ? downloadedAt.value : this.downloadedAt,
      );
  Segment copyWithCompanion(SegmentsCompanion data) {
    return Segment(
      id: data.id.present ? data.id.value : this.id,
      downloadId:
          data.downloadId.present ? data.downloadId.value : this.downloadId,
      fileId: data.fileId.present ? data.fileId.value : this.fileId,
      number: data.number.present ? data.number.value : this.number,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      size: data.size.present ? data.size.value : this.size,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
      retries: data.retries.present ? data.retries.value : this.retries,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Segment(')
          ..write('id: $id, ')
          ..write('downloadId: $downloadId, ')
          ..write('fileId: $fileId, ')
          ..write('number: $number, ')
          ..write('messageId: $messageId, ')
          ..write('size: $size, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('retries: $retries, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, downloadId, fileId, number, messageId,
      size, isDownloaded, retries, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Segment &&
          other.id == this.id &&
          other.downloadId == this.downloadId &&
          other.fileId == this.fileId &&
          other.number == this.number &&
          other.messageId == this.messageId &&
          other.size == this.size &&
          other.isDownloaded == this.isDownloaded &&
          other.retries == this.retries &&
          other.downloadedAt == this.downloadedAt);
}

class SegmentsCompanion extends UpdateCompanion<Segment> {
  final Value<String> id;
  final Value<String> downloadId;
  final Value<String?> fileId;
  final Value<int> number;
  final Value<String> messageId;
  final Value<int> size;
  final Value<bool> isDownloaded;
  final Value<int> retries;
  final Value<DateTime?> downloadedAt;
  final Value<int> rowid;
  const SegmentsCompanion({
    this.id = const Value.absent(),
    this.downloadId = const Value.absent(),
    this.fileId = const Value.absent(),
    this.number = const Value.absent(),
    this.messageId = const Value.absent(),
    this.size = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.retries = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SegmentsCompanion.insert({
    required String id,
    required String downloadId,
    this.fileId = const Value.absent(),
    required int number,
    required String messageId,
    required int size,
    required bool isDownloaded,
    required int retries,
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        downloadId = Value(downloadId),
        number = Value(number),
        messageId = Value(messageId),
        size = Value(size),
        isDownloaded = Value(isDownloaded),
        retries = Value(retries);
  static Insertable<Segment> custom({
    Expression<String>? id,
    Expression<String>? downloadId,
    Expression<String>? fileId,
    Expression<int>? number,
    Expression<String>? messageId,
    Expression<int>? size,
    Expression<bool>? isDownloaded,
    Expression<int>? retries,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (downloadId != null) 'download_id': downloadId,
      if (fileId != null) 'file_id': fileId,
      if (number != null) 'number': number,
      if (messageId != null) 'message_id': messageId,
      if (size != null) 'size': size,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (retries != null) 'retries': retries,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SegmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? downloadId,
      Value<String?>? fileId,
      Value<int>? number,
      Value<String>? messageId,
      Value<int>? size,
      Value<bool>? isDownloaded,
      Value<int>? retries,
      Value<DateTime?>? downloadedAt,
      Value<int>? rowid}) {
    return SegmentsCompanion(
      id: id ?? this.id,
      downloadId: downloadId ?? this.downloadId,
      fileId: fileId ?? this.fileId,
      number: number ?? this.number,
      messageId: messageId ?? this.messageId,
      size: size ?? this.size,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      retries: retries ?? this.retries,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (downloadId.present) {
      map['download_id'] = Variable<String>(downloadId.value);
    }
    if (fileId.present) {
      map['file_id'] = Variable<String>(fileId.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (retries.present) {
      map['retries'] = Variable<int>(retries.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SegmentsCompanion(')
          ..write('id: $id, ')
          ..write('downloadId: $downloadId, ')
          ..write('fileId: $fileId, ')
          ..write('number: $number, ')
          ..write('messageId: $messageId, ')
          ..write('size: $size, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('retries: $retries, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadGroupsTable extends DownloadGroups
    with TableInfo<$DownloadGroupsTable, DownloadGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downloadIdMeta =
      const VerificationMeta('downloadId');
  @override
  late final GeneratedColumn<String> downloadId = GeneratedColumn<String>(
      'download_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES downloads (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, downloadId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_groups';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadGroup> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('download_id')) {
      context.handle(
          _downloadIdMeta,
          downloadId.isAcceptableOrUnknown(
              data['download_id']!, _downloadIdMeta));
    } else if (isInserting) {
      context.missing(_downloadIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadGroup(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      downloadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}download_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $DownloadGroupsTable createAlias(String alias) {
    return $DownloadGroupsTable(attachedDatabase, alias);
  }
}

class DownloadGroup extends DataClass implements Insertable<DownloadGroup> {
  final String id;
  final String downloadId;
  final String name;
  const DownloadGroup(
      {required this.id, required this.downloadId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['download_id'] = Variable<String>(downloadId);
    map['name'] = Variable<String>(name);
    return map;
  }

  DownloadGroupsCompanion toCompanion(bool nullToAbsent) {
    return DownloadGroupsCompanion(
      id: Value(id),
      downloadId: Value(downloadId),
      name: Value(name),
    );
  }

  factory DownloadGroup.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadGroup(
      id: serializer.fromJson<String>(json['id']),
      downloadId: serializer.fromJson<String>(json['downloadId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'downloadId': serializer.toJson<String>(downloadId),
      'name': serializer.toJson<String>(name),
    };
  }

  DownloadGroup copyWith({String? id, String? downloadId, String? name}) =>
      DownloadGroup(
        id: id ?? this.id,
        downloadId: downloadId ?? this.downloadId,
        name: name ?? this.name,
      );
  DownloadGroup copyWithCompanion(DownloadGroupsCompanion data) {
    return DownloadGroup(
      id: data.id.present ? data.id.value : this.id,
      downloadId:
          data.downloadId.present ? data.downloadId.value : this.downloadId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadGroup(')
          ..write('id: $id, ')
          ..write('downloadId: $downloadId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, downloadId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadGroup &&
          other.id == this.id &&
          other.downloadId == this.downloadId &&
          other.name == this.name);
}

class DownloadGroupsCompanion extends UpdateCompanion<DownloadGroup> {
  final Value<String> id;
  final Value<String> downloadId;
  final Value<String> name;
  final Value<int> rowid;
  const DownloadGroupsCompanion({
    this.id = const Value.absent(),
    this.downloadId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadGroupsCompanion.insert({
    required String id,
    required String downloadId,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        downloadId = Value(downloadId),
        name = Value(name);
  static Insertable<DownloadGroup> custom({
    Expression<String>? id,
    Expression<String>? downloadId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (downloadId != null) 'download_id': downloadId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadGroupsCompanion copyWith(
      {Value<String>? id,
      Value<String>? downloadId,
      Value<String>? name,
      Value<int>? rowid}) {
    return DownloadGroupsCompanion(
      id: id ?? this.id,
      downloadId: downloadId ?? this.downloadId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (downloadId.present) {
      map['download_id'] = Variable<String>(downloadId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadGroupsCompanion(')
          ..write('id: $id, ')
          ..write('downloadId: $downloadId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NewznabIndexersTable extends NewznabIndexers
    with TableInfo<$NewznabIndexersTable, NewznabIndexer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NewznabIndexersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
      'host', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
      'api_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, host, apiKey, enabled, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'newznab_indexers';
  @override
  VerificationContext validateIntegrity(Insertable<NewznabIndexer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
          _hostMeta, host.isAcceptableOrUnknown(data['host']!, _hostMeta));
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('api_key')) {
      context.handle(_apiKeyMeta,
          apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta));
    } else if (isInserting) {
      context.missing(_apiKeyMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NewznabIndexer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NewznabIndexer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      host: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host'])!,
      apiKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}api_key'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NewznabIndexersTable createAlias(String alias) {
    return $NewznabIndexersTable(attachedDatabase, alias);
  }
}

class NewznabIndexer extends DataClass implements Insertable<NewznabIndexer> {
  final String id;
  final String name;
  final String host;
  final String apiKey;
  final bool enabled;
  final DateTime createdAt;
  const NewznabIndexer(
      {required this.id,
      required this.name,
      required this.host,
      required this.apiKey,
      required this.enabled,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['host'] = Variable<String>(host);
    map['api_key'] = Variable<String>(apiKey);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NewznabIndexersCompanion toCompanion(bool nullToAbsent) {
    return NewznabIndexersCompanion(
      id: Value(id),
      name: Value(name),
      host: Value(host),
      apiKey: Value(apiKey),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
    );
  }

  factory NewznabIndexer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NewznabIndexer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      host: serializer.fromJson<String>(json['host']),
      apiKey: serializer.fromJson<String>(json['apiKey']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'host': serializer.toJson<String>(host),
      'apiKey': serializer.toJson<String>(apiKey),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NewznabIndexer copyWith(
          {String? id,
          String? name,
          String? host,
          String? apiKey,
          bool? enabled,
          DateTime? createdAt}) =>
      NewznabIndexer(
        id: id ?? this.id,
        name: name ?? this.name,
        host: host ?? this.host,
        apiKey: apiKey ?? this.apiKey,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt ?? this.createdAt,
      );
  NewznabIndexer copyWithCompanion(NewznabIndexersCompanion data) {
    return NewznabIndexer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      host: data.host.present ? data.host.value : this.host,
      apiKey: data.apiKey.present ? data.apiKey.value : this.apiKey,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NewznabIndexer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('apiKey: $apiKey, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, host, apiKey, enabled, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NewznabIndexer &&
          other.id == this.id &&
          other.name == this.name &&
          other.host == this.host &&
          other.apiKey == this.apiKey &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt);
}

class NewznabIndexersCompanion extends UpdateCompanion<NewznabIndexer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> host;
  final Value<String> apiKey;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NewznabIndexersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.host = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NewznabIndexersCompanion.insert({
    required String id,
    required String name,
    required String host,
    required String apiKey,
    this.enabled = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        host = Value(host),
        apiKey = Value(apiKey),
        createdAt = Value(createdAt);
  static Insertable<NewznabIndexer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? host,
    Expression<String>? apiKey,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (host != null) 'host': host,
      if (apiKey != null) 'api_key': apiKey,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NewznabIndexersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? host,
      Value<String>? apiKey,
      Value<bool>? enabled,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return NewznabIndexersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      apiKey: apiKey ?? this.apiKey,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NewznabIndexersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('host: $host, ')
          ..write('apiKey: $apiKey, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ServerConfigsTable serverConfigs = $ServerConfigsTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  late final $DownloadFilesTable downloadFiles = $DownloadFilesTable(this);
  late final $SegmentsTable segments = $SegmentsTable(this);
  late final $DownloadGroupsTable downloadGroups = $DownloadGroupsTable(this);
  late final $NewznabIndexersTable newznabIndexers =
      $NewznabIndexersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        serverConfigs,
        downloads,
        downloadFiles,
        segments,
        downloadGroups,
        newznabIndexers
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('downloads',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('download_files', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('downloads',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('segments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('download_files',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('segments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('downloads',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('download_groups', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ServerConfigsTableCreateCompanionBuilder = ServerConfigsCompanion
    Function({
  required String id,
  required String name,
  required String host,
  required int port,
  required bool useSsl,
  required String username,
  required String password,
  required int maxConnections,
  required int priority,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ServerConfigsTableUpdateCompanionBuilder = ServerConfigsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> host,
  Value<int> port,
  Value<bool> useSsl,
  Value<String> username,
  Value<String> password,
  Value<int> maxConnections,
  Value<int> priority,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ServerConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get host => $composableBuilder(
      column: $table.host, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get useSsl => $composableBuilder(
      column: $table.useSsl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxConnections => $composableBuilder(
      column: $table.maxConnections,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ServerConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get host => $composableBuilder(
      column: $table.host, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get useSsl => $composableBuilder(
      column: $table.useSsl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxConnections => $composableBuilder(
      column: $table.maxConnections,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ServerConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServerConfigsTable> {
  $$ServerConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<bool> get useSsl =>
      $composableBuilder(column: $table.useSsl, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<int> get maxConnections => $composableBuilder(
      column: $table.maxConnections, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ServerConfigsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServerConfigsTable,
    ServerConfig,
    $$ServerConfigsTableFilterComposer,
    $$ServerConfigsTableOrderingComposer,
    $$ServerConfigsTableAnnotationComposer,
    $$ServerConfigsTableCreateCompanionBuilder,
    $$ServerConfigsTableUpdateCompanionBuilder,
    (
      ServerConfig,
      BaseReferences<_$AppDatabase, $ServerConfigsTable, ServerConfig>
    ),
    ServerConfig,
    PrefetchHooks Function()> {
  $$ServerConfigsTableTableManager(_$AppDatabase db, $ServerConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> host = const Value.absent(),
            Value<int> port = const Value.absent(),
            Value<bool> useSsl = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<int> maxConnections = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServerConfigsCompanion(
            id: id,
            name: name,
            host: host,
            port: port,
            useSsl: useSsl,
            username: username,
            password: password,
            maxConnections: maxConnections,
            priority: priority,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String host,
            required int port,
            required bool useSsl,
            required String username,
            required String password,
            required int maxConnections,
            required int priority,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ServerConfigsCompanion.insert(
            id: id,
            name: name,
            host: host,
            port: port,
            useSsl: useSsl,
            username: username,
            password: password,
            maxConnections: maxConnections,
            priority: priority,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServerConfigsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServerConfigsTable,
    ServerConfig,
    $$ServerConfigsTableFilterComposer,
    $$ServerConfigsTableOrderingComposer,
    $$ServerConfigsTableAnnotationComposer,
    $$ServerConfigsTableCreateCompanionBuilder,
    $$ServerConfigsTableUpdateCompanionBuilder,
    (
      ServerConfig,
      BaseReferences<_$AppDatabase, $ServerConfigsTable, ServerConfig>
    ),
    ServerConfig,
    PrefetchHooks Function()>;
typedef $$DownloadsTableCreateCompanionBuilder = DownloadsCompanion Function({
  required String id,
  required String nzbPath,
  required String filename,
  Value<String?> subject,
  Value<String?> poster,
  required DownloadStatus status,
  required int totalBytes,
  required int downloadedBytes,
  required int totalSegments,
  required int completedSegments,
  required String outputPath,
  Value<String?> errorMessage,
  Value<int> lastPosition,
  Value<double> health,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$DownloadsTableUpdateCompanionBuilder = DownloadsCompanion Function({
  Value<String> id,
  Value<String> nzbPath,
  Value<String> filename,
  Value<String?> subject,
  Value<String?> poster,
  Value<DownloadStatus> status,
  Value<int> totalBytes,
  Value<int> downloadedBytes,
  Value<int> totalSegments,
  Value<int> completedSegments,
  Value<String> outputPath,
  Value<String?> errorMessage,
  Value<int> lastPosition,
  Value<double> health,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

final class $$DownloadsTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadsTable, Download> {
  $$DownloadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DownloadFilesTable, List<DownloadFile>>
      _downloadFilesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.downloadFiles,
              aliasName: $_aliasNameGenerator(
                  db.downloads.id, db.downloadFiles.downloadId));

  $$DownloadFilesTableProcessedTableManager get downloadFilesRefs {
    final manager = $$DownloadFilesTableTableManager($_db, $_db.downloadFiles)
        .filter((f) => f.downloadId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadFilesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SegmentsTable, List<Segment>> _segmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.segments,
          aliasName:
              $_aliasNameGenerator(db.downloads.id, db.segments.downloadId));

  $$SegmentsTableProcessedTableManager get segmentsRefs {
    final manager = $$SegmentsTableTableManager($_db, $_db.segments)
        .filter((f) => f.downloadId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_segmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DownloadGroupsTable, List<DownloadGroup>>
      _downloadGroupsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.downloadGroups,
              aliasName: $_aliasNameGenerator(
                  db.downloads.id, db.downloadGroups.downloadId));

  $$DownloadGroupsTableProcessedTableManager get downloadGroupsRefs {
    final manager = $$DownloadGroupsTableTableManager($_db, $_db.downloadGroups)
        .filter((f) => f.downloadId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadGroupsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nzbPath => $composableBuilder(
      column: $table.nzbPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poster => $composableBuilder(
      column: $table.poster, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DownloadStatus, DownloadStatus, int>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
      column: $table.downloadedBytes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSegments => $composableBuilder(
      column: $table.totalSegments, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedSegments => $composableBuilder(
      column: $table.completedSegments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outputPath => $composableBuilder(
      column: $table.outputPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPosition => $composableBuilder(
      column: $table.lastPosition, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get health => $composableBuilder(
      column: $table.health, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> downloadFilesRefs(
      Expression<bool> Function($$DownloadFilesTableFilterComposer f) f) {
    final $$DownloadFilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.downloadFiles,
        getReferencedColumn: (t) => t.downloadId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadFilesTableFilterComposer(
              $db: $db,
              $table: $db.downloadFiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> segmentsRefs(
      Expression<bool> Function($$SegmentsTableFilterComposer f) f) {
    final $$SegmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.segments,
        getReferencedColumn: (t) => t.downloadId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SegmentsTableFilterComposer(
              $db: $db,
              $table: $db.segments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> downloadGroupsRefs(
      Expression<bool> Function($$DownloadGroupsTableFilterComposer f) f) {
    final $$DownloadGroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.downloadGroups,
        getReferencedColumn: (t) => t.downloadId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadGroupsTableFilterComposer(
              $db: $db,
              $table: $db.downloadGroups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nzbPath => $composableBuilder(
      column: $table.nzbPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poster => $composableBuilder(
      column: $table.poster, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
      column: $table.downloadedBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSegments => $composableBuilder(
      column: $table.totalSegments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedSegments => $composableBuilder(
      column: $table.completedSegments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outputPath => $composableBuilder(
      column: $table.outputPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPosition => $composableBuilder(
      column: $table.lastPosition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get health => $composableBuilder(
      column: $table.health, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nzbPath =>
      $composableBuilder(column: $table.nzbPath, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get poster =>
      $composableBuilder(column: $table.poster, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DownloadStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => column);

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
      column: $table.downloadedBytes, builder: (column) => column);

  GeneratedColumn<int> get totalSegments => $composableBuilder(
      column: $table.totalSegments, builder: (column) => column);

  GeneratedColumn<int> get completedSegments => $composableBuilder(
      column: $table.completedSegments, builder: (column) => column);

  GeneratedColumn<String> get outputPath => $composableBuilder(
      column: $table.outputPath, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<int> get lastPosition => $composableBuilder(
      column: $table.lastPosition, builder: (column) => column);

  GeneratedColumn<double> get health =>
      $composableBuilder(column: $table.health, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  Expression<T> downloadFilesRefs<T extends Object>(
      Expression<T> Function($$DownloadFilesTableAnnotationComposer a) f) {
    final $$DownloadFilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.downloadFiles,
        getReferencedColumn: (t) => t.downloadId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadFilesTableAnnotationComposer(
              $db: $db,
              $table: $db.downloadFiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> segmentsRefs<T extends Object>(
      Expression<T> Function($$SegmentsTableAnnotationComposer a) f) {
    final $$SegmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.segments,
        getReferencedColumn: (t) => t.downloadId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SegmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.segments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> downloadGroupsRefs<T extends Object>(
      Expression<T> Function($$DownloadGroupsTableAnnotationComposer a) f) {
    final $$DownloadGroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.downloadGroups,
        getReferencedColumn: (t) => t.downloadId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadGroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.downloadGroups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DownloadsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadsTable,
    Download,
    $$DownloadsTableFilterComposer,
    $$DownloadsTableOrderingComposer,
    $$DownloadsTableAnnotationComposer,
    $$DownloadsTableCreateCompanionBuilder,
    $$DownloadsTableUpdateCompanionBuilder,
    (Download, $$DownloadsTableReferences),
    Download,
    PrefetchHooks Function(
        {bool downloadFilesRefs, bool segmentsRefs, bool downloadGroupsRefs})> {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nzbPath = const Value.absent(),
            Value<String> filename = const Value.absent(),
            Value<String?> subject = const Value.absent(),
            Value<String?> poster = const Value.absent(),
            Value<DownloadStatus> status = const Value.absent(),
            Value<int> totalBytes = const Value.absent(),
            Value<int> downloadedBytes = const Value.absent(),
            Value<int> totalSegments = const Value.absent(),
            Value<int> completedSegments = const Value.absent(),
            Value<String> outputPath = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int> lastPosition = const Value.absent(),
            Value<double> health = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadsCompanion(
            id: id,
            nzbPath: nzbPath,
            filename: filename,
            subject: subject,
            poster: poster,
            status: status,
            totalBytes: totalBytes,
            downloadedBytes: downloadedBytes,
            totalSegments: totalSegments,
            completedSegments: completedSegments,
            outputPath: outputPath,
            errorMessage: errorMessage,
            lastPosition: lastPosition,
            health: health,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nzbPath,
            required String filename,
            Value<String?> subject = const Value.absent(),
            Value<String?> poster = const Value.absent(),
            required DownloadStatus status,
            required int totalBytes,
            required int downloadedBytes,
            required int totalSegments,
            required int completedSegments,
            required String outputPath,
            Value<String?> errorMessage = const Value.absent(),
            Value<int> lastPosition = const Value.absent(),
            Value<double> health = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadsCompanion.insert(
            id: id,
            nzbPath: nzbPath,
            filename: filename,
            subject: subject,
            poster: poster,
            status: status,
            totalBytes: totalBytes,
            downloadedBytes: downloadedBytes,
            totalSegments: totalSegments,
            completedSegments: completedSegments,
            outputPath: outputPath,
            errorMessage: errorMessage,
            lastPosition: lastPosition,
            health: health,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DownloadsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {downloadFilesRefs = false,
              segmentsRefs = false,
              downloadGroupsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (downloadFilesRefs) db.downloadFiles,
                if (segmentsRefs) db.segments,
                if (downloadGroupsRefs) db.downloadGroups
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (downloadFilesRefs)
                    await $_getPrefetchedData<Download, $DownloadsTable,
                            DownloadFile>(
                        currentTable: table,
                        referencedTable: $$DownloadsTableReferences
                            ._downloadFilesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DownloadsTableReferences(db, table, p0)
                                .downloadFilesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.downloadId == item.id),
                        typedResults: items),
                  if (segmentsRefs)
                    await $_getPrefetchedData<Download, $DownloadsTable,
                            Segment>(
                        currentTable: table,
                        referencedTable:
                            $$DownloadsTableReferences._segmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DownloadsTableReferences(db, table, p0)
                                .segmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.downloadId == item.id),
                        typedResults: items),
                  if (downloadGroupsRefs)
                    await $_getPrefetchedData<Download, $DownloadsTable,
                            DownloadGroup>(
                        currentTable: table,
                        referencedTable: $$DownloadsTableReferences
                            ._downloadGroupsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DownloadsTableReferences(db, table, p0)
                                .downloadGroupsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.downloadId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DownloadsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadsTable,
    Download,
    $$DownloadsTableFilterComposer,
    $$DownloadsTableOrderingComposer,
    $$DownloadsTableAnnotationComposer,
    $$DownloadsTableCreateCompanionBuilder,
    $$DownloadsTableUpdateCompanionBuilder,
    (Download, $$DownloadsTableReferences),
    Download,
    PrefetchHooks Function(
        {bool downloadFilesRefs, bool segmentsRefs, bool downloadGroupsRefs})>;
typedef $$DownloadFilesTableCreateCompanionBuilder = DownloadFilesCompanion
    Function({
  required String id,
  required String downloadId,
  required String filename,
  required String subject,
  required int size,
  Value<int> rowid,
});
typedef $$DownloadFilesTableUpdateCompanionBuilder = DownloadFilesCompanion
    Function({
  Value<String> id,
  Value<String> downloadId,
  Value<String> filename,
  Value<String> subject,
  Value<int> size,
  Value<int> rowid,
});

final class $$DownloadFilesTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadFilesTable, DownloadFile> {
  $$DownloadFilesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DownloadsTable _downloadIdTable(_$AppDatabase db) =>
      db.downloads.createAlias(
          $_aliasNameGenerator(db.downloadFiles.downloadId, db.downloads.id));

  $$DownloadsTableProcessedTableManager get downloadId {
    final $_column = $_itemColumn<String>('download_id')!;

    final manager = $$DownloadsTableTableManager($_db, $_db.downloads)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_downloadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SegmentsTable, List<Segment>> _segmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.segments,
          aliasName:
              $_aliasNameGenerator(db.downloadFiles.id, db.segments.fileId));

  $$SegmentsTableProcessedTableManager get segmentsRefs {
    final manager = $$SegmentsTableTableManager($_db, $_db.segments)
        .filter((f) => f.fileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_segmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DownloadFilesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadFilesTable> {
  $$DownloadFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  $$DownloadsTableFilterComposer get downloadId {
    final $$DownloadsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableFilterComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> segmentsRefs(
      Expression<bool> Function($$SegmentsTableFilterComposer f) f) {
    final $$SegmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.segments,
        getReferencedColumn: (t) => t.fileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SegmentsTableFilterComposer(
              $db: $db,
              $table: $db.segments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DownloadFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadFilesTable> {
  $$DownloadFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  $$DownloadsTableOrderingComposer get downloadId {
    final $$DownloadsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableOrderingComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DownloadFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadFilesTable> {
  $$DownloadFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  $$DownloadsTableAnnotationComposer get downloadId {
    final $$DownloadsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableAnnotationComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> segmentsRefs<T extends Object>(
      Expression<T> Function($$SegmentsTableAnnotationComposer a) f) {
    final $$SegmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.segments,
        getReferencedColumn: (t) => t.fileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SegmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.segments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DownloadFilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadFilesTable,
    DownloadFile,
    $$DownloadFilesTableFilterComposer,
    $$DownloadFilesTableOrderingComposer,
    $$DownloadFilesTableAnnotationComposer,
    $$DownloadFilesTableCreateCompanionBuilder,
    $$DownloadFilesTableUpdateCompanionBuilder,
    (DownloadFile, $$DownloadFilesTableReferences),
    DownloadFile,
    PrefetchHooks Function({bool downloadId, bool segmentsRefs})> {
  $$DownloadFilesTableTableManager(_$AppDatabase db, $DownloadFilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> downloadId = const Value.absent(),
            Value<String> filename = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<int> size = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadFilesCompanion(
            id: id,
            downloadId: downloadId,
            filename: filename,
            subject: subject,
            size: size,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String downloadId,
            required String filename,
            required String subject,
            required int size,
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadFilesCompanion.insert(
            id: id,
            downloadId: downloadId,
            filename: filename,
            subject: subject,
            size: size,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DownloadFilesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({downloadId = false, segmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (segmentsRefs) db.segments],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (downloadId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.downloadId,
                    referencedTable:
                        $$DownloadFilesTableReferences._downloadIdTable(db),
                    referencedColumn:
                        $$DownloadFilesTableReferences._downloadIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (segmentsRefs)
                    await $_getPrefetchedData<DownloadFile, $DownloadFilesTable,
                            Segment>(
                        currentTable: table,
                        referencedTable: $$DownloadFilesTableReferences
                            ._segmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DownloadFilesTableReferences(db, table, p0)
                                .segmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.fileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DownloadFilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadFilesTable,
    DownloadFile,
    $$DownloadFilesTableFilterComposer,
    $$DownloadFilesTableOrderingComposer,
    $$DownloadFilesTableAnnotationComposer,
    $$DownloadFilesTableCreateCompanionBuilder,
    $$DownloadFilesTableUpdateCompanionBuilder,
    (DownloadFile, $$DownloadFilesTableReferences),
    DownloadFile,
    PrefetchHooks Function({bool downloadId, bool segmentsRefs})>;
typedef $$SegmentsTableCreateCompanionBuilder = SegmentsCompanion Function({
  required String id,
  required String downloadId,
  Value<String?> fileId,
  required int number,
  required String messageId,
  required int size,
  required bool isDownloaded,
  required int retries,
  Value<DateTime?> downloadedAt,
  Value<int> rowid,
});
typedef $$SegmentsTableUpdateCompanionBuilder = SegmentsCompanion Function({
  Value<String> id,
  Value<String> downloadId,
  Value<String?> fileId,
  Value<int> number,
  Value<String> messageId,
  Value<int> size,
  Value<bool> isDownloaded,
  Value<int> retries,
  Value<DateTime?> downloadedAt,
  Value<int> rowid,
});

final class $$SegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $SegmentsTable, Segment> {
  $$SegmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DownloadsTable _downloadIdTable(_$AppDatabase db) =>
      db.downloads.createAlias(
          $_aliasNameGenerator(db.segments.downloadId, db.downloads.id));

  $$DownloadsTableProcessedTableManager get downloadId {
    final $_column = $_itemColumn<String>('download_id')!;

    final manager = $$DownloadsTableTableManager($_db, $_db.downloads)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_downloadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DownloadFilesTable _fileIdTable(_$AppDatabase db) =>
      db.downloadFiles.createAlias(
          $_aliasNameGenerator(db.segments.fileId, db.downloadFiles.id));

  $$DownloadFilesTableProcessedTableManager? get fileId {
    final $_column = $_itemColumn<String>('file_id');
    if ($_column == null) return null;
    final manager = $$DownloadFilesTableTableManager($_db, $_db.downloadFiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retries => $composableBuilder(
      column: $table.retries, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));

  $$DownloadsTableFilterComposer get downloadId {
    final $$DownloadsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableFilterComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DownloadFilesTableFilterComposer get fileId {
    final $$DownloadFilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fileId,
        referencedTable: $db.downloadFiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadFilesTableFilterComposer(
              $db: $db,
              $table: $db.downloadFiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retries => $composableBuilder(
      column: $table.retries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));

  $$DownloadsTableOrderingComposer get downloadId {
    final $$DownloadsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableOrderingComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DownloadFilesTableOrderingComposer get fileId {
    final $$DownloadFilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fileId,
        referencedTable: $db.downloadFiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadFilesTableOrderingComposer(
              $db: $db,
              $table: $db.downloadFiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => column);

  GeneratedColumn<int> get retries =>
      $composableBuilder(column: $table.retries, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);

  $$DownloadsTableAnnotationComposer get downloadId {
    final $$DownloadsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableAnnotationComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DownloadFilesTableAnnotationComposer get fileId {
    final $$DownloadFilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.fileId,
        referencedTable: $db.downloadFiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadFilesTableAnnotationComposer(
              $db: $db,
              $table: $db.downloadFiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SegmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SegmentsTable,
    Segment,
    $$SegmentsTableFilterComposer,
    $$SegmentsTableOrderingComposer,
    $$SegmentsTableAnnotationComposer,
    $$SegmentsTableCreateCompanionBuilder,
    $$SegmentsTableUpdateCompanionBuilder,
    (Segment, $$SegmentsTableReferences),
    Segment,
    PrefetchHooks Function({bool downloadId, bool fileId})> {
  $$SegmentsTableTableManager(_$AppDatabase db, $SegmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> downloadId = const Value.absent(),
            Value<String?> fileId = const Value.absent(),
            Value<int> number = const Value.absent(),
            Value<String> messageId = const Value.absent(),
            Value<int> size = const Value.absent(),
            Value<bool> isDownloaded = const Value.absent(),
            Value<int> retries = const Value.absent(),
            Value<DateTime?> downloadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SegmentsCompanion(
            id: id,
            downloadId: downloadId,
            fileId: fileId,
            number: number,
            messageId: messageId,
            size: size,
            isDownloaded: isDownloaded,
            retries: retries,
            downloadedAt: downloadedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String downloadId,
            Value<String?> fileId = const Value.absent(),
            required int number,
            required String messageId,
            required int size,
            required bool isDownloaded,
            required int retries,
            Value<DateTime?> downloadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SegmentsCompanion.insert(
            id: id,
            downloadId: downloadId,
            fileId: fileId,
            number: number,
            messageId: messageId,
            size: size,
            isDownloaded: isDownloaded,
            retries: retries,
            downloadedAt: downloadedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SegmentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({downloadId = false, fileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (downloadId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.downloadId,
                    referencedTable:
                        $$SegmentsTableReferences._downloadIdTable(db),
                    referencedColumn:
                        $$SegmentsTableReferences._downloadIdTable(db).id,
                  ) as T;
                }
                if (fileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fileId,
                    referencedTable: $$SegmentsTableReferences._fileIdTable(db),
                    referencedColumn:
                        $$SegmentsTableReferences._fileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SegmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SegmentsTable,
    Segment,
    $$SegmentsTableFilterComposer,
    $$SegmentsTableOrderingComposer,
    $$SegmentsTableAnnotationComposer,
    $$SegmentsTableCreateCompanionBuilder,
    $$SegmentsTableUpdateCompanionBuilder,
    (Segment, $$SegmentsTableReferences),
    Segment,
    PrefetchHooks Function({bool downloadId, bool fileId})>;
typedef $$DownloadGroupsTableCreateCompanionBuilder = DownloadGroupsCompanion
    Function({
  required String id,
  required String downloadId,
  required String name,
  Value<int> rowid,
});
typedef $$DownloadGroupsTableUpdateCompanionBuilder = DownloadGroupsCompanion
    Function({
  Value<String> id,
  Value<String> downloadId,
  Value<String> name,
  Value<int> rowid,
});

final class $$DownloadGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadGroupsTable, DownloadGroup> {
  $$DownloadGroupsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DownloadsTable _downloadIdTable(_$AppDatabase db) =>
      db.downloads.createAlias(
          $_aliasNameGenerator(db.downloadGroups.downloadId, db.downloads.id));

  $$DownloadsTableProcessedTableManager get downloadId {
    final $_column = $_itemColumn<String>('download_id')!;

    final manager = $$DownloadsTableTableManager($_db, $_db.downloads)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_downloadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DownloadGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadGroupsTable> {
  $$DownloadGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  $$DownloadsTableFilterComposer get downloadId {
    final $$DownloadsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableFilterComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DownloadGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadGroupsTable> {
  $$DownloadGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  $$DownloadsTableOrderingComposer get downloadId {
    final $$DownloadsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableOrderingComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DownloadGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadGroupsTable> {
  $$DownloadGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$DownloadsTableAnnotationComposer get downloadId {
    final $$DownloadsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.downloadId,
        referencedTable: $db.downloads,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DownloadsTableAnnotationComposer(
              $db: $db,
              $table: $db.downloads,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DownloadGroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadGroupsTable,
    DownloadGroup,
    $$DownloadGroupsTableFilterComposer,
    $$DownloadGroupsTableOrderingComposer,
    $$DownloadGroupsTableAnnotationComposer,
    $$DownloadGroupsTableCreateCompanionBuilder,
    $$DownloadGroupsTableUpdateCompanionBuilder,
    (DownloadGroup, $$DownloadGroupsTableReferences),
    DownloadGroup,
    PrefetchHooks Function({bool downloadId})> {
  $$DownloadGroupsTableTableManager(
      _$AppDatabase db, $DownloadGroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> downloadId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadGroupsCompanion(
            id: id,
            downloadId: downloadId,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String downloadId,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadGroupsCompanion.insert(
            id: id,
            downloadId: downloadId,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DownloadGroupsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({downloadId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (downloadId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.downloadId,
                    referencedTable:
                        $$DownloadGroupsTableReferences._downloadIdTable(db),
                    referencedColumn:
                        $$DownloadGroupsTableReferences._downloadIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DownloadGroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadGroupsTable,
    DownloadGroup,
    $$DownloadGroupsTableFilterComposer,
    $$DownloadGroupsTableOrderingComposer,
    $$DownloadGroupsTableAnnotationComposer,
    $$DownloadGroupsTableCreateCompanionBuilder,
    $$DownloadGroupsTableUpdateCompanionBuilder,
    (DownloadGroup, $$DownloadGroupsTableReferences),
    DownloadGroup,
    PrefetchHooks Function({bool downloadId})>;
typedef $$NewznabIndexersTableCreateCompanionBuilder = NewznabIndexersCompanion
    Function({
  required String id,
  required String name,
  required String host,
  required String apiKey,
  Value<bool> enabled,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$NewznabIndexersTableUpdateCompanionBuilder = NewznabIndexersCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> host,
  Value<String> apiKey,
  Value<bool> enabled,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$NewznabIndexersTableFilterComposer
    extends Composer<_$AppDatabase, $NewznabIndexersTable> {
  $$NewznabIndexersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get host => $composableBuilder(
      column: $table.host, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get apiKey => $composableBuilder(
      column: $table.apiKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NewznabIndexersTableOrderingComposer
    extends Composer<_$AppDatabase, $NewznabIndexersTable> {
  $$NewznabIndexersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get host => $composableBuilder(
      column: $table.host, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get apiKey => $composableBuilder(
      column: $table.apiKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NewznabIndexersTableAnnotationComposer
    extends Composer<_$AppDatabase, $NewznabIndexersTable> {
  $$NewznabIndexersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<String> get apiKey =>
      $composableBuilder(column: $table.apiKey, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NewznabIndexersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NewznabIndexersTable,
    NewznabIndexer,
    $$NewznabIndexersTableFilterComposer,
    $$NewznabIndexersTableOrderingComposer,
    $$NewznabIndexersTableAnnotationComposer,
    $$NewznabIndexersTableCreateCompanionBuilder,
    $$NewznabIndexersTableUpdateCompanionBuilder,
    (
      NewznabIndexer,
      BaseReferences<_$AppDatabase, $NewznabIndexersTable, NewznabIndexer>
    ),
    NewznabIndexer,
    PrefetchHooks Function()> {
  $$NewznabIndexersTableTableManager(
      _$AppDatabase db, $NewznabIndexersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NewznabIndexersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NewznabIndexersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NewznabIndexersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> host = const Value.absent(),
            Value<String> apiKey = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NewznabIndexersCompanion(
            id: id,
            name: name,
            host: host,
            apiKey: apiKey,
            enabled: enabled,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String host,
            required String apiKey,
            Value<bool> enabled = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              NewznabIndexersCompanion.insert(
            id: id,
            name: name,
            host: host,
            apiKey: apiKey,
            enabled: enabled,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NewznabIndexersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NewznabIndexersTable,
    NewznabIndexer,
    $$NewznabIndexersTableFilterComposer,
    $$NewznabIndexersTableOrderingComposer,
    $$NewznabIndexersTableAnnotationComposer,
    $$NewznabIndexersTableCreateCompanionBuilder,
    $$NewznabIndexersTableUpdateCompanionBuilder,
    (
      NewznabIndexer,
      BaseReferences<_$AppDatabase, $NewznabIndexersTable, NewznabIndexer>
    ),
    NewznabIndexer,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ServerConfigsTableTableManager get serverConfigs =>
      $$ServerConfigsTableTableManager(_db, _db.serverConfigs);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
  $$DownloadFilesTableTableManager get downloadFiles =>
      $$DownloadFilesTableTableManager(_db, _db.downloadFiles);
  $$SegmentsTableTableManager get segments =>
      $$SegmentsTableTableManager(_db, _db.segments);
  $$DownloadGroupsTableTableManager get downloadGroups =>
      $$DownloadGroupsTableTableManager(_db, _db.downloadGroups);
  $$NewznabIndexersTableTableManager get newznabIndexers =>
      $$NewznabIndexersTableTableManager(_db, _db.newznabIndexers);
}
