import 'package:arewecookin/providers/discover_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DownRepository extends RecipeRepository {
  @override
  Future<PaginatedRecipes> getRecipes({
    int limit = 20,
    dynamic startAfter,
    int offset = 0,
    String? category,
    String? cuisine,
    String? searchQuery,
    int? maxMinutes,
    String? difficulty,
  }) async {
    throw Exception('offline');
  }
}

void main() {
  testWidgets('when loading fails, the error screen still offers saved recipes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer(overrides: [recipeRepositoryProvider.overrideWithValue(_DownRepository())]);
    addTearDown(c.dispose);
    final seed = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    await c.read(savedRecipesProvider.notifier).toggleSave(seed);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('discover_retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('error_open_saved')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('discover_retry')), findsNothing);
    expect(find.text(seed.localizedTitle('en')), findsWidgets);
    expect(c.read(discoverProvider).errorMessage, isNotNull);
  });
}
