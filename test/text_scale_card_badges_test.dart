import 'package:arewecookin/providers/avoided_ingredients_provider.dart';
import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:arewecookin/providers/discover_provider.dart';
import 'package:arewecookin/providers/recipe_notes_provider.dart';
import 'package:arewecookin/repositories/recipe_repository.dart';
import 'package:arewecookin/screens/discover_screen.dart';
import 'package:arewecookin/widgets/avoided_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _scaled(Widget child) => MaterialApp(
      builder: (ctx, w) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(textScaler: const TextScaler.linear(1.8)),
        child: w!,
      ),
      home: child,
    );

void main() {
  testWidgets('a Discover card with note, rating and cooked marks has no overflow at 1.8x text, 360px', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: _scaled(const Scaffold(body: DiscoverScreen()))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final first = c.read(discoverProvider).recipes.first;
    c.read(recipeNotesProvider.notifier).setNote(first.id, 'note');
    c.read(recipeNotesProvider.notifier).setRating(first.id, 5);
    c.read(cookHistoryProvider.notifier).markCooked(first.id, at: DateTime(2026, 1, 1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(Key('note_badge_${first.id}')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the avoided badge shortens long word lists instead of overflowing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final base = (await RecipeRepository().getRecipes(limit: 1)).recipes.first;
    final words = base.ingredients.map((i) => RecipeRepository.normalizeSearch(i.name.trim())).where((w) => w.length > 2).join(' ');
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(avoidedIngredientsProvider.notifier).add(words);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: _scaled(Scaffold(body: Center(child: SizedBox(width: 150, child: Wrap(children: [AvoidedBadge(recipe: base)]))))),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('avoided_badge_${base.id}')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
