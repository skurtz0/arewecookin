import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/shopping_list_provider.dart';
import 'meal_plan_screen.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final items = ref.watch(shoppingListProvider);
    final notifier = ref.read(shoppingListProvider.notifier);
    final doneCount = items.where((e) => e.done).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(strings.shoppingListTitle),
        actions: [
          IconButton(
            key: const Key('open_meal_plan'),
            tooltip: strings.mealPlanTitle,
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const MealPlanScreen())),
          ),
          if (doneCount > 0)
            TextButton(
              onPressed: notifier.clearDone,
              child: Text(strings.shoppingClearDone),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      strings.shoppingEmptyTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final qty = [item.amount, item.unit].where((e) => e.trim().isNotEmpty).join(' ');
                return Dismissible(
                  key: ValueKey('shop_${item.key}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red.shade400,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) => notifier.removeAt(i),
                  child: CheckboxListTile(
                    value: item.done,
                    onChanged: (_) => notifier.toggle(i),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF10B981),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.done ? TextDecoration.lineThrough : null,
                        color: item.done ? Colors.grey : const Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: item.recipeTitle.isEmpty ? null : Text(item.recipeTitle),
                    secondary: qty.isEmpty
                        ? null
                        : Text(qty,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                  ),
                );
              },
            ),
    );
  }
}
