import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'avoided_ingredients_provider.dart';
import '../repositories/recipe_repository.dart';

class PantryState {
  final Set<String> selectedKeys;
  final String selectedCuisine;
  final bool onlyFullMatches;
  final bool sortByTime;
  final List<Recipe> matchedRecipes;
  final bool isLoading;
  final String? errorMessage;

  const PantryState({
    this.selectedKeys = const {},
    this.selectedCuisine = 'Tümü',
    this.onlyFullMatches = false,
    this.sortByTime = false,
    this.matchedRecipes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PantryState copyWith({
    Set<String>? selectedKeys,
    String? selectedCuisine,
    bool? onlyFullMatches,
    bool? sortByTime,
    List<Recipe>? matchedRecipes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PantryState(
      selectedKeys: selectedKeys ?? this.selectedKeys,
      selectedCuisine: selectedCuisine ?? this.selectedCuisine,
      onlyFullMatches: onlyFullMatches ?? this.onlyFullMatches,
      sortByTime: sortByTime ?? this.sortByTime,
      matchedRecipes: matchedRecipes ?? this.matchedRecipes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PantryNotifier extends Notifier<PantryState> {
  RecipeRepository get _repository => ref.read(recipeRepositoryProvider);

  static const _prefKey = 'pantry_keys_v1';
  static const _cuisineKey = 'pantry_cuisine_v1';
  static const _fullKey = 'pantry_full_only_v1';
  static const _sortKey = 'pantry_sort_time_v1';
  bool _filtersTouched = false;
  // Saving waits for the stored selection to be read first, so an early tap never overwrites it.
  Future<void> _ready = Future.value();

  @override
  PantryState build() {
    _ready = _restore();
    return const PantryState();
  }

  /// Pantry selection survives app restarts (and works offline).
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Filters the user already changed before the load finished win over the stored ones.
      if (!_filtersTouched) {
        final cuisine = prefs.getString(_cuisineKey);
        final full = prefs.getBool(_fullKey);
        if (cuisine != null || full != null) {
          state = state.copyWith(selectedCuisine: cuisine, onlyFullMatches: full);
        }
      }
      if (!state.sortByTime && prefs.getBool(_sortKey) == true) {
        state = state.copyWith(sortByTime: true);
      }
      final saved = prefs.getStringList(_prefKey);
      final merged = {...?saved, ...state.selectedKeys};
      final keysChanged = merged.length != state.selectedKeys.length;
      if (keysChanged) state = state.copyWith(selectedKeys: merged);
      if (keysChanged || (!_filtersTouched && merged.isNotEmpty)) await _searchMatches();
    } catch (_) {}
  }

  Future<void> _persistFilters() async {
    try {
      await _ready;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cuisineKey, state.selectedCuisine);
      await prefs.setBool(_fullKey, state.onlyFullMatches);
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      await _ready;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, state.selectedKeys.toList());
    } catch (_) {}
  }

  Future<void> setCuisine(String cuisine) async {
    if (state.selectedCuisine == cuisine) return;
    _filtersTouched = true;
    state = state.copyWith(selectedCuisine: cuisine);
    _persistFilters();
    await _searchMatches();
  }

  Future<void> toggleOnlyFullMatches() async {
    _filtersTouched = true;
    state = state.copyWith(onlyFullMatches: !state.onlyFullMatches);
    _persistFilters();
    await _searchMatches();
  }

  /// Orders the shown matches quickest-first (view only, no new search).
  void toggleSortByTime() {
    state = state.copyWith(sortByTime: !state.sortByTime);
    final on = state.sortByTime;
    () async {
      try {
        await _ready;
        final prefs = await SharedPreferences.getInstance();
        if (on) {
          await prefs.setBool(_sortKey, true);
        } else {
          await prefs.remove(_sortKey);
        }
      } catch (_) {}
    }();
  }

  Future<void> toggleIngredient(String key) async {
    final normalized = key.toLowerCase().trim();
    final updated = Set<String>.from(state.selectedKeys);

    if (updated.contains(normalized)) {
      updated.remove(normalized);
    } else {
      updated.add(normalized);
    }

    state = state.copyWith(selectedKeys: updated);
    _persist();
    await _searchMatches();
  }

  /// Adds several ingredients with one search; returns how many were new.
  Future<int> addIngredients(Iterable<String> keys) async {
    final updated = Set<String>.from(state.selectedKeys);
    var added = 0;
    for (final k in keys) {
      final normalized = k.toLowerCase().trim();
      if (normalized.isNotEmpty && updated.add(normalized)) added++;
    }
    if (added == 0) return 0;
    state = state.copyWith(selectedKeys: updated);
    _persist();
    await _searchMatches();
    return added;
  }

  Future<void> addIngredient(String key) async {
    final normalized = key.toLowerCase().trim();
    if (normalized.isEmpty || state.selectedKeys.contains(normalized)) return;

    final updated = Set<String>.from(state.selectedKeys)..add(normalized);
    state = state.copyWith(selectedKeys: updated);
    _persist();
    await _searchMatches();
  }

  /// Puts a previous selection back (used by "Undo" after clearing).
  Future<void> restoreSelection(Set<String> keys) async {
    state = state.copyWith(selectedKeys: {...keys});
    _persist();
    await _searchMatches();
  }

  /// Runs the pantry search again (used by the error state's retry button).
  Future<void> retry() => _searchMatches();

  Future<void> clearAll() async {
    state = state.copyWith(
      selectedKeys: const {},
      matchedRecipes: const [],
      isLoading: false,
      errorMessage: null,
    );
    _persist();
  }

  Future<void> _searchMatches() async {
    if (state.selectedKeys.isEmpty) {
      state = state.copyWith(
        matchedRecipes: const [],
        isLoading: false,
        errorMessage: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      var recipes = await _repository.matchRecipesByPantry(
        userIngredientKeys: state.selectedKeys.toList(),
        cuisine: state.selectedCuisine == 'Tümü' ? null : state.selectedCuisine,
        limit: 50,
      );

      // Recipes with a word the user avoids are left out here too.
      final avoid = ref.read(avoidedIngredientsProvider);
      if (avoid.isNotEmpty) {
        recipes = recipes.where((r) => !avoid.any((w) => RecipeRepository.mentionsWord(r, w))).toList();
      }

      if (state.onlyFullMatches) {
        final userKeys = state.selectedKeys.toList();
        recipes = recipes
            .where((r) => r.calculateMatchScore(userKeys) >= 99.9)
            .toList();
      }

      state = state.copyWith(
        matchedRecipes: recipes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'match_failed',
      );
    }
  }
}

final pantryProvider = NotifierProvider<PantryNotifier, PantryState>(PantryNotifier.new);
