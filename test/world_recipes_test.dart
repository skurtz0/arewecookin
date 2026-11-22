import 'package:arewecookin/data/world_countries.dart';
import 'package:arewecookin/data/world_recipes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final recipes = WorldRecipes.all;

  test('world recipes: enough, unique ids, many countries', () {
    expect(recipes.length, greaterThanOrEqualTo(50));
    expect(recipes.map((r) => r.id).toSet().length, recipes.length);
    expect(recipes.map((r) => r.cuisine).toSet().length, greaterThanOrEqualTo(50));
  });

  test('every recipe has dish-specific steps with English text and a known country', () {
    for (final r in recipes) {
      expect(WorldCountries.byId(r.cuisine), isNotNull, reason: '${r.id} country');
      expect(r.titleEn, isNotNull);
      expect(r.ingredients.length, greaterThanOrEqualTo(3), reason: r.id);
      expect(r.steps.length, greaterThanOrEqualTo(3), reason: r.id);
      for (final s in r.steps) {
        expect(s.instructionEn, isNotNull, reason: '${r.id} step ${s.order}');
        expect(s.titleEn, isNotNull);
        expect(s.localizedInstruction('en'), s.instructionEn);
        expect(s.localizedInstruction('tr'), s.instruction);
      }
      for (final i in r.ingredients) {
        expect(i.nameEn, isNotNull, reason: '${r.id} ${i.name}');
      }
      if (r.imageUrl != null) expect(r.imageUrl, contains('wikimedia.org/'));
    }
  });

  test('English locale shows localized title and country', () {
    final r = recipes.firstWhere((e) => e.id == 'w_jp_oyakodon');
    expect(r.localizedTitle('en'), 'Oyakodon (親子丼)');
    expect(WorldCountries.label('Japonya', false), 'Japan');
    expect(WorldCountries.label('Japonya', true), 'Japonya');
  });
}
