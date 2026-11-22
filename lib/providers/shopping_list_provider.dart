import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One line on the shopping list. Names are stored already localized
/// (the language the user had when adding), so the list is readable offline.
class ShoppingItem {
  final String name;
  final String amount;
  final String unit;
  final String recipeTitle;
  final bool done;

  const ShoppingItem({
    required this.name,
    this.amount = '',
    this.unit = '',
    this.recipeTitle = '',
    this.done = false,
  });

  String get key => name.trim().toLowerCase();

  ShoppingItem copyWith({bool? done}) => ShoppingItem(
        name: name,
        amount: amount,
        unit: unit,
        recipeTitle: recipeTitle,
        done: done ?? this.done,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'amount': amount,
        'unit': unit,
        'recipe': recipeTitle,
        'done': done,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> m) => ShoppingItem(
        name: m['name'] as String? ?? '',
        amount: m['amount']?.toString() ?? '',
        unit: m['unit'] as String? ?? '',
        recipeTitle: m['recipe'] as String? ?? '',
        done: m['done'] as bool? ?? false,
      );
}

class ShoppingListNotifier extends Notifier<List<ShoppingItem>> {
  static const _prefKey = 'shopping_list_v1';

  @override
  List<ShoppingItem> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? const [];
      final items = <ShoppingItem>[];
      for (final s in raw) {
        try {
          final item = ShoppingItem.fromMap(jsonDecode(s) as Map<String, dynamic>);
          if (item.name.isNotEmpty) items.add(item);
        } catch (_) {}
      }
      // Items added before the load finished stay on top.
      state = [...state, ...items];
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state.map((e) => jsonEncode(e.toMap())).toList());
    } catch (_) {}
  }

  /// Adds items, skipping ones whose name is already on the list. Returns how many were added.
  int addAll(Iterable<ShoppingItem> items) {
    final keys = state.map((e) => e.key).toSet();
    final fresh = <ShoppingItem>[];
    for (final i in items) {
      if (i.name.trim().isEmpty || !keys.add(i.key)) continue;
      fresh.add(i);
    }
    if (fresh.isEmpty) return 0;
    state = [...state, ...fresh];
    _save();
    return fresh.length;
  }

  void toggle(int index) {
    if (index < 0 || index >= state.length) return;
    final next = [...state];
    next[index] = next[index].copyWith(done: !next[index].done);
    state = next;
    _save();
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
    _save();
  }

  void clearDone() {
    state = state.where((e) => !e.done).toList();
    _save();
  }

  /// Plain-text version of the list (unchecked first), for sharing/pasting.
  String asText() {
    final lines = <String>[];
    for (final i in [...state.where((e) => !e.done), ...state.where((e) => e.done)]) {
      final qty = [i.amount, i.unit].where((e) => e.trim().isNotEmpty).join(' ');
      lines.add('${i.done ? '[x]' : '[ ]'} ${i.name}${qty.isEmpty ? '' : ' - $qty'}');
    }
    return lines.join('\n');
  }

  void clearAll() {
    state = const [];
    _save();
  }
}

final shoppingListProvider =
    NotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(ShoppingListNotifier.new);
