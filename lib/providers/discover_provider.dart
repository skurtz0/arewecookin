import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final int? maxMinutes;
  final String? difficulty;
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
    this.maxMinutes,
    this.difficulty,
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
    int? maxMinutes,
    String? difficulty,
    bool clearDifficulty = false,
    bool clearMaxMinutes = false,
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
      maxMinutes: clearMaxMinutes ? null : (maxMinutes ?? this.maxMinutes),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      errorMessage: errorMessage,
    );
  }
}

class DiscoverNotifier extends Notifier<DiscoverState> {
  RecipeRepository get _repository => ref.read(recipeRepositoryProvider);

  static const _prefKey = 'discover_filters_v1';
  bool _filtersTouched = false;
  Future<void> _ready = Future.value();

  @override
  DiscoverState build() {
    _ready = _restoreFiltersAndLoad();
    return const DiscoverState();
  }

  /// Category, cuisine, time and difficulty filters survive app restarts. Filters the user
  /// changed before the stored ones were read win.
  Future<void> _restoreFiltersAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null && !_filtersTouched) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        state = DiscoverState(
          selectedCategory: m['c'] as String? ?? 'Tümü',
          selectedCuisine: m['u'] as String? ?? 'Tümü',
          maxMinutes: (m['m'] as num?)?.toInt(),
          difficulty: m['d'] as String?,
        );
      }
    } catch (_) {}
    if (!_filtersTouched || state.recipes.isEmpty) {
      await loadInitial();
    }
  }

  Future<void> _persistFilters() async {
    try {
      await _ready;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKey,
        jsonEncode({
          'c': state.selectedCategory,
          'u': state.selectedCuisine,
          if (state.maxMinutes != null) 'm': state.maxMinutes,
          if (state.difficulty != null) 'd': state.difficulty,
        }),
      );
    } catch (_) {}
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
        maxMinutes: state.maxMinutes,
        difficulty: state.difficulty,
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
        maxMinutes: state.maxMinutes,
        difficulty: state.difficulty,
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
    _filtersTouched = true;
    state = state.copyWith(selectedCuisine: cuisine);
    _persistFilters();
    loadInitial();
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    _filtersTouched = true;
    state = state.copyWith(selectedCategory: category);
    _persistFilters();
    loadInitial();
  }

  void setMaxMinutes(int? minutes) {
    if (state.maxMinutes == minutes) return;
    _filtersTouched = true;
    state = minutes == null ? state.copyWith(clearMaxMinutes: true) : state.copyWith(maxMinutes: minutes);
    _persistFilters();
    loadInitial();
  }

  void setDifficulty(String? group) {
    if (state.difficulty == group) return;
    _filtersTouched = true;
    state = group == null ? state.copyWith(clearDifficulty: true) : state.copyWith(difficulty: group);
    _persistFilters();
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
