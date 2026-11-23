import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('saving a recipe from the detail screen can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save_toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(savedRecipesProvider).savedIds, contains(recipe.id));
    tester.widget<SnackBarAction>(find.byKey(const Key('save_toggle_undo'))).onPressed();
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(savedRecipesProvider).savedIds, isNot(contains(recipe.id)));
  });
}
