import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('asText lists open items first, checked last', () {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(shoppingListProvider.notifier);
    n.addAll(const [ShoppingItem(name: 'Süt', amount: '1', unit: 'l'), ShoppingItem(name: 'Un')]);
    n.toggle(0);
    expect(n.asText(), '[ ] Un\n[x] Süt - 1 l');
  });

  test('same ingredient from another recipe sums amounts; same recipe twice does not', () {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(shoppingListProvider.notifier);
    const a = ShoppingItem(name: 'Süt', amount: '1', unit: 'l', recipeTitle: 'Sütlaç');
    const b = ShoppingItem(name: 'süt', amount: '0,5', unit: 'L', recipeTitle: 'Kazandibi');
    expect(n.addAll([a]), 1);
    expect(n.addAll([a]), 0);
    expect(n.addAll([b]), 1);
    expect(n.addAll([b]), 0);
    final item = c.read(shoppingListProvider).single;
    expect(item.amount, '1.5');
    expect(item.recipeTitle, 'Sütlaç, Kazandibi');
  });
  test('different units are not merged', () {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(shoppingListProvider.notifier);
    n.addAll(const [ShoppingItem(name: 'Un', amount: '1', unit: 'cup', recipeTitle: 'A')]);
    expect(n.addAll(const [ShoppingItem(name: 'Un', amount: '200', unit: 'g', recipeTitle: 'B')]), 0);
    expect(c.read(shoppingListProvider).single.amount, '1');
  });
}
