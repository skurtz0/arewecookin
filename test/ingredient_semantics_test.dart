import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ingredient rows tell screen readers whether they are checked', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final handle = tester.ensureSemantics();
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: RecipeDetailScreen(recipe: recipe))));
    await tester.pumpAndSettle();
    final row = find.byKey(const Key('ingredient_0'));
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    expect(tester.getSemantics(row).getSemanticsData().flagsCollection.isChecked.name, 'isFalse');
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(tester.getSemantics(row).getSemanticsData().flagsCollection.isChecked.name, 'isTrue');
    handle.dispose();
  });
}
