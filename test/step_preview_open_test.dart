import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/cooking_mode_screen.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('tapping a step on the detail screen opens cooking mode at that step', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipes = (await RecipeRepository().getRecipes(limit: 20)).recipes;
    final recipe = recipes.firstWhere((r) => r.steps.length >= 3);
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: RecipeDetailScreen(recipe: recipe))));
    await tester.pumpAndSettle();
    final step = find.byKey(const Key('step_preview_2'));
    await tester.ensureVisible(step);
    await tester.pumpAndSettle();
    await tester.tap(step);
    await tester.pumpAndSettle();
    expect(find.byType(CookingModeScreen), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('step_progress'))).data, contains('3 /'));
  });

  testWidgets('step rows on the detail screen are announced as buttons', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipes = (await RecipeRepository().getRecipes(limit: 20)).recipes;
    final recipe = recipes.firstWhere((r) => r.steps.length >= 3);
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: RecipeDetailScreen(recipe: recipe))));
    await tester.pumpAndSettle();
    final step = find.byKey(const Key('step_preview_0'));
    await tester.ensureVisible(step);
    await tester.pumpAndSettle();
    final node = find.ancestor(of: step, matching: find.byWidgetPredicate((w) => w is Semantics && w.properties.button == true));
    expect(node, findsWidgets);
    handle.dispose();
  });
}
