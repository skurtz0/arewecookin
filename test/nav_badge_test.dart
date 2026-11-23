import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shopping tab shows the number of open items', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: MainNavigationScreen())));
    await tester.pump(const Duration(milliseconds: 300));
    Badge badge() => tester.widget<Badge>(find.byKey(const Key('shopping_badge')));
    expect(badge().isLabelVisible, isFalse);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'A'), ShoppingItem(name: 'B')]);
    c.read(shoppingListProvider.notifier).toggle(0);
    await tester.pump();
    expect(badge().isLabelVisible, isTrue);
    expect((badge().label as Text).data, '1');
  });

  testWidgets('pantry tab shows how many ingredients are in the pantry', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: MainNavigationScreen())));
    await tester.pump(const Duration(milliseconds: 300));
    Badge badge() => tester.widget<Badge>(find.byKey(const Key('pantry_badge')));
    expect(badge().isLabelVisible, isFalse);
    await c.read(pantryProvider.notifier).addIngredients(['yumurta', 'süt', 'un']);
    await tester.pump(const Duration(milliseconds: 300));
    expect(badge().isLabelVisible, isTrue);
    expect((badge().label as Text).data, '3');
  });
}
