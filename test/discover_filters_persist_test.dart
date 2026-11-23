import 'package:arewecookin/providers/discover_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 300));

void main() {
  test('Discover filters are restored after restart and the list loads with them', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    a.read(discoverProvider);
    await settle();
    a.read(discoverProvider.notifier).setMaxMinutes(30);
    a.read(discoverProvider.notifier).setDifficulty('easy');
    await settle();
    a.dispose();

    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(discoverProvider);
    await settle();
    final s = b.read(discoverProvider);
    expect(s.maxMinutes, 30);
    expect(s.difficulty, 'easy');
    expect(s.recipes, isNotEmpty);
    expect(s.recipes.every((r) => r.totalTime <= 30), isTrue);
  });

  test('a filter changed before the stored ones load wins', () async {
    SharedPreferences.setMockInitialValues({
      'discover_filters_v1': '{"c":"Tümü","u":"Tümü","m":15,"d":"hard"}',
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(discoverProvider);
    c.read(discoverProvider.notifier).setMaxMinutes(60);
    await settle();
    expect(c.read(discoverProvider).maxMinutes, 60);
  });

  test('without stored filters nothing is filtered', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(discoverProvider);
    await settle();
    final s = c.read(discoverProvider);
    expect(s.maxMinutes, isNull);
    expect(s.difficulty, isNull);
    expect(s.recipes, isNotEmpty);
  });
}
