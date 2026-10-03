import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../repositories/recipe_repository.dart';

// --- SAVED (FAVORITE) RECIPES ---

class SavedRecipesState {
  final List<Recipe> recipes;
  final Set<String> savedIds;
  final bool isLoaded;

  const SavedRecipesState({
    this.recipes = const [],
    this.savedIds = const {},
    this.isLoaded = false,
  });

  bool isSaved(String recipeId) => savedIds.contains(recipeId);
}

class SavedRecipesNotifier extends Notifier<SavedRecipesState> {
  static const _prefKey = 'user_saved_recipes_v1';

  @override
  SavedRecipesState build() {
    _loadFromStorage();
    return const SavedRecipesState();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_prefKey);
      if (jsonList != null && jsonList.isNotEmpty) {
        final List<Recipe> loaded = [];
        final Set<String> ids = {};
        for (final itemStr in jsonList) {
          try {
            final map = jsonDecode(itemStr) as Map<String, dynamic>;
            final recipe = Recipe.fromMap(map);
            loaded.add(recipe);
            ids.add(recipe.id);
          } catch (_) {}
        }
        state = SavedRecipesState(recipes: loaded, savedIds: ids, isLoaded: true);
        return;
      }
    } catch (_) {}
    state = const SavedRecipesState(isLoaded: true);
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = state.recipes.map((r) => jsonEncode(r.toMap())).toList();
      await prefs.setStringList(_prefKey, list);
    } catch (_) {}
  }

  Future<bool> toggleSave(Recipe recipe) async {
    final ids = Set<String>.from(state.savedIds);
    final list = List<Recipe>.from(state.recipes);

    final bool nowSaved;
    if (ids.contains(recipe.id)) {
      ids.remove(recipe.id);
      list.removeWhere((r) => r.id == recipe.id);
      nowSaved = false;
    } else {
      ids.add(recipe.id);
      list.insert(0, recipe);
      nowSaved = true;
    }

    state = SavedRecipesState(recipes: list, savedIds: ids, isLoaded: true);
    await _saveToStorage();
    return nowSaved;
  }

  Future<void> remove(String recipeId) async {
    if (!state.savedIds.contains(recipeId)) return;
    final ids = Set<String>.from(state.savedIds)..remove(recipeId);
    final list = List<Recipe>.from(state.recipes)..removeWhere((r) => r.id == recipeId);
    state = SavedRecipesState(recipes: list, savedIds: ids, isLoaded: true);
    await _saveToStorage();
  }
}

final savedRecipesProvider =
    NotifierProvider<SavedRecipesNotifier, SavedRecipesState>(SavedRecipesNotifier.new);

// --- CUSTOM USER RECIPES ---

class CustomRecipesNotifier extends Notifier<List<Recipe>> {
  static const _prefKey = 'user_custom_recipes_v1';

  @override
  List<Recipe> build() {
    _loadFromStorage();
    return const [];
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_prefKey);
      if (jsonList != null && jsonList.isNotEmpty) {
        final List<Recipe> loaded = [];
        final repo = ref.read(recipeRepositoryProvider);
        for (final itemStr in jsonList) {
          try {
            final map = jsonDecode(itemStr) as Map<String, dynamic>;
            final recipe = Recipe.fromMap(map);
            loaded.add(recipe);
            repo.addCustomRecipe(recipe);
          } catch (_) {}
        }
        state = loaded;
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = state.map((r) => jsonEncode(r.toMap())).toList();
      await prefs.setStringList(_prefKey, list);
    } catch (_) {}
  }

  Future<void> addRecipe(Recipe recipe) async {
    final repo = ref.read(recipeRepositoryProvider);
    repo.addCustomRecipe(recipe);
    final list = List<Recipe>.from(state)
      ..removeWhere((r) => r.id == recipe.id)
      ..insert(0, recipe);
    state = list;
    await _saveToStorage();
  }

  Future<void> deleteRecipe(String recipeId) async {
    final repo = ref.read(recipeRepositoryProvider);
    repo.removeCustomRecipe(recipeId);
    final list = List<Recipe>.from(state)..removeWhere((r) => r.id == recipeId);
    state = list;
    await _saveToStorage();
  }
}

final customRecipesProvider =
    NotifierProvider<CustomRecipesNotifier, List<Recipe>>(CustomRecipesNotifier.new);
