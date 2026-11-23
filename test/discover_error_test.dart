import 'package:arewecookin/providers/discover_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FlakyRepository extends RecipeRepository {
  bool down = false;
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
    if (down) throw Exception('offline');
    return super.getRecipes(
        limit: limit, startAfter: startAfter, offset: offset, category: category,
        cuisine: cuisine, searchQuery: searchQuery, maxMinutes: maxMinutes, difficulty: difficulty);
  }
}

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

  testWidgets('when the next batch fails, the list shows a retry instead of a endless spinner', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final repo = _FlakyRepository();
    final c = ProviderContainer(overrides: [recipeRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.read(discoverProvider).hasMore, isTrue);
    repo.down = true;
    await c.read(discoverProvider.notifier).loadMore();
    expect(c.read(discoverProvider).errorMessage, isNotNull);
    final retry = find.byKey(const Key('load_more_retry'));
    await tester.scrollUntilVisible(retry, 500, scrollable: find.byType(Scrollable).first, maxScrolls: 80);
    expect(retry, findsOneWidget);
    repo.down = false;
    final before = c.read(discoverProvider).recipes.length;
    await tester.ensureVisible(retry);
    await tester.pump();
    await tester.tap(retry);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    expect(c.read(discoverProvider).errorMessage, isNull);
    expect(c.read(discoverProvider).recipes.length, greaterThan(before));
  });
}
