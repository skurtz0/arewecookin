import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'photo_uploader.dart' show photosBaseUrl;
import 'package:http/http.dart' as http;

/// Translates short user text into [target] (language code such as 'tr').
/// Uses the free MyMemory endpoint (no key). Returns null on failure.
abstract class TranslationService {
  Future<String?> translate(String text, String target);
}

class MyMemoryTranslationService implements TranslationService {
  final http.Client _client;
  MyMemoryTranslationService([http.Client? client]) : _client = client ?? http.Client();

  /// MyMemory accepts at most ~500 bytes per query: split on sentence/space.
  static List<String> chunk(String text, {int max = 400}) {
    final out = <String>[];
    var rest = text.trim();
    while (rest.length > max) {
      var cut = rest.lastIndexOf(RegExp(r'[.!?\n]'), max);
      if (cut < max ~/ 2) cut = rest.lastIndexOf(' ', max);
      if (cut < 1) cut = max;
      out.add(rest.substring(0, cut + 1).trim());
      rest = rest.substring(cut + 1).trim();
    }
    if (rest.isNotEmpty) out.add(rest);
    return out;
  }

  @override
  Future<String?> translate(String text, String target) async {
    final lang = target.split(RegExp('[_-]')).first;
    final parts = <String>[];
    try {
      for (final c in chunk(text)) {
        final uri = Uri.https('api.mymemory.translated.net', '/get', {'q': c, 'langpair': 'Autodetect|$lang'});
        final r = await _client.get(uri).timeout(const Duration(seconds: 10));
        if (r.statusCode != 200) return null;
        final j = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
        if ((j['responseStatus'] ?? 200).toString() != '200') return null;
        final t = (j['responseData'] as Map<String, dynamic>?)?['translatedText'] as String?;
        if (t == null || t.isEmpty) return null;
        parts.add(t);
      }
    } catch (_) {
      return null;
    }
    return parts.isEmpty ? null : parts.join(' ');
  }
}

/// Cloudflare Workers AI through our own Worker (signed-in users). Returns null on any failure.
class WorkerTranslationService implements TranslationService {
  final http.Client _client;
  final Future<String?> Function() _token;
  WorkerTranslationService({http.Client? client, Future<String?> Function()? token})
      : _client = client ?? http.Client(),
        _token = token ?? (() async => FirebaseAuth.instance.currentUser?.getIdToken());

  @override
  Future<String?> translate(String text, String target) async {
    try {
      final token = await _token();
      if (token == null) return null;
      final r = await _client
          .post(Uri.parse('$photosBaseUrl/translate'),
              headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
              body: jsonEncode({'text': text, 'target': target}))
          .timeout(const Duration(seconds: 25));
      if (r.statusCode != 200) return null;
      final t = (jsonDecode(utf8.decode(r.bodyBytes)) as Map)['text'] as String?;
      return (t == null || t.isEmpty) ? null : t;
    } catch (_) {
      return null;
    }
  }
}

/// Tries [primary] first and falls back to [fallback] (guests, quota, outages).
class FallbackTranslationService implements TranslationService {
  final TranslationService primary;
  final TranslationService fallback;
  FallbackTranslationService(this.primary, this.fallback);

  @override
  Future<String?> translate(String text, String target) async =>
      await primary.translate(text, target) ?? await fallback.translate(text, target);
}

final translationServiceProvider = Provider<TranslationService>(
    (ref) => FallbackTranslationService(WorkerTranslationService(), MyMemoryTranslationService()));
