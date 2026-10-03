import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/locale_provider.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';

class FakeLocaleNotifier extends LocaleNotifier {
  final Locale _initial;
  FakeLocaleNotifier([this._initial = const Locale('tr')]);

  @override
  Locale build() => _initial;
}

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

    testWidgets('renders step 1 with tool icon, instruction, pro tip, timer and navigates through wizard in Turkish', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr'))),
          ],
          child: MaterialApp(
            home: CookingModeScreen(recipe: sampleRecipe),
          ),
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
      expect(find.text('Şefin Püf Noktası 💡'), findsOneWidget);
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
      expect(find.text('Durdur'), findsOneWidget);

      // Pause timer
      await tester.tap(find.text('Durdur'));
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

    testWidgets('displays step ingredients and full ingredients bottom sheet in cooking mode in Turkish', (tester) async {
      const detailedRecipe = Recipe(
        id: 'rec_00099',
        title: 'Güveçte Kuru Fasulye',
        category: 'Ana Yemek',
        prepTime: 15,
        cookTime: 45,
        difficulty: 'Orta',
        ingredientKeys: ['fasulye', 'sogan', 'tereyagi'],
        ingredients: [
          Ingredient(name: 'Kuru Fasulye', amount: '2', unit: 'su bardağı'),
          Ingredient(name: 'Kuru Soğan', amount: '1', unit: 'adet'),
          Ingredient(name: 'Tereyağı', amount: '2', unit: 'yemek kaşığı'),
        ],
        substitutions: [],
        steps: [
          CookingStep(
            order: 1,
            title: 'Bakliyat Süzme & Doğrama',
            instruction: 'Fasulyeleri süzün ve soğanı yemeklik doğrayın.',
            toolIcon: 'knife',
            timerSeconds: 300,
            proTip: 'Karbonat gazını alır.',
            stepIngredients: ['2 su bardağı Kuru Fasulye', '1 adet Kuru Soğan'],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr'))),
          ],
          child: const MaterialApp(
            home: CookingModeScreen(recipe: detailedRecipe),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify step ingredients card is rendered
      expect(find.text('Bu Adımda Kullanılacak Malzemeler:'), findsOneWidget);
      expect(find.text('2 su bardağı Kuru Fasulye'), findsOneWidget);
      expect(find.text('1 adet Kuru Soğan'), findsOneWidget);

      // Verify Malzeme button in AppBar
      final allIngredientsButton = find.text('3 Malzeme');
      expect(allIngredientsButton, findsOneWidget);

      // Tap Malzeme button -> opens bottom sheet
      await tester.tap(allIngredientsButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet content
      expect(find.text('Gerekli Malzemeler'), findsOneWidget);
      expect(find.text('2 su bardağı Kuru Fasulye'), findsWidgets);
      expect(find.text('2 yemek kaşığı Tereyağı'), findsOneWidget);

      // Tap on an ingredient to toggle checked state
      await tester.tap(find.text('2 yemek kaşığı Tereyağı'));
      await tester.pump();
      expect(find.text('1/3 Hazır'), findsOneWidget);
    });

    testWidgets('renders cooking mode in English localization', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CookingModeScreen(recipe: sampleRecipe),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Step 1 header and title in English
      expect(find.text('STEP 1'), findsOneWidget);
      expect(find.text('Start Timer'), findsOneWidget);
      expect(find.text('Next Step'), findsOneWidget);
      expect(find.text('2 Ingredients'), findsOneWidget);
    });
  });
}
