import 'dart:async';

import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SlowRepo extends RecipeRepository {
  final done = Completer<List<Recipe>>();
  @override
  Future<List<Recipe>> matchRecipesByPantry({
    required List<String> userIngredientKeys,
    String? cuisine,
    int limit = 50,
  }) =>
      done.future;
}

void main() {
  testWidgets('pantry loading spinner has a screen reader label', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = _SlowRepo();
    final c = ProviderContainer(overrides: [recipeRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    unawaited(c.read(pantryProvider.notifier).addIngredients(['yumurta', 'süt', 'un']));
    await tester.pump(const Duration(milliseconds: 100));
    final p = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(p.semanticsLabel, isNotEmpty);
    repo.done.complete(<Recipe>[]);
    await tester.pump(const Duration(milliseconds: 100));
  });
}
