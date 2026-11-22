import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Personal rating (1-5, 0 = none) and free-text note for one recipe.
class RecipeNote {
  final int rating;
  final String note;
  const RecipeNote({this.rating = 0, this.note = ''});

  bool get isEmpty => rating == 0 && note.trim().isEmpty;

  Map<String, dynamic> toMap() => {'r': rating, 'n': note};

  factory RecipeNote.fromMap(Map<String, dynamic> m) =>
      RecipeNote(rating: ((m['r'] as num?)?.toInt() ?? 0).clamp(0, 5), note: m['n'] as String? ?? '');
}

/// Notes and ratings keyed by recipe id; stored on the device (works offline).
class RecipeNotesNotifier extends Notifier<Map<String, RecipeNote>> {
  static const _prefKey = 'recipe_notes_v1';

  @override
  Map<String, RecipeNote> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final loaded = <String, RecipeNote>{};
      map.forEach((id, v) {
        try {
          final n = RecipeNote.fromMap(Map<String, dynamic>.from(v as Map));
          if (!n.isEmpty) loaded[id] = n;
        } catch (_) {}
      });
      // Edits made before loading finished win over stored values.
      state = {...loaded, ...state};
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(state.map((k, v) => MapEntry(k, v.toMap()))));
    } catch (_) {}
  }

  RecipeNote of(String recipeId) => state[recipeId] ?? const RecipeNote();

  void _put(String id, RecipeNote n) {
    final copy = {...state};
    if (n.isEmpty) {
      copy.remove(id);
    } else {
      copy[id] = n;
    }
    state = copy;
    _save();
  }

  /// Tapping the current rating again clears it.
  void setRating(String id, int rating) {
    final cur = of(id);
    _put(id, RecipeNote(rating: cur.rating == rating ? 0 : rating.clamp(0, 5), note: cur.note));
  }

  void setNote(String id, String note) {
    final cur = of(id);
    _put(id, RecipeNote(rating: cur.rating, note: note));
  }
}

final recipeNotesProvider =
    NotifierProvider<RecipeNotesNotifier, Map<String, RecipeNote>>(RecipeNotesNotifier.new);
