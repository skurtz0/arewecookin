import 'dart:async';
import 'package:arewecookin/providers/avoided_ingredients_provider.dart';
import 'package:arewecookin/providers/cook_history_provider.dart';
import 'package:arewecookin/providers/cook_text_size_provider.dart';
import 'package:arewecookin/providers/discover_provider.dart';
import 'package:arewecookin/providers/household_servings_provider.dart';
import 'package:arewecookin/providers/meal_plan_provider.dart';
import 'package:arewecookin/providers/pantry_provider.dart';
import 'package:arewecookin/providers/recent_recipes_provider.dart';
import 'package:arewecookin/providers/recent_searches_provider.dart';
import 'package:arewecookin/providers/recipe_notes_provider.dart';
import 'package:arewecookin/providers/recipe_progress_provider.dart';
import 'package:arewecookin/providers/shopping_list_provider.dart';
import 'package:arewecookin/providers/timer_sound_provider.dart';
import 'package:arewecookin/providers/unit_system_provider.dart';
import 'package:arewecookin/providers/user_recipes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const keys = [
    'recent_searches_v1', 'user_saved_recipes_v1', 'user_custom_recipes_v1', 'recipe_notes_v1',
    'cook_text_size_v1', 'recipe_progress_v1', 'household_servings_v1', 'meal_plan_v1',
    'timer_sound_v1', 'shopping_list_v1', 'pantry_keys_v1', 'pantry_cuisine_v1',
    'pantry_full_only_v1', 'pantry_sort_time_v1', 'recent_recipes_v1', 'discover_filters_v1',
    'avoided_ingredients_v1', 'cook_history_v1', 'imperial_units_v1',
  ];

  // Same garbage under every key, once as a string, once as a list: wrong shape either way.
  for (final garbage in <Object>['{not json', '[1,2', '"x"', <String>['{bad', '[]', 'null']]) {
    test('unreadable stored data (${garbage.runtimeType}) does not crash any provider', () async {
      SharedPreferences.setMockInitialValues({for (final k in keys) k: garbage});
      final errors = <Object>[];
      await runZonedGuardedForTest(errors, () async {
        final c = ProviderContainer();
        addTearDown(c.dispose);
        c.read(recentSearchesProvider);
        c.read(savedRecipesProvider);
        c.read(customRecipesProvider);
        c.read(recipeNotesProvider);
        c.read(cookTextSizeProvider);
        c.read(recipeProgressProvider);
        c.read(householdServingsProvider);
        c.read(mealPlanProvider);
        c.read(timerSoundProvider);
        c.read(shoppingListProvider);
        c.read(pantryProvider);
        c.read(recentRecipesProvider);
        c.read(discoverProvider);
        c.read(avoidedIngredientsProvider);
        c.read(cookHistoryProvider);
        c.read(imperialUnitsProvider);
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      expect(errors, isEmpty);
    });
  }
}

Future<void> runZonedGuardedForTest(List<Object> errors, Future<void> Function() body) async {
  await runZonedGuarded(body, (e, s) => errors.add('$e\n$s'));
}
