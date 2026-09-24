import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';

void main() {
  group('RecipeRepository Tests', () {
    late RecipeRepository repository;

    setUp(() {
      repository = RecipeRepository();
    });

    test('getRecipes returns paginated chunk of 20 items with hasMore true', () async {
      final page1 = await repository.getRecipes(limit: 20, offset: 0);

      expect(page1.recipes.length, 20);
      expect(page1.hasMore, true);
      expect(page1.nextOffset, 20);
      expect(page1.recipes.first.id, 'rec_00001');

      // Fetch second page
      final page2 = await repository.getRecipes(limit: 20, offset: page1.nextOffset);
      expect(page2.recipes.length, 20);
      expect(page2.hasMore, true);
      expect(page2.recipes.first.id, 'rec_00021');

      // Verify no overlap between page 1 and page 2
      final page1Ids = page1.recipes.map((r) => r.id).toSet();
      final page2Ids = page2.recipes.map((r) => r.id).toSet();
      expect(page1Ids.intersection(page2Ids), isEmpty);
    });

    test('getRecipes filters by category accurately', () async {
      final result = await repository.getRecipes(
        limit: 15,
        offset: 0,
        category: 'Tatlı',
      );

      expect(result.recipes.length, 15);
      for (final r in result.recipes) {
        expect(r.category, 'Tatlı');
      }
    });

    test('getRecipes filters by search query accurately', () async {
      final result = await repository.getRecipes(
        limit: 10,
        offset: 0,
        searchQuery: 'menemen',
      );

      expect(result.recipes, isNotEmpty);
      for (final r in result.recipes) {
        expect(r.title.toLowerCase(), contains('menemen'));
      }
    });

    test('matchRecipesByPantry computes match score and ranks highest matches first', () async {
      final matches = await repository.matchRecipesByPantry(
        userIngredientKeys: ['un', 'seker', 'sut', 'yumurta'],
        limit: 10,
      );

      expect(matches, isNotEmpty);
      // High score first
      final score1 = matches[0].calculateMatchScore(['un', 'seker', 'sut', 'yumurta']);
      final scoreLast = matches.last.calculateMatchScore(['un', 'seker', 'sut', 'yumurta']);
      expect(score1, greaterThanOrEqualTo(scoreLast));
    });

    test('getRecipeById fetches target recipe', () async {
      final recipe = await repository.getRecipeById('rec_00042');
      expect(recipe, isNotNull);
      expect(recipe!.id, 'rec_00042');
    });
  });
}
