import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:arewecookin/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> check(WidgetTester tester, Widget Function(Recipe) build) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360 * 2, 740 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: w!,
        ),
        home: build(recipe),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  }

  testWidgets('RecipeDetail at 1.8x text', (t) => check(t, (r) => RecipeDetailScreen(recipe: r)));
  testWidgets('CookingMode at 1.8x text', (t) => check(t, (r) => CookingModeScreen(recipe: r)));
  testWidgets('Pantry at 1.8x text', (t) => check(t, (_) => const PantryScreen()));
}
