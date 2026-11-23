import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('grouped shopping list has no overflow at 360px and 1.8x text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [
      ShoppingItem(name: 'Flour', amount: '500', unit: 'g', recipeTitle: 'A very long recipe title for bread'),
      ShoppingItem(name: 'Carrot', recipeTitle: 'Soup'),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: const ShoppingListScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shopping_group_check_Soup')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
