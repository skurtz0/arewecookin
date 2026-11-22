import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('cook history counts and persists', () async {
    SharedPreferences.setMockInitialValues({});
    final a = ProviderContainer();
    final n = a.read(cookHistoryProvider.notifier);
    n.markCooked('r', at: DateTime(2026, 11, 20));
    n.markCooked('r', at: DateTime(2026, 11, 22));
    expect(a.read(cookHistoryProvider)['r']!.count, 2);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    a.dispose();
    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(cookHistoryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(b.read(cookHistoryProvider)['r']!.count, 2);
    expect(b.read(cookHistoryProvider)['r']!.last, DateTime(2026, 11, 22));
  });

  testWidgets('detail screen shows how often it was cooked', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: RecipeDetailScreen(recipe: recipe)),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cooked_times')), findsNothing);
    c.read(cookHistoryProvider.notifier)
      ..markCooked(recipe.id)
      ..markCooked(recipe.id);
    await tester.pumpAndSettle();
    final t = find.byKey(const Key('cooked_times'));
    await tester.ensureVisible(t);
    expect(tester.widget<Text>(t).data, contains('2'));
  });
}
