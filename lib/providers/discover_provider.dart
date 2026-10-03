import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/recipe_repository.dart';

class DiscoverState {
  final List<Recipe> recipes;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final int nextOffset;
  final String selectedCategory;
  final String selectedCuisine;
  final String searchQuery;
  final String? errorMessage;

  const DiscoverState({
    this.recipes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.lastDocument,
    this.nextOffset = 0,
    this.selectedCategory = 'Tümü',
    this.selectedCuisine = 'Tümü',
    this.searchQuery = '',
    this.errorMessage,
  });

  DiscoverState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int? nextOffset,
    String? selectedCategory,
    String? selectedCuisine,
    String? searchQuery,
    String? errorMessage,
  }) {
    return DiscoverState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      nextOffset: nextOffset ?? this.nextOffset,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCuisine: selectedCuisine ?? this.selectedCuisine,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class DiscoverNotifier extends Notifier<DiscoverState> {
  RecipeRepository get _repository => ref.read(recipeRepositoryProvider);

  @override
  DiscoverState build() {
    Future.microtask(() => loadInitial());
    return const DiscoverState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      recipes: [],
      lastDocument: null,
      nextOffset: 0,
      hasMore: true,
      errorMessage: null,
    );

    try {
      final result = await _repository.getRecipes(
        limit: 20,
        offset: 0,
        category: state.selectedCategory == 'Tümü' ? null : state.selectedCategory,
        cuisine: state.selectedCuisine == 'Tümü' ? null : state.selectedCuisine,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      );

      state = state.copyWith(
        recipes: result.recipes,
        lastDocument: result.lastDocument,
        hasMore: result.hasMore,
        nextOffset: result.nextOffset,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tarifler yüklenirken hata oluştu: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _repository.getRecipes(
        limit: 20,
        startAfter: state.lastDocument,
        offset: state.nextOffset,
        category: state.selectedCategory == 'Tümü' ? null : state.selectedCategory,
        cuisine: state.selectedCuisine == 'Tümü' ? null : state.selectedCuisine,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      );

      final updatedList = [...state.recipes, ...result.recipes];

      state = state.copyWith(
        recipes: updatedList,
        lastDocument: result.lastDocument,
        hasMore: result.hasMore && result.recipes.isNotEmpty,
        nextOffset: result.nextOffset,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Daha fazla tarif yüklenemedi.',
      );
    }
  }

  void setCuisine(String cuisine) {
    if (state.selectedCuisine == cuisine) return;
    state = state.copyWith(selectedCuisine: cuisine);
    loadInitial();
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    loadInitial();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadInitial();
  }
}

final discoverProvider = NotifierProvider<DiscoverNotifier, DiscoverState>(DiscoverNotifier.new);

/// Notifier to trigger scroll-to-top on the Discover tab
class DiscoverScrollToTopNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}

final discoverScrollToTopProvider = NotifierProvider<DiscoverScrollToTopNotifier, int>(
  DiscoverScrollToTopNotifier.new,
);
