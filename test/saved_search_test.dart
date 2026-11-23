import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('saved list gets a search box once it has more than 5 recipes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final all = (await RecipeRepository().getRecipes(limit: 8)).recipes;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
    for (final r in all.take(5)) {
      await c.read(savedRecipesProvider.notifier).toggleSave(r);
    }
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AccountScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saved_search')), findsNothing);
    await c.read(savedRecipesProvider.notifier).toggleSave(all[5]);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saved_search')), findsOneWidget);
    final target = all[5];
    await tester.enterText(find.byKey(const Key('saved_search')), target.title);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('unsave_${target.id}')), findsOneWidget);
    expect(find.byKey(Key('unsave_${all[0].id}')),
        all[0].title.toLowerCase().contains(target.title.toLowerCase()) ? findsOneWidget : findsNothing);
  });

  testWidgets('saved search also finds recipes by ingredient', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final all = (await RecipeRepository().getRecipes(limit: 6)).recipes;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
    for (final r in all) {
      await c.read(savedRecipesProvider.notifier).toggleSave(r);
    }
    final ing = all[0].ingredients.first.name;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AccountScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('saved_search')), ing);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('unsave_${all[0].id}')), findsOneWidget);
  });

  testWidgets('saved search box does not overflow at 360px and 1.8x text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final all = (await RecipeRepository().getRecipes(limit: 6)).recipes;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
    for (final r in all.take(6)) {
      await c.read(savedRecipesProvider.notifier).toggleSave(r);
    }
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: const AccountScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.byKey(const Key('saved_search')),
        find.byType(Scrollable).first, const Offset(0, -200));
    expect(find.byKey(const Key('saved_search')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
