import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/locale_provider.dart';
import '../providers/meal_plan_provider.dart';

/// Long-press shortcut: pick a weekday and put this recipe on the meal plan.
Future<void> quickAddToPlan(BuildContext context, WidgetRef ref, Recipe recipe) async {
  final strings = ref.read(appStringsProvider);
  HapticFeedback.selectionClick();
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
              child: Text(strings.mealPlanPickDay,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            for (var d = 1; d <= 7; d++)
              ListTile(
                key: Key('card_plan_day_$d'),
                title: Text(d == DateTime.now().weekday
                    ? '${strings.weekdayName(d)} · ${strings.todayLabel}'
                    : strings.weekdayName(d)),
                trailing: (ref.read(mealPlanProvider)[d] ?? const <Recipe>[]).any((r) => r.id == recipe.id)
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
                    : null,
                onTap: () => Navigator.of(ctx).pop(d),
              ),
          ],
        ),
      ),
    ),
  );
  if (day == null || !context.mounted) return;
  final notifier = ref.read(mealPlanProvider.notifier);
  final ok = notifier.add(day, recipe);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(ok ? strings.mealPlanAddedTo(strings.weekdayName(day)) : strings.mealPlanAlready),
      action: ok
          ? SnackBarAction(
              key: const Key('card_plan_undo'),
              label: strings.undoLabel,
              onPressed: () => notifier.remove(day, recipe.id),
            )
          : null,
    ));
}
