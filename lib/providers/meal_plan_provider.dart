import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Weekly meal plan: weekday (1 = Monday ... 7 = Sunday) -> recipes. Stored locally, works offline.
class MealPlanNotifier extends Notifier<Map<int, List<Recipe>>> {
  static const _prefKey = 'meal_plan_v1';

  @override
  Map<int, List<Recipe>> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final loaded = <int, List<Recipe>>{};
      map.forEach((k, v) {
        final day = int.tryParse(k);
        if (day == null || day < 1 || day > 7) return;
        final list = <Recipe>[];
        for (final r in (v as List)) {
          try {
            list.add(Recipe.fromMap(Map<String, dynamic>.from(r as Map)));
          } catch (_) {}
        }
        if (list.isNotEmpty) loaded[day] = list;
      });
      // Anything added before loading finished is kept.
      final merged = {...loaded};
      state.forEach((d, l) => merged[d] = [...?merged[d], ...l]);
      state = merged;
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKey,
        jsonEncode(state.map((d, l) => MapEntry('$d', l.map((r) => r.toMap()).toList()))),
      );
    } catch (_) {}
  }

  /// Returns false when the recipe is already planned for that day.
  bool add(int day, Recipe recipe) {
    if (day < 1 || day > 7) return false;
    final current = state[day] ?? const [];
    if (current.any((r) => r.id == recipe.id)) return false;
    state = {...state, day: [...current, recipe]};
    _save();
    return true;
  }

  void remove(int day, String recipeId) {
    final current = state[day];
    if (current == null) return;
    final next = current.where((r) => r.id != recipeId).toList();
    final copy = {...state};
    if (next.isEmpty) {
      copy.remove(day);
    } else {
      copy[day] = next;
    }
    state = copy;
    _save();
  }

  void clear() {
    state = const {};
    _save();
  }
}

final mealPlanProvider =
    NotifierProvider<MealPlanNotifier, Map<int, List<Recipe>>>(MealPlanNotifier.new);
