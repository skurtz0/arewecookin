import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('long-pressing a recipe card adds it to the chosen day, with undo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(700, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: DiscoverScreen()),
    ));
    await tester.pumpAndSettle();
    final save = find.byWidgetPredicate((w) => w.key is Key && '${w.key}'.contains('card_save_') && !'${w.key}'.contains('undo')).first;
    final card = find.ancestor(of: save, matching: find.byType(InkWell)).first;
    await tester.longPress(card, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('card_plan_day_3')), findsOneWidget);
    await tester.tap(find.byKey(const Key('card_plan_day_3')));
    await tester.pumpAndSettle();
    expect(c.read(mealPlanProvider)[3], hasLength(1));
    await tester.tap(find.byKey(const Key('card_plan_undo')));
    await tester.pumpAndSettle();
    expect(c.read(mealPlanProvider)[3] ?? const [], isEmpty);
  });

  testWidgets('long-pressing a pantry match card adds it to the meal plan', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(700, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: PantryScreen()),
    ));
    await tester.pumpAndSettle();
    await c.read(pantryProvider.notifier).addIngredients(['yumurta', 'süt', 'un']);
    await tester.pumpAndSettle();
    final save = find.byWidgetPredicate((w) => w.key is Key && '${w.key}'.contains('pantry_save_')).first;
    await tester.ensureVisible(save);
    await tester.pump();
    // The save button sits next to the card's InkWell inside the same Stack.
    final stack = find.ancestor(of: save, matching: find.byType(Stack)).first;
    final card = find.descendant(of: stack, matching: find.byType(InkWell)).first;
    await tester.longPress(card, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('card_plan_day_2')));
    await tester.pumpAndSettle();
    expect(c.read(mealPlanProvider)[2], hasLength(1));
  });
}
