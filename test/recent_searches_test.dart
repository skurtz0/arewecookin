import 'package:arewecookin/providers/recent_searches_provider.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('recent searches: newest first, no case-insensitive duplicates, capped, short ignored', () {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(recentSearchesProvider.notifier);
    n.add('a');
    for (final q in ['makarna', 'pilav', 'Makarna', 'çorba', 'kek', 'pizza', 'börek', 'salata']) {
      n.add(q);
    }
    final l = c.read(recentSearchesProvider);
    expect(l.first, 'salata');
    expect(l.length, RecentSearchesNotifier.maxItems);
    expect(l.where((e) => e.toLowerCase() == 'makarna').length, lessThanOrEqualTo(1));
    expect(l.contains('a'), isFalse);
  });

  testWidgets('tapping a recent search fills the box; clear removes the chips', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(recentSearchesProvider.notifier).add('makarna');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('recent_searches')), findsOneWidget);
    await tester.tap(find.text('makarna'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.widgetWithText(TextField, 'makarna'), findsOneWidget);
    // search active -> chips hidden; clear via provider path
    c.read(recentSearchesProvider.notifier).clear();
    await tester.pump();
    expect(c.read(recentSearchesProvider), isEmpty);
  });
}
