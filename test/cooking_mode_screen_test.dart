import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/household_servings_provider.dart';
import 'package:arewecookin/providers/locale_provider.dart';
import 'package:arewecookin/providers/recipe_progress_provider.dart';
import 'package:arewecookin/providers/recipe_notes_provider.dart';
import 'package:arewecookin/providers/timer_sound_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      SharedPreferences.setMockInitialValues({});
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

    testWidgets('ingredient sheet uses the servings chosen on the detail screen', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(overrides: [
        localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr'))),
      ]);
      addTearDown(container.dispose);
      container.read(recipeProgressProvider.notifier).setServings(sampleRecipe.id, sampleRecipe.servings * 2);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Malzeme').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('4 adet Yumurta'), findsOneWidget);
      expect(find.textContaining('2 adet Yumurta'), findsNothing);
    });

    testWidgets('ingredient ticks are shared with the recipe progress (both directions)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(overrides: [
        localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr'))),
      ]);
      addTearDown(container.dispose);
      container.read(recipeProgressProvider.notifier).setChecked(sampleRecipe.id, {0});
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Malzeme').first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Domates').first);
      await tester.pumpAndSettle();
      expect(container.read(recipeProgressProvider)[sampleRecipe.id]!.checked, {0, 1});
    });

    testWidgets('text size button enlarges the step instruction and wraps around', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(ProviderScope(
        overrides: [localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr')))],
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      double size() => tester.widget<Text>(find.byKey(const Key('step_instruction'))).style!.fontSize!;
      expect(size(), 18);
      await tester.ensureVisible(find.byKey(const Key('cook_text_size')));
      await tester.tap(find.byKey(const Key('cook_text_size')));
      await tester.pumpAndSettle();
      expect(size(), 22);
      await tester.tap(find.byKey(const Key('cook_text_size')));
      await tester.tap(find.byKey(const Key('cook_text_size')));
      await tester.pumpAndSettle();
      expect(size(), 18);
    });

    testWidgets('header shows the timer minutes left and shrinks as steps advance', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(ProviderScope(
        overrides: [localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr')))],
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      // 180 s + 60 s = 4 min
      expect(find.textContaining('~4 dk sayaç kaldı'), findsOneWidget);
    });

    testWidgets('completion dialog is localized and lets you rate the recipe', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(overrides: [
        localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('en'))),
      ]);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      container.read(recipeProgressProvider.notifier).setChecked(sampleRecipe.id, {0, 1});
      for (var i = 0; i < sampleRecipe.steps.length; i++) {
        await tester.tap(find.byIcon(Icons.arrow_forward_rounded).evaluate().isNotEmpty
            ? find.byIcon(Icons.arrow_forward_rounded).first
            : find.textContaining('🎉').last);
        await tester.pumpAndSettle();
      }
      expect(find.text('Well done! 🎉'), findsOneWidget);
      expect(container.read(recipeProgressProvider)[sampleRecipe.id]?.checked ?? <int>{}, isEmpty);
      expect(find.text('Back to recipes'), findsOneWidget);
      await tester.tap(find.byKey(const Key('done_rate_4')));
      await tester.pumpAndSettle();
      expect(container.read(recipeNotesProvider)[sampleRecipe.id]?.rating, 4);
      // A note typed in the completion dialog is saved for the recipe.
      await tester.enterText(find.byKey(const Key('done_note')), 'More chili next time');
      await tester.pump();
      expect(container.read(recipeNotesProvider)[sampleRecipe.id]?.note, 'More chili next time');
      expect(container.read(recipeNotesProvider)[sampleRecipe.id]?.rating, 4);
    });

    testWidgets('ingredient sheet rows expose their checked state', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(ProviderScope(
        overrides: [localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr')))],
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Malzeme').first);
      await tester.pumpAndSettle();
      final row = find.byKey(const Key('cook_ingredient_0'));
      String checked() => tester.getSemantics(row).getSemanticsData().flagsCollection.isChecked.name;
      expect(checked(), 'isFalse');
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(checked(), 'isTrue');
      handle.dispose();
    });

    testWidgets('a step previews the next one, the last step does not', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(ProviderScope(
        overrides: [localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr')))],
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Sonraki: Yumurtaları Kırma'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('next_step_preview')), findsNothing);
    });

    testWidgets('timer sound can be muted and the choice is remembered', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(overrides: [
        localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('en'))),
      ]);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Timer sound on'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('timer_sound_toggle')));
      await tester.tap(find.byKey(const Key('timer_sound_toggle')));
      await tester.pumpAndSettle();
      expect(container.read(timerSoundProvider), isFalse);
      expect(find.byTooltip('Timer sound off'), findsOneWidget);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('timer_sound_v1'), isFalse);
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

    testWidgets('a running timer keeps counting after moving to the next step', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr'))),
          ],
          child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sayacı Başlat'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('Sonraki Adım'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('timers_elsewhere')), findsOneWidget);
      await tester.tap(find.text('Önceki'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      // 180 s minus about 6 s elapsed (timer kept running on the other step)
      expect(find.text('02:54'), findsOneWidget);
      // stop the ticker so the test ends cleanly
      await tester.tap(find.text('Durdur'));
      await tester.pump();
    });

    testWidgets('+1 min adds a minute to the step timer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr')))],
          child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('03:00'), findsOneWidget);
      await tester.tap(find.byKey(const Key('add_minute')));
      await tester.pump();
      expect(find.text('04:00'), findsOneWidget);
      await tester.tap(find.text('Sıfırla'));
      await tester.pump();
      expect(find.text('03:00'), findsOneWidget);
    });

    testWidgets('timer is exposed to screen readers with a label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('en')))],
          child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp(r'step timer: 03:00', caseSensitive: false)), findsOneWidget);
      handle.dispose();
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
      expect(find.textContaining('Gerekli Malzemeler'), findsOneWidget);
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

    testWidgets('ingredients sheet says which servings the amounts are scaled to', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final c = ProviderContainer(overrides: [
        localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('en'))),
      ]);
      addTearDown(c.dispose);
      c.read(householdServingsProvider.notifier).set(7);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cook_ingredients_button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('7 '), findsWidgets);
      final title = tester.widget<Text>(find.byKey(const Key('cook_ingredients_title'))).data!;
      expect(title, contains('7'));
      // The number chosen for this recipe wins over the preference.
      c.read(recipeProgressProvider.notifier).setServings(sampleRecipe.id, 3);
    });

    testWidgets('ingredients sheet shows my note for the recipe', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final c = ProviderContainer(overrides: [
        localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('en'))),
      ]);
      addTearDown(c.dispose);
      c.read(recipeNotesProvider.notifier).setNote(sampleRecipe.id, 'Add less salt');
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(home: CookingModeScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cook_ingredients_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cook_note')), findsOneWidget);
      expect(find.text('Add less salt'), findsOneWidget);
    });
  });
}
