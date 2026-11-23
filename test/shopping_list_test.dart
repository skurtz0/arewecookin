import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shopping list: add skips duplicates, toggle, clear done', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(shoppingListProvider.notifier);
    expect(n.addAll(const [ShoppingItem(name: 'Süt', amount: '1', unit: 'l'), ShoppingItem(name: 'süt'), ShoppingItem(name: 'Un')]), 2);
    expect(n.addAll(const [ShoppingItem(name: 'UN')]), 0);
    n.toggle(0);
    expect(c.read(shoppingListProvider)[0].done, isTrue);
    n.clearDone();
    expect(c.read(shoppingListProvider).map((e) => e.name), ['Un']);
  });

  test('shopping list persists across containers', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    a.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Tuz')]);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    a.dispose();
    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(shoppingListProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(b.read(shoppingListProvider).map((e) => e.name), ['Tuz']);
  });

  test('adding an item that was already checked off reopens it', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(shoppingListProvider.notifier);
    n.addAll(const [ShoppingItem(name: 'Milk'), ShoppingItem(name: 'Eggs')]);
    n.toggle(0);
    expect(c.read(shoppingListProvider)[0].done, isTrue);
    expect(n.addAll(const [ShoppingItem(name: 'milk')]), 1);
    expect(c.read(shoppingListProvider)[0].done, isFalse);
    expect(c.read(shoppingListProvider).length, 2);
    // An open item stays untouched.
    expect(n.addAll(const [ShoppingItem(name: 'Milk')]), 0);
  });
}
