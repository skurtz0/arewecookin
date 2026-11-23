import 'dart:convert';

import '../l10n/recipe_localization.dart';
import '../models/models.dart';
import 'world_recipes_data.dart';

/// Hand-written recipes from around the world (Turkish + English text).
/// Every recipe has its own dish-specific steps; images are Wikipedia-verified.
class WorldRecipes {
  WorldRecipes._();

  static List<Recipe>? _cache;

  static List<Recipe> get all => _cache ??= _build();

  /// Generated base dishes superseded by a curated recipe (hidden from the generated list).
  static final Set<String> coveredDishes = {
    for (final e in jsonDecode(worldRecipesJson) as List)
      if (((e as Map)['cov'] as String).isNotEmpty) e['cov'] as String,
  };

  static bool isWorldId(String id) => id.startsWith('w_');

  static Recipe? byId(String id) {
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }

  static List<Recipe> _build() {
    final raw = jsonDecode(worldRecipesJson) as List;
    return raw.map((e) => _fromJson(e as Map<String, dynamic>)).toList(growable: false);
  }

  /// Attach, to every step, the ingredients its instruction actually mentions.
  static List<CookingStep> _withStepIngredients(List<CookingStep> steps, List<Ingredient> ings) {
    return steps.map((s) {
      final text = s.instruction.toLowerCase();
      final used = <String>[];
      for (final i in ings) {
        final first = i.name.split(' ').first.toLowerCase();
        final stem = first.length > 5 ? first.substring(0, 5) : first;
        if (stem.length >= 3 && text.contains(stem)) used.add(i.name);
      }
      return s.copyWith(stepIngredients: used);
    }).toList();
  }

  static String? _nz(Object? v) {
    final s = v?.toString() ?? '';
    return s.isEmpty ? null : s;
  }

  /// [packed]: a recipe from a server pack (its id is already final), not one of the bundled ones.
  static Recipe fromJson(Map<String, dynamic> m, {bool packed = false}) => _fromJson(m, packed: packed);

  static Recipe _fromJson(Map<String, dynamic> m, {bool packed = false}) {
    final ings = (m['ing'] as List).map((e) {
      final i = e as Map<String, dynamic>;
      final en = _nz(i['ne']);
      if (en != null) RecipeLocalization.registerIngredientEn(i['n'] as String, en);
      return Ingredient(
        name: i['n'] as String,
        amount: i['a'] as String,
        unit: i['u'] as String,
        nameEn: _nz(i['ne']),
        unitEn: _nz(i['ue']),
      );
    }).toList();
    final steps = (m['st'] as List).map((e) {
      final s = e as Map<String, dynamic>;
      return CookingStep(
        order: s['o'] as int,
        title: s['t'] as String,
        instruction: s['i'] as String,
        toolIcon: s['tool'] as String,
        timerSeconds: s['sec'] as int,
        proTip: (s['p'] as String?) ?? '',
        titleEn: _nz(s['te']),
        instructionEn: _nz(s['ie']),
        proTipEn: _nz(s['pe']),
      );
    }).toList();
    return Recipe(
      id: packed ? m['id'] as String : 'w_${m['id']}',
      title: m['tr'] as String,
      titleEn: m['en'] as String,
      baseDish: m['tr'] as String,
      category: m['cat'] as String,
      cuisine: m['c'] as String,
      prepTime: m['p'] as int,
      cookTime: m['k'] as int,
      difficulty: m['d'] as String,
      servings: m['sv'] as int,
      ingredientKeys: ings.isEmpty ? const [] : (m['ing'] as List).map((e) => (e as Map)['k'].toString()).toList(),
      ingredients: ings,
      substitutions: const [],
      steps: _withStepIngredients(steps, ings),
      imageUrl: _nz(m['img']),
    );
  }
}
