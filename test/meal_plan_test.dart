import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('meal plan: add, no duplicate per day, remove, persist', () async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final a = ProviderContainer();
    final n = a.read(mealPlanProvider.notifier);
    expect(n.add(2, recipe), isTrue);
    expect(n.add(2, recipe), isFalse);
    expect(n.add(9, recipe), isFalse);
    expect(n.add(3, recipe), isTrue);
    n.remove(3, recipe.id);
    expect(a.read(mealPlanProvider).keys, [2]);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    a.dispose();
    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(mealPlanProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(b.read(mealPlanProvider)[2]!.single.id, recipe.id);
  });

  test('plan as text lists only days with meals', () async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(mealPlanProvider.notifier);
    n.add(3, recipe);
    final text = n.asText((d) => 'Day$d', (r) => r.title);
    expect(text, 'Day3\n- ${recipe.title}');
  });

  test('plan text can include the day total in minutes', () async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(mealPlanProvider.notifier);
    n.add(3, recipe);
    final text = n.asText((d) => 'Day$d', (r) => r.title, (m) => '$m min');
    expect(text, 'Day3 · ${recipe.totalTime} min\n- ${recipe.title}');
  });
}
