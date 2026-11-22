import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Last searches (newest first, max 6), stored on the device.
class RecentSearchesNotifier extends Notifier<List<String>> {
  static const _prefKey = 'recent_searches_v1';
  static const maxItems = 6;

  @override
  List<String> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefKey) ?? const [];
      final have = state.map((e) => e.toLowerCase()).toSet();
      state = [...state, ...saved.where((e) => have.add(e.toLowerCase()))].take(maxItems).toList();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state);
    } catch (_) {}
  }

  void add(String query) {
    final q = query.trim();
    if (q.length < 2) return;
    state = [q, ...state.where((e) => e.toLowerCase() != q.toLowerCase())].take(maxItems).toList();
    _save();
  }

  void clear() {
    state = const [];
    _save();
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(RecentSearchesNotifier.new);
