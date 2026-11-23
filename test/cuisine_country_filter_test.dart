import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/data/world_countries.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';

Future<List<String>> _cuisines(String filter, {int pages = 3}) async {
  final repo = RecipeRepository();
  final out = <String>[];
  var off = 0;
  for (var p = 0; p < pages; p++) {
    final r = await repo.getRecipes(limit: 40, offset: off, cuisine: filter);
    out.addAll(r.recipes.map((e) => e.cuisine));
    off = r.nextOffset;
    if (!r.hasMore) break;
  }
  return out;
}

void main() {
  // Tapping a country flag must list that country's dishes, not just one curated recipe.
  for (final c in ['İtalya', 'Fransa', 'Japonya', 'Çin', 'Meksika', 'ABD', 'Lübnan', 'Endonezya', 'Mısır']) {
    test('country filter "$c" returns many recipes, all of that country', () async {
      final r = await _cuisines(c);
      expect(r.length, greaterThan(20), reason: c);
      expect(r.toSet(), {c});
    });
  }

  test('group filters include the country dishes', () async {
    expect((await _cuisines('Asya & Uzak Doğu')).toSet(), containsAll(['Japonya', 'Çin']));
    expect((await _cuisines('İtalyan Mutfağı')).toSet(), {'İtalya'});
    expect((await _cuisines('Meksika Mutfağı')).toSet(), {'Meksika'});
    expect((await _cuisines('Fransız & Dünya')).toSet(), containsAll(['Fransa', 'ABD']));
  });

  test('every recipe cuisine is a country id or one of the known groups', () async {
    final known = {...WorldCountries.all.map((c) => c.id), 'Türk Mutfağı', 'Akdeniz Mutfağı', 'Asya & Uzak Doğu', 'Fransız & Dünya', 'Pratik & Sokak'};
    final repo = RecipeRepository();
    final r = await repo.getRecipes(limit: 300);
    expect(r.recipes.map((e) => e.cuisine).toSet().difference(known), isEmpty);
  });
}
