import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/locale_provider.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';

class FakeLocaleNotifier extends LocaleNotifier {
  final Locale _initial;
  FakeLocaleNotifier([this._initial = const Locale('tr')]);

  @override
  Locale build() => _initial;
}

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
        difficulty: 'Orta',
        ingredientKeys: ['kuru fasulye', 'sogan', 'salca'],
        ingredients: [
          Ingredient(name: 'Kuru Fasulye', amount: '2', unit: 'su bardağı'),
          Ingredient(name: 'Soğan', amount: '1', unit: 'adet'),
          Ingredient(name: 'Salça', amount: '1', unit: 'yemek kaşığı'),
        ],
        substitutions: [
          Substitution(
            ingredient: 'Kuru Fasulye',
            alternative: 'Nohut veya Barbunya',
            tip: 'Pişme süresi değişebilir.',
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

    testWidgets('renders details, scales servings, toggles checklist and launches cooking mode in Turkish', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr'))),
          ],
          child: MaterialApp(
            home: RecipeDetailScreen(recipe: sampleRecipe),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title & stats
      expect(find.text('Özel Güveçte Kuru Fasulye #1'), findsWidgets);
      expect(find.text('Ana Yemek'), findsOneWidget);
      expect(find.text('4 Kişilik'), findsWidgets);
      expect(find.text('15 dk'), findsOneWidget);
      expect(find.text('45 dk'), findsOneWidget);

      // Verify initial ingredient amount: '2 su bardağı'
      expect(find.text('2 su bardağı'), findsOneWidget);

      // Scale servings up from 4 to 5 (increase servings)
      final addServingsButton = find.byIcon(Icons.add_circle_outline_rounded);
      expect(addServingsButton, findsOneWidget);
      await tester.ensureVisible(addServingsButton);
      await tester.pumpAndSettle();
      await tester.tap(addServingsButton);
      await tester.pumpAndSettle();

      // Check servings updated to 5 Kişilik
      expect(find.text('5 Kişilik'), findsWidgets);
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

      // Tap CTA: "Pişirme Modunu Başlat 🍳"
      final ctaButton = find.text('Pişirme Modunu Başlat 🍳');
      expect(ctaButton, findsOneWidget);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      expect(find.byType(CookingModeScreen), findsOneWidget);
    });

    testWidgets('renders recipe details with English localization', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeDetailScreen(recipe: sampleRecipe),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify English localized labels
      expect(find.text('Special Clay Pot White Bean Stew'), findsWidgets);
      expect(find.text('Main Dish'), findsOneWidget);
      expect(find.text('4 Servings'), findsWidgets);
      expect(find.text('15 min'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
      expect(find.text('Start Cooking Mode 🍳'), findsOneWidget);
    });

    testWidgets('copy button puts the recipe text on the clipboard', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr')))],
          child: MaterialApp(home: RecipeDetailScreen(recipe: sampleRecipe)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('copy_recipe')));
      await tester.pumpAndSettle();
      expect(copied, isNotNull);
      expect(copied, contains('Kuru Fasulye'));
      expect(copied, contains('1.'));
    });

    testWidgets('add to shopping list skips ingredients already ticked as available', (tester) async {
      final container = ProviderContainer(overrides: [
        localeProvider.overrideWith(() => FakeLocaleNotifier(const Locale('tr'))),
      ]);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: RecipeDetailScreen(recipe: sampleRecipe)),
      ));
      await tester.pumpAndSettle();
      final first = sampleRecipe.ingredients.first.localizedName('tr');
      await tester.ensureVisible(find.text(first));
      await tester.tap(find.text(first));
      await tester.pump();
      final btn = find.byKey(const Key('add_to_shopping_list'));
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pump();
      final names = container.read(shoppingListProvider).map((e) => e.name).toList();
      expect(names, isNot(contains(first)));
      expect(names.length, sampleRecipe.ingredients.length - 1);
    });
  });
}
