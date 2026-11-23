import 'package:arewecookin/providers/discover_provider.dart';
import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:arewecookin/screens/meal_plan_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:arewecookin/screens/pantry_screen.dart';
import 'package:arewecookin/screens/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ticking a shopping item gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha')]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: ShoppingListScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(calls, isNotEmpty);
    expect(c.read(shoppingListProvider).first.done, isTrue);
  });

  testWidgets('swiping a shopping item right to tick it gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha')]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: ShoppingListScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(calls, isNotEmpty);
    expect(c.read(shoppingListProvider).first.done, isTrue);
  });

  testWidgets('adding a shopping item gives a light tap only when something was added', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ShoppingListScreen())));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('shopping_add_field')), 'Milk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(calls, isNotEmpty);
    calls.clear();
    await tester.enterText(find.byKey(const Key('shopping_add_field')), 'Milk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(calls, isEmpty, reason: 'nothing new was added');
  });

  testWidgets('adding a custom pantry ingredient gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PantryScreen())));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('pantry_custom_field')), 'zzcustom');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(calls, isNotEmpty);
  });

  testWidgets('moving to the next cooking step gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: CookingModeScreen(recipe: recipe))));
    await tester.pumpAndSettle();
    calls.clear();
    await tester.tap(find.ancestor(of: find.byIcon(Icons.arrow_forward_rounded), matching: find.byType(ElevatedButton)));
    await tester.pumpAndSettle();
    expect(calls, isNotEmpty);
  });

  testWidgets('tapping a pantry ingredient chip gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PantryScreen())));
    await tester.pumpAndSettle();
    final chip = find.byWidgetPredicate((w) => w is FilterChip && w.selectedColor == const Color(0xFF059669)).last;
    await tester.ensureVisible(chip);
    await tester.pump();
    await tester.tap(chip);
    await tester.pump();
    expect(calls, isNotEmpty);
  });

  testWidgets('check / uncheck all in the shopping list gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha'), ShoppingItem(name: 'Beta')]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: ShoppingListScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done_all_rounded).first);
    await tester.pump();
    expect(calls, isNotEmpty);
    expect(c.read(shoppingListProvider).every((e) => e.done), isTrue);
  });

  test('saving or unsaving a recipe gives a light tap', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final recipe = (await RecipeRepository().getRecipeById('rec_00042'))!;
    await c.read(savedRecipesProvider.notifier).toggleSave(recipe);
    expect(calls, isNotEmpty);
  });
  testWidgets('clearing a day in the meal plan gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(mealPlanProvider.notifier).add(DateTime.now().weekday, recipe);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: MealPlanScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('plan_day_clear_${DateTime.now().weekday}')));
    await tester.pump();
    expect(calls, isNotEmpty);
    expect(c.read(mealPlanProvider), isEmpty);
  });
  testWidgets('changing servings gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: RecipeDetailScreen(recipe: recipe))));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_circle_outline_rounded).first);
    await tester.pump();
    expect(calls, isNotEmpty);
  });
  testWidgets('picking a Discover time filter gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(discoverProvider.notifier).setMaxMinutes(30);
    await tester.pump();
    expect(calls, isNotEmpty);
    expect(c.read(discoverProvider).maxMinutes, 30);
  });
  testWidgets('clearing the done items of the shopping list gives a light tap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(shoppingListProvider.notifier).addAll(const [ShoppingItem(name: 'Alpha')]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: ShoppingListScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    calls.clear();
    await tester.tap(find.byKey(const Key('shopping_clear_done')));
    await tester.pumpAndSettle();
    expect(c.read(shoppingListProvider), isEmpty);
    expect(calls, isNotEmpty);
  });
}
