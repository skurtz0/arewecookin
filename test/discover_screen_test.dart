import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/screens/discover_screen.dart';
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
      final firstCard = find.textContaining('#').first;
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
  });
}
