import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 300));

void main() {
  test('pantry quickest-first sort is remembered after restart and can be turned off', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    a.read(pantryProvider);
    await settle();
    a.read(pantryProvider.notifier).toggleSortByTime();
    await settle();
    a.dispose();

    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(pantryProvider);
    await settle();
    expect(b.read(pantryProvider).sortByTime, isTrue);
    b.read(pantryProvider.notifier).toggleSortByTime();
    await settle();
    b.dispose();

    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(pantryProvider);
    await settle();
    expect(c.read(pantryProvider).sortByTime, isFalse);
  });
}
