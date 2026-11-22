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

  static final _quick = RegExp(r'^(\d+(?:[.,]\d+)?)\s*([^\s\d]+)?\s+(.+)$');
  static const _knownUnits = {
    'kg', 'g', 'gr', 'l', 'lt', 'ml', 'adet', 'paket', 'kutu', 'şişe', 'bardak', 'kaşık',
    'pcs', 'lb', 'oz', 'pack', 'can', 'bottle', 'cup', 'tbsp', 'tsp',
  };

  /// Parses typed text like "2 kg süt", "3 yumurta" or "süt" into amount, unit and name.
  factory ShoppingItem.parse(String text) {
    final t = text.trim();
    final m = _quick.firstMatch(t);
    if (m == null) return ShoppingItem(name: t);
    final amount = m.group(1)!.replaceAll(',', '.');
    final unit = m.group(2);
    final rest = m.group(3)!.trim();
    if (unit != null && _knownUnits.contains(unit.toLowerCase())) {
      return ShoppingItem(name: rest, amount: amount, unit: unit);
    }
    // No known unit: the "unit" word belongs to the name ("3 büyük domates").
    return ShoppingItem(name: [?unit, rest].join(' '), amount: amount);
  }

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
      final have = state.map((e) => e.key).toSet();
      state = [...state, ...items.where((e) => have.add(e.key))];
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state.map((e) => jsonEncode(e.toMap())).toList());
    } catch (_) {}
  }

  static double? _num(String v) => double.tryParse(v.trim().replaceAll(',', '.'));

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  /// Adds items. An item that is already on the list is skipped, except when both have a
  /// numeric amount in the same unit and come from a different recipe: then the amounts are summed.
  /// Returns how many items were added or merged.
  int addAll(Iterable<ShoppingItem> items) {
    final next = [...state];
    var changed = 0;
    for (final i in items) {
      if (i.name.trim().isEmpty) continue;
      final idx = next.indexWhere((e) => e.key == i.key);
      if (idx < 0) {
        next.add(i);
        changed++;
        continue;
      }
      final old = next[idx];
      final a = _num(old.amount), b = _num(i.amount);
      final newSource = i.recipeTitle.isNotEmpty && !old.recipeTitle.split(', ').contains(i.recipeTitle);
      if (a != null && b != null && old.unit.trim().toLowerCase() == i.unit.trim().toLowerCase() && newSource) {
        next[idx] = ShoppingItem(
          name: old.name,
          amount: _fmt(a + b),
          unit: old.unit,
          recipeTitle: old.recipeTitle.isEmpty ? i.recipeTitle : '${old.recipeTitle}, ${i.recipeTitle}',
          done: false,
        );
        changed++;
      }
    }
    if (changed == 0) return 0;
    state = next;
    _save();
    return changed;
  }

  void toggle(int index) {
    if (index < 0 || index >= state.length) return;
    final next = [...state];
    next[index] = next[index].copyWith(done: !next[index].done);
    state = next;
    _save();
  }

  /// Puts an item back at [index] (used by "Undo" after a swipe-delete).
  void insertAt(int index, ShoppingItem item) {
    if (state.any((e) => e.key == item.key)) return;
    final next = [...state];
    next.insert(index.clamp(0, next.length), item);
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
