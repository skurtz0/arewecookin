import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/providers/recipe_notes_provider.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/shopping_list_screen.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(ProviderContainer c, Widget home) => UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (ctx, w) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: w!,
        ),
        home: home,
      ),
    );

void main() {
  detailTest();
  shoppingGroupedTest();
  testWidgets('MealPlan with meals on several days at 1.8x text, 360px wide', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipes = (await RecipeRepository().getRecipes(limit: 4)).recipes;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(mealPlanProvider.notifier);
    n.add(DateTime.now().weekday, recipes[0]);
    n.add(DateTime.now().weekday, recipes[1]);
    n.add(1, recipes[2]);
    n.add(5, recipes[3]);
    await tester.pumpWidget(_app(c, const MealPlanScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Discover with cards, saved and cooked marks at 1.8x text, 360px wide', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipes = (await RecipeRepository().getRecipes(limit: 4)).recipes;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(_app(c, const Scaffold(body: DiscoverScreen())));
    await tester.pumpAndSettle();
    await c.read(savedRecipesProvider.notifier).toggleSave(recipes[0]);
    c.read(cookHistoryProvider.notifier).markCooked(recipes[0].id);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

void detailTest() {
  testWidgets('RecipeDetail with cooked, planned, rated and half servings at 1.8x text, 360px', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(cookHistoryProvider.notifier).markCooked(recipe.id);
    c.read(mealPlanProvider.notifier).add(1, recipe);
    c.read(mealPlanProvider.notifier).add(3, recipe);
    c.read(mealPlanProvider.notifier).add(7, recipe);
    c.read(recipeNotesProvider.notifier).setRating(recipe.id, 4);
    await tester.pumpWidget(_app(c, RecipeDetailScreen(recipe: recipe)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

void shoppingGroupedTest() {
  testWidgets('Grouped ShoppingList with long names at 1.8x text, 360px', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [
      ShoppingItem(name: 'Extra virgin olive oil, cold pressed', amount: '1,5', unit: 'litre', recipeTitle: 'Very long recipe title number one, Another long recipe title'),
      ShoppingItem(name: 'Süt', amount: '2', unit: 'su bardağı', recipeTitle: 'Menemen'),
      ShoppingItem(name: 'Un'),
      ShoppingItem(name: 'Yumurta', recipeTitle: 'Menemen', done: true),
    ]);
    await tester.pumpWidget(_app(c, const ShoppingListScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
