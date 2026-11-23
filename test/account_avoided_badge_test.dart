import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/avoided_ingredients_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final scale in [1.0, 1.8]) {
    testWidgets('saved recipes in the account list warn about avoided words (${scale}x, 360px)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
      await c.read(savedRecipesProvider.notifier).toggleSave(recipe);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          builder: (ctx, w) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)),
            child: w!,
          ),
          home: const AccountScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('avoided_badge_${recipe.id}')), findsNothing);
      c.read(avoidedIngredientsProvider.notifier).add(recipe.ingredients.first.name);
      await tester.pumpAndSettle();
      expect(find.byKey(Key('avoided_badge_${recipe.id}')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
