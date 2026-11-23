import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('filled meal plan has no overflow at 360px and 1.8x text', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(mealPlanProvider.notifier).add(DateTime.now().weekday, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: child!,
        ),
        home: const MealPlanScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('plan_day_clear_${DateTime.now().weekday}')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
