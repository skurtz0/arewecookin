import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pantry matches can be sorted quickest first', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await container.read(pantryProvider.notifier).addIngredients(['yumurta', 'süt', 'un']);
    await tester.pumpAndSettle();
    final sortBtn = find.byKey(const Key('pantry_sort_time'));
    expect(sortBtn, findsOneWidget);
    await tester.tap(sortBtn);
    await tester.pumpAndSettle();
    final s = container.read(pantryProvider);
    expect(s.sortByTime, isTrue);
    expect(s.matchedRecipes.length, greaterThan(1));
    final sorted = [...s.matchedRecipes]..sort((a, b) => a.totalTime.compareTo(b.totalTime));
    final fast = sorted.firstWhere((r) => r.totalTime == sorted.first.totalTime);
    final slow = sorted.lastWhere((r) => r.totalTime == sorted.last.totalTime);
    if (fast.totalTime < slow.totalTime) {
      final a = find.text(fast.title);
      final b = find.text(slow.title);
      if (a.evaluate().isNotEmpty && b.evaluate().isNotEmpty) {
        expect(tester.getTopLeft(a.first).dy, lessThan(tester.getTopLeft(b.first).dy));
      }
    }
    await tester.tap(sortBtn);
    await tester.pumpAndSettle();
    expect(container.read(pantryProvider).sortByTime, isFalse);
  });
}
