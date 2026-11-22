import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Last viewed recipes (newest first, max 10). Stored locally, so it works offline.
class RecentRecipesNotifier extends Notifier<List<Recipe>> {
  static const _prefKey = 'recent_recipes_v1';
  static const maxItems = 10;

  @override
  List<Recipe> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? const [];
      final loaded = <Recipe>[];
      for (final s in raw) {
        try {
          loaded.add(Recipe.fromMap(jsonDecode(s) as Map<String, dynamic>));
        } catch (_) {}
      }
      final ids = state.map((r) => r.id).toSet();
      state = [...state, ...loaded.where((r) => !ids.contains(r.id))].take(maxItems).toList();
    } catch (_) {}
  }

  void add(Recipe recipe) {
    state = [recipe, ...state.where((r) => r.id != recipe.id)].take(maxItems).toList();
    () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_prefKey, state.map((r) => jsonEncode(r.toMap())).toList());
      } catch (_) {}
    }();
  }

  void clear() {
    state = const [];
    () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefKey);
      } catch (_) {}
    }();
  }
}

final recentRecipesProvider =
    NotifierProvider<RecentRecipesNotifier, List<Recipe>>(RecentRecipesNotifier.new);
