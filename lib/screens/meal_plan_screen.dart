import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import '../providers/household_servings_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/user_recipes_provider.dart';
import '../widgets/avoided_badge.dart';
import '../widgets/recipe_image.dart';
import 'cooking_mode_screen.dart';
import 'recipe_detail_screen.dart';
import '../models/models.dart';

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final plan = ref.watch(mealPlanProvider);
    final total = plan.values.fold<int>(0, (a, l) => a + l.length);

    Future<void> addFromSaved() async {
      final saved = ref.read(savedRecipesProvider).recipes;
      if (saved.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(strings.planFromSavedEmpty)));
        return;
      }
      final recipe = await showModalBottomSheet<Recipe>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
          child: ListView(
            key: const Key('plan_saved_list'),
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  strings.planFromSaved,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              for (final r in saved)
                ListTile(
                  key: Key('plan_saved_${r.id}'),
                  title: Text(r.localizedTitle(strings.locale)),
                  subtitle: Text(strings.minutesShort(r.totalTime)),
                  onTap: () => Navigator.of(ctx).pop(r),
                ),
            ],
          ),
        ),
      );
      if (recipe == null || !context.mounted) return;
      final day = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    strings.mealPlanPickDay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (var d = 1; d <= 7; d++)
                  ListTile(
                    key: Key('plan_add_day_$d'),
                    title: Text(strings.weekdayName(d)),
                    onTap: () => Navigator.of(ctx).pop(d),
                  ),
              ],
            ),
          ),
        ),
      );
      if (day == null || !context.mounted) return;
      final ok = ref.read(mealPlanProvider.notifier).add(day, recipe);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? strings.mealPlanAddedTo(strings.weekdayName(day))
                  : strings.mealPlanAlready,
            ),
          ),
        );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('plan_add_from_saved'),
        heroTag: 'plan_add_fab',
        onPressed: addFromSaved,
        icon: const Icon(Icons.bookmark_add_outlined),
        label: Text(strings.planFromSaved),
      ),
      appBar: AppBar(
        title: Text(strings.mealPlanTitle),
        actions: [
          if (total > 0)
            IconButton(
              key: const Key('plan_copy'),
              tooltip: strings.planCopy,
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                final text = ref
                    .read(mealPlanProvider.notifier)
                    .asText(
                      strings.weekdayName,
                      (r) => r.localizedTitle(strings.locale),
                      strings.minutesShort,
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
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(strings.cancel),
                      ),
                      TextButton(
                        key: const Key('plan_clear_confirm'),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(strings.mealPlanClear),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  final notifier = ref.read(mealPlanProvider.notifier);
                  final before = ref.read(mealPlanProvider);
                  notifier.clear();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(strings.listCleared),
                        action: SnackBarAction(
                          label: strings.undoLabel,
                          onPressed: () => notifier.restore(before),
                        ),
                      ),
                    );
                }
              },
            ),
          if (total > 0)
            IconButton(
              key: const Key('plan_to_shopping_list'),
              tooltip: strings.mealPlanToList,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              onPressed: () => _addToShopping(
                ref,
                context,
                strings,
                plan.values.expand((e) => e),
              ),
            ),
        ],
      ),
      body: total == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.mealPlanEmptyTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.mealPlanEmptyHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                for (var day = 1; day <= 7; day++)
                  if ((plan[day] ?? const []).isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              header: true,
                              child: Text(
                                '${day == DateTime.now().weekday ? '${strings.weekdayName(day)} · ${strings.todayLabel}' : strings.weekdayName(day)}'
                                ' · ${strings.minutesShort(plan[day]!.fold<int>(0, (a, r) => a + r.totalTime))}',
                                key: Key('plan_day_total_$day'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF5722),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            key: Key('plan_day_clear_$day'),
                            tooltip: strings.mealPlanClearDay,
                            icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                            onPressed: () {
                              final before = ref.read(mealPlanProvider);
                              ref.read(mealPlanProvider.notifier).clearDay(day);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  content: Text(strings.mealPlanClearDay),
                                  action: SnackBarAction(
                                    key: const Key('plan_day_clear_undo'),
                                    label: strings.undoLabel,
                                    onPressed: () => ref
                                        .read(mealPlanProvider.notifier)
                                        .restore(before),
                                  ),
                                ));
                            },
                          ),
                          IconButton(
                            key: Key('plan_day_copy_$day'),
                            tooltip: strings.mealPlanCopyDay,
                            icon: const Icon(Icons.copy_all_rounded, size: 20),
                            onPressed: () async {
                              final to = await showModalBottomSheet<int>(
                                context: context,
                                builder: (ctx) => SafeArea(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(strings.mealPlanPickDay,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                        for (var d = 1; d <= 7; d++)
                                          if (d != day)
                                            ListTile(
                                              key: Key('plan_copy_to_$d'),
                                              title: Text(strings.weekdayName(d)),
                                              onTap: () => Navigator.of(ctx).pop(d),
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              if (to == null || !context.mounted) return;
                              final before = ref.read(mealPlanProvider);
                              final n = ref.read(mealPlanProvider.notifier).copyDay(day, to);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  content: Text(n > 0
                                      ? strings.mealPlanAddedTo(strings.weekdayName(to))
                                      : strings.mealPlanAlready),
                                  action: n == 0
                                      ? null
                                      : SnackBarAction(
                                          key: const Key('plan_copy_undo'),
                                          label: strings.undoLabel,
                                          onPressed: () => ref
                                              .read(mealPlanProvider.notifier)
                                              .restore(before),
                                        ),
                                ));
                            },
                          ),
                          IconButton(
                            key: Key('plan_day_to_list_$day'),
                            tooltip: strings.mealPlanDayToList,
                            icon: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 20,
                            ),
                            onPressed: () => _addToShopping(
                              ref,
                              context,
                              strings,
                              plan[day]!,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final r in plan[day]!)
                      Dismissible(
                        key: ValueKey('plan_row_${day}_${r.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: AlignmentDirectional.centerEnd,
                          padding: const EdgeInsetsDirectional.only(end: 20),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          final notifier = ref.read(mealPlanProvider.notifier);
                          notifier.remove(day, r.id);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(strings.mealPlanRemove),
                                action: SnackBarAction(
                                  key: const Key('plan_swipe_undo'),
                                  label: strings.undoLabel,
                                  onPressed: () => notifier.add(day, r),
                                ),
                              ),
                            );
                        },
                        child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: RecipeImage(
                            key: Key('plan_thumb_${day}_${r.id}'),
                            imageUrl: r.imageUrl,
                            category: r.category,
                            width: 52,
                            height: 52,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Text(r.localizedTitle(strings.locale)),
                          subtitle: Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(strings.minutesShort(r.totalTime)),
                              AvoidedBadge(recipe: r),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(recipe: r),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                key: Key('plan_cook_${day}_${r.id}'),
                                tooltip: strings.startCooking,
                                icon: const Icon(
                                  Icons.play_circle_outline_rounded,
                                  color: Color(0xFFFF5722),
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CookingModeScreen(recipe: r),
                                  ),
                                ),
                              ),
                              IconButton(
                                key: Key('plan_move_${day}_${r.id}'),
                                tooltip: strings.mealPlanMove,
                                icon: const Icon(Icons.swap_horiz_rounded),
                                onPressed: () async {
                                  final to = await showModalBottomSheet<int>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (ctx) => SafeArea(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                strings.mealPlanMove,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            for (var d = 1; d <= 7; d++)
                                              if (d != day)
                                                ListTile(
                                                  key: Key('plan_move_to_$d'),
                                                  title: Text(
                                                    strings.weekdayName(d),
                                                  ),
                                                  onTap: () =>
                                                      Navigator.of(ctx).pop(d),
                                                ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                  if (to != null) {
                                    ref
                                        .read(mealPlanProvider.notifier)
                                        .move(day, to, r);
                                  }
                                },
                              ),
                              IconButton(
                                key: Key('plan_remove_${day}_${r.id}'),
                                tooltip: strings.mealPlanRemove,
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  final notifier = ref.read(
                                    mealPlanProvider.notifier,
                                  );
                                  notifier.remove(day, r.id);
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(strings.mealPlanRemove),
                                        action: SnackBarAction(
                                          label: strings.undoLabel,
                                          onPressed: () => notifier.add(day, r),
                                        ),
                                      ),
                                    );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                  ],
              ],
            ),
    );
  }
}

