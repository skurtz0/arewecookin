import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/data/photo_credits.dart';
import 'package:arewecookin/data/world_recipes.dart';
import 'package:arewecookin/screens/recipe_detail_screen.dart';
import 'package:arewecookin/services/recipe_generator.dart';

void main() {
  test('every photo in the app has a credit', () {
    final urls = <String>{
      ...RecipeGenerator.dishImages.values,
      for (final r in WorldRecipes.all)
        if (r.imageUrl != null) r.imageUrl!,
    };
    expect(urls.length, greaterThan(100));
    final missing = urls.where((u) => photoCreditFor(u) == null).toList();
    expect(missing, isEmpty);
  });

  test('credit text names Wikimedia Commons and unknown pictures have none', () {
    final any = photoCredits.keys.first;
    expect(photoCreditFor(any), contains('Wikimedia Commons'));
    expect(photoCreditFor('https://example.com/x.jpg'), isNull);
    expect(photoCreditFor(null), isNull);
  });

  testWidgets('recipe page shows the photo credit', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final recipe = WorldRecipes.all.firstWhere((r) => r.imageUrl != null);
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: RecipeDetailScreen(recipe: recipe))));
    await tester.pump();
    expect(find.byKey(const Key('photo_credit')), findsOneWidget);
  });

  test('photos are well-formed https links', () {
    for (final u in RecipeGenerator.dishImages.values) {
      expect(Uri.parse(u).scheme, 'https', reason: u);
    }
  });
}
