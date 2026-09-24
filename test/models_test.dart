import 'package:flutter_test/flutter_test.dart';
import 'package:arewecookin/models/models.dart';

void main() {
  group('Models Serialization & Logic', () {
    test('Ingredient serialization and displayText', () {
      const ingredient = Ingredient(
        name: 'Un',
        amount: '2',
        unit: 'su bardağı',
        isOptional: false,
      );

      final map = ingredient.toMap();
      expect(map['name'], 'Un');
      expect(map['amount'], '2');
      expect(map['unit'], 'su bardağı');
      expect(map['isOptional'], false);
      expect(ingredient.displayText, '2 su bardağı Un');

      final deserialized = Ingredient.fromMap(map);
      expect(deserialized.name, 'Un');
      expect(deserialized.amount, '2');
      expect(deserialized.unit, 'su bardağı');
      expect(deserialized.isOptional, false);
    });

    test('Substitution serialization', () {
      const sub = Substitution(
        ingredient: 'un',
        alternative: 'Yulaf unu',
        tip: 'Bağlayıcılık için 1 yumurta fazla kırın.',
      );

      final map = sub.toMap();
      final fromMap = Substitution.fromMap(map);
      expect(fromMap.ingredient, 'un');
      expect(fromMap.alternative, 'Yulaf unu');
      expect(fromMap.tip, 'Bağlayıcılık için 1 yumurta fazla kırın.');
    });

    test('CookingStep serialization', () {
      const step = CookingStep(
        order: 1,
        title: 'Hazırlık',
        instruction: 'Fırını 180 dereceye ayarlayın.',
        toolIcon: 'microwave',
        timerSeconds: 600,
        proTip: 'Önceden ısıtın.',
      );

      final map = step.toMap();
      final fromMap = CookingStep.fromMap(map);
      expect(fromMap.order, 1);
      expect(fromMap.title, 'Hazırlık');
      expect(fromMap.instruction, 'Fırını 180 dereceye ayarlayın.');
      expect(fromMap.toolIcon, 'microwave');
      expect(fromMap.timerSeconds, 600);
      expect(fromMap.proTip, 'Önceden ısıtın.');
    });

    test('Recipe serialization and match score calculations', () {
      final recipe = Recipe(
        id: 'rec_1',
        title: 'Kek',
        category: 'Tatlı',
        prepTime: 15,
        cookTime: 35,
        difficulty: 'Kolay',
        ingredientKeys: ['un', 'seker', 'yumurta'],
        ingredients: [
          const Ingredient(name: 'Un', amount: '2', unit: 'bardak'),
          const Ingredient(name: 'Şeker', amount: '1', unit: 'bardak'),
          const Ingredient(name: 'Yumurta', amount: '3', unit: 'adet'),
        ],
        substitutions: [
          const Substitution(
            ingredient: 'un',
            alternative: 'Yulaf unu',
            tip: 'Daha yoğun olur.',
          ),
        ],
        steps: [
          const CookingStep(
            order: 1,
            title: 'Çırpma',
            instruction: 'Yumurta ve şekeri çırpın.',
            toolIcon: 'whisk',
            timerSeconds: 180,
            proTip: 'Köpük köpük olana kadar çırpın.',
          ),
        ],
      );

      final map = recipe.toMap();
      final deserialized = Recipe.fromMap(map, 'rec_1');
      expect(deserialized.id, 'rec_1');
      expect(deserialized.title, 'Kek');
      expect(deserialized.totalTime, 50);
      expect(deserialized.ingredients.length, 3);
      expect(deserialized.substitutions.length, 1);
      expect(deserialized.steps.length, 1);

      // Pantry calculation test
      final matchScore = deserialized.calculateMatchScore(['un', 'seker']);
      expect(matchScore, closeTo(66.66, 0.1));

      final missing = deserialized.getMissingKeys(['un', 'seker']);
      expect(missing, ['yumurta']);

      final missingUn = deserialized.getMissingKeys(['seker', 'yumurta']);
      final subs = deserialized.getApplicableSubstitutions(['seker', 'yumurta']);
      expect(missingUn, ['un']);
      expect(subs.length, 1);
      expect(subs.first.alternative, 'Yulaf unu');
    });
  });
}
