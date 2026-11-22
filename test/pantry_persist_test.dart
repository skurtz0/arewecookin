import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('pantry selection is restored after restart', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    await a.read(pantryProvider.notifier).addIngredient('Domates');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    a.dispose();
    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(pantryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(b.read(pantryProvider).selectedKeys, {'domates'});
  });
}
