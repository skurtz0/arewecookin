import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('difficulty groups', () {
    expect(RecipeRepository.matchesDifficulty('Çok Kolay', 'easy'), isTrue);
    expect(RecipeRepository.matchesDifficulty('Kolay', 'easy'), isTrue);
    expect(RecipeRepository.matchesDifficulty('Orta', 'easy'), isFalse);
    expect(RecipeRepository.matchesDifficulty('Zor', 'hard'), isTrue);
  });

  test('difficulty filter only returns that group', () async {
    final res = await RecipeRepository().getRecipes(limit: 20, difficulty: 'medium');
    expect(res.recipes, isNotEmpty);
    expect(res.recipes.every((r) => r.difficulty == 'Orta'), isTrue);
  });
}
