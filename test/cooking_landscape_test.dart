import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final size in [const Size(640, 360), const Size(844, 390), const Size(1024, 768)]) {
    testWidgets('cooking mode has no overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final recipes = (await RecipeRepository().getRecipes(limit: 30)).recipes;
      final r = recipes.firstWhere((r) => r.steps.any((s) => s.timerSeconds > 0));
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: CookingModeScreen(recipe: r))));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      for (var i = 0; i < r.steps.length - 1 && i < 3; i++) {
        final next = find.ancestor(of: find.byIcon(Icons.arrow_forward_rounded), matching: find.byType(ElevatedButton));
        final c = tester.getCenter(next);
        expect(c.dy, lessThanOrEqualTo(size.height), reason: 'next button is on screen');
        await tester.tap(next);
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: 'step $i');
      }
    });
  }
}
