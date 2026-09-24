import 'package:flutter_test/flutter_test.dart';
import '../scripts/bulk_seeder.dart';

void main() {
  group('BulkRecipeSeeder & Generator Tests', () {
    test('generateRecipe produces valid recipe with pro-tips and tool icons', () {
      final seeder = BulkRecipeSeeder();
      final recipe = seeder.generateRecipe(0);

      expect(recipe.id, 'rec_00001');
      expect(recipe.title, isNotEmpty);
      expect(recipe.category, 'Ana Yemek');
      expect(recipe.prepTime, greaterThan(0));
      expect(recipe.cookTime, greaterThan(0));
      expect(recipe.ingredientKeys, isNotEmpty);
      expect(recipe.ingredients, isNotEmpty);
      expect(recipe.steps, isNotEmpty);

      // Check step properties: toolIcon and proTip
      for (final step in recipe.steps) {
        expect(step.toolIcon, isNotEmpty);
        expect(step.proTip, isNotEmpty);
        expect(step.instruction, isNotEmpty);
        expect(step.title, isNotEmpty);
      }
    });

    test('generateRecipe covers all 8 categories systematically', () {
      final seeder = BulkRecipeSeeder();
      final observedCategories = <String>{};

      for (int i = 0; i < 8; i++) {
        final recipe = seeder.generateRecipe(i);
        observedCategories.add(recipe.category);
      }

      expect(observedCategories, {
        'Ana Yemek',
        'Tatlı',
        'Çorba',
        'Kahvaltılık',
        'Pratik',
        'Hamur İşi',
        'Salata',
        'Vegan',
      });
    });

    test('seedRecipes executes 10,000 recipes dry-run with max 500 batch chunking', () async {
      final seeder = BulkRecipeSeeder();
      final progressBatches = <int>[];

      final total = await seeder.seedRecipes(
        totalCount: 10000,
        chunkSize: 500,
        dryRun: true,
        onProgress: (done, total) {
          progressBatches.add(done);
        },
      );

      expect(total, 10000);
      expect(progressBatches.length, 20); // 10000 / 500 = 20 batches
      expect(progressBatches.last, 10000);
      expect(progressBatches.first, 500);
    });

    test('batch size constraint rejects chunks > 500', () {
      final seeder = BulkRecipeSeeder();
      expect(
        () => seeder.seedRecipes(
          totalCount: 1000,
          chunkSize: 501,
          dryRun: true,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
