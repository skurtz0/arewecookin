import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/services/recipe_generator.dart';
import 'package:arewecookin/data/world_recipes.dart';
import 'package:arewecookin/data/photo_credits.dart';

void main() {
  test('every curated and generated recipe has a photo with a credit', () {
    final missing = <String>{};
    for (final r in WorldRecipes.all) {
      if (r.imageUrl == null || r.imageUrl!.isEmpty) {
        missing.add(r.title);
      } else if (photoCreditFor(r.imageUrl) == null) {
        missing.add('${r.title} (no credit)');
      }
    }
    for (var i = 0; i < RecipeGenerator.totalCapacity; i++) {
      final r = RecipeGenerator.generate(i);
      // Dishes that a curated recipe replaces are never shown.
      if (r.id.startsWith('rec_') && WorldRecipes.coveredDishes.contains(r.baseDish)) continue;
      if (r.imageUrl == null || r.imageUrl!.isEmpty) {
        missing.add(r.baseDish ?? r.title);
      }
    }
    expect(missing, isEmpty);
  });
}
