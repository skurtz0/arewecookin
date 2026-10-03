import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';

void main() {
  group('RecipeDetailScreen Widget Tests', () {
    late Recipe sampleRecipe;

    setUp(() {
      sampleRecipe = const Recipe(
        id: 'rec_00001',
        title: 'Özel Güveçte Kuru Fasulye #1',
        category: 'Ana Yemek',
        prepTime: 15,
        cookTime: 45,
        difficulty: 'Kolay',
        ingredientKeys: ['kuru fasulye', 'sogan', 'salca'],
        ingredients: [
          Ingredient(name: 'Kuru Fasulye', amount: '2', unit: 'su bardağı'),
          Ingredient(name: 'Kuru Soğan', amount: '1', unit: 'adet'),
          Ingredient(name: 'Salça', amount: '1', unit: 'yemek kaşığı'),
        ],
        substitutions: [
          Substitution(
            ingredient: 'kuru fasulye',
            alternative: 'Nohut veya Barbunya',
            tip: 'Pişme süresi benzerdir.',
          ),
        ],
        steps: [
          CookingStep(
            order: 1,
            title: 'Ön Islatma',
            instruction: 'Fasulyeleri geceden ıslatın.',
            toolIcon: 'bowl',
            timerSeconds: 0,
            proTip: 'Islatma suyuna biraz tuz atın.',
          ),
        ],
        servings: 4,
      );
    });

    testWidgets('renders details, scales servings, toggles checklist and launches cooking mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeDetailScreen(recipe: sampleRecipe),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title & stats
      expect(find.text('Özel Güveçte Kuru Fasulye #1'), findsWidgets);
      expect(find.text('Ana Yemek'), findsOneWidget);
      expect(find.text('4 Kişi'), findsOneWidget);
      expect(find.text('15 dk'), findsOneWidget);
      expect(find.text('45 dk'), findsOneWidget);

      // Verify initial ingredient amount: '2 su bardağı'
      expect(find.text('2 su bardağı'), findsOneWidget);

      // Scale servings up from 4 to 5 (increase servings)
      final addServingsButton = find.byIcon(Icons.add_circle_outline_rounded);
      expect(addServingsButton, findsOneWidget);
      await tester.tap(addServingsButton);
      await tester.pumpAndSettle();

      // Check servings updated to 5 Kişilik
      expect(find.text('5 Kişilik'), findsOneWidget);
      // 2 * (5/4) = 2.5
      expect(find.text('2.5 su bardağı'), findsOneWidget);

      // Test ingredient checklist toggle
      expect(find.text('0 / 3 hazır (0%)'), findsOneWidget);
      final firstIngredient = find.text('Kuru Fasulye');
      await tester.ensureVisible(firstIngredient);
      await tester.tap(firstIngredient);
      await tester.pumpAndSettle();

      expect(find.text('1 / 3 hazır (33%)'), findsOneWidget);

      // Test "Tümünü Seç"
      final toggleAll = find.text('Tümünü Seç');
      await tester.ensureVisible(toggleAll);
      await tester.tap(toggleAll);
      await tester.pumpAndSettle();
      expect(find.text('3 / 3 hazır (100%)'), findsOneWidget);

      // Verify substitutions section is visible
      expect(find.text('Akıllı İkame Önerileri'), findsOneWidget);
      expect(find.textContaining('Nohut veya Barbunya'), findsOneWidget);

      // Tap CTA: "Yapmaya Başlayalım 🍳"
      final ctaButton = find.text('Yapmaya Başlayalım 🍳');
      expect(ctaButton, findsOneWidget);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      expect(find.byType(CookingModeScreen), findsOneWidget);
    });
  });
}
