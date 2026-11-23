import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('the meal plan opens scrolled to today', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(400, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipes = (await RecipeRepository().getRecipes(limit: 3)).recipes;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    for (var d = 1; d <= 7; d++) {
      for (final r in recipes) {
        c.read(mealPlanProvider.notifier).add(d, r);
      }
    }
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    final today = DateTime.now().weekday;
    final header = find.byKey(Key('plan_day_total_$today'));
    expect(header, findsOneWidget);
    final y = tester.getTopLeft(header).dy;
    expect(y, greaterThanOrEqualTo(0));
    expect(y, lessThan(500));
    expect(tester.takeException(), isNull);
  });
}