void _addToShopping(
  WidgetRef ref,
  BuildContext context,
  AppStrings strings,
  Iterable<Recipe> recipes,
) {
  final items = <ShoppingItem>[];
  // With a default servings preference set, amounts are scaled to it (like the recipe screen does).
  final household = ref.read(householdServingsProvider);
  String scaled(Recipe r, String raw) {
    final n = double.tryParse(raw.replaceAll(',', '.'));
    if (household == null || n == null || r.servings <= 0) return raw;
    final v = n * household / r.servings;
    return v == v.toInt() ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  for (final r in recipes) {
    for (final i in r.ingredients.where((i) => !i.isOptional)) {
      items.add(
        ShoppingItem(
          name: i.localizedName(strings.locale),
          amount: scaled(r, i.amount),
          unit: i.localizedUnit(strings.locale),
          recipeTitle: r.localizedTitle(strings.locale),
        ),
      );
    }
  }
  final before = List.of(ref.read(shoppingListProvider));
  final added = ref.read(shoppingListProvider.notifier).addAll(items);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          added == 0
              ? strings.shoppingNothingNew
              : strings.shoppingAdded(added),
        ),
        action: added == 0
            ? null
            : SnackBarAction(
                key: const Key('shopping_add_undo'),
                label: strings.undoLabel,
                onPressed: () =>
                    ref.read(shoppingListProvider.notifier).restore(before),
              ),
      ),
    );
}
