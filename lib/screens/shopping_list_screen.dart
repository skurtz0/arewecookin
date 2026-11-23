import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import '../providers/pantry_provider.dart';
import '../providers/shopping_list_provider.dart';
import 'meal_plan_screen.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(shoppingListProvider.notifier).addAll(ShoppingItem.parseMany(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final items = ref.watch(shoppingListProvider);
    final notifier = ref.read(shoppingListProvider.notifier);
    final doneCount = items.where((e) => e.done).length;
    final order = [
      for (var n = 0; n < items.length; n++)
        if (!items[n].done) n,
      for (var n = 0; n < items.length; n++)
        if (items[n].done) n,
    ];

    void clearWithUndo(void Function() clear) {
      final before = [...items];
      clear();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(strings.listCleared),
          action: SnackBarAction(
            label: strings.undoLabel,
            onPressed: () => notifier.restore(before),
          ),
        ));
    }

    Future<void> editItem(int i, ShoppingItem item) async {
      final qty = [item.amount, item.unit].where((e) => e.trim().isNotEmpty).join(' ');
      final controller = TextEditingController(text: [qty, item.name].where((e) => e.isNotEmpty).join(' '));
      final text = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(strings.shoppingEditItem),
          content: TextField(
            key: const Key('shopping_edit_field'),
            controller: controller,
            autofocus: true,
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(strings.cancel)),
            TextButton(
              key: const Key('shopping_edit_save'),
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: Text(strings.saveChanges),
            ),
          ],
        ),
      );
      if (text != null) notifier.replaceAt(i, ShoppingItem.parse(text));
    }

    void removeItem(int i, ShoppingItem removed) {
      notifier.removeAt(i);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(strings.itemRemoved),
          action: SnackBarAction(
            label: strings.undoLabel,
            onPressed: () => notifier.insertAt(i, removed),
          ),
        ));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.shoppingListTitle),
            if (items.isNotEmpty)
              Text(
                '$doneCount / ${items.length}',
                key: const Key('shopping_progress'),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('open_meal_plan'),
            tooltip: strings.mealPlanTitle,
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MealPlanScreen())),
          ),
          if (items.isNotEmpty)
            IconButton(
              key: const Key('copy_shopping_list'),
              tooltip: strings.shoppingCopy,
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: notifier.asText()));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(strings.shoppingCopied)),
                  );
              },
            ),
          if (items.isNotEmpty)
            IconButton(
              key: const Key('shopping_toggle_all'),
              tooltip: strings.shoppingToggleAll,
              icon: Icon(doneCount == items.length ? Icons.remove_done_rounded : Icons.done_all_rounded),
              onPressed: notifier.toggleAll,
            ),
          if (items.isNotEmpty)
            IconButton(
              key: const Key('shopping_clear_all'),
              tooltip: strings.shoppingClearAll,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(strings.shoppingClearAll),
                    content: Text(strings.shoppingClearAllConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(strings.cancel)),
                      TextButton(
                        key: const Key('shopping_clear_all_confirm'),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(strings.shoppingClearAll),
                      ),
                    ],
                  ),
                );
                if (ok == true) clearWithUndo(notifier.clearAll);
              },
            ),
          if (doneCount > 0)
            IconButton(
              key: const Key('shopping_to_pantry'),
              tooltip: strings.shoppingToPantry,
              icon: const Icon(Icons.kitchen_outlined),
              onPressed: () async {
                final names = [for (final e in items) if (e.done) e.name];
                final added = await ref.read(pantryProvider.notifier).addIngredients(names);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(strings.pantryAdded(added))));
              },
            ),
          if (doneCount > 0)
            IconButton(
              key: const Key('shopping_clear_done'),
              tooltip: strings.shoppingClearDone,
              icon: const Icon(Icons.playlist_remove_rounded),
              onPressed: () => clearWithUndo(notifier.clearDone),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              key: const Key('shopping_add_field'),
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: strings.shoppingAddHint,
                prefixIcon: const Icon(Icons.add_rounded),
                suffixIcon: IconButton(
                  tooltip: strings.shoppingAddHint,
                  icon: const Icon(Icons.check_rounded),
                  onPressed: _submit,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  strings.shoppingHint,
                  key: const Key('shopping_hint'),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            strings.shoppingEmptyTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.shoppingEmptyHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: order.length,
                    itemBuilder: (context, pos) {
                      // Checked items sink to the bottom; `i` is the real index in the stored list.
                      final i = order[pos];
                      final item = items[i];
                      final qty = [
                        item.amount,
                        item.unit,
                      ].where((e) => e.trim().isNotEmpty).join(' ');
                      return Dismissible(
                        key: ValueKey('shop_${item.key}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red.shade400,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => removeItem(i, item),
                        child: Semantics(
                          customSemanticsActions: {
                            CustomSemanticsAction(label: strings.shoppingDeleteItem): () => removeItem(i, item),
                          },
                          child: GestureDetector(
                            onLongPress: () => editItem(i, item),
                            child: CheckboxListTile(
                          value: item.done,
                          onChanged: (_) => notifier.toggle(i),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFF10B981),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              decoration: item.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.done
                                  ? Colors.grey
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: item.recipeTitle.isEmpty
                              ? null
                              : Text(item.recipeTitle),
                          secondary: qty.isEmpty
                              ? null
                              : Text(
                                  qty,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF5722),
                                  ),
                                ),
                        ),
                        ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
