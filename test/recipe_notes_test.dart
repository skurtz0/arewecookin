import 'package:arewecookin/providers/recipe_notes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('rating toggles off when tapped again; empty note is dropped; persists', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    final n = a.read(recipeNotesProvider.notifier);
    n.setRating('r1', 4);
    n.setNote('r1', 'less salt');
    expect(a.read(recipeNotesProvider)['r1']!.rating, 4);
    n.setRating('r1', 4);
    expect(a.read(recipeNotesProvider)['r1']!.rating, 0);
    n.setNote('r2', 'x');
    n.setNote('r2', '');
    expect(a.read(recipeNotesProvider).containsKey('r2'), isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    a.dispose();
    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(recipeNotesProvider);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(b.read(recipeNotesProvider)['r1']!.note, 'less salt');
  });

  testWidgets('detail screen: stars and note are saved', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    final star = find.byKey(const Key('rate_4'));
    await tester.ensureVisible(star);
    await tester.pumpAndSettle();
    await tester.tap(star);
    await tester.enterText(find.byKey(const Key('recipe_note_field')), 'great');
    await tester.pump();
    final saved = c.read(recipeNotesProvider)[recipe.id]!;
    expect(saved.rating, 4);
    expect(saved.note, 'great');
  });
}
