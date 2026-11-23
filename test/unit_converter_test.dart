import 'package:arewecookin/models/models.dart';
import 'package:arewecookin/providers/unit_system_provider.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:arewecookin/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('metric to US conversion', () {
    expect(UnitConverter.format(UnitConverter.toImperial(100, 'g')!.amount), '3.5');
    expect(UnitConverter.toImperial(100, 'g')!.unit, 'oz');
    expect(UnitConverter.toImperial(500, 'g')!.unit, 'lb');
    expect(UnitConverter.format(UnitConverter.toImperial(1, 'kg')!.amount), '2.2');
    expect(UnitConverter.toImperial(250, 'ml')!.unit, 'fl oz');
    expect(UnitConverter.toImperial(2, 'su bardağı'), isNull);
    expect(UnitConverter.toImperial(5, 'adet'), isNull);
  });

  testWidgets('detail screen shows ounces when US units are selected', (tester) async {
    SharedPreferences.setMockInitialValues({});
    const recipe = Recipe(
      id: 'u1', title: 'Test', category: 'Ana Yemek', prepTime: 5, cookTime: 5, difficulty: 'Kolay',
      servings: 4,
      ingredients: [
        Ingredient(name: 'Un', amount: '200', unit: 'g', unitEn: 'g'),
        Ingredient(name: 'Süt', amount: '2', unit: 'su bardağı', unitEn: 'cup'),
        Ingredient(name: 'Tuz', amount: '1', unit: 'tutam', unitEn: 'pinch'),
      ],
      ingredientKeys: ['un', 'sut', 'tuz'],
      steps: [CookingStep(order: 1, title: 'a', instruction: 'b', toolIcon: 'pan', timerSeconds: 0, proTip: '')],
      substitutions: [],
    );
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('200 g'), findsOneWidget);
    c.read(imperialUnitsProvider.notifier).set(true);
    await tester.pumpAndSettle();
    expect(find.text('200 g'), findsNothing);
    expect(find.text('7.1 oz'), findsOneWidget);
    expect(find.text('2 cup'), findsOneWidget);
  });

  test('kitchen fractions', () {
    expect(AmountFormat.fraction(2.5), '2½');
    expect(AmountFormat.fraction(0.25), '¼');
    expect(AmountFormat.fraction(1.75), '1¾');
    expect(AmountFormat.fraction(1 / 3), '⅓');
    expect(AmountFormat.fraction(3.0), '3');
    expect(AmountFormat.fraction(2.98), '3');
    expect(AmountFormat.fraction(1.1), '1.1');
  });

  test('AmountFormat.parse reads amounts people type', () {
    expect(AmountFormat.parse('2'), 2);
    expect(AmountFormat.parse(' 1,5 '), 1.5);
    expect(AmountFormat.parse('1/2'), 0.5);
    expect(AmountFormat.parse('1 1/2'), 1.5);
    expect(AmountFormat.parse('½'), 0.5);
    expect(AmountFormat.parse('1½'), 1.5);
    expect(AmountFormat.parse('2 ¼'), 2.25);
    expect(AmountFormat.parse('1/0'), isNull);
    expect(AmountFormat.parse('bir tutam'), isNull);
    expect(AmountFormat.parse(''), isNull);
  });
}
