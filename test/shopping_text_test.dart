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
}
