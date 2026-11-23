import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Words (allergens, dislikes) the user never wants in Discover results. Each one works like a
/// "-word" exclusion in the search: recipes with it in the title or an ingredient are left out.
/// Stored on the device.
class AvoidedIngredientsNotifier extends Notifier<List<String>> {
  static const _prefKey = 'avoided_ingredients_v1';
  bool _touched = false;

  @override
  List<String> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null || _touched) return;
      state = [for (final e in jsonDecode(raw) as List) '$e'];
    } catch (_) {}
  }

  /// Adds the words in [text] (separated by commas, semicolons or spaces). Returns how many were new.
  int add(String text) {
    _touched = true;
    final next = [...state];
    var added = 0;
    for (final w in text.split(RegExp(r'[,;\s]+'))) {
      final word = w.trim().toLowerCase().replaceAll(RegExp(r'^-+'), '');
      if (word.length < 2 || next.contains(word)) continue;
      next.add(word);
      added++;
    }
    if (added > 0) {
      state = next;
      _save();
    }
    return added;
  }

  void remove(String word) {
    _touched = true;
    state = state.where((w) => w != word).toList();
    _save();
  }

  void _save() {
    () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, jsonEncode(state));
      } catch (_) {}
    }();
  }
}

final avoidedIngredientsProvider =
    NotifierProvider<AvoidedIngredientsNotifier, List<String>>(AvoidedIngredientsNotifier.new);
