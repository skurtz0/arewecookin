import 'package:arewecookin/providers/pantry_provider.dart';
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
    final ids = node.getSemanticsData().customSemanticsActionIds!;
    expect(ids.length, 2); // delete + edit
    final actionId = ids.firstWhere(
        (id) => CustomSemanticsAction.getAction(id)?.label == 'Delete item');
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
    await tester.tap(find.byKey(const Key('shopping_clear_done')));
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

  testWidgets('check-all toggles every item, and unchecks when all are checked', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shopping_toggle_all')));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider).every((e) => e.done), isTrue);
    await tester.tap(find.byKey(const Key('shopping_toggle_all')));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider).any((e) => e.done), isFalse);
    tester.widget<SnackBarAction>(find.byKey(const Key('toggle_all_undo'))).onPressed();
    await tester.pump();
    expect(c.read(shoppingListProvider).every((e) => e.done), isTrue);
  });

  testWidgets('checked items can be added to the pantry', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Eggs'), ShoppingItem(name: 'Milk')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shopping_to_pantry')), findsNothing);
    await tester.tap(find.text('Eggs'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shopping_to_pantry')));
    await tester.pumpAndSettle();
    expect(c.read(pantryProvider).selectedKeys, {'eggs'});
    expect(find.text('1 ingredients added to pantry'), findsOneWidget);
    await tester.tap(find.byKey(const Key('shopping_to_pantry_undo')));
    await tester.pumpAndSettle();
    expect(c.read(pantryProvider).selectedKeys, isEmpty);
  });

  testWidgets('open items are grouped by source recipe once there are several sources', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [
      ShoppingItem(name: 'Flour', recipeTitle: 'Bread'),
      ShoppingItem(name: 'Tomato', recipeTitle: 'Soup'),
      ShoppingItem(name: 'Salt', recipeTitle: 'Bread'),
      ShoppingItem(name: 'Gum'),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shopping_group_Bread')), findsOneWidget);
    expect(find.byKey(const Key('shopping_group_Soup')), findsOneWidget);
    expect(find.byKey(const Key('shopping_group_Added by hand')), findsOneWidget);
    expect(find.text('Bread · 2'), findsOneWidget);
    expect(find.text('Soup · 1'), findsOneWidget);
    expect(find.text('Added by hand · 1'), findsOneWidget);
    double y(String t) => tester.getTopLeft(find.text(t)).dy;
    expect(y('Salt'), lessThan(y('Tomato')));
    expect(y('Flour'), lessThan(y('Salt')));
  });

  testWidgets('a single source shows no group headers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Flour'), ShoppingItem(name: 'Gum')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shopping_group_Added by hand')), findsNothing);
  });

  testWidgets('progress bar follows the number of checked items', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    double value() => tester.widget<LinearProgressIndicator>(find.byKey(const Key('shopping_progress_bar'))).value!;
    expect(value(), 0);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(value(), 0.5);
  });

  testWidgets('typing an item that is already on the list says so', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Milk')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('shopping_add_field')), 'milk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(seconds: 1));
    expect(c.read(shoppingListProvider).length, 1);
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.enterText(find.byKey(const Key('shopping_add_field')), 'bread');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(seconds: 1));
    expect(c.read(shoppingListProvider).length, 2);
  });

  testWidgets('swiping an item right ticks it, swiping left deletes it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Alpha'), const Offset(400, 0));
    await tester.pumpAndSettle();
    final list = c.read(shoppingListProvider);
    expect(list.length, 2);
    expect(list.firstWhere((e) => e.name == 'Alpha').done, isTrue);
    await tester.drag(find.text('Beta'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider).map((e) => e.name), ['Alpha']);
  });

  testWidgets('a group header can tick off its whole group, with undo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [
      ShoppingItem(name: 'Flour', recipeTitle: 'Bread'),
      ShoppingItem(name: 'Yeast', recipeTitle: 'Bread'),
      ShoppingItem(name: 'Carrot', recipeTitle: 'Soup'),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('shopping_group_check_Bread')));
    await tester.pump();
    bool done(String n) => c.read(shoppingListProvider).firstWhere((e) => e.name == n).done;
    expect(done('Flour'), isTrue);
    expect(done('Yeast'), isTrue);
    expect(done('Carrot'), isFalse);
    await tester.pump(const Duration(milliseconds: 500));
    tester.widget<SnackBarAction>(find.byKey(const Key('shopping_group_undo'))).onPressed();
    await tester.pump();
    expect(done('Flour'), isFalse);
  });

  testWidgets('the progress count is announced when it changes (live region)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final handle = tester.ensureSemantics();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.byKey(const Key('shopping_progress')));
    expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
    expect(node.label, contains('0 / 2'));
    handle.dispose();
  });
}
