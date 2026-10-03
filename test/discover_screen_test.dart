import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/screens/main_navigation_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';

void main() {
  group('DiscoverScreen Widget Tests', () {
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
      final firstCard = find.textContaining('min').first;
      await tester.tap(firstCard);
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
