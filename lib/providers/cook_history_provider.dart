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

  bool _loaded = false;
  // Cooks recorded before the stored history finished loading (kept apart so they are added, not double-counted).
  final Map<String, int> _pendingCount = {};
  final Map<String, DateTime> _pendingLast = {};

  Future<void> _load() async {
    final loaded = <String, CookRecord>{};
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        (jsonDecode(raw) as Map<String, dynamic>).forEach((id, v) {
          try {
            final r = CookRecord.fromMap(Map<String, dynamic>.from(v as Map));
            if (r.count > 0) loaded[id] = r;
          } catch (_) {}
        });
      }
    } catch (_) {
      // Unreadable storage: do not overwrite it with a partial history.
      return;
    }
    final merged = {...loaded};
    _pendingCount.forEach((id, n) {
      final old = loaded[id];
      merged[id] = CookRecord(count: (old?.count ?? 0) + n, last: _pendingLast[id] ?? old?.last);
    });
    final hadPending = _pendingCount.isNotEmpty;
    _pendingCount.clear();
    _pendingLast.clear();
    _loaded = true;
    state = merged;
    if (hadPending) _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(state.map((k, v) => MapEntry(k, v.toMap()))));
    } catch (_) {}
  }

  void markCooked(String recipeId, {DateTime? at}) {
    final when = at ?? DateTime.now();
    final cur = state[recipeId] ?? const CookRecord();
    state = {...state, recipeId: CookRecord(count: cur.count + 1, last: when)};
    if (_loaded) {
      _save();
    } else {
      _pendingCount[recipeId] = (_pendingCount[recipeId] ?? 0) + 1;
      _pendingLast[recipeId] = when;
    }
  }
}

final cookHistoryProvider =
    NotifierProvider<CookHistoryNotifier, Map<String, CookRecord>>(CookHistoryNotifier.new);
