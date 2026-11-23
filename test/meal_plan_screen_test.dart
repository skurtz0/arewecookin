import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('meal plan screen marks today and can be cleared after confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(mealPlanProvider.notifier).add(DateTime.now().weekday, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Today'), findsOneWidget);
    final day = DateTime.now().weekday;
    expect(find.byKey(Key('plan_day_total_$day')), findsOneWidget);
    expect(find.textContaining('${recipe.totalTime}'), findsWidgets);
    await tester.tap(find.byKey(const Key('plan_clear')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_clear_confirm')));
    await tester.pumpAndSettle();
    expect(container.read(mealPlanProvider), isEmpty);
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(container.read(mealPlanProvider)[DateTime.now().weekday]!.single.id, recipe.id);
  });

  testWidgets('removing a planned meal can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final day = DateTime.now().weekday;
    container.read(mealPlanProvider.notifier).add(day, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plan_remove_${day}_${recipe.id}')));
    await tester.pumpAndSettle();
    expect(container.read(mealPlanProvider), isEmpty);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(container.read(mealPlanProvider)[day]!.length, 1);
  });

  testWidgets('a planned meal can be moved to another day', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(mealPlanProvider.notifier).add(1, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plan_move_1_${recipe.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_move_to_5')));
    await tester.pumpAndSettle();
    final plan = container.read(mealPlanProvider);
    expect(plan.containsKey(1), isFalse);
    expect(plan[5]!.single.id, recipe.id);
  });

  testWidgets('planned meals show a thumbnail', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(mealPlanProvider.notifier).add(2, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('plan_thumb_2_${recipe.id}')), findsOneWidget);
  });
}
