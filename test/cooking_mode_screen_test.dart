import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';

void main() {
  group('CookingModeScreen Widget Tests', () {
    late Recipe sampleRecipe;

    setUp(() {
      sampleRecipe = const Recipe(
        id: 'rec_00001',
        title: 'Özel Menemen #1',
        category: 'Kahvaltılık',
        prepTime: 5,
        cookTime: 10,
        difficulty: 'Kolay',
        ingredientKeys: ['yumurta', 'domates', 'biber'],
        ingredients: [
          Ingredient(name: 'Yumurta', amount: '2', unit: 'adet'),
          Ingredient(name: 'Domates', amount: '2', unit: 'adet'),
        ],
        substitutions: [],
        steps: [
          CookingStep(
            order: 1,
            title: 'Sebzeleri Soteleme',
            instruction: 'Biber ve domatesleri tavada 3 dakika soteleyin.',
            toolIcon: 'pan',
            timerSeconds: 180,
            proTip: 'Tavanın ısısını orta seviyede tutun, yakmayın.',
          ),
          CookingStep(
            order: 2,
            title: 'Yumurtaları Kırma',
            instruction: 'Yumurtaları kırıp hafifçe karıştırın ve ocağı kapatın.',
            toolIcon: 'spoon',
            timerSeconds: 60,
            proTip: 'Yumurtaların çok kurumaması için tavanın sıcağı yeterlidir.',
          ),
        ],
      );
    });

    testWidgets('renders step 1 with tool icon, instruction, pro tip, timer and navigates through wizard', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CookingModeScreen(recipe: sampleRecipe),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Step 1 header and title
      expect(find.text('ADIM 1'), findsOneWidget);
      expect(find.text('Sebzeleri Soteleme'), findsOneWidget);
      expect(find.textContaining('Biber ve domatesleri tavada 3 dakika soteleyin'), findsOneWidget);

      // Verify tool icon label
      expect(find.text('Tava / Wok'), findsOneWidget);

      // Verify Pro-tip
      expect(find.text('Acemi Püf Noktası 💡'), findsOneWidget);
      expect(find.text('Tavanın ısısını orta seviyede tutun, yakmayın.'), findsOneWidget);

      // Verify Timer section
      expect(find.text('03:00'), findsOneWidget);
      final startTimerButton = find.text('Sayacı Başlat');
      expect(startTimerButton, findsOneWidget);

      // Start timer and advance clock
      await tester.tap(startTimerButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // After 2 seconds, time should be 02:58
      expect(find.text('02:58'), findsOneWidget);
      expect(find.text('Duraklat'), findsOneWidget);

      // Pause timer
      await tester.tap(find.text('Duraklat'));
      await tester.pump();
      expect(find.text('Sayacı Başlat'), findsOneWidget);

      // Navigate to Next Step (Step 2)
      final nextButton = find.text('Sonraki Adım');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Verify Step 2 is shown
      expect(find.text('ADIM 2'), findsOneWidget);
      expect(find.text('Yumurtaları Kırma'), findsOneWidget);
      expect(find.text('Tahta Kaşık / Spatula'), findsOneWidget);
      expect(find.text('01:00'), findsOneWidget);

      // Previous button should now be visible
      final prevButton = find.text('Önceki');
      expect(prevButton, findsOneWidget);

      // Step 2 is the final step, so the action button says "Pişirmeyi Tamamla 🎉"
      final finishButton = find.text('Pişirmeyi Tamamla 🎉');
      expect(finishButton, findsOneWidget);

      // Tap finish button -> shows congratulations dialog
      await tester.tap(finishButton);
      await tester.pumpAndSettle();

      expect(find.text('Tebrikler! 🎉'), findsOneWidget);
      expect(find.textContaining('Özel Menemen #1 tarifini ustalıkla tamamladınız'), findsOneWidget);

      // Dismiss dialog and exit cooking mode
      final returnButton = find.text('Tariflere Geri Dön');
      expect(returnButton, findsOneWidget);
      await tester.tap(returnButton);
      await tester.pumpAndSettle();
    });
  });
}
