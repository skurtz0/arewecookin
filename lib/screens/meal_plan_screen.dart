import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/shopping_list_provider.dart';
import 'recipe_detail_screen.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final plan = ref.watch(mealPlanProvider);
    final total = plan.values.fold<int>(0, (a, l) => a + l.length);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(strings.mealPlanTitle),
        actions: [
          if (total > 0)
            IconButton(
              key: const Key('plan_copy'),
              tooltip: strings.planCopy,
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                final text = ref.read(mealPlanProvider.notifier).asText(
                      strings.weekdayName,
                      (r) => r.localizedTitle(strings.locale),
                    );
                await Clipboard.setData(ClipboardData(text: text));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(strings.planCopied)));
              },
            ),
          if (total > 0)
            IconButton(
              key: const Key('plan_clear'),
              tooltip: strings.mealPlanClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(strings.mealPlanClear),
                    content: Text(strings.mealPlanClearConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(strings.cancel)),
                      TextButton(
                        key: const Key('plan_clear_confirm'),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(strings.mealPlanClear),
                      ),
                    ],
                  ),
                );
                if (ok == true) ref.read(mealPlanProvider.notifier).clear();
              },
            ),
          if (total > 0)
            IconButton(
              key: const Key('plan_to_shopping_list'),
              tooltip: strings.mealPlanToList,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              onPressed: () {
                final items = <ShoppingItem>[];
                for (final recipes in plan.values) {
                  for (final r in recipes) {
                    for (final i in r.ingredients.where((i) => !i.isOptional)) {
                      items.add(ShoppingItem(
                        name: i.localizedName(strings.locale),
                        amount: i.amount,
                        unit: i.localizedUnit(strings.locale),
                        recipeTitle: r.localizedTitle(strings.locale),
                      ));
                    }
                  }
                }
                final added = ref.read(shoppingListProvider.notifier).addAll(items);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(added == 0
                        ? strings.shoppingNothingNew
                        : strings.shoppingAdded(added)),
                  ));
              },
            ),
        ],
      ),
      body: total == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(strings.mealPlanEmptyTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(strings.mealPlanEmptyHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600)),
                ]),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var day = 1; day <= 7; day++)
                  if ((plan[day] ?? const []).isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: Text(
                          '${day == DateTime.now().weekday ? '${strings.weekdayName(day)} · ${strings.todayLabel}' : strings.weekdayName(day)}'
                          ' · ${strings.minutesShort(plan[day]!.fold<int>(0, (a, r) => a + r.totalTime))}',
                          key: Key('plan_day_total_$day'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                    ),
                    for (final r in plan[day]!)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(r.localizedTitle(strings.locale)),
                          subtitle: Text('${r.totalTime} min'),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r))),
                          trailing: IconButton(
                            key: Key('plan_remove_${day}_${r.id}'),
                            tooltip: strings.mealPlanRemove,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              final notifier = ref.read(mealPlanProvider.notifier);
                              notifier.remove(day, r.id);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  content: Text(strings.mealPlanRemove),
                                  action: SnackBarAction(
                                    label: strings.undoLabel,
                                    onPressed: () => notifier.add(day, r),
                                  ),
                                ));
                            },
                          ),
                        ),
                      ),
                  ],
              ],
            ),
    );
  }
}
