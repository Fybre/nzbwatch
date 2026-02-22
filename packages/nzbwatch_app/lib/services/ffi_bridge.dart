import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/nzb_models.dart';

// FFI function types
typedef CoreInitC = Pointer<Void> Function();
typedef CoreInitDart = Pointer<Void> Function();
typedef CoreDestroyC = Void Function(Pointer<Void>);
typedef CoreDestroyDart = void Function(Pointer<Void>);
typedef CoreParseNzbC = Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreParseNzbDart = Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreStartDownloadC = Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreStartDownloadDart = Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreCheckAvailabilityC = Double Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreCheckAvailabilityDart = double Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreCancelDownloadC = Void Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreCancelDownloadDart = void Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreDeleteDownloadC = Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>);
typedef CoreDeleteDownloadDart = int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>);
typedef CoreTestServerC = Int32 Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreTestServerDart = int Function(Pointer<Void>, Pointer<Utf8>);
typedef CoreFreeStringC = Void Function(Pointer<Utf8>);
typedef CoreFreeStringDart = void Function(Pointer<Utf8>);

class FfiBridge {
  static final FfiBridge _instance = FfiBridge._internal();
  factory FfiBridge() => _instance;
  
  late final DynamicLibrary _lib;
  late final Pointer<Void> _api;
  String libPath = 'unknown';
  
  late final CoreInitDart _init;
  late final CoreDestroyDart _destroy;
  late final CoreParseNzbDart _parseNzb;
  late final CoreStartDownloadDart _startDownload;
  late final CoreCheckAvailabilityDart _checkAvailability;
  late final CoreCancelDownloadDart _cancelDownload;
  late final CoreDeleteDownloadDart _deleteDownload;
  late final CoreTestServerDart _testServer;
  late final CoreFreeStringDart _freeString;
  
  FfiBridge._internal() {
    _lib = _load();
    
    _init = _lib.lookupFunction<CoreInitC, CoreInitDart>('core_init');
    _destroy = _lib.lookupFunction<CoreDestroyC, CoreDestroyDart>('core_destroy');
    _parseNzb = _lib.lookupFunction<CoreParseNzbC, CoreParseNzbDart>('core_parse_nzb');
    _startDownload = _lib.lookupFunction<CoreStartDownloadC, CoreStartDownloadDart>('core_start_download');
    _checkAvailability = _lib.lookupFunction<CoreCheckAvailabilityC, CoreCheckAvailabilityDart>('core_check_availability');
    _cancelDownload = _lib.lookupFunction<CoreCancelDownloadC, CoreCancelDownloadDart>('core_cancel_download');
    _deleteDownload = _lib.lookupFunction<CoreDeleteDownloadC, CoreDeleteDownloadDart>('core_delete_download');
    _testServer = _lib.lookupFunction<CoreTestServerC, CoreTestServerDart>('core_test_server');
    _freeString = _lib.lookupFunction<CoreFreeStringC, CoreFreeStringDart>('core_free_string');
    
    _api = _init();
  }

  DynamicLibrary _load() {
    final paths = <String>[];
    final name = Platform.isMacOS ? 'libnzbwatch_core.dylib' : (Platform.isWindows ? 'nzbwatch_core.dll' : 'libnzbwatch_core.so');
    
    if (Platform.isMacOS) {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      paths.addAll([
        p.join(exeDir, '..', 'Frameworks', name),
        p.join(exeDir, name),
        name,
      ]);
    } else {
      paths.add(name);
    }

    for (final path in paths) {
      try {
        final l = DynamicLibrary.open(path);
        libPath = path;
        return l;
      } catch (_) {}
    }
    return DynamicLibrary.open(name);
  }

  void dispose() => _destroy(_api);

  NzbFile? parseNzb(String xml) {
    final xmlPtr = xml.toNativeUtf8();
    try {
      final resPtr = _parseNzb(_api, xmlPtr);
      if (resPtr == nullptr) return null;
      final json = resPtr.toDartString();
      _freeString(resPtr);
      return _parseNzbFileJson(json);
    } finally {
      calloc.free(xmlPtr);
    }
  }

  Future<String?> startDownload({
    required String downloadId,
    required NzbFile nzb,
    required List<ServerConfig> servers,
    required String outputDir,
    required String tempDir,
  }) async {
    final config = jsonEncode({
      "download_id": downloadId,
      "nzb": _nzbToMap(nzb),
      "servers": servers.map((s) => s.toJson()).toList(),
      "output_dir": outputDir,
      "temp_dir": tempDir,
    });
    final ptr = config.toNativeUtf8();
    try {
      final resPtr = _startDownload(_api, ptr);
      if (resPtr == nullptr) return null;
      final id = resPtr.toDartString();
      _freeString(resPtr);
      return id;
    } finally {
      calloc.free(ptr);
    }
  }

  Future<double> checkAvailability({
    required NzbFile nzb,
    required List<ServerConfig> servers,
  }) async {
    final configJson = jsonEncode({
      "download_id": "check",
      "nzb": _nzbToMap(nzb),
      "servers": servers.map((s) => s.toJson()).toList(),
      "output_dir": "/tmp",
      "temp_dir": "/tmp",
    });
    return await compute(_checkAvailabilityWorker, configJson);
  }

  void cancelDownload(String id) {
    final ptr = id.toNativeUtf8();
    try { _cancelDownload(_api, ptr); } finally { calloc.free(ptr); }
  }

  void deleteDownload(String id, NzbFile nzb, List<ServerConfig> servers, String dir) {
    final idPtr = id.toNativeUtf8();
    final config = jsonEncode({
      "download_id": id,
      "nzb": _nzbToMap(nzb),
      "servers": servers.map((s) => s.toJson()).toList(),
      "output_dir": dir,
      "temp_dir": "/tmp",
    });
    final cfgPtr = config.toNativeUtf8();
    try { _deleteDownload(_api, idPtr, cfgPtr); } finally {
      calloc.free(idPtr);
      calloc.free(cfgPtr);
    }
  }

  Future<bool> testServer(ServerConfig s) async {
    final ptr = jsonEncode(s.toJson()).toNativeUtf8();
    try { return _testServer(_api, ptr) == 1; } finally { calloc.free(ptr); }
  }

  Map<String, dynamic> _nzbToMap(NzbFile nzb) => {
    "name": nzb.name,
    "poster": nzb.poster,
    "groups": nzb.groups,
    "files": nzb.files.map((f) => {
      "filename": f.filename,
      "subject": f.subject,
      "segments": f.segments.map((s) => {"number": s.number, "message_id": s.messageId, "size": s.size}).toList(),
      "size": f.size,
    }).toList(),
    "total_size": nzb.totalSize,
  };

  NzbFile _parseNzbFileJson(String s) {
    final d = jsonDecode(s);
    final files = (d['files'] as List).map((f) => NzbFileEntry(
      filename: f['filename'],
      subject: f['subject'],
      segments: (f['segments'] as List).map((s) => NzbSegment(number: s['number'], messageId: s['message_id'], size: s['size'])).toList(),
      size: f['size'],
    )).toList();
    return NzbFile(name: d['name'] ?? 'unknown', poster: d['poster'], groups: List<String>.from(d['groups'] ?? []), files: files, totalSize: d['total_size'] ?? 0);
  }
}

/// Isolate worker for background health checks
double _checkAvailabilityWorker(String configJson) {
  final bridge = FfiBridge(); 
  final ptr = configJson.toNativeUtf8();
  try {
    return bridge._checkAvailability(bridge._api, ptr);
  } finally {
    calloc.free(ptr);
  }
}

final ffiBridgeProvider = FfiBridge();
