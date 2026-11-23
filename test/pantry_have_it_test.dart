import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('tapping a missing ingredient on a pantry card adds it to the pantry', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await c.read(pantryProvider.notifier).addIngredients(['yumurta']);
    await tester.pumpAndSettle();
    final have = find.byWidgetPredicate(
        (w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('have_'));
    for (var n = 0; n < 15 && have.evaluate().isEmpty; n++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pump();
    }
    expect(have, findsWidgets);
    final before = c.read(pantryProvider).selectedKeys.length;
    final chip = have.first;
    await tester.ensureVisible(chip);
    await tester.pump();
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(c.read(pantryProvider).selectedKeys.length, before + 1);
  });
}
