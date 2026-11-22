import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('missing ingredients of a pantry match can be sent to the shopping list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await container.read(pantryProvider.notifier).addIngredient('yumurta');
    await tester.pumpAndSettle();
    final buttons = find.byWidgetPredicate((w) => w.key.toString().contains('add_missing_'));
    expect(buttons, findsWidgets);
    await tester.ensureVisible(buttons.first);
    await tester.pumpAndSettle();
    await tester.tap(buttons.first);
    await tester.pump();
    expect(container.read(shoppingListProvider), isNotEmpty);
  });

  testWidgets('full matches only hides recipes with missing ingredients', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await container.read(pantryProvider.notifier).addIngredient('yumurta');
    await tester.pumpAndSettle();
    final buttons = find.byWidgetPredicate((w) => w.key.toString().contains('add_missing_'));
    final before = tester.widgetList(buttons).length;
    expect(before, greaterThan(0));
    final chip = find.byKey(const Key('pantry_full_only'));
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(tester.widgetList(buttons).length, 0);
  });
}
