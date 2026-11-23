import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/pack_recipes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../data/world_recipes.dart';
import '../data/world_countries.dart';
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
  static const int generatedCapacity = RecipeGenerator.totalCapacity;
  static int get totalCapacity => WorldRecipes.all.length + generatedCapacity;

  /// Curated world recipes come first, then the generated catalogue.
  static Recipe _recipeAt(int i) {
    final world = WorldRecipes.all;
    return i < world.length ? world[i] : RecipeGenerator.generate(i - world.length);
  }
  final List<Recipe> _customRecipes = [];

  /// When a Firestore query last came back empty (key: category|cuisine). Skips the network round trip
  /// on every page while the shared collection has nothing for that filter.
  final Map<String, DateTime> _remoteEmptyAt = {};

  /// Server-side recipe packs (null in tests that do not need them).
  final PackSource? packs;

  RecipeRepository({this.firestore, this.packs});

  List<Recipe> get customRecipes => List.unmodifiable(_customRecipes);

  void addCustomRecipe(Recipe recipe) {
    _customRecipes.removeWhere((r) => r.id == recipe.id);
    _customRecipes.insert(0, recipe);
    if (firestore != null) {
      try {
        final data = recipe.toMap();
        // Who owns the copy: lets the security rules keep others from changing or deleting it.
        String? owner;
        try {
          owner = FirebaseAuth.instance.currentUser?.uid;
        } catch (_) {}
        if (owner != null) data['ownerId'] = owner;
        firestore!.collection('recipes').doc(recipe.id).set(data);
      } catch (_) {}
    }
  }

  void removeCustomRecipe(String recipeId) {
    _customRecipes.removeWhere((r) => r.id == recipeId);
    if (firestore != null) {
      try {
        firestore!.collection('recipes').doc(recipeId).delete();
      } catch (_) {}
    }
  }

  /// Country packs come first (real, hand-checked recipes), then the bundled and generated ones.
  /// Offsets below the pack size index the pack; beyond it they continue in the bundled catalogue.
  Future<PaginatedRecipes> getRecipes({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int offset = 0,
    String? category,
    String? cuisine,
    String? searchQuery,
    int? maxMinutes,
    String? difficulty,
  }) async {
    final packCountry = _packCountryFor(cuisine);
    final source = packs;
    if (packCountry == null || source == null || startAfter != null) {
      return _getRecipesBase(
          limit: limit, startAfter: startAfter, offset: offset, category: category, cuisine: cuisine,
          searchQuery: searchQuery, maxMinutes: maxMinutes, difficulty: difficulty);
    }
    final cleanCategory = (category == null || category == 'Tümü' || category.trim().isEmpty) ? null : category.trim();
    final cleanQuery = searchQuery?.trim().toLowerCase();
    final all = await source.country(packCountry);
    final pack = [
      for (final r in all)
        if ((cleanCategory == null || r.category == cleanCategory) &&
            (cleanQuery == null || cleanQuery.isEmpty || _matchesQuery(r, cleanQuery)) &&
            (maxMinutes == null || r.totalTime <= maxMinutes) &&
            (difficulty == null || matchesDifficulty(r.difficulty, difficulty)))
          r
    ];
    final p = pack.length;
    if (p == 0) {
      return _getRecipesBase(
          limit: limit, offset: offset, category: category, cuisine: cuisine,
          searchQuery: searchQuery, maxMinutes: maxMinutes, difficulty: difficulty);
    }
    final first = offset < p ? pack.skip(offset).take(limit).toList() : <Recipe>[];
    if (first.length >= limit) {
      return PaginatedRecipes(recipes: first, hasMore: true, nextOffset: offset + first.length);
    }
    final baseOffset = offset < p ? 0 : offset - p;
    final rest = await _getRecipesBase(
        limit: limit - first.length, offset: baseOffset, category: category, cuisine: cuisine,
        searchQuery: searchQuery, maxMinutes: maxMinutes, difficulty: difficulty);
    return PaginatedRecipes(
      recipes: [...first, ...rest.recipes],
      lastDocument: rest.lastDocument,
      hasMore: rest.hasMore,
      nextOffset: p + rest.nextOffset,
    );
  }

  /// The country whose pack serves this cuisine filter (broad chips such as "Asya & Uzak Doğu" have none).
  static String? _packCountryFor(String? cuisine) {
    final c = cuisine?.trim();
    if (c == null || c.isEmpty || c == 'Tümü') return null;
    switch (c) {
      case 'İtalyan Mutfağı':
        return 'İtalya';
      case 'Meksika Mutfağı':
        return 'Meksika';
    }
    return WorldCountries.byId(c) != null ? c : null;
  }

  /// Fetches recipes with infinite-scroll pagination (limit & startAfterDocument).

  /// Supports category, cuisine filtering and title search.
  Future<PaginatedRecipes> _getRecipesBase({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int offset = 0,
    String? category,
    String? cuisine,
    String? searchQuery,
    int? maxMinutes,
    String? difficulty,
  }) async {
    final cleanCategory = (category == null || category == 'Tümü' || category.trim().isEmpty)
        ? null
        : category.trim();
    final cleanCuisine = (cuisine == null || cuisine == 'Tümü' || cuisine.trim().isEmpty)
        ? null
        : cuisine.trim();
    final cleanQuery = searchQuery?.trim().toLowerCase();

    // The time filter is applied on the local dataset (a Firestore range query would break paging/sorting).
    final remoteKey = '${cleanCategory ?? ''}|${cleanCuisine ?? ''}';
    final emptyAt = _remoteEmptyAt[remoteKey];
    final remoteKnownEmpty = startAfter == null &&
        emptyAt != null &&
        DateTime.now().difference(emptyAt) < const Duration(minutes: 10);
    final db = (maxMinutes == null && difficulty == null && !remoteKnownEmpty) ? firestore : null;
    if (db != null) {
      try {
        Query<Map<String, dynamic>> query = db.collection('recipes');

        if (cleanCategory != null) {
          query = query.where('category', isEqualTo: cleanCategory);
        }

        if (cleanCuisine != null) {
          query = query.where('cuisine', isEqualTo: cleanCuisine);
        }

        query = query.orderBy('id');

        if (startAfter != null) {
          query = query.startAfterDocument(startAfter);
        }

        query = query.limit(limit);

        final querySnapshot = await query.get().timeout(const Duration(seconds: 4));
        if (querySnapshot.docs.isEmpty) {
          _remoteEmptyAt[remoteKey] = DateTime.now();
        }
        if (querySnapshot.docs.isNotEmpty) {
          List<Recipe> recipes = querySnapshot.docs
              .map((doc) => Recipe.fromDocumentSnapshot(doc))
              .toList();

          if (cleanQuery != null && cleanQuery.isNotEmpty) {
            recipes = recipes
                .where((r) => _matchesQuery(r, cleanQuery))
                .toList();
          }

          if (startAfter == null && offset == 0) {
            final ids = recipes.map((r) => r.id).toSet();
            final world = WorldRecipes.all.where((r) =>
                !ids.contains(r.id) &&
                (cleanCategory == null || r.category == cleanCategory) &&
                (cleanCuisine == null || cuisineMatches(r.cuisine, cleanCuisine)) &&
                (cleanQuery == null || cleanQuery.isEmpty || _matchesQuery(r, cleanQuery)));
            recipes = [...world, ...recipes];
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
    return await _getFallbackPaginatedRecipes(
      limit: limit,
      offset: offset,
      category: cleanCategory,
      cuisine: cleanCuisine,
      searchQuery: cleanQuery,
      maxMinutes: maxMinutes,
      difficulty: difficulty,
    );
  }

  /// Match recipes based on user pantry ingredients and optional cuisine filter.
  /// Uses arrayContainsAny in Firestore (or local match), and calculates match percentage.
  Future<List<Recipe>> matchRecipesByPantry({
    required List<String> userIngredientKeys,
    String? cuisine,
    int limit = 50,
  }) async {
    if (userIngredientKeys.isEmpty) return [];

    final normalizedUserKeys = userIngredientKeys
        .map((k) => k.toLowerCase().trim())
        .where((k) => k.isNotEmpty)
        .toList();

    if (normalizedUserKeys.isEmpty) return [];

    final cleanCuisine = (cuisine == null || cuisine == 'Tümü' || cuisine.trim().isEmpty)
        ? null
        : cuisine.trim();

    List<Recipe> candidateRecipes = [];

    final db = firestore;
    if (db != null) {
      try {
        // Firestore arrayContainsAny supports max 30 elements
        final queryKeys = normalizedUserKeys.take(30).toList();
        Query<Map<String, dynamic>> query = db
            .collection('recipes')
            .where('ingredientKeys', arrayContainsAny: queryKeys);

        if (cleanCuisine != null) {
          query = query.where('cuisine', isEqualTo: cleanCuisine);
        }

        final querySnapshot = await query.limit(limit * 2).get().timeout(const Duration(seconds: 4));

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
      // Evaluate the universe of base dishes in the deterministic dataset
      for (final r in WorldRecipes.all) {
        if (cleanCuisine != null && !cuisineMatches(r.cuisine, cleanCuisine)) {
          continue;
        }
        if (r.ingredientKeys.any((k) => normalizedUserKeys.contains(k))) {
          candidateRecipes.add(r);
        }
      }
      for (int i = 0; i < 256; i++) {
        final r = RecipeGenerator.generate(i);
        if (cleanCuisine != null && !cuisineMatches(r.cuisine, cleanCuisine)) {
          continue;
        }
        if (r.ingredientKeys.any((k) => normalizedUserKeys.contains(k))) {
          candidateRecipes.add(r);
        }
      }
    }

    // STRICT DEDUPLICATION: Every dish appears AT MOST ONCE.
    // If multiple variants of the same dish exist (from Firestore or generator),
    // collapse them by cleanTitle so users never see repeated dishes in Akıllı Kiler!
    final Map<String, Recipe> uniqueRecipes = {};
    for (final recipe in candidateRecipes) {
      final key = recipe.cleanTitle.toLowerCase().trim();
      if (!uniqueRecipes.containsKey(key)) {
        uniqueRecipes[key] = recipe;
      }
    }

    // Client-side Riverpod match percentage calculation and smart sorting
    final scored = uniqueRecipes.values.map((recipe) {
      final score = recipe.calculateMatchScore(normalizedUserKeys);
      final missingCount = recipe.getMissingKeys(normalizedUserKeys).length;
      return (recipe: recipe, score: score, missingCount: missingCount);
    }).where((entry) => entry.score > 0).toList();

    // Sort:
    // 1. Higher score first (100% matches rank at the top)
    // 2. Fewer missing ingredients first
    // 3. Shorter total cook time as tie-breaker
    scored.sort((a, b) {
      final cmpScore = b.score.compareTo(a.score);
      if (cmpScore != 0) return cmpScore;
      final cmpMissing = a.missingCount.compareTo(b.missingCount);
      if (cmpMissing != 0) return cmpMissing;
      return a.recipe.totalTime.compareTo(b.recipe.totalTime);
    });

    return scored.take(limit).map((e) => e.recipe).toList();
  }

  /// Get a single recipe by its ID
  Future<Recipe?> getRecipeById(String id) async {
    for (final r in _customRecipes) {
      if (r.id == id) return r;
    }

    final db = firestore;
    if (db != null) {
      try {
        final doc = await db.collection('recipes').doc(id).get().timeout(const Duration(seconds: 4));
        if (doc.exists) {
          return Recipe.fromDocumentSnapshot(doc);
        }
      } catch (_) {}
    }

    final world = WorldRecipes.byId(id);
    if (world != null) return world;

    if (id.startsWith('p_') && packs != null) {
      final packed = await packs!.byId(id);
      if (packed != null) return packed;
    }

    // Fallback search in deterministic set
    if (id.startsWith('rec_')) {
      final numStr = id.replaceFirst('rec_', '');
      final index = int.tryParse(numStr);
      if (index != null && index >= 1 && index <= generatedCapacity) {
        return RecipeGenerator.generate(index - 1);
      }
    }

    return null;
  }

  Future<PaginatedRecipes> _getFallbackPaginatedRecipes({
    required int limit,
    required int offset,
    String? category,
    String? cuisine,
    String? searchQuery,
    int? maxMinutes,
    String? difficulty,
  }) async {
    final List<Recipe> matching = [];

    // Prepend custom recipes when at initial offset
    if (offset == 0) {
      for (final r in _customRecipes) {
        if (category != null && r.category != category) continue;
        if (cuisine != null && !cuisineMatches(r.cuisine, cuisine)) continue;
        if (searchQuery != null && !_matchesQuery(r, searchQuery)) continue;
        if (maxMinutes != null && r.totalTime > maxMinutes) continue;
        if (difficulty != null && !matchesDifficulty(r.difficulty, difficulty)) continue;
        matching.add(r);
      }
    }

    int currentIndex = offset;

    var scanned = 0;
    while (currentIndex < totalCapacity && matching.length < limit) {
      // Let the UI draw a frame now and then: a rare filter or search scans thousands of dishes.
      if (++scanned % 150 == 0) await Future<void>.delayed(Duration.zero);
      final recipe = _recipeAt(currentIndex);
      currentIndex++;

      if (recipe.id.startsWith('rec_') &&
          WorldRecipes.coveredDishes.contains(recipe.baseDish)) {
        continue;
      }

      if (category != null && recipe.category != category) {
        continue;
      }

      if (cuisine != null && !cuisineMatches(recipe.cuisine, cuisine)) {
        continue;
      }

      if (searchQuery != null && !_matchesQuery(recipe, searchQuery)) {
        continue;
      }

      if (maxMinutes != null && recipe.totalTime > maxMinutes) {
        continue;
      }

      if (difficulty != null && !matchesDifficulty(recipe.difficulty, difficulty)) {
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

  static const _asia = {'Tayland', 'Japonya', 'Hindistan', 'Çin', 'Güney Kore', 'Vietnam', 'Endonezya', 'Filipinler', 'Singapur', 'Nepal', 'Pakistan', 'Kamboçya', 'Tayvan', 'Özbekistan'};
  static const _mediterranean = {'Yunanistan', 'İspanya', 'Lübnan', 'Fas', 'Tunus', 'Mısır', 'Portekiz', 'İran'};

  /// A recipe matches a cuisine filter directly, or through the broad legacy chip its country belongs to
  /// (e.g. a recipe of "İtalya" also shows under "İtalyan Mutfağı", "Japonya" under "Asya & Uzak Doğu").
  static bool cuisineMatches(String recipeCuisine, String filter) {
    if (recipeCuisine == filter) return true;
    switch (filter) {
      case 'İtalyan Mutfağı':
        return recipeCuisine == 'İtalya';
      case 'Meksika Mutfağı':
        return recipeCuisine == 'Meksika';
      case 'Asya & Uzak Doğu':
        return _asia.contains(recipeCuisine);
      case 'Akdeniz Mutfağı':
        return _mediterranean.contains(recipeCuisine);
      case 'Fransız & Dünya':
        return recipeCuisine == 'Fransa' ||
            (WorldCountries.byId(recipeCuisine) != null &&
                recipeCuisine != 'İtalya' &&
                recipeCuisine != 'Meksika' &&
                recipeCuisine != 'Türk Mutfağı' &&
                !_asia.contains(recipeCuisine) &&
                !_mediterranean.contains(recipeCuisine));
    }
    return false;
  }

  /// Difficulty groups used by the Discover filter: easy = Çok Kolay + Kolay, medium = Orta, hard = Zor.
  static bool matchesDifficulty(String difficulty, String group) {
    switch (group) {
      case 'easy':
        return difficulty == 'Çok Kolay' || difficulty == 'Kolay';
      case 'medium':
        return difficulty == 'Orta';
      case 'hard':
        return difficulty == 'Zor';
    }
    return true;
  }

  /// True when [word] appears in the recipe's title or in any ingredient name (diacritics ignored).
  static bool mentionsWord(Recipe r, String word) {
    final w = normalizeSearch(word).trim();
    if (w.isEmpty) return false;
    final title = normalizeSearch([r.title, r.cleanTitle, r.localizedTitle('en')].join(' '));
    if (title.contains(w)) return true;
    return [
      ...r.ingredientKeys,
      for (final i in r.ingredients) ...[i.name, i.nameEn ?? ''],
    ].any((k) => normalizeSearch(k).contains(w));
  }

  /// Lower-cases and strips diacritics so "sutlac" finds "Sütlaç" and "ISPANAK" finds "ıspanak".
  static String normalizeSearch(String input) {
    const from = 'çğıöşüâîûéèêàáíóúñåäß';
    const to = 'cgiosuaiueeeaaiounaas';
    final lower = input.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase().replaceAll('\u0307', '');
    final sb = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      sb.write(i >= 0 ? to[i] : ch);
    }
    return sb.toString();
  }

  /// Every word of the query must appear in the title/category/cuisine, or the whole query must be
  /// (part of) one ingredient name. A query with commas, semicolons or "+" ("tomato, onion") lists
  /// several terms: each must be in the title or in an ingredient, so recipes holding all of them match.
  /// Words written with a leading minus ("pasta -egg") are exclusions: recipes whose title or any
  /// ingredient contains them are left out. A query of only exclusions lists everything else.
  bool _matchesQuery(Recipe r, String query) {
    var q = normalizeSearch(query).trim();
    final titleHay = normalizeSearch(
      [r.title, r.cleanTitle, r.localizedTitle('en'), r.category, r.cuisine].join(' '),
    );
    final ingredientHay = [
      ...r.ingredientKeys,
      for (final i in r.ingredients) ...[i.name, i.nameEn ?? ''],
    ].map(normalizeSearch).toList();
    final exclusion = RegExp(r'(?:^|\s)-(\S+)');
    for (final m in exclusion.allMatches(q)) {
      final t = m.group(1)!;
      if (titleHay.contains(t) || ingredientHay.any((k) => k.contains(t))) return false;
    }
    q = q.replaceAll(exclusion, ' ').trim();
    if (q.isEmpty) return true;
    if (ingredientHay.any((k) => k.contains(q))) return true;
    final terms = q.split(RegExp(r'[,;+]'));
    if (terms.length > 1) {
      return terms.map((t) => t.trim()).where((t) => t.isNotEmpty).every(
            (t) => titleHay.contains(t) || ingredientHay.any((k) => k.contains(t)),
          );
    }
    return q.split(RegExp(r'\s+')).every(titleHay.contains);
  }
}

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  FirebaseFirestore? firestore;
  try {
    firestore = FirebaseFirestore.instance;
  } catch (_) {
    // If Firebase isn't initialized yet or in mock test environment
  }
  return RecipeRepository(firestore: firestore, packs: HttpPackSource());
});
