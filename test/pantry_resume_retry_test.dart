import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FlakyPantryRepo extends RecipeRepository {
  bool down = true;
  @override
  Future<List<Recipe>> matchRecipesByPantry({
    required List<String> userIngredientKeys,
    String? cuisine,
    int limit = 50,
  }) async {
    if (down) throw Exception('offline');
    return super.matchRecipesByPantry(userIngredientKeys: userIngredientKeys, cuisine: cuisine, limit: limit);
  }
}

void main() {
  testWidgets('coming back to the app after a failed pantry search retries by itself', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = _FlakyPantryRepo();
    final c = ProviderContainer(overrides: [recipeRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await c.read(pantryProvider.notifier).addIngredients(['yumurta', 'süt', 'un']);
    await tester.pumpAndSettle();
    expect(c.read(pantryProvider).errorMessage, isNotNull);
    repo.down = false;
    for (final st in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(st);
    }
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(c.read(pantryProvider).errorMessage, isNull);
    expect(c.read(pantryProvider).matchedRecipes, isNotEmpty);
  });
}
