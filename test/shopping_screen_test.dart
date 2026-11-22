import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

  testWidgets('swipe-deleting an item can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Alpha'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider).map((e) => e.name), ['Beta']);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider).map((e) => e.name), ['Alpha', 'Beta']);
  });

  testWidgets('clear list asks for confirmation, then empties it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shopping_clear_all')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider).length, 2);
    await tester.tap(find.byKey(const Key('shopping_clear_all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shopping_clear_all_confirm')));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider), isEmpty);
  });

  testWidgets('screen readers get a delete action on shopping items', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final handle = tester.ensureSemantics();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    final withAction = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.customSemanticsActions != null);
    expect(withAction, findsOneWidget);
    final node = tester.getSemantics(withAction);
    final actionId = node.getSemanticsData().customSemanticsActionIds!.first;
    expect(c.read(shoppingListProvider).length, 1);
    tester.semantics.performAction(find.semantics.byAction(SemanticsAction.customAction), SemanticsAction.customAction, args: actionId);
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider), isEmpty);
    handle.dispose();
  });

  testWidgets('clear checked can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear checked'));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider).map((e) => e.name), ['Beta']);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    final names = c.read(shoppingListProvider);
    expect(names.length, 2);
    expect(names.firstWhere((e) => e.name == 'Alpha').done, isTrue);
  });

  testWidgets('long press edits an item and keeps its checked state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Milk')]);
    c.read(shoppingListProvider.notifier).toggle(0);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Milk'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('shopping_edit_field')), '2 kg oat milk');
    await tester.tap(find.byKey(const Key('shopping_edit_save')));
    await tester.pumpAndSettle();
    final item = c.read(shoppingListProvider).single;
    expect([item.amount, item.unit, item.name], ['2', 'kg', 'oat milk']);
    expect(item.done, isTrue);
  });

  testWidgets('title shows checked / total count', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    expect(find.text('0 / 2'), findsOneWidget);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('hint about edit and delete shows only when the list has items', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shopping_hint')), findsNothing);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha')]);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shopping_hint')), findsOneWidget);
  });
}
