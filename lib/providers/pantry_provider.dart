import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  PantryState build() {
    return const PantryState();
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
    await _searchMatches();
  }

  Future<void> addIngredient(String key) async {
    final normalized = key.toLowerCase().trim();
    if (normalized.isEmpty || state.selectedKeys.contains(normalized)) return;

    final updated = Set<String>.from(state.selectedKeys)..add(normalized);
    state = state.copyWith(selectedKeys: updated);
    await _searchMatches();
  }

  Future<void> clearAll() async {
    state = state.copyWith(
      selectedKeys: const {},
      matchedRecipes: const [],
      isLoading: false,
      errorMessage: null,
    );
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
