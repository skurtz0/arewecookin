import 'package:arewecookin/providers/locale_provider.dart';
import 'package:arewecookin/providers/recipe_progress_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('progress: servings and step persist, empty progress is dropped', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    final n = a.read(recipeProgressProvider.notifier);
    n.setServings('r', 6);
    n.setStep('r', 2);
    n.setStep('x', 0);
    expect(a.read(recipeProgressProvider).containsKey('x'), isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    a.dispose();
    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(recipeProgressProvider);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(b.read(recipeProgressProvider)['r']!.servings, 6);
    expect(b.read(recipeProgressProvider)['r']!.step, 2);
  });

  test('progress: ticked ingredients persist and clearing them drops the entry', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    a.read(recipeProgressProvider.notifier).setChecked('r', {0, 2});
    await Future<void>.delayed(const Duration(milliseconds: 80));
    a.dispose();
    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(recipeProgressProvider);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(b.read(recipeProgressProvider)['r']!.checked, {0, 2});
    b.read(recipeProgressProvider.notifier).setChecked('r', {});
    expect(b.read(recipeProgressProvider).containsKey('r'), isFalse);
  });

  testWidgets('detail screen restores saved servings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(recipeProgressProvider.notifier).setServings(recipe.id, 9);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('9'), findsWidgets);
    final strings = c.read(appStringsProvider);
    expect(find.text(strings.servingsFormat(9)), findsWidgets);
  });

  testWidgets('cooking mode resumes at the saved step', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    expect(recipe.steps.length, greaterThan(2));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(recipeProgressProvider.notifier).setStep(recipe.id, 2);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: CookingModeScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    final strings = c.read(appStringsProvider);
    expect(find.text('${strings.step} 3 / ${recipe.steps.length}'), findsOneWidget);
  });
}
