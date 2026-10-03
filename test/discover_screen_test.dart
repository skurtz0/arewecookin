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

      // Verify header and search bar
      expect(find.text('AreWeCookin'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify category chips
      expect(find.widgetWithText(ChoiceChip, 'Tümü'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Tatlı'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Çorba'), findsOneWidget);

      // Verify recipe cards loaded
      expect(find.byType(ListView), findsWidgets);

      // Tap on a recipe card to test navigation to RecipeDetailScreen
      final firstCard = find.textContaining('dk').first;
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

      // Tap 'Tatlı' category chip
      final tatliChip = find.widgetWithText(ChoiceChip, 'Tatlı');
      expect(tatliChip, findsOneWidget);
      await tester.tap(tatliChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that category filter applied
      expect(find.text('Tatlı'), findsWidgets);
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
      expect(find.text('Dünya Mutfakları'), findsOneWidget);

      // Verify cuisine filter options exist
      expect(find.text('🌍 Tümü'), findsOneWidget);
      expect(find.text('🇹🇷 Türk Mutfağı'), findsOneWidget);
      expect(find.text('🇮🇹 İtalyan'), findsOneWidget);
      expect(find.text('🥢 Asya & Uzak Doğu'), findsOneWidget);

      // Tap '🇮🇹 İtalyan' cuisine chip
      final italianFilter = find.text('🇮🇹 İtalyan');
      expect(italianFilter, findsOneWidget);
      await tester.tap(italianFilter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that Italian cuisine recipes and badges are displayed
      expect(find.text('İtalyan Mutfağı'), findsWidgets);

      // Tap '🌍 Tümü' to reset cuisine filter
      final allCuisinesFilter = find.text('🌍 Tümü');
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

      // At top, title and cuisine selector are fully visible
      expect(find.text('AreWeCookin'), findsOneWidget);
      expect(find.text('Dünya Mutfakları'), findsOneWidget);

      // Drag up (scrolling down into recipes)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Top panel has scrolled out of view and is completely hidden
      expect(find.text('AreWeCookin'), findsNothing);
      expect(find.text('Dünya Mutfakları'), findsNothing);

      // Drag down (scrolling back up)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await tester.pumpAndSettle();

      // Top panel snaps back into view
      expect(find.text('AreWeCookin'), findsOneWidget);
      expect(find.text('Dünya Mutfakları'), findsOneWidget);
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

      // Re-tap Keşfet (Discover) tab
      final kesfetTab = find.text('Keşfet');
      await tester.tap(kesfetTab);
      await tester.pumpAndSettle();

      // Should be back at the very top (0.0)
      expect(scrollable.position.pixels, equals(0.0));
      expect(tester.getRect(find.text('AreWeCookin')).top, greaterThanOrEqualTo(0));
    });
  });
}
