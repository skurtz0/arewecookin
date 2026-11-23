import 'package:arewecookin/providers/avoided_ingredients_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('long-pressing an ingredient adds it to the avoided list, with undo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    final row = find.byKey(const Key('ingredient_0'));
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    expect(c.read(avoidedIngredientsProvider), isEmpty);
    expect(find.byKey(const Key('avoid_hint')), findsOneWidget);
    await tester.longPress(row);
    await tester.pump(const Duration(milliseconds: 400));
    expect(c.read(avoidedIngredientsProvider), isNotEmpty);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('avoid_hint')), findsNothing);
    tester.widget<SnackBarAction>(find.byKey(const Key('avoid_undo'))).onPressed();
    await tester.pump();
    expect(c.read(avoidedIngredientsProvider), isEmpty);
  });
}
