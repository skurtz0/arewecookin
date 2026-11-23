import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/services/recipe_generator.dart';

void main() {
  test('every verified dish photo belongs to a known dish and is https', () {
    for (final e in RecipeGenerator.dishImages.entries) {
      expect(RecipeGenerator.dishCuisines.containsKey(e.key), isTrue, reason: e.key);
      expect(e.value.startsWith('https://'), isTrue, reason: e.key);
    }
    expect(RecipeGenerator.dishImages.length, greaterThan(50));
  });
}
