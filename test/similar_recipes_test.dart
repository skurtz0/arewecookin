import 'package:arewecookin/providers/discover_provider.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('detail lists loaded recipes of the same category and opens one', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(discoverProvider);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    final all = c.read(discoverProvider).recipes;
    final recipe = all.firstWhere((r) => all.any((o) => o.id != r.id && o.category == r.category));
    final sibling = all.firstWhere((o) => o.id != recipe.id && o.category == recipe.category);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    final chip = find.byKey(Key('similar_${sibling.id}'));
    await tester.ensureVisible(chip);
    expect(find.byKey(Key('similar_${recipe.id}')), findsNothing);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.byType(RecipeDetailScreen, skipOffstage: false), findsNWidgets(2));
  });
}
