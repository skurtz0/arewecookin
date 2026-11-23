import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'meal plan screen marks today and can be cleared after confirmation',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final recipe = (await RecipeRepository().getRecipes(limit: 1))
          .recipes
          .first;
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(mealPlanProvider.notifier)
          .add(DateTime.now().weekday, recipe);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: MealPlanScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Today'), findsOneWidget);
      final day = DateTime.now().weekday;
      expect(find.byKey(Key('plan_day_total_$day')), findsOneWidget);
      expect(find.textContaining('${recipe.totalTime}'), findsWidgets);
      await tester.tap(find.byKey(const Key('plan_clear')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('plan_clear_confirm')));
      await tester.pumpAndSettle();
      expect(container.read(mealPlanProvider), isEmpty);
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(
        container.read(mealPlanProvider)[DateTime.now().weekday]!.single.id,
        recipe.id,
      );
    },
  );

  testWidgets('removing a planned meal can be undone', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1))
        .recipes
        .first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final day = DateTime.now().weekday;
    container.read(mealPlanProvider.notifier).add(day, recipe);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plan_remove_${day}_${recipe.id}')));
    await tester.pumpAndSettle();
    expect(container.read(mealPlanProvider), isEmpty);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(container.read(mealPlanProvider)[day]!.length, 1);
  });

  testWidgets('a planned meal can be moved to another day', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1))
        .recipes
        .first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(mealPlanProvider.notifier).add(1, recipe);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plan_move_1_${recipe.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_move_to_5')));
    await tester.pumpAndSettle();
    final plan = container.read(mealPlanProvider);
    expect(plan.containsKey(1), isFalse);
    expect(plan[5]!.single.id, recipe.id);
    tester.widget<SnackBarAction>(find.byKey(const Key('plan_move_undo'))).onPressed();
    await tester.pumpAndSettle();
    final back = container.read(mealPlanProvider);
    expect(back[1]!.single.id, recipe.id);
    expect(back.containsKey(5), isFalse);
  });

  testWidgets('planned meals show a thumbnail', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1))
        .recipes
        .first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(mealPlanProvider.notifier).add(2, recipe);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(Key('plan_thumb_2_${recipe.id}')), findsOneWidget);
  });

  testWidgets('a favorite can be added to a chosen day from the plan screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1))
        .recipes
        .first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(savedRecipesProvider.notifier).toggleSave(recipe);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_add_from_saved')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plan_saved_${recipe.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_add_day_4')));
    await tester.pumpAndSettle();
    expect(container.read(mealPlanProvider)[4]!.single.id, recipe.id);
  });

  testWidgets('with no favorites the plan screen explains what to do', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_add_from_saved')));
    await tester.pumpAndSettle();
    expect(find.text('Save a recipe to favorites first.'), findsOneWidget);
  });

  testWidgets('a planned meal can start cooking mode directly', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1))
        .recipes
        .first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(mealPlanProvider.notifier).add(1, recipe);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plan_cook_1_${recipe.id}')));
    await tester.pumpAndSettle();
    expect(find.byType(CookingModeScreen), findsOneWidget);
  });

  testWidgets(
    'plan with a meal has no overflow at 1.8x text on a narrow phone',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final recipe = (await RecipeRepository().getRecipes(limit: 1))
          .recipes
          .first;
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(mealPlanProvider.notifier).add(1, recipe);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (c, w) => MediaQuery(
              data: MediaQuery.of(c)
                  .copyWith(textScaler: const TextScaler.linear(1.8)),
              child: w!,
            ),
            home: const MealPlanScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a day can send only its own ingredients to the shopping list', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final recipes = (await RecipeRepository().getRecipes(limit: 2)).recipes;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(mealPlanProvider.notifier).add(1, recipes[0]);
    container.read(mealPlanProvider.notifier).add(2, recipes[1]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_day_to_list_1')));
    await tester.pumpAndSettle();
    final titles = container
        .read(shoppingListProvider)
        .map((e) => e.recipeTitle)
        .toSet();
    expect(titles, isNotEmpty);
    expect(titles.any((t) => t.contains(recipes[1].title)), isFalse);
    await tester.tap(find.byKey(const Key('shopping_add_undo')));
    await tester.pumpAndSettle();
    expect(container.read(shoppingListProvider), isEmpty);
  });

  testWidgets('the plan shopping button skips ingredients already in the pantry', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final owned = recipe.ingredients.firstWhere((i) => !i.isOptional);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(mealPlanProvider.notifier).add(1, recipe);
    await container.read(pantryProvider.notifier).addIngredient(owned.name.toLowerCase());
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MealPlanScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_day_to_list_1')));
    await tester.pumpAndSettle();
    final names = container.read(shoppingListProvider).map((e) => e.name.toLowerCase());
    expect(names.contains(owned.localizedName('en').toLowerCase()), isFalse);
  });

  testWidgets('a day can be copied to another day without duplicates', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipes = (await RecipeRepository().getRecipes(limit: 2)).recipes;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(mealPlanProvider.notifier);
    n.add(1, recipes[0]);
    n.add(1, recipes[1]);
    n.add(3, recipes[0]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_day_copy_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_copy_to_3')));
    await tester.pumpAndSettle();
    final plan = container.read(mealPlanProvider);
    expect(plan[3]!.map((r) => r.id).toList(), [recipes[0].id, recipes[1].id]);
    expect(plan[1]!.length, 2);
    await tester.tap(find.byKey(const Key('plan_copy_undo')));
    await tester.pumpAndSettle();
    expect(container.read(mealPlanProvider)[3]!.map((r) => r.id).toList(), [recipes[0].id]);
    expect(container.read(mealPlanProvider.notifier).copyDay(1, 3), 1);
    expect(container.read(mealPlanProvider.notifier).copyDay(1, 3), 0);
  });

  testWidgets('a single day can be cleared and restored', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipes = (await RecipeRepository().getRecipes(limit: 2)).recipes;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(mealPlanProvider.notifier);
    n.add(1, recipes[0]);
    n.add(2, recipes[1]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_day_clear_1')));
    await tester.pump(const Duration(seconds: 1));
    final plan = container.read(mealPlanProvider);
    expect(plan.containsKey(1), isFalse);
    expect(plan[2]!.length, 1);
    tester.widget<SnackBarAction>(find.byKey(const Key('plan_day_clear_undo'))).onPressed();
    await tester.pump();
    expect(container.read(mealPlanProvider)[1]!.single.id, recipes[0].id);
  });

  testWidgets('swiping a planned meal left removes it and offers undo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final day = DateTime.now().weekday;
    container.read(mealPlanProvider.notifier).add(day, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    final f = find.byKey(ValueKey('plan_row_${day}_${recipe.id}'));
    await tester.drag(f, const Offset(-500, 0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(mealPlanProvider)[day] ?? const [], isEmpty);
    tester.widget<SnackBarAction>(find.byKey(const Key('plan_swipe_undo'))).onPressed();
    await tester.pump();
    expect(container.read(mealPlanProvider)[day]!.single.id, recipe.id);
  });
}
