import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Weekly meal plan: weekday (1 = Monday ... 7 = Sunday) -> recipes. Stored locally, works offline.
class MealPlanNotifier extends Notifier<Map<int, List<Recipe>>> {
  static const _prefKey = 'meal_plan_v1';
  // Saving waits for the stored data to be read first, so an early change never overwrites it.
  Future<void> _ready = Future.value();

  @override
  Map<int, List<Recipe>> build() {
    _ready = _load();
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
      state.forEach((d, l) {
        final ids = (merged[d] ?? const <Recipe>[]).map((r) => r.id).toSet();
        merged[d] = [...?merged[d], ...l.where((r) => !ids.contains(r.id))];
      });
      state = merged;
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      await _ready;
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

  /// Copies every meal of [from] to [to], skipping ones already there. Returns how many were added.
  int copyDay(int from, int to) {
    if (from == to || to < 1 || to > 7) return 0;
    var added = 0;
    for (final r in List.of(state[from] ?? const <Recipe>[])) {
      if (add(to, r)) added++;
    }
    return added;
  }

  /// Moves a meal to another day. If the target day already has it, it is just removed from the old day.
  void move(int from, int to, Recipe recipe) {
    if (from == to || to < 1 || to > 7) return;
    remove(from, recipe.id);
    add(to, recipe);
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

  /// Plain-text week plan (days with meals only), for pasting into notes or chats.
  String asText(String Function(int day) dayName, String Function(Recipe r) title,
      [String Function(int minutes)? minutes]) {
    final b = StringBuffer();
    for (var d = 1; d <= 7; d++) {
      final list = state[d];
      if (list == null || list.isEmpty) continue;
      final total = list.fold<int>(0, (a, r) => a + r.totalTime);
      b.writeln(minutes == null ? dayName(d) : '${dayName(d)} · ${minutes(total)}');
      for (final r in list) {
        b.writeln('- ${title(r)}');
      }
    }
    return b.toString().trimRight();
  }

  /// Replaces the whole plan (used by "Undo" after clearing).
  void restore(Map<int, List<Recipe>> plan) {
    state = {for (final e in plan.entries) e.key: [...e.value]};
    _save();
  }

  void clear() {
    state = const {};
    _save();
  }
}

final mealPlanProvider =
    NotifierProvider<MealPlanNotifier, Map<int, List<Recipe>>>(MealPlanNotifier.new);
