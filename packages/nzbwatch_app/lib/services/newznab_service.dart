import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';

import '../models/nzb_models.dart' as models;
import 'database.dart';

class NewznabService {
  final AppDatabase _db;
  final _uuid = const Uuid();

  NewznabService(this._db);

  /// Get all configured indexers
  Future<List<models.NewznabIndexer>> getAllIndexers() async {
    final indexers = await _db.getAllIndexers();
    return indexers.map((i) => models.NewznabIndexer(
      id: i.id,
      name: i.name,
      host: i.host,
      apiKey: i.apiKey,
      enabled: i.enabled,
    )).toList();
  }

  /// Add a new indexer
  Future<models.NewznabIndexer> addIndexer({
    required String name,
    required String host,
    required String apiKey,
  }) async {
    final id = _uuid.v4();
    
    // Normalize host: ensure it has a scheme and no trailing slash
    String normalizedHost = host.trim();
    if (!normalizedHost.startsWith('http://') && !normalizedHost.startsWith('https://')) {
      normalizedHost = 'https://$normalizedHost';
    }
    if (normalizedHost.endsWith('/')) {
      normalizedHost = normalizedHost.substring(0, normalizedHost.length - 1);
    }
    
    await _db.insertIndexer(NewznabIndexersCompanion.insert(
      id: id,
      name: name,
      host: normalizedHost,
      apiKey: apiKey,
      createdAt: DateTime.now(),
    ));

    return models.NewznabIndexer(
      id: id,
      name: name,
      host: normalizedHost,
      apiKey: apiKey,
    );
  }

  /// Update an existing indexer
  Future<void> updateIndexer(models.NewznabIndexer indexer) async {
    String normalizedHost = indexer.host.trim();
    if (!normalizedHost.startsWith('http://') && !normalizedHost.startsWith('https://')) {
      normalizedHost = 'https://$normalizedHost';
    }
    if (normalizedHost.endsWith('/')) {
      normalizedHost = normalizedHost.substring(0, normalizedHost.length - 1);
    }

    await _db.updateIndexer(NewznabIndexersCompanion(
      id: Value(indexer.id),
      name: Value(indexer.name),
      host: Value(normalizedHost),
      apiKey: Value(indexer.apiKey),
      enabled: Value(indexer.enabled),
    ));
  }

  /// Delete an indexer
  Future<void> deleteIndexer(String id) async {
    await _db.deleteIndexer(id);
  }

  /// Search across all enabled indexers
  Future<List<models.SearchResult>> search(String query) async {
    final indexers = await getAllIndexers();
    final enabledIndexers = indexers.where((i) => i.enabled).toList();
    
    print('[NewznabService] Searching for "$query" across ${enabledIndexers.length} indexers');
    
    final allResults = <models.SearchResult>[];
    
    // For now, search sequentially. Could be parallelized.
    for (final indexer in enabledIndexers) {
      try {
        print('[NewznabService] Querying indexer: ${indexer.name} (${indexer.host})');
        final results = await _searchIndexer(indexer, query);
        print('[NewznabService] Found ${results.length} results from ${indexer.name}');
        allResults.addAll(results);
      } catch (e) {
        print('[NewznabService] Search failed for ${indexer.name}: $e');
      }
    }
    
    // Sort by date descending
    allResults.sort((a, b) {
      if (a.pubDate == null) return 1;
      if (b.pubDate == null) return -1;
      return b.pubDate!.compareTo(a.pubDate!);
    });
    
    print('[NewznabService] Total results found: ${allResults.length}');
    return allResults;
  }

