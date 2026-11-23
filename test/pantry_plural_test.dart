import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/utils/pantry_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('foldPlural folds common English plurals', () {
    expect(foldPlural('Tomatoes'), foldPlural('tomato '));
    expect(foldPlural('berries'), foldPlural('berry'));
    expect(foldPlural('eggs'), foldPlural('egg'));
    expect(foldPlural('glass'), 'glass');
    expect(foldPlural('un'), 'un');
  });

  test('pantry with "egg" covers an ingredient named "eggs"', () {
    final i = Ingredient(name: 'Eggs', amount: '2', unit: '');
    expect(ingredientInPantry(i, {'egg'}, 'en'), isTrue);
    expect(ingredientInPantry(i, {'milk'}, 'en'), isFalse);
  });
}
