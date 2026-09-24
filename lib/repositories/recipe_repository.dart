import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/recipe_generator.dart';

class PaginatedRecipes {
  final List<Recipe> recipes;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
  final int nextOffset;

  const PaginatedRecipes({
    required this.recipes,
    this.lastDocument,
    required this.hasMore,
    this.nextOffset = 0,
  });
}

class RecipeRepository {
  final FirebaseFirestore? firestore;
  static const int totalCapacity = RecipeGenerator.totalCapacity;

  RecipeRepository({this.firestore});

  /// Fetches recipes with infinite-scroll pagination (limit & startAfterDocument).
  /// Supports category filtering and title search.
  Future<PaginatedRecipes> getRecipes({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int offset = 0,
    String? category,
    String? searchQuery,
  }) async {
    final cleanCategory = (category == null || category == 'Tümü' || category.trim().isEmpty)
        ? null
        : category.trim();
    final cleanQuery = searchQuery?.trim().toLowerCase();

    final db = firestore;
    if (db != null) {
      try {
        Query<Map<String, dynamic>> query = db.collection('recipes');

        if (cleanCategory != null) {
          query = query.where('category', isEqualTo: cleanCategory);
        }

        query = query.orderBy('id');

        if (startAfter != null) {
          query = query.startAfterDocument(startAfter);
        }

        query = query.limit(limit);

        final querySnapshot = await query.get();
        if (querySnapshot.docs.isNotEmpty) {
          List<Recipe> recipes = querySnapshot.docs
              .map((doc) => Recipe.fromDocumentSnapshot(doc))
              .toList();

          if (cleanQuery != null && cleanQuery.isNotEmpty) {
            recipes = recipes
                .where((r) => r.title.toLowerCase().contains(cleanQuery))
                .toList();
          }

          final lastDoc = querySnapshot.docs.last;
          final hasMore = querySnapshot.docs.length >= limit;

          return PaginatedRecipes(
            recipes: recipes,
            lastDocument: lastDoc,
            hasMore: hasMore,
            nextOffset: offset + recipes.length,
          );
        }
      } catch (_) {
        // Fallback to local 10k deterministic generator on Firestore error or lack of connection
      }
    }

    // Offline / Mock 10,000 recipe generator with infinite pagination
    return _getFallbackPaginatedRecipes(
      limit: limit,
      offset: offset,
      category: cleanCategory,
      searchQuery: cleanQuery,
    );
  }

  /// Match recipes based on user pantry ingredients.
  /// Uses arrayContainsAny in Firestore (or local match), and calculates match percentage.
  Future<List<Recipe>> matchRecipesByPantry({
    required List<String> userIngredientKeys,
    int limit = 50,
  }) async {
    if (userIngredientKeys.isEmpty) return [];

    final normalizedUserKeys = userIngredientKeys
        .map((k) => k.toLowerCase().trim())
        .where((k) => k.isNotEmpty)
        .toList();

    if (normalizedUserKeys.isEmpty) return [];

    List<Recipe> candidateRecipes = [];

    final db = firestore;
    if (db != null) {
      try {
        // Firestore arrayContainsAny supports max 30 elements
        final queryKeys = normalizedUserKeys.take(30).toList();
        final querySnapshot = await db
            .collection('recipes')
            .where('ingredientKeys', arrayContainsAny: queryKeys)
            .limit(limit * 2)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          candidateRecipes = querySnapshot.docs
              .map((doc) => Recipe.fromDocumentSnapshot(doc))
              .toList();
        }
      } catch (_) {
        // Fallback to generator
      }
    }

    if (candidateRecipes.isEmpty) {
      // Search across a slice of 500 recipes from the 10,000 dataset for matches
      for (int i = 0; i < 500; i++) {
        final r = RecipeGenerator.generate(i);
        if (r.ingredientKeys.any((k) => normalizedUserKeys.contains(k))) {
          candidateRecipes.add(r);
        }
      }
    }

    // Client-side Riverpod match percentage calculation and sorting
    final scored = candidateRecipes.map((recipe) {
      final score = recipe.calculateMatchScore(normalizedUserKeys);
      return MapEntry(recipe, score);
    }).where((entry) => entry.value > 0).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.take(limit).map((e) => e.key).toList();
  }

  /// Get a single recipe by its ID
  Future<Recipe?> getRecipeById(String id) async {
    final db = firestore;
    if (db != null) {
      try {
        final doc = await db.collection('recipes').doc(id).get();
        if (doc.exists) {
          return Recipe.fromDocumentSnapshot(doc);
        }
      } catch (_) {}
    }

    // Fallback search in deterministic set
    if (id.startsWith('rec_')) {
      final numStr = id.replaceFirst('rec_', '');
      final index = int.tryParse(numStr);
      if (index != null && index >= 1 && index <= totalCapacity) {
        return RecipeGenerator.generate(index - 1);
      }
    }

    return null;
  }

  PaginatedRecipes _getFallbackPaginatedRecipes({
    required int limit,
    required int offset,
    String? category,
    String? searchQuery,
  }) {
    final List<Recipe> matching = [];
    int currentIndex = offset;

    while (currentIndex < totalCapacity && matching.length < limit) {
      final recipe = RecipeGenerator.generate(currentIndex);
      currentIndex++;

      if (category != null && recipe.category != category) {
        continue;
      }

      if (searchQuery != null && !recipe.title.toLowerCase().contains(searchQuery)) {
        continue;
      }

      matching.add(recipe);
    }

    final hasMore = currentIndex < totalCapacity;

    return PaginatedRecipes(
      recipes: matching,
      hasMore: hasMore,
      nextOffset: currentIndex,
    );
  }
}

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  FirebaseFirestore? firestore;
  try {
    firestore = FirebaseFirestore.instance;
  } catch (_) {
    // If Firebase isn't initialized yet or in mock test environment
  }
  return RecipeRepository(firestore: firestore);
});
