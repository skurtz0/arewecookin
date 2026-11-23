import 'package:arewecookin/providers/household_servings_provider.dart';
import 'package:arewecookin/providers/recipe_progress_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/account_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('household servings are clamped and remembered', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(householdServingsProvider.notifier).set(500);
    expect(c.read(householdServingsProvider), 99);
    c.read(householdServingsProvider.notifier).set(2);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect((await SharedPreferences.getInstance()).getInt('household_servings_v1'), 2);
    c.read(householdServingsProvider.notifier).set(null);
    expect(c.read(householdServingsProvider), isNull);
  });

  testWidgets('recipes open scaled to the household size unless the user chose another number', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(householdServingsProvider.notifier).set(recipe.servings + 3);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('${recipe.servings + 3}'), findsWidgets);
    // A number picked for this recipe wins over the household size.
    c.read(recipeProgressProvider.notifier).setServings(recipe.id, recipe.servings + 1);
    await tester.pumpAndSettle();
    expect(find.textContaining('${recipe.servings + 1} '), findsWidgets);
  });

  testWidgets('account preferences step the household size and survive 1.8x text at 360px', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (ctx, w) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: w!,
        ),
        home: const AccountScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    final more = find.byKey(const Key('household_more'));
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(c.read(householdServingsProvider), 2);
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(c.read(householdServingsProvider), 3);
    final less = find.byKey(const Key('household_less'));
    await tester.tap(less);
    await tester.pumpAndSettle();
    await tester.tap(less);
    await tester.pumpAndSettle();
    expect(c.read(householdServingsProvider), 1);
    await tester.tap(less);
    await tester.pumpAndSettle();
    expect(c.read(householdServingsProvider), isNull);
    expect(tester.takeException(), isNull);
  });
}
