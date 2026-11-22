import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maxMinutes filter only returns recipes within the limit', () async {
    final repo = RecipeRepository();
    final res = await repo.getRecipes(limit: 30, maxMinutes: 30);
    expect(res.recipes, isNotEmpty);
    expect(res.recipes.every((r) => r.totalTime <= 30), isTrue);
  });
}
