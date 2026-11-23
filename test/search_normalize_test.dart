import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeSearch strips diacritics and Turkish dotted/dotless i', () {
    expect(RecipeRepository.normalizeSearch('Sütlaç'), 'sutlac');
    expect(RecipeRepository.normalizeSearch('ISPANAK'), 'ispanak');
    expect(RecipeRepository.normalizeSearch('İmam Bayıldı'), 'imam bayildi');
  });

  test('search ignores diacritics and needs all words', () async {
    final repo = RecipeRepository();
    final a = await repo.getRecipes(limit: 5, searchQuery: 'sutlac');
    expect(a.recipes, isNotEmpty);
    final b = await repo.getRecipes(limit: 5, searchQuery: 'sütlaç');
    expect(b.recipes.map((e) => e.id), a.recipes.map((e) => e.id));
    final none = await repo.getRecipes(limit: 5, searchQuery: 'sutlac zzzxyz');
    expect(none.recipes, isEmpty);
  });

  test('search can combine several ingredients (comma separated)', () async {
    final repo = RecipeRepository();
    final base = (await repo.getRecipes(limit: 1)).recipes.first;
    final names = base.ingredients.where((i) => i.name.trim().length > 3).map((i) => i.name.trim()).toList();
    expect(names.length, greaterThan(1));
    final a = names[0], b = names[1];
    final comma = await repo.getRecipes(limit: 500, searchQuery: '$a, $b');
    expect(comma.recipes.map((e) => e.id), contains(base.id));
    final none = await repo.getRecipes(limit: 500, searchQuery: '$a, zzzxyz');
    expect(none.recipes, isEmpty);
  });
}
