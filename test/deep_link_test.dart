import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/data/world_recipes.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:arewecookin/utils/deep_link.dart';

void main() {
  test('recipe id is read from a shared route', () {
    expect(recipeIdFromRoute('/recipe/th_padthai'), 'th_padthai');
    expect(recipeIdFromRoute('#/recipe/rec_00042'), 'rec_00042');
    expect(recipeIdFromRoute('/recipe/a%20b'), 'a b');
    expect(recipeIdFromRoute('/'), isNull);
    expect(recipeIdFromRoute('/recipe/'), isNull);
    expect(recipeIdFromRoute('/other/x'), isNull);
  });

  test('share url round-trips and every kind of recipe id resolves', () async {
    final repo = RecipeRepository();
    for (final id in [WorldRecipes.all.first.id, 'rec_00001', 'rec_09999']) {
      final back = recipeIdFromRoute(recipeShareUrl(id).replaceFirst(siteUrl, ''));
      expect(back, id);
      expect(await repo.getRecipeById(id), isNotNull, reason: id);
    }
    expect(await repo.getRecipeById('nope_123'), isNull);
  });

  testWidgets('link button copies the recipe address', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = WorldRecipes.all.first;
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: RecipeDetailScreen(recipe: recipe))));
    await tester.pump();
    await tester.tap(find.byKey(const Key('share_link')));
    await tester.pump();
    expect(copied, recipeShareUrl(recipe.id));
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
