import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-recipe memory: the servings the user picked and the cooking step they stopped at.
class RecipeProgress {
  final int? servings;
  final int step;
  const RecipeProgress({this.servings, this.step = 0});

  bool get isEmpty => servings == null && step == 0;

  Map<String, dynamic> toMap() => {if (servings != null) 's': servings, 'p': step};

  factory RecipeProgress.fromMap(Map<String, dynamic> m) =>
      RecipeProgress(servings: (m['s'] as num?)?.toInt(), step: (m['p'] as num?)?.toInt() ?? 0);
}

class RecipeProgressNotifier extends Notifier<Map<String, RecipeProgress>> {
  static const _prefKey = 'recipe_progress_v1';

  @override
  Map<String, RecipeProgress> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return;
      final loaded = <String, RecipeProgress>{};
      (jsonDecode(raw) as Map<String, dynamic>).forEach((id, v) {
        try {
          final p = RecipeProgress.fromMap(Map<String, dynamic>.from(v as Map));
          if (!p.isEmpty) loaded[id] = p;
        } catch (_) {}
      });
      state = {...loaded, ...state};
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(state.map((k, v) => MapEntry(k, v.toMap()))));
    } catch (_) {}
  }

  void _put(String id, RecipeProgress p) {
    final copy = {...state};
    if (p.isEmpty) {
      copy.remove(id);
    } else {
      copy[id] = p;
    }
    state = copy;
    _save();
  }

  void setServings(String id, int servings) {
    final cur = state[id] ?? const RecipeProgress();
    _put(id, RecipeProgress(servings: servings, step: cur.step));
  }

  void setStep(String id, int step) {
    final cur = state[id] ?? const RecipeProgress();
    _put(id, RecipeProgress(servings: cur.servings, step: step < 0 ? 0 : step));
  }
}

final recipeProgressProvider =
    NotifierProvider<RecipeProgressNotifier, Map<String, RecipeProgress>>(RecipeProgressNotifier.new);
