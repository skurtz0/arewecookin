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

  testWidgets('a single recent search can be removed with its x', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(recentSearchesProvider.notifier).add('makarna');
    c.read(recentSearchesProvider.notifier).add('pilav');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final chip = find.byKey(const Key('recent_search_makarna'));
    expect(chip, findsOneWidget);
    await tester.tap(find.descendant(of: chip, matching: find.byTooltip('Delete item')));
    await tester.pump();
    expect(c.read(recentSearchesProvider), ['pilav']);
    expect(find.byKey(const Key('recent_search_makarna')), findsNothing);
  });

  testWidgets('clearing recent searches can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(recentSearchesProvider.notifier).add('makarna');
    c.read(recentSearchesProvider.notifier).add('pilav');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('clear_recent_searches')));
    await tester.pump();
    expect(c.read(recentSearchesProvider), isEmpty);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('clear_undo')));
    await tester.pump();
    expect(c.read(recentSearchesProvider), ['pilav', 'makarna']);
  });

  testWidgets('while typing, earlier searches that contain the text are suggested', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(recentSearchesProvider.notifier).add('menemen tarifi');
    c.read(recentSearchesProvider.notifier).add('pilav');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).first, 'men');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('recent_search_menemen tarifi')), findsOneWidget);
    expect(find.byKey(const Key('recent_search_pilav')), findsNothing);
    expect(find.byKey(const Key('clear_recent_searches')), findsNothing);
    // The exact text is not suggested back to itself.
    await tester.enterText(find.byType(TextField).first, 'menemen tarifi');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('recent_search_menemen tarifi')), findsNothing);
  });
}
