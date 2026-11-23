import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('with animations turned off, the next step shows right away', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 30)).recipes.firstWhere((r) => r.steps.length >= 2);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        builder: (ctx, w) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: w!,
        ),
        home: CookingModeScreen(recipe: recipe),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.ancestor(of: find.byIcon(Icons.arrow_forward_rounded), matching: find.byType(ElevatedButton)));
    await tester.pump(const Duration(milliseconds: 1));
    expect(tester.widget<Text>(find.byKey(const Key('step_progress'))).data, contains('2 /'));
    expect(tester.widget<Text>(find.byKey(const Key('step_progress'))).data, contains('2 /'));
  });
}
