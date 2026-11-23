import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/providers/recipe_notes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final scale in [1.0, 1.8]) {
    testWidgets('planned meals show cooked and note badges (${scale}x text, 360px)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(mealPlanProvider.notifier).add(2, recipe);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          builder: (ctx, w) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)),
            child: w!,
          ),
          home: const MealPlanScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('plan_cooked_2_${recipe.id}')), findsNothing);
      expect(find.byKey(Key('plan_note_2_${recipe.id}')), findsNothing);
      c.read(cookHistoryProvider.notifier).markCooked(recipe.id);
      c.read(recipeNotesProvider.notifier).setNote(recipe.id, 'less salt');
      await tester.pumpAndSettle();
      expect(find.byKey(Key('plan_cooked_2_${recipe.id}')), findsOneWidget);
      expect(find.byKey(Key('plan_note_2_${recipe.id}')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
