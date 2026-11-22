import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('day picker marks days that already have this recipe', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(mealPlanProvider.notifier).add(3, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    final btn = find.byKey(const Key('add_to_meal_plan'));
    await tester.ensureVisible(btn);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('plan_day_has_recipe')), findsOneWidget);
    expect(
      find.descendant(of: find.byKey(const Key('plan_day_3')), matching: find.byKey(const Key('plan_day_has_recipe'))),
      findsOneWidget,
    );
  });

  testWidgets('detail shows on which days the recipe is planned', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('planned_on')), findsNothing);
    c.read(mealPlanProvider.notifier).add(2, recipe);
    c.read(mealPlanProvider.notifier).add(5, recipe);
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(find.byKey(const Key('planned_on'))).data!;
    expect(text, startsWith('Planned: '));
    expect(text.split(', ').length, 2);
  });
}
