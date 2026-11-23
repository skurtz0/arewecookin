import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('meal plan day titles are headings for screen readers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final handle = tester.ensureSemantics();
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(mealPlanProvider.notifier).add(3, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: MealPlanScreen())));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.byKey(const Key('plan_day_total_3')));
    expect(node.getSemanticsData().flagsCollection.isHeader, isTrue);
    handle.dispose();
  });

  testWidgets('detail section titles are headings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final handle = tester.ensureSemantics();
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: RecipeDetailScreen(recipe: recipe))));
    await tester.pumpAndSettle();
    final title = find.text('Required Ingredients');
    await tester.ensureVisible(title);
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.ancestor(of: title, matching: find.byWidgetPredicate((w) => w is Semantics && w.properties.header == true)).first);
    expect(node.getSemanticsData().flagsCollection.isHeader, isTrue);
    handle.dispose();
  });
}
