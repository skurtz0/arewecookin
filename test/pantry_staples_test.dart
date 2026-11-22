import 'package:arewecookin/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('salt/water/black pepper never count as missing in pantry matching', () {
    const r = Recipe(
      id: 'x', title: 'T', category: 'Ana Yemek', prepTime: 5, cookTime: 5, difficulty: 'Kolay',
      ingredients: [], ingredientKeys: ['yumurta', 'tuz', 'su', 'domates'], steps: [], substitutions: [],
    );
    expect(r.getMissingKeys(['yumurta']), ['domates']);
    expect(r.calculateMatchScore(['yumurta']), 75.0);
    expect(r.calculateMatchScore(['yumurta', 'domates']), 100.0);
  });
}
