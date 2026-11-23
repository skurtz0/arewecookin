import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  shoppingFullToolbarTest();
  for (final entry in {
    'Discover': const DiscoverScreen(),
    'ShoppingList': const ShoppingListScreen(),
    'MealPlan': const MealPlanScreen(),
  }.entries) {
    testWidgets('${entry.key} lays out without overflow at 1.8x text scale', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          builder: (c, w) => MediaQuery(
            data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.8)),
            child: w!,
          ),
          home: entry.value,
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    });
  }
}

void shoppingFullToolbarTest() {
  testWidgets('ShoppingList with checked items (full toolbar) at 1.8x text scale', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    c.read(shoppingListProvider.notifier).toggle(0);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (c, w) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: w!,
        ),
        home: const ShoppingListScreen(),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });
}
