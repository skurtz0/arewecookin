import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_strings.dart';
import '../l10n/recipe_localization.dart';
import 'ingredient.dart';
import 'substitution.dart';
import 'cooking_step.dart';

class Recipe {
  final String id;
  final String title;
  final String category;
  final String cuisine;
  final String? baseDish;
  final int prepTime;
  final int cookTime;
  final String difficulty;
  final List<String> ingredientKeys;
  final List<Ingredient> ingredients;
  final List<Substitution> substitutions;
  final List<CookingStep> steps;
  final int servings;
  final String? imageUrl;

  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    this.cuisine = 'Türk Mutfağı',
    this.baseDish,
    required this.prepTime,
    required this.cookTime,
    required this.difficulty,
    required this.ingredientKeys,
    required this.ingredients,
    required this.substitutions,
    required this.steps,
    this.servings = 4,
    this.imageUrl,
  });

  int get totalTime => prepTime + cookTime;

  /// Returns a clean, authentic dish title without procedural numbers or suffixes
  String get cleanTitle {
    if (baseDish != null && baseDish!.trim().isNotEmpty) {
      return baseDish!.trim();
    }
    final cleaned = title.replaceAll(RegExp(r'\s*#\d+'), '').trim();
    return cleaned.isNotEmpty ? cleaned : title;
  }

  String localizedTitle(String locale) => RecipeLocalization.localizeTitle(this, locale);
  String localizedCleanTitle(String locale) => RecipeLocalization.localizeCleanTitle(this, locale);
  String localizedCategory(AppStrings strings) => RecipeLocalization.localizeCategory(category, strings);
  String localizedCuisine(AppStrings strings) => RecipeLocalization.localizeCuisine(cuisine, strings);
  String localizedDifficulty(AppStrings strings) => RecipeLocalization.localizeDifficulty(difficulty, strings);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'cuisine': cuisine,
      if (baseDish != null) 'baseDish': baseDish,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'difficulty': difficulty,
      'ingredientKeys': ingredientKeys,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'substitutions': substitutions.map((s) => s.toMap()).toList(),
      'steps': steps.map((s) => s.toMap()).toList(),
      'servings': servings,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawIngredientKeys = map['ingredientKeys'];
    final List<String> parsedKeys = rawIngredientKeys is List
        ? rawIngredientKeys.map((e) => e.toString().toLowerCase().trim()).toList()
        : <String>[];

    final rawIngredients = map['ingredients'];
    final List<Ingredient> parsedIngredients = rawIngredients is List
        ? rawIngredients
            .whereType<Map<String, dynamic>>()
            .map((item) => Ingredient.fromMap(item))
            .toList()
        : <Ingredient>[];

    final rawSubstitutions = map['substitutions'];
    final List<Substitution> parsedSubstitutions = rawSubstitutions is List
        ? rawSubstitutions
            .whereType<Map<String, dynamic>>()
            .map((item) => Substitution.fromMap(item))
            .toList()
        : <Substitution>[];

    final rawSteps = map['steps'];
    final List<CookingStep> parsedSteps = rawSteps is List
        ? rawSteps
            .whereType<Map<String, dynamic>>()
            .map((item) => CookingStep.fromMap(item))
            .toList()
        : <CookingStep>[];

    return Recipe(
      id: docId ?? map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Genel',
      cuisine: map['cuisine'] as String? ?? 'Türk Mutfağı',
      baseDish: map['baseDish'] as String?,
      prepTime: (map['prepTime'] as num?)?.toInt() ?? 0,
      cookTime: (map['cookTime'] as num?)?.toInt() ?? 0,
      difficulty: map['difficulty'] as String? ?? 'Kolay',
      ingredientKeys: parsedKeys,
      ingredients: parsedIngredients,
      substitutions: parsedSubstitutions,
      steps: parsedSteps,
      servings: (map['servings'] as num?)?.toInt() ?? 4,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  factory Recipe.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Recipe.fromMap(data, doc.id);
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    String? cuisine,
    String? baseDish,
    int? prepTime,
    int? cookTime,
    String? difficulty,
    List<String>? ingredientKeys,
    List<Ingredient>? ingredients,
    List<Substitution>? substitutions,
    List<CookingStep>? steps,
    int? servings,
    String? imageUrl,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      cuisine: cuisine ?? this.cuisine,
      baseDish: baseDish ?? this.baseDish,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      ingredientKeys: ingredientKeys ?? this.ingredientKeys,
      ingredients: ingredients ?? this.ingredients,
      substitutions: substitutions ?? this.substitutions,
      steps: steps ?? this.steps,
      servings: servings ?? this.servings,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Calculates pantry match percentage: (Available Required / Total Required) * 100
  double calculateMatchScore(List<String> userKeys) {
    final normalizedUser = userKeys.map((k) => k.toLowerCase().trim()).toSet();
    if (ingredientKeys.isEmpty) return 100.0;

    int matchedCount = 0;
    for (final key in ingredientKeys) {
      if (normalizedUser.contains(key.toLowerCase().trim())) {
        matchedCount++;
      }
    }

    return (matchedCount / ingredientKeys.length) * 100.0;
  }

  /// Returns list of missing ingredient keys given the user's pantry
  List<String> getMissingKeys(List<String> userKeys) {
    final normalizedUser = userKeys.map((k) => k.toLowerCase().trim()).toSet();
    return ingredientKeys
        .where((key) => !normalizedUser.contains(key.toLowerCase().trim()))
        .toList();
  }

  /// Finds matching substitution for missing ingredients
  List<Substitution> getApplicableSubstitutions(List<String> userKeys) {
    final missing = getMissingKeys(userKeys).map((k) => k.toLowerCase()).toSet();
    return substitutions
        .where((s) => missing.contains(s.ingredient.toLowerCase().trim()))
        .toList();
  }
}
