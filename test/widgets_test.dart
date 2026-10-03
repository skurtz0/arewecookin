import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/widgets/recipe_image.dart';
import 'package:arewecookin/widgets/cooking_technique_animation.dart';
import 'package:arewecookin/utils/cooking_icons.dart';

void main() {
  group('RecipeImage Widget Tests', () {
    testWidgets('renders fallback gradient and category icon when imageUrl is null or empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecipeImage(
              imageUrl: null,
              category: 'Ana Yemek',
              height: 120,
              width: 120,
            ),
          ),
        ),
      );

      expect(find.byType(RecipeImage), findsOneWidget);
      // Fallback has a background watermark icon + center badge icon
      expect(find.byIcon(Icons.restaurant_rounded), findsNWidgets(2));
    });

    testWidgets('renders fallback gracefully on invalid image url', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecipeImage(
              imageUrl: 'https://example.com/invalid_food.jpg',
              category: 'Tatlı',
              height: 150,
              width: 200,
            ),
          ),
        ),
      );

      expect(find.byType(RecipeImage), findsOneWidget);
    });
  });

  group('CookingTechniqueAnimation Widget Tests', () {
    testWidgets('renders all 8 technique types without layout error', (tester) async {
      for (final technique in CookingTechniqueType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CookingTechniqueAnimation(
                  technique: technique,
                  height: 160,
                  isDarkMode: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(technique.title), findsOneWidget);
        expect(find.text(technique.guidanceText), findsOneWidget);
      }
    });

    testWidgets('toggles play/pause and opens full modal dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CookingTechniqueAnimation(
              technique: CookingTechniqueType.clawGripKnife,
              height: 160,
              isDarkMode: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap play/pause button
      final pauseButton = find.byIcon(Icons.pause_rounded);
      expect(pauseButton, findsOneWidget);
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();

      final playButton = find.byIcon(Icons.play_arrow_rounded);
      expect(playButton, findsOneWidget);

      // Open modal with fullscreen icon
      final modalTrigger = find.byIcon(Icons.fullscreen_rounded);
      expect(modalTrigger, findsOneWidget);
      await tester.tap(modalTrigger);
      await tester.pumpAndSettle();

      // Verify modal content
      final understandBtn = find.text('Anladım, Uygulayalım');
      expect(understandBtn, findsOneWidget);
      await tester.ensureVisible(understandBtn);
      await tester.tap(understandBtn);
      await tester.pumpAndSettle();

      expect(find.text('Anladım, Uygulayalım'), findsNothing);
    });

    test('CookingTechniqueType.detect maps keywords accurately', () {
      expect(
        CookingTechniqueType.detect(toolIcon: 'knife', proTip: 'bıçak ile parmakları koruyun'),
        CookingTechniqueType.clawGripKnife,
      );
      expect(
        CookingTechniqueType.detect(toolIcon: 'pan', proTip: 'tavayı ısıtın ve su serp cızırdatın'),
        CookingTechniqueType.panHeatTest,
      );
      expect(
        CookingTechniqueType.detect(toolIcon: 'whisk', proTip: '8 rakamı çizerek çırpın'),
        CookingTechniqueType.whiskFigureEight,
      );
      expect(
        CookingTechniqueType.detect(toolIcon: 'pot', proTip: 'kapağı kapalı tutun buhar yoğunlaşsın'),
        CookingTechniqueType.simmerSteamLock,
      );
      expect(
        CookingTechniqueType.detect(toolIcon: 'spoon', proTip: 'kızgın yağda baharat aromalarını açın'),
        CookingTechniqueType.spiceBloom,
      );
      expect(
        CookingTechniqueType.detect(toolIcon: 'bowl', proTip: 'piştikten sonra dinlendirin'),
        CookingTechniqueType.restingJuices,
      );
      expect(
        CookingTechniqueType.detect(
          toolIcon: 'plate',
          proTip: 'Dinlenen bakliyat yemeğinin sosu koyulaşır ve tüm aromatik lezzetler birbirine tam olarak geçer.',
        ),
        CookingTechniqueType.restingJuices,
      );
      expect(
        CookingTechniqueType.detect(toolIcon: 'spoon', proTip: 'yoğurt yerine labne ikame edilebilir'),
        CookingTechniqueType.substitutionBalance,
      );
      expect(CookingIcons.getToolIcon('plate'), Icons.dinner_dining_rounded);
      expect(CookingIcons.getToolLabel('plate'), 'Servis Tabağı & Sunum');
    });
  });
}
