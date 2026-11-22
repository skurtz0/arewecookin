import 'package:arewecookin/providers/recent_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('recent recipes: newest first, no duplicates, capped', () async {
    SharedPreferences.setMockInitialValues({});
    final recipes = (await RecipeRepository().getRecipes(limit: 14)).recipes;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(recentRecipesProvider.notifier);
    for (final r in recipes) {
      n.add(r);
    }
    n.add(recipes.first);
    final list = c.read(recentRecipesProvider);
    expect(list.length, RecentRecipesNotifier.maxItems);
    expect(list.first.id, recipes.first.id);
    expect(list.map((r) => r.id).toSet().length, list.length);
  });
}
