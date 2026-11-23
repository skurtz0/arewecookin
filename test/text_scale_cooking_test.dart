import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final scale in [1.0, 1.8]) {
    testWidgets('cooking mode has no overflow at ${scale}x text, 360x640', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final recipes = (await RecipeRepository().getRecipes(limit: 30)).recipes;
      final withTimer = recipes.firstWhere((r) => r.steps.any((s) => s.timerSeconds > 0));
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          builder: (ctx, w) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)),
            child: w!,
          ),
          home: CookingModeScreen(recipe: withTimer),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      for (var i = 0; i < withTimer.steps.length - 1 && i < 4; i++) {
        final next = find.ancestor(
            of: find.byIcon(Icons.arrow_forward_rounded), matching: find.byType(ElevatedButton));
        expect(next, findsOneWidget);
        await tester.tap(next);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      }
      final shown = tester.widget<Text>(find.byKey(const Key('step_progress'))).data!;
      expect(shown, contains('${(withTimer.steps.length - 1).clamp(1, 4) + 1} /'));
    });
  }
}
