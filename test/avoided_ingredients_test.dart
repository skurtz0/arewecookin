import 'package:arewecookin/providers/avoided_ingredients_provider.dart';
import 'package:arewecookin/providers/discover_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('avoided words are split, cleaned, de-duplicated and remembered', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(avoidedIngredientsProvider.notifier);
    expect(n.add('Fıstık, -SÜT; süt a'), 2);
    expect(c.read(avoidedIngredientsProvider), ['fıstık', 'süt']);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(avoidedIngredientsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(c2.read(avoidedIngredientsProvider), ['fıstık', 'süt']);
    n.remove('süt');
    expect(c.read(avoidedIngredientsProvider), ['fıstık']);
  });

  test('Discover leaves out recipes with an avoided word', () async {
    SharedPreferences.setMockInitialValues({});
    final base = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final word = RecipeRepository.normalizeSearch(base.ingredients.firstWhere((i) => i.name.trim().length > 3).name.trim());
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(discoverProvider);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    c.read(avoidedIngredientsProvider.notifier).add(word);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final shown = c.read(discoverProvider).recipes;
    expect(shown, isNotEmpty);
    expect(shown.any((r) => r.id == base.id), isFalse);
    for (final r in shown) {
      expect(r.ingredients.any((i) => RecipeRepository.normalizeSearch(i.name).contains(word)), isFalse);
    }
  });

  testWidgets('account can add and remove avoided words, at 1.8x text and 360px', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (ctx, w) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: w!,
        ),
        home: const AccountScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    final field = find.byKey(const Key('avoided_field'));
    await tester.ensureVisible(field);
    await tester.enterText(field, 'peanut, milk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(c.read(avoidedIngredientsProvider), ['peanut', 'milk']);
    expect(find.byKey(const Key('avoided_peanut')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('avoided_milk')));
    expect(tester.takeException(), isNull);
    await tester.tap(find.descendant(of: find.byKey(const Key('avoided_peanut')), matching: find.byTooltip('Delete item')));
    await tester.pumpAndSettle();
    expect(c.read(avoidedIngredientsProvider), ['milk']);
  });
}
