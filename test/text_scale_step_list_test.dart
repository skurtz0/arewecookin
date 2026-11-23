import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('cooking step list has no overflow at 360x640 and 1.8x text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipes = (await RecipeRepository().getRecipes(limit: 30)).recipes;
    final r = recipes.firstWhere((r) => r.steps.any((s) => s.timerSeconds >= 60));
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        builder: (ctx, w) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: w!,
        ),
        home: CookingModeScreen(recipe: r),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('step_overview_open')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('step_overview_0')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cooking ingredient sheet with servings buttons has no overflow at 360x640, 1.8x', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipes = (await RecipeRepository().getRecipes(limit: 5)).recipes;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        builder: (ctx, w) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: w!,
        ),
        home: CookingModeScreen(recipe: recipes.first),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const Key('cook_ingredients_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cook_servings_more')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
