import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/account_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('recipe stats are spoken as "label: value"', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: RecipeDetailScreen(recipe: recipe))));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^Total Time: \d+ min')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Prep Time: \d+ min')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('profile stats are spoken as "label: count"', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AccountScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^[^:\n]+: 0$')), findsWidgets);
    handle.dispose();
  });

  testWidgets('the Saved / My recipes tabs report which one is selected', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(authProvider.notifier).signInWithEmail('test@arewecookin.com', '123456');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AccountScreen()),
    ));
    await tester.pumpAndSettle();
    final counts = find.textContaining('(0)');
    expect(counts, findsNWidgets(2));
    bool selectedOf(Finder f) => tester
        .widget<Semantics>(find.ancestor(of: f, matching: find.byWidgetPredicate((w) => w is Semantics && w.properties.selected != null)).first)
        .properties
        .selected!;
    expect(selectedOf(counts.at(0)), isTrue);
    expect(selectedOf(counts.at(1)), isFalse);
    handle.dispose();
  });

  testWidgets('sign-in screen toggles report which one is selected', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AccountScreen())));
    await tester.pumpAndSettle();
    final selected = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.button == true && w.properties.selected == true);
    final notSelected = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.button == true && w.properties.selected == false);
    expect(selected, findsWidgets);
    expect(notSelected, findsWidgets);
    handle.dispose();
  });
}
