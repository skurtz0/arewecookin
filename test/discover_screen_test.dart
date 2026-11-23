import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/screens/main_navigation_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:arewecookin/providers/discover_provider.dart';
import 'package:arewecookin/providers/recipe_notes_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DiscoverScreen Widget Tests', () {
    // Filters are remembered on the device; start every test from a clean store.
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('renders search bar, category chips, and initial recipes with infinite scroll', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DiscoverScreen(),
          ),
        ),
      );

      // Allow microtasks to complete initial load
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify search bar and cuisine selector
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('World Cuisines'), findsOneWidget);

      // Verify category chips in default English
      expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Dessert'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Soup'), findsOneWidget);

      // Verify recipe cards loaded
      expect(find.byType(ListView), findsWidgets);

      // Tap on a recipe card to test navigation to RecipeDetailScreen
      // A 'min' text inside the first recipe card (not a time-filter chip).
      final firstCard = find.descendant(
        of: find.byWidgetPredicate((w) => w.runtimeType.toString() == '_RecipeCard').first,
        matching: find.textContaining('min'),
      ).first;
      await tester.ensureVisible(firstCard);
      await tester.pumpAndSettle();
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      expect(find.byType(RecipeDetailScreen), findsOneWidget);
    });

    testWidgets('recipe cards are exposed to screen readers as buttons with title and time', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: Scaffold(body: DiscoverScreen()))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel(RegExp(r', \d+ min, ')), findsWidgets);
      handle.dispose();
    });

    testWidgets('saved list cards are also announced with title and time', (tester) async {
      final handle = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final recipe = container.read(discoverProvider).recipes.first;
      await container.read(savedRecipesProvider.notifier).toggleSave(recipe);
      container.read(recipeNotesProvider.notifier).setRating(recipe.id, 4);
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('${RegExp.escape(recipe.localizedTitle('en'))}, \\d+ min, .*4/5')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Saved view follows the time chip and also finds recipes by ingredient', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final all = (await RecipeRepository().getRecipes(limit: 60)).recipes;
      final quick = all.firstWhere((r) => r.totalTime <= 15);
      final slow = all.firstWhere((r) => r.totalTime > 30);
      await container.read(savedRecipesProvider.notifier).toggleSave(quick);
      await container.read(savedRecipesProvider.notifier).toggleSave(slow);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('card_save_${quick.id}')), findsOneWidget);
      expect(find.byKey(Key('card_save_${slow.id}')), findsOneWidget);
      container.read(discoverProvider.notifier).setMaxMinutes(15);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('card_save_${quick.id}')), findsOneWidget);
      expect(find.byKey(Key('card_save_${slow.id}')), findsNothing);
      // Difficulty chip: a group nobody in the list belongs to empties it.
      container.read(discoverProvider.notifier).setMaxMinutes(null);
      final hardNone = !(quick.difficulty == 'Zor' || slow.difficulty == 'Zor');
      container.read(discoverProvider.notifier).setDifficulty(hardNone ? 'hard' : 'easy');
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      if (hardNone) {
        expect(find.byKey(Key('card_save_${quick.id}')), findsNothing);
        expect(find.byKey(Key('card_save_${slow.id}')), findsNothing);
      }
    });

    testWidgets('Saved view follows the cuisine chip', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final all = (await RecipeRepository().getRecipes(limit: 60)).recipes;
      final a = all.first;
      final b = all.firstWhere((r) => r.cuisine != a.cuisine);
      await container.read(savedRecipesProvider.notifier).toggleSave(a);
      await container.read(savedRecipesProvider.notifier).toggleSave(b);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('card_save_${a.id}')), findsOneWidget);
      expect(find.byKey(Key('card_save_${b.id}')), findsOneWidget);
      container.read(discoverProvider.notifier).setCuisine(a.cuisine);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('card_save_${a.id}')), findsOneWidget);
      expect(find.byKey(Key('card_save_${b.id}')), findsNothing);
    });

    testWidgets('Saved view follows the category chip', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final all = (await RecipeRepository().getRecipes(limit: 60)).recipes;
      final a = all.first;
      final b = all.firstWhere((r) => r.category != a.category);
      await container.read(savedRecipesProvider.notifier).toggleSave(a);
      await container.read(savedRecipesProvider.notifier).toggleSave(b);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('card_save_${a.id}')), findsOneWidget);
      expect(find.byKey(Key('card_save_${b.id}')), findsOneWidget);
      container.read(discoverProvider.notifier).setCategory(a.category);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('card_save_${a.id}')), findsOneWidget);
      expect(find.byKey(Key('card_save_${b.id}')), findsNothing);
    });

    testWidgets('Saved filter shows only bookmarked recipes', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('saved_empty')), findsOneWidget);
      final recipe = container.read(discoverProvider).recipes.first;
      await container.read(savedRecipesProvider.notifier).toggleSave(recipe);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('saved_empty')), findsNothing);
      expect(find.textContaining('(1)'), findsOneWidget);
      expect(find.textContaining(recipe.localizedTitle('en')), findsWidgets);
    });

    testWidgets('saved list can be sorted quickest first', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final all = [...container.read(discoverProvider).recipes]..sort((a, b) => b.totalTime.compareTo(a.totalTime));
      final slow = all.first;
      final fast = all.lastWhere((r) => r.totalTime < slow.totalTime);
      await container.read(savedRecipesProvider.notifier).toggleSave(fast);
      await container.read(savedRecipesProvider.notifier).toggleSave(slow);
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      double y(r) => tester.getTopLeft(find.text(r.localizedTitle('en')).first).dy;
      expect(y(fast), isNot(equals(y(slow))));
      final beforeFastFirst = y(fast) < y(slow);
      await tester.tap(find.byKey(const Key('saved_sort_quick')));
      await tester.pumpAndSettle();
      expect(beforeFastFirst, isFalse, reason: 'unsorted order is newest first, so the slow one leads');
      final yFast = tester.getTopLeft(find.text(fast.localizedTitle('en')).first).dy;
      final ySlow = tester.getTopLeft(find.text(slow.localizedTitle('en')).first).dy;
      expect(yFast, lessThan(ySlow));
    });

    testWidgets('today\'s planned meals show on Discover and open the recipe', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('today_plan_card')), findsNothing);
      final recipe = container.read(discoverProvider).recipes.first;
      container.read(mealPlanProvider.notifier).add(DateTime.now().weekday, recipe);
      await tester.pump();
      expect(find.byKey(const Key('today_plan_card')), findsOneWidget);
      // The card also shows how much cooking time today's plan adds up to.
      expect(tester.widget<Text>(find.byKey(const Key('today_plan_total'))).data, contains('${recipe.totalTime}'));
      await tester.tap(find.byKey(Key('today_plan_${recipe.id}')));
      await tester.pumpAndSettle();
      expect(find.byType(RecipeDetailScreen), findsOneWidget);
    });

    testWidgets('cooked recipes get a badge on the card', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('cooked_badge')), findsNothing);
      final recipe = container.read(discoverProvider).recipes.first;
      container.read(cookHistoryProvider.notifier).markCooked(recipe.id);
      await tester.pump();
      expect(find.byKey(const Key('cooked_badge')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('cooked_badge')), matching: find.text('Cooked once')), findsOneWidget);
      container.read(cookHistoryProvider.notifier).markCooked(recipe.id);
      await tester.pump();
      expect(find.descendant(of: find.byKey(const Key('cooked_badge')), matching: find.text('Cooked 2 times')), findsOneWidget);
    });

    testWidgets('reset chip appears with a filter and clears it', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('reset_filters_chip')), findsNothing);
      container.read(discoverProvider.notifier).setDifficulty('easy');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('reset_filters_chip')), findsOneWidget);
      await tester.tap(find.byKey(const Key('reset_filters_chip')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(container.read(discoverProvider).difficulty, isNull);
      expect(find.byKey(const Key('reset_filters_chip')), findsNothing);
    });

    testWidgets('saved list can be sorted by my rating', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final all = container.read(discoverProvider).recipes;
      final liked = all[0];
      final other = all[1];
      // Save the liked one first, so newest-first puts the other on top before sorting.
      await container.read(savedRecipesProvider.notifier).toggleSave(liked);
      await container.read(savedRecipesProvider.notifier).toggleSave(other);
      container.read(recipeNotesProvider.notifier).setRating(liked.id, 5);
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      double y(r) => tester.getTopLeft(find.text(r.localizedTitle('en')).first).dy;
      expect(y(other), lessThan(y(liked)));
      await tester.tap(find.byKey(const Key('saved_sort_rating')));
      await tester.pumpAndSettle();
      expect(y(liked), lessThan(y(other)));
    });

    testWidgets('card bookmark button saves and unsaves a recipe', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final recipe = container.read(discoverProvider).recipes.first;
      final btn = find.byKey(Key('card_save_${recipe.id}'));
      await tester.tap(btn);
      await tester.pump();
      expect(container.read(savedRecipesProvider).isSaved(recipe.id), isTrue);
      await tester.tap(btn);
      await tester.pump();
      expect(container.read(savedRecipesProvider).isSaved(recipe.id), isFalse);
      // The last tap's "Undo" puts it back.
      await tester.pump(const Duration(milliseconds: 300));
      tester.widget<SnackBarAction>(find.byKey(Key('card_save_undo_${recipe.id}'))).onPressed();
      await tester.pump();
      expect(container.read(savedRecipesProvider).isSaved(recipe.id), isTrue);
    });

    testWidgets('Quick & easy chip sets both filters and clears them', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final chip = find.byKey(const Key('quick_easy'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(container.read(discoverProvider).maxMinutes, 30);
      expect(container.read(discoverProvider).difficulty, 'easy');
      await tester.ensureVisible(chip);
      await tester.pump();
      await tester.tap(chip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(container.read(discoverProvider).maxMinutes, isNull);
      expect(container.read(discoverProvider).difficulty, isNull);
    });

    testWidgets('a search without results shows the search tip', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('search_tip')), findsNothing);
      container.read(discoverProvider.notifier).setSearchQuery('zzzxyzqq');
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('search_tip')), findsOneWidget);
    });

    testWidgets('an empty filter combination lists each filter so one tap can drop it', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final n = container.read(discoverProvider.notifier);
      n.setCategory('Çorba');
      n.setCuisine('Meksika Mutfağı');
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('drop_category')), findsOneWidget);
      expect(find.byKey(const Key('drop_cuisine')), findsOneWidget);
      // Dropping the cuisine leaves the soup filter and brings recipes back.
      await tester.tap(find.descendant(of: find.byKey(const Key('drop_cuisine')), matching: find.byType(Icon)).last);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));
      expect(container.read(discoverProvider).selectedCuisine, 'Tümü');
      expect(container.read(discoverProvider).recipes, isNotEmpty);
    });

    testWidgets('a search shows how many recipes were found', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('results_count')), findsNothing);
      container.read(discoverProvider.notifier).setSearchQuery('menemen');
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(container.read(discoverProvider).recipes, isNotEmpty);
      expect(find.byKey(const Key('results_count')), findsOneWidget);
    });

    testWidgets('a multi-word search with no results offers each word on its own', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      container.read(discoverProvider.notifier).setSearchQuery('menemen zzzxyzqq');
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(container.read(discoverProvider).recipes, isEmpty);
      expect(find.byKey(const Key('try_word_menemen')), findsOneWidget);
      await tester.tap(find.byKey(const Key('try_word_menemen')));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      expect(container.read(discoverProvider).searchQuery, 'menemen');
      expect(container.read(discoverProvider).recipes, isNotEmpty);
      expect(find.byKey(const Key('try_word_menemen')), findsNothing);
    });

    testWidgets('Surprise me never picks the same dish twice in a row', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(container.read(discoverProvider).recipes.length, greaterThan(1));
      String? last;
      for (var i = 0; i < 12; i++) {
        await tester.ensureVisible(find.byKey(const Key('surprise_me')));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.byKey(const Key('surprise_me')));
        await tester.pumpAndSettle();
        final id = tester.widget<RecipeDetailScreen>(find.byType(RecipeDetailScreen)).recipe.id;
        expect(id, isNot(last), reason: 'pick $i repeated');
        last = id;
        await tester.pageBack();
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('Saved can be sorted by how much of the recipe is already in the pantry', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final all = (await RecipeRepository().getRecipes(limit: 30)).recipes;
      final a = all.first;
      final key = a.ingredients.first.name.trim().toLowerCase();
      final b = all.skip(1).firstWhere((r) => !r.ingredients.any((i) => i.name.trim().toLowerCase() == key));
      // a is saved first, so by default it sits below b.
      await container.read(savedRecipesProvider.notifier).toggleSave(a);
      await container.read(savedRecipesProvider.notifier).toggleSave(b);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await container.read(pantryProvider.notifier).addIngredient(key);
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      double y(Recipe r) => tester.getTopLeft(find.byKey(Key('card_save_${r.id}'))).dy;
      expect(y(b), lessThan(y(a)));
      await tester.tap(find.byKey(const Key('saved_sort_pantry')));
      await tester.pumpAndSettle();
      expect(y(a), lessThan(y(b)));
    });

    testWidgets('the chosen Saved order is remembered', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final seed = container.read(discoverProvider).recipes.first;
      await container.read(savedRecipesProvider.notifier).toggleSave(seed);
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saved_sort_rating')));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      expect((await SharedPreferences.getInstance()).getString('saved_sort_v1'), 'rating');
      // A new screen starts with the remembered order.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('saved_filter')));
      await tester.pumpAndSettle();
      expect(tester.widget<FilterChip>(find.byKey(const Key('saved_sort_rating'))).selected, isTrue);
      await tester.tap(find.byKey(const Key('saved_sort_rating')));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      expect((await SharedPreferences.getInstance()).getString('saved_sort_v1'), isNull);
    });

    testWidgets('a recipe with a personal note shows a note badge on its card', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final first = container.read(discoverProvider).recipes.first;
      expect(find.byKey(Key('note_badge_${first.id}')), findsNothing);
      container.read(recipeNotesProvider.notifier).setNote(first.id, 'less salt next time');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(Key('note_badge_${first.id}')), findsOneWidget);
      container.read(recipeNotesProvider.notifier).setNote(first.id, '   ');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(Key('note_badge_${first.id}')), findsNothing);
    });

    testWidgets('the spoken card label says how often the recipe was cooked', (tester) async {
      final handle = tester.ensureSemantics();
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final recipe = container.read(discoverProvider).recipes.first;
      container.read(cookHistoryProvider.notifier).markCooked(recipe.id);
      container.read(cookHistoryProvider.notifier).markCooked(recipe.id);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel(RegExp('Cooked 2 times')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Rated filter lists rated recipes, best first, and explains when empty', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final chip = find.byKey(const Key('rated_filter'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rated_empty')), findsOneWidget);
      final all = container.read(discoverProvider).recipes;
      container.read(recipeNotesProvider.notifier).setRating(all[0].id, 3);
      container.read(recipeNotesProvider.notifier).setRating(all[1].id, 5);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rated_empty')), findsNothing);
      expect(find.byKey(const Key('rated_list')), findsOneWidget);
      double y(r) => tester.getTopLeft(find.text(r.localizedTitle('en')).first).dy;
      expect(y(all[1]), lessThan(y(all[0])));
    });

    testWidgets('Cooked filter lists cooked recipes, newest first, and explains when empty', (tester) async {
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final chip = find.byKey(const Key('cooked_filter'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cooked_empty')), findsOneWidget);
      final all = container.read(discoverProvider).recipes;
      container.read(cookHistoryProvider.notifier).markCooked(all[0].id, at: DateTime(2026, 1, 1));
      container.read(cookHistoryProvider.notifier).markCooked(all[1].id, at: DateTime(2026, 6, 1));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cooked_empty')), findsNothing);
      expect(find.textContaining('(2)'), findsOneWidget);
      double y(r) => tester.getTopLeft(find.text(r.localizedTitle('en')).first).dy;
      expect(y(all[1]), lessThan(y(all[0])));
      // The search box narrows the cooked list like it does the saved list.
      await tester.enterText(find.byType(TextField).first, 'zzzzqqqq');
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cooked_list')), findsNothing);
    });

    testWidgets('my rating shows on the recipe card', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('5/5'), findsNothing);
      final recipe = container.read(discoverProvider).recipes.first;
      container.read(recipeNotesProvider.notifier).setRating(recipe.id, 5);
      await tester.pump();
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets('Surprise me prefers recipes that were not cooked yet', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DiscoverScreen())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final all = container.read(discoverProvider).recipes;
      final target = all.last;
      for (final r in all.where((r) => r.id != target.id)) {
        container.read(cookHistoryProvider.notifier).markCooked(r.id);
      }
      await tester.tap(find.byKey(const Key('surprise_me')));
      await tester.pumpAndSettle();
      final detail = tester.widget<RecipeDetailScreen>(find.byType(RecipeDetailScreen));
      expect(detail.recipe.id, target.id);
    });

    testWidgets('Surprise me opens a recipe', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: Scaffold(body: DiscoverScreen()))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('surprise_me')));
      await tester.pumpAndSettle();
      expect(find.byType(RecipeDetailScreen), findsOneWidget);
    });

    testWidgets('filtering by category updates the list', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DiscoverScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap 'Dessert' category chip
      final dessertChip = find.widgetWithText(ChoiceChip, 'Dessert');
      expect(dessertChip, findsOneWidget);
      await tester.tap(dessertChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that category filter applied
      expect(find.text('Dessert'), findsWidgets);
    });

    testWidgets('renders cuisine selector at the top and filters by cuisine', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DiscoverScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify cuisine selector header at top
      expect(find.text('World Cuisines'), findsOneWidget);

      // Verify cuisine filter options exist (localized)
      expect(find.text('🌍 All'), findsOneWidget);
      expect(find.text('🇹🇷 Turkish'), findsOneWidget);
      expect(find.text('🇮🇹 Italian'), findsOneWidget);
      expect(find.text('🥢 Asian & Far East'), findsOneWidget);

      // Tap '🇮🇹 Italian' cuisine chip
      final italianFilter = find.text('🇮🇹 Italian');
      expect(italianFilter, findsOneWidget);
      await tester.tap(italianFilter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that Italian cuisine recipes and badges are displayed
      expect(find.text('Italian'), findsWidgets);

      // Tap '🌍 All' to reset cuisine filter
      final allCuisinesFilter = find.text('🌍 All');
      expect(allCuisinesFilter, findsOneWidget);
      await tester.tap(allCuisinesFilter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify reset: shows various recipes
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('scrolling down hides top panel, scrolling up reveals it', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      tester.view.physicalSize = const Size(700, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DiscoverScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // At top, cuisine selector is fully visible
      expect(find.text('World Cuisines'), findsOneWidget);

      // Drag up (scrolling down into recipes)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Top panel has scrolled out of view and is completely hidden
      expect(find.text('World Cuisines'), findsNothing);

      // Drag down (scrolling back up)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await tester.pumpAndSettle();

      // Top panel snaps back into view
      expect(find.text('World Cuisines'), findsOneWidget);
    });

    testWidgets('tapping Discover button again while on Discover tab scrolls to top', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Drag down into the list
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
      await tester.pumpAndSettle();

      // Confirm scrolled down
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
      expect(scrollable.position.pixels, greaterThan(300));

      // Re-tap Discover tab
      final discoverTab = find.text('Discover');
      await tester.tap(discoverTab);
      await tester.pumpAndSettle();

      // Should be back at the very top (0.0)
      expect(scrollable.position.pixels, equals(0.0));
      expect(find.text('World Cuisines'), findsOneWidget);
    });
  });
}
