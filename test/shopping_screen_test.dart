import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('checked items move to the bottom of the shopping list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta'), ShoppingItem(name: 'Gamma')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    final ys = ['Alpha', 'Beta', 'Gamma'].map((t) => tester.getTopLeft(find.text(t)).dy).toList();
    expect(ys[0], greaterThan(ys[1]));
    expect(ys[0], greaterThan(ys[2]));
  });
}
