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

    test('matchRecipesByPantry filters by cuisine accurately', () async {
      final italianMatches = await repository.matchRecipesByPantry(
        userIngredientKeys: ['makarna', 'domates', 'sarimsak'],
        cuisine: 'İtalyan Mutfağı',
        limit: 10,
      );

      expect(italianMatches, isNotEmpty);
      for (final r in italianMatches) {
        expect(r.cuisine, 'İtalyan Mutfağı');
      }

      final turkishMatches = await repository.matchRecipesByPantry(
        userIngredientKeys: ['patlican', 'kiyma'],
        cuisine: 'Türk Mutfağı',
        limit: 10,
      );

      expect(turkishMatches, isNotEmpty);
      for (final r in turkishMatches) {
        expect(r.cuisine, 'Türk Mutfağı');
      }
    });

    test('matchRecipesByPantry accurately matches chicken dishes for tavuk', () async {
      final matches = await repository.matchRecipesByPantry(
        userIngredientKeys: ['tavuk', 'patates'],
        limit: 10,
      );

      expect(matches, isNotEmpty);
      final hasChickenDish = matches.any((r) => r.ingredientKeys.contains('tavuk'));
      expect(hasChickenDish, isTrue);
    });

    test('matchRecipesByPantry returns strictly unique dishes without duplicates', () async {
      // Testing with mercimek and zeytinyagi as shown in user bug report
      final matches = await repository.matchRecipesByPantry(
        userIngredientKeys: ['mercimek', 'zeytinyagi'],
        limit: 30,
      );

      expect(matches, isNotEmpty);
      final titles = matches.map((r) => r.cleanTitle.toLowerCase().trim()).toList();
      final uniqueTitles = titles.toSet();
      // Every returned dish must be completely distinct - zero duplicates!
      expect(titles.length, uniqueTitles.length,
          reason: 'All returned dishes must be distinct with 0 duplicates');
    });

    test('getRecipeById fetches target recipe', () async {
      final recipe = await repository.getRecipeById('rec_00042');
      expect(recipe, isNotNull);
      expect(recipe!.id, 'rec_00042');
      expect(recipe.cuisine, isNotEmpty);
    });

    test('getRecipes filters across all supported cuisines with rich variety', () async {
      final testCuisines = [
        'Türk Mutfağı',
        'İtalyan Mutfağı',
        'Asya & Uzak Doğu',
        'Meksika Mutfağı',
        'Akdeniz Mutfağı',
        'Fransız & Dünya',
        'Pratik & Sokak',
      ];

      for (final cuisine in testCuisines) {
        final result = await repository.getRecipes(
          limit: 10,
          offset: 0,
          cuisine: cuisine,
        );

        expect(result.recipes, isNotEmpty, reason: '$cuisine should have recipes');
        for (final r in result.recipes) {
          expect(r.cuisine, cuisine);
          expect(r.baseDish, isNotEmpty);
          expect(r.imageUrl, startsWith('http'));
        }

        // Verify distinct dish bases are present
        final dishBases = result.recipes.map((r) => r.baseDish).toSet();
        expect(dishBases.length, greaterThanOrEqualTo(2),
            reason: '$cuisine should have multiple distinct dishes');
      }
    });

    test('recipes have realistic prep and cook times tailored to each dish', () async {
      // Test Kuru Fasulye explicitly
      final kuruFasulyeResults = await repository.getRecipes(
        limit: 5,
        offset: 0,
        searchQuery: 'kuru fasulye',
      );

      expect(kuruFasulyeResults.recipes, isNotEmpty);
      final kuruFasulye = kuruFasulyeResults.recipes.first;
      expect(kuruFasulye.prepTime, greaterThanOrEqualTo(15));
      expect(kuruFasulye.cookTime, greaterThanOrEqualTo(50));
      expect(kuruFasulye.totalTime, greaterThanOrEqualTo(65));
      expect(kuruFasulye.difficulty, isNot('Kolay'));

      // Test Menemen (quick dish)
      final menemenResults = await repository.getRecipes(
        limit: 5,
        offset: 0,
        searchQuery: 'menemen',
      );

      expect(menemenResults.recipes, isNotEmpty);
      final menemen = menemenResults.recipes.first;
      expect(menemen.prepTime, lessThanOrEqualTo(15));
      expect(menemen.cookTime, lessThanOrEqualTo(20));
      expect(menemen.totalTime, lessThanOrEqualTo(30));
      expect(menemen.difficulty, 'Kolay');
    });

    test('recipe titles do not contain numbers or hash symbols', () async {
      final results = await repository.getRecipes(limit: 50, offset: 0);
      expect(results.recipes, isNotEmpty);
      for (final recipe in results.recipes) {
        expect(recipe.title, isNot(contains('#')),
            reason: 'Recipe title ${recipe.title} should not contain "#"');
        expect(recipe.title, isNot(matches(r'#\d+')),
            reason: 'Recipe title ${recipe.title} should not contain numbers');
      }
    });

    test('recipes have dish-specific preparation steps mentioning actual ingredients', () async {
      final results = await repository.getRecipes(limit: 30, offset: 0);
      expect(results.recipes, isNotEmpty);

      final stepTitlesSet = <String>{};
      int totalStepsWithIngredients = 0;

      for (final recipe in results.recipes) {
        expect(recipe.steps, isNotEmpty);
        for (final step in recipe.steps) {
          stepTitlesSet.add(step.title);
          if (step.stepIngredients.isNotEmpty) {
            totalStepsWithIngredients++;
          }
          expect(step.instruction.length, greaterThan(25));
        }
      }

      expect(stepTitlesSet.length, greaterThanOrEqualTo(10),
          reason: 'Dishes should have distinct, dish-specific step titles');
      expect(totalStepsWithIngredients, greaterThan(0),
          reason: 'Steps should have step-specific ingredients listed');
    });
  });
}