  Future<List<models.SearchResult>> _searchIndexer(models.NewznabIndexer indexer, String query) async {
    final url = Uri.parse('${indexer.host}/api?t=search&q=${Uri.encodeComponent(query)}&apikey=${indexer.apiKey}&o=xml');
    
    print('[NewznabService] Request URL: $url');
    
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    print('[NewznabService] Response status: ${response.statusCode}');
    
    if (response.statusCode != 200) {
      print('[NewznabService] Error response body: ${response.body}');
      throw Exception('Indexer returned status ${response.statusCode}');
    }

    try {
      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');
      print('[NewznabService] Parsed ${items.length} <item> elements from XML');
      
      return items.map((item) {
        final title = item.findElements('title').firstOrNull?.innerText ?? 'Unknown';
        final guid = item.findElements('guid').firstOrNull?.innerText ?? '';
        final link = item.findElements('link').firstOrNull?.innerText;
        
        final pubDateStr = item.findElements('pubDate').firstOrNull?.innerText;
        DateTime? pubDate;
        if (pubDateStr != null) {
          pubDate = _parseRssDate(pubDateStr);
        }

        int size = 0;
        String? poster;
        String? group;
        String? category;
        DateTime? usenetDate;

        // Newznab specific attributes
        for (final element in item.children) {
          if (element is XmlElement && element.name.local == 'attr') {
            final name = element.getAttribute('name');
            final value = element.getAttribute('value');
            
            if (name == 'size') size = int.tryParse(value ?? '0') ?? 0;
            if (name == 'poster') poster = value;
            if (name == 'group') group = value;
            if (name == 'category') category = value;
            if (name == 'usenetdate') {
              usenetDate = _parseRssDate(value ?? '');
            }
          }
        }

        // Prefer usenetDate if available
        final finalDate = usenetDate ?? pubDate;

        // Sometimes size is in enclosure
        if (size == 0) {
          final enclosure = item.findElements('enclosure').firstOrNull;
          if (enclosure != null) {
            size = int.tryParse(enclosure.getAttribute('length') ?? '0') ?? 0;
          }
        }

        return models.SearchResult(
          title: title,
          guid: guid,
          link: link,
          pubDate: finalDate,
          size: size,
          indexerName: indexer.name,
          poster: poster,
          group: group,
          category: category,
        );
      }).toList();
    } catch (e) {
      print('[NewznabService] XML Parsing error: $e');
      print('[NewznabService] Raw body start: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      rethrow;
    }
  }

  /// Parses RSS date formats (RFC 822/1123)
  DateTime? _parseRssDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    
    // Try standard ISO parse first
    final iso = DateTime.tryParse(dateStr);
    if (iso != null) return iso;

    try {
      // Clean up common RSS date issues
      String cleaned = dateStr.trim();
      
      // Remove "UT" or "GMT" if present at end for simpler parsing
      if (cleaned.endsWith(' UT')) cleaned = cleaned.substring(0, cleaned.length - 3);
      if (cleaned.endsWith(' GMT')) cleaned = cleaned.substring(0, cleaned.length - 4);
      
      // Common Newznab format: "Mon, 17 Feb 2025 20:30:15 +0000"
      // DateFormat from intl can be picky, so we'll try a few variations
      final formats = [
        'E, d MMM yyyy HH:mm:ss Z',
        'E, d MMM yyyy HH:mm:ss z',
        'd MMM yyyy HH:mm:ss Z',
        'yyyy-MM-dd HH:mm:ss',
      ];

      for (final format in formats) {
        try {
          return DateFormat(format).parse(cleaned);
        } catch (_) {}
      }
    } catch (e) {
      print('[NewznabService] Failed to parse date "$dateStr": $e');
    }
    
    return null;
  }

  /// Download NZB content from indexer
  Future<String> downloadNzb(models.SearchResult result) async {
    final indexers = await getAllIndexers();
    final indexer = indexers.firstWhere((i) => i.name == result.indexerName);
    
    // According to the API reference, we should always use t=get&id=[GUID]
    // Some indexers put a full URL in the <guid> field, but the ID is usually at the end.
    String id = result.guid;
    if (id.contains('id=')) {
      id = Uri.parse(id).queryParameters['id'] ?? id;
    } else if (id.startsWith('http')) {
      // If it's a URL but doesn't have id=, it might be the last segment
      id = id.split('/').last;
    }

    final url = Uri.parse('${indexer.host}/api?t=get&id=$id&apikey=${indexer.apiKey}');
    
    print('[NewznabService] Downloading NZB from: $url');
    
    final response = await http.get(url).timeout(const Duration(seconds: 30));
    print('[NewznabService] Download response status: ${response.statusCode}');
    
    if (response.statusCode != 200) {
      print('[NewznabService] Error response body: ${response.body}');
      throw Exception('Failed to download NZB: status ${response.statusCode}');
    }

    final body = response.body.trim();

    // Check if we got HTML instead of XML (happens on redirects/auth errors)
    if (body.toLowerCase().startsWith('<!doctype html') || 
        body.toLowerCase().startsWith('<html')) {
      print('[NewznabService] Error: Received HTML instead of NZB XML.');
      throw Exception('Indexer returned a login page or error page. Check your API key.');
    }
    
    return body;
  }
}

final newznabServiceProvider = Provider<NewznabService>((ref) {
  final db = ref.watch(databaseProvider);
  return NewznabService(db);
});

final indexersProvider = FutureProvider<List<models.NewznabIndexer>>((ref) async {
  final service = ref.watch(newznabServiceProvider);
  return service.getAllIndexers();
});

final watchIndexersProvider = StreamProvider<List<models.NewznabIndexer>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllIndexers().map((list) => list.map((i) => models.NewznabIndexer(
    id: i.id,
    name: i.name,
    host: i.host,
    apiKey: i.apiKey,
    enabled: i.enabled,
  )).toList());
});
