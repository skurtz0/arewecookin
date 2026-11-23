import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'world_recipes.dart';

const recipePacksBaseUrl = 'https://arewecookin-photos.areyouskurtz.workers.dev/packs';

/// Recipe packs: every country's hand-checked recipes live on the server in pages of ~100 and are
/// loaded when someone opens that country (a thousand recipes per country do not belong in the app bundle).
abstract class PackSource {
  /// Recipe counts per country id (Turkish cuisine id), null when the packs are unreachable.
  Future<Map<String, int>?> counts();

  /// All pack recipes of one country (empty when it has none or the packs are unreachable).
  Future<List<Recipe>> country(String cuisineId);

  Future<Recipe?> byId(String id);
}

class HttpPackSource implements PackSource {
  final http.Client _client;
  final String baseUrl;
  HttpPackSource({http.Client? client, this.baseUrl = recipePacksBaseUrl}) : _client = client ?? http.Client();

  Map<String, dynamic>? _manifest;
  DateTime? _manifestAt;
  final Map<String, List<Recipe>> _countries = {};
  final Map<String, Future<List<Recipe>>> _loading = {};

  Future<Map<String, dynamic>?> _loadManifest() async {
    final at = _manifestAt;
    if (_manifest != null && at != null && DateTime.now().difference(at) < const Duration(minutes: 10)) return _manifest;
    try {
      final r = await _client.get(Uri.parse('$baseUrl/manifest.json')).timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return _manifest;
      _manifest = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      _manifestAt = DateTime.now();
    } catch (_) {}
    return _manifest;
  }

  @override
  Future<Map<String, int>?> counts() async {
    final m = await _loadManifest();
    if (m == null) return null;
    final c = (m['countries'] as Map).cast<String, dynamic>();
    return {for (final e in c.entries) e.key: ((e.value as Map)['count'] as num).toInt()};
  }

  Future<List<Recipe>?> _page(String iso, int k) async {
    try {
      final r = await _client.get(Uri.parse('$baseUrl/$iso/$k.json')).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return null;
      return (jsonDecode(utf8.decode(r.bodyBytes)) as List)
          .map((e) => WorldRecipes.fromJson(e as Map<String, dynamic>, packed: true))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Recipe>> country(String cuisineId) {
    final have = _countries[cuisineId];
    if (have != null) return Future.value(have);
    return _loading[cuisineId] ??= () async {
      try {
        final m = await _loadManifest();
        final info = (m?['countries'] as Map?)?[cuisineId] as Map?;
        if (info == null) return <Recipe>[];
        final iso = info['iso'] as String;
        final pages = (info['pages'] as num).toInt();
        final parts = await Future.wait([for (var k = 0; k < pages; k++) _page(iso, k)]);
        if (parts.any((p) => p == null)) return <Recipe>[]; // partial data would break paging: retry next time
        final all = [for (final p in parts) ...p!];
        _countries[cuisineId] = all;
        return all;
      } finally {
        _loading.remove(cuisineId);
      }
    }();
  }

  @override
  Future<Recipe?> byId(String id) async {
    final m = RegExp(r'^p_([A-Z]{2})_(\d+)$').firstMatch(id);
    if (m == null) return null;
    final iso = m.group(1)!;
    final manifest = await _loadManifest();
    final countries = (manifest?['countries'] as Map?)?.cast<String, dynamic>();
    final entry = countries?.entries.where((e) => (e.value as Map)['iso'] == iso).firstOrNull;
    if (entry == null) return null;
    final cached = _countries[entry.key];
    if (cached != null) return cached.where((r) => r.id == id).firstOrNull;
    final size = ((manifest!['pageSize'] ?? 100) as num).toInt();
    final page = await _page(iso, (int.parse(m.group(2)!) - 1) ~/ size);
    return page?.where((r) => r.id == id).firstOrNull;
  }
}
