import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('deleting one of my own recipes can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
    await c.read(customRecipesProvider.notifier).addRecipe(recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AccountScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('(1)').last);
    await tester.pumpAndSettle();
    final del = find.byKey(Key('delete_custom_${recipe.id}'));
    await tester.ensureVisible(del);
    await tester.tap(del);
    await tester.pump(const Duration(seconds: 1));
    expect(c.read(customRecipesProvider).any((r) => r.id == recipe.id), isFalse);
    tester.widget<SnackBarAction>(find.byKey(const Key('delete_custom_undo'))).onPressed();
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.read(customRecipesProvider).any((r) => r.id == recipe.id), isTrue);
  });

  testWidgets('removing a saved recipe from the account list can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
    await c.read(savedRecipesProvider.notifier).toggleSave(recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AccountScreen()),
    ));
    await tester.pumpAndSettle();
    final btn = find.byKey(Key('unsave_${recipe.id}'));
    await tester.ensureVisible(btn);
    await tester.tap(btn);
    await tester.pump(const Duration(seconds: 1));
    expect(c.read(savedRecipesProvider).savedIds, isEmpty);
    tester.widget<SnackBarAction>(find.byKey(const Key('unsave_undo'))).onPressed();
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.read(savedRecipesProvider).savedIds, contains(recipe.id));
  });

  testWidgets('an own recipe can be edited and keeps its id', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
    await c.read(customRecipesProvider.notifier).addRecipe(recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AccountScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('(1)').last);
    await tester.pumpAndSettle();
    final edit = find.byKey(Key('edit_custom_${recipe.id}'));
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(find.text('Edit recipe'), findsOneWidget);
    final title = find.widgetWithText(TextFormField, recipe.title);
    expect(title, findsOneWidget);
    await tester.enterText(title, 'Yeni Ad');
    await tester.tap(find.text('Publish Recipe').first);
    await tester.pumpAndSettle();
    final list = c.read(customRecipesProvider);
    expect(list.length, 1);
    expect(list.single.id, recipe.id);
    expect(list.single.title, 'Yeni Ad');
    expect(list.single.ingredients.length, recipe.ingredients.length);
    expect(list.single.steps.length, recipe.steps.length);
  });
}
