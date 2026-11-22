import 'package:arewecookin/providers/recipe_notes_provider.dart';
import 'package:arewecookin/providers/recipe_progress_provider.dart';
import 'package:arewecookin/providers/recent_searches_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 150));

void main() {
  test('a change made before stored data loads does not erase the stored data', () async {
    SharedPreferences.setMockInitialValues({
      'recipe_progress_v1': '{"old":{"s":6,"p":1}}',
      'recipe_notes_v1': '{"old":{"r":5,"n":"great"}}',
      'recent_searches_v1': ['soup'],
    });
    final a = ProviderContainer();
    addTearDown(a.dispose);
    a.read(recipeProgressProvider.notifier).setServings('new', 2);
    a.read(recipeNotesProvider.notifier).setRating('new', 3);
    a.read(recentSearchesProvider.notifier).add('pasta');
    await settle();
    a.dispose();

    final b = ProviderContainer();
    addTearDown(b.dispose);
    b.read(recipeProgressProvider);
    b.read(recipeNotesProvider);
    b.read(recentSearchesProvider);
    await settle();
    expect(b.read(recipeProgressProvider)['old']!.servings, 6);
    expect(b.read(recipeProgressProvider)['new']!.servings, 2);
    expect(b.read(recipeNotesProvider)['old']!.rating, 5);
    expect(b.read(recipeNotesProvider)['new']!.rating, 3);
    expect(b.read(recentSearchesProvider), containsAll(['soup', 'pasta']));
  });
}
