import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('long-pressing a recipe card adds it to the chosen day, with undo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 2400);
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
}
