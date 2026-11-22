import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How often (and when last) the user finished cooking a recipe. Stored on the device.
class CookRecord {
  final int count;
  final DateTime? last;
  const CookRecord({this.count = 0, this.last});

  Map<String, dynamic> toMap() => {'c': count, if (last != null) 'l': last!.toIso8601String()};

  factory CookRecord.fromMap(Map<String, dynamic> m) => CookRecord(
        count: (m['c'] as num?)?.toInt() ?? 0,
        last: DateTime.tryParse(m['l'] as String? ?? ''),
      );
}

class CookHistoryNotifier extends Notifier<Map<String, CookRecord>> {
  static const _prefKey = 'cook_history_v1';

  @override
  Map<String, CookRecord> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return;
      final loaded = <String, CookRecord>{};
      (jsonDecode(raw) as Map<String, dynamic>).forEach((id, v) {
        try {
          final r = CookRecord.fromMap(Map<String, dynamic>.from(v as Map));
          if (r.count > 0) loaded[id] = r;
        } catch (_) {}
      });
      // Anything recorded before loading finished is added on top of the stored count.
      final merged = {...loaded};
      state.forEach((id, r) {
        final old = loaded[id];
        merged[id] = CookRecord(count: (old?.count ?? 0) + r.count, last: r.last ?? old?.last);
      });
      state = merged;
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(state.map((k, v) => MapEntry(k, v.toMap()))));
    } catch (_) {}
  }

  void markCooked(String recipeId, {DateTime? at}) {
    final cur = state[recipeId] ?? const CookRecord();
    state = {...state, recipeId: CookRecord(count: cur.count + 1, last: at ?? DateTime.now())};
    _save();
  }
}

final cookHistoryProvider =
    NotifierProvider<CookHistoryNotifier, Map<String, CookRecord>>(CookHistoryNotifier.new);
