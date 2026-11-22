import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../repositories/recipe_repository.dart';

class PantryState {
  final Set<String> selectedKeys;
  final String selectedCuisine;
  final bool onlyFullMatches;
  final List<Recipe> matchedRecipes;
  final bool isLoading;
  final String? errorMessage;

  const PantryState({
    this.selectedKeys = const {},
    this.selectedCuisine = 'Tümü',
    this.onlyFullMatches = false,
    this.matchedRecipes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PantryState copyWith({
    Set<String>? selectedKeys,
    String? selectedCuisine,
    bool? onlyFullMatches,
    List<Recipe>? matchedRecipes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PantryState(
      selectedKeys: selectedKeys ?? this.selectedKeys,
      selectedCuisine: selectedCuisine ?? this.selectedCuisine,
      onlyFullMatches: onlyFullMatches ?? this.onlyFullMatches,
      matchedRecipes: matchedRecipes ?? this.matchedRecipes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PantryNotifier extends Notifier<PantryState> {
  RecipeRepository get _repository => ref.read(recipeRepositoryProvider);

  static const _prefKey = 'pantry_keys_v1';
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
      final saved = prefs.getStringList(_prefKey);
      if (saved == null || saved.isEmpty) return;
      final merged = {...saved, ...state.selectedKeys};
      if (merged.length == state.selectedKeys.length) return;
      state = state.copyWith(selectedKeys: merged);
      await _searchMatches();
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
    state = state.copyWith(selectedCuisine: cuisine);
    await _searchMatches();
  }

  Future<void> toggleOnlyFullMatches() async {
    state = state.copyWith(onlyFullMatches: !state.onlyFullMatches);
    await _searchMatches();
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

  Future<void> addIngredient(String key) async {
    final normalized = key.toLowerCase().trim();
    if (normalized.isEmpty || state.selectedKeys.contains(normalized)) return;

    final updated = Set<String>.from(state.selectedKeys)..add(normalized);
    state = state.copyWith(selectedKeys: updated);
    _persist();
    await _searchMatches();
  }

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
        errorMessage: 'Eşleşmeler hesaplanırken hata oluştu: $e',
      );
    }
  }
}

final pantryProvider = NotifierProvider<PantryNotifier, PantryState>(PantryNotifier.new);
