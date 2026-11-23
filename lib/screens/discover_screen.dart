import 'dart:math';
import '../data/world_countries.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/cooking_icons.dart';
import '../models/models.dart';
import '../l10n/recipe_localization.dart';
import '../providers/discover_provider.dart';
import '../repositories/recipe_repository.dart';
import '../providers/recent_recipes_provider.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/recipe_notes_provider.dart';
import '../providers/user_recipes_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/cook_history_provider.dart';
import '../widgets/avoided_badge.dart';
import '../widgets/recipe_image.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => DiscoverScreenState();
}

class DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  /// Spoken description of a recipe card: title, time, difficulty, and my rating / cooked marks when present.
  String _cardLabel(Recipe recipe, AppStrings strings) {
    final rating = ref.watch(recipeNotesProvider.select((m) => m[recipe.id]?.rating ?? 0));
    final cookedCount = ref.watch(cookHistoryProvider.select((m) => m[recipe.id]?.count ?? 0));
    final hasNote = ref.watch(recipeNotesProvider.select((m) => (m[recipe.id]?.note ?? '').trim().isNotEmpty));
    return [
      recipe.localizedTitle(strings.locale),
      strings.minutesShort(recipe.totalTime),
      recipe.localizedDifficulty(strings),
      if (rating > 0) '$rating/5',
      if (cookedCount > 0) strings.cookedTimes(cookedCount),
      if (hasNote) strings.myNotes,
    ].join(', ');
  }

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _onlySaved = false;
  bool _onlyCooked = false;
  bool _onlyRated = false;
  bool _savedQuickest = false;
  bool _savedTopRated = false;
  Timer? _debounceTimer;

  static final List<Map<String, String>> cuisineFilters = [
    {'id': 'Tümü', 'flag': '🌍', 'label': '🌍 Tümü'},
    {'id': 'Türk Mutfağı', 'flag': '🇹🇷', 'label': '🇹🇷 Türk Mutfağı'},
    {'id': 'İtalyan Mutfağı', 'flag': '🇮🇹', 'label': '🇮🇹 İtalyan'},
    {'id': 'Asya & Uzak Doğu', 'flag': '🥢', 'label': '🥢 Asya & Uzak Doğu'},
    {'id': 'Meksika Mutfağı', 'flag': '🇲🇽', 'label': '🇲🇽 Meksika'},
    {'id': 'Akdeniz Mutfağı', 'flag': '🫒', 'label': '🫒 Akdeniz'},
    {'id': 'Fransız & Dünya', 'flag': '🇫🇷', 'label': '🇫🇷 Fransız & Dünya'},
    {'id': 'Pratik & Sokak', 'flag': '⚡', 'label': '⚡ Pratik & Sokak'},
    for (final c in WorldCountries.all)
      if (c.id != 'Türk Mutfağı')
      {'id': c.id, 'flag': c.flag, 'label': '${c.flag} ${c.id}'},
  ];

  static const List<String> categories = [
    'Tümü',
    'Ana Yemek',
    'Tatlı',
    'Çorba',
    'Kahvaltılık',
    'Pratik',
    'Hamur İşi',
    'Salata',
    'Vegan',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _restoreSavedSort();
  }

  static const _savedSortKey = 'saved_sort_v1';

  /// The chosen order of the Saved list (fastest / top rated) is remembered on the device.
  Future<void> _restoreSavedSort() async {
    try {
      final v = (await SharedPreferences.getInstance()).getString(_savedSortKey);
      if (!mounted || (_savedQuickest || _savedTopRated)) return;
      setState(() {
        _savedQuickest = v == 'quick';
        _savedTopRated = v == 'rating';
      });
    } catch (_) {}
  }

  Future<void> _persistSavedSort() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = _savedTopRated ? 'rating' : (_savedQuickest ? 'quick' : null);
      if (v == null) {
        await prefs.remove(_savedSortKey);
      } else {
        await prefs.setString(_savedSortKey, v);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Scrolls smoothly to the very top of the Discover feed
  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger loading next batch when 300px away from the end
    if (currentScroll >= maxScroll - 300) {
      ref.read(discoverProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      ref.read(discoverProvider.notifier).setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for re-tap on Discover tab to scroll to top
    ref.listen<int>(discoverScrollToTopProvider, (prev, next) {
      if (next > 0) {
        scrollToTop();
      }
    });

    final discoverState = ref.watch(discoverProvider);
    final strings = ref.watch(appStringsProvider);
    final recent = ref.watch(recentRecipesProvider);
    final searches = ref.watch(recentSearchesProvider);
    final todayPlan = ref.watch(mealPlanProvider)[DateTime.now().weekday] ?? const <Recipe>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'discover_add_recipe_fab',
        onPressed: () {
          final authState = ref.read(authProvider);
          final strings = ref.read(appStringsProvider);
          if (!authState.user.isLoggedIn) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(strings.loginRequiredToPublish),
                content: Text(strings.loginToPublishMsg),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(strings.cancel),
                  ),
                ],
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddRecipeScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          strings.addRecipe,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF5722),
        onRefresh: () => ref.read(discoverProvider.notifier).loadInitial(),
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(240 + 48 * (MediaQuery.textScalerOf(context).scale(14) / 14 - 1).clamp(0.0, 2.0)),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. En Başta Mutfak Seçimi (Cuisine Selector)
                      _buildCuisineSelector(discoverState, strings),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: TextField(
                          key: const Key('discover_search_field'),
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onChanged: _onSearchChanged,
                          onSubmitted: (v) => ref.read(recentSearchesProvider.notifier).add(v),
                          decoration: InputDecoration(
                            hintText: strings.searchPlaceholder,
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: const Icon(CookingIcons.search, color: Color(0xFFFF5722), size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    tooltip: strings.a11yClear,
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(discoverProvider.notifier).setSearchQuery('');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFFF5722), width: 1.5),
                            ),
                          ),
                        ),
                      ),

                      // Categories Horizontal Chips
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category == discoverState.selectedCategory;

                            return ChoiceChip(
                              label: Text(RecipeLocalization.localizeCategory(category, strings)),
                              selected: isSelected,
                              onSelected: (_) {
                                ref.read(discoverProvider.notifier).setCategory(category);
                              },
                              selectedColor: const Color(0xFFFF5722),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 13,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected ? const Color(0xFFFF5722) : Colors.grey.shade200,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 6),
                      Container(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (searches.isNotEmpty && discoverState.searchQuery.isEmpty && !_onlySaved && !_onlyCooked && !_onlyRated)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Wrap(
                    key: const Key('recent_searches'),
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final q in searches)
                        InputChip(
                          key: Key('recent_search_$q'),
                          avatar: const Icon(Icons.history_rounded, size: 16),
                          label: Text(q),
                          deleteButtonTooltipMessage: strings.shoppingDeleteItem,
                          onDeleted: () => ref.read(recentSearchesProvider.notifier).remove(q),
                          onPressed: () {
                            _searchController.text = q;
                            ref.read(discoverProvider.notifier).setSearchQuery(q);
                          },
                        ),
                      IconButton(
                        key: const Key('clear_recent_searches'),
                        tooltip: strings.clearHistory,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          final before = ref.read(recentSearchesProvider);
                          ref.read(recentSearchesProvider.notifier).clear();
                          _showClearUndo(strings, () => ref.read(recentSearchesProvider.notifier).restore(before));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (todayPlan.isNotEmpty && discoverState.searchQuery.isEmpty && !_onlySaved && !_onlyCooked && !_onlyRated)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Card(
                    key: const Key('today_plan_card'),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(strings.todayInPlan,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final r in todayPlan)
                                ActionChip(
                                  key: Key('today_plan_${r.id}'),
                                  avatar: const Icon(Icons.calendar_month_outlined, size: 16),
                                  label: Text(r.localizedTitle(strings.locale), overflow: TextOverflow.ellipsis),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (recent.isNotEmpty && discoverState.searchQuery.isEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 0),
                      child: Row(children: [
                        Expanded(
                          child: Text(strings.recentlyViewed,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          key: const Key('recent_clear'),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          onPressed: () {
                            final before = ref.read(recentRecipesProvider);
                            ref.read(recentRecipesProvider.notifier).clear();
                            _showClearUndo(strings, () => ref.read(recentRecipesProvider.notifier).restore(before));
                          },
                          child: Text(strings.clearAll),
                        ),
                      ]),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        key: const Key('recent_strip'),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: recent.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => ActionChip(
                          label: Text(recent[i].localizedTitle(strings.locale)),
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(recipe: recent[i]))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!_onlyRated &&
                !_onlyCooked &&
                !_onlySaved &&
                !discoverState.isLoading &&
                discoverState.searchQuery.trim().isNotEmpty &&
                discoverState.recipes.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      strings.resultsCount(discoverState.recipes.length, discoverState.hasMore),
                      key: const Key('results_count'),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
            if (_onlyRated)
              _buildRatedSliver(context, strings)
            else if (_onlyCooked)
              _buildCookedSliver(context, strings)
            else if (_onlySaved)
              _buildSavedSliver(context, strings)
            else if (discoverState.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF5722)),
                ),
              )
            else if (discoverState.recipes.isEmpty && discoverState.errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(context),
              )
            else if (discoverState.recipes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(context),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == discoverState.recipes.length) {
                        return _buildBottomLoader();
                      }

                      final recipe = discoverState.recipes[index];
                      return Semantics(
                        button: true,
                        excludeSemantics: true,
                        label: _cardLabel(recipe, strings),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                        ),
                        child: _RecipeCard(
                          recipe: recipe,
                          onTap: () {
                            // A search that led to opening a recipe is worth remembering.
                            ref.read(recentSearchesProvider.notifier).add(discoverState.searchQuery);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: discoverState.recipes.length + (discoverState.hasMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisineSelector(DiscoverState discoverState, AppStrings strings) {
    final savedCount = ref.watch(savedRecipesProvider.select((s) => s.recipes.length));
    final cookedCount = ref.watch(cookHistoryProvider.select((m) => m.length));
    final ratedCount = ref.watch(recipeNotesProvider.select((m) => m.values.where((n) => n.rating > 0).length));
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.public_rounded,
                  size: 15,
                  color: Color(0xFFFF5722),
                ),
                const SizedBox(width: 6),
                Text(
                  strings.worldCuisines,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                if (discoverState.selectedCuisine != 'Tümü')
                  Semantics(
                    button: true,
                    hint: strings.resetFilters,
                    child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => ref.read(discoverProvider.notifier).setCuisine('Tümü'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBE6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            RecipeLocalization.localizeCuisine(discoverState.selectedCuisine, strings),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5722),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.close_rounded, size: 12, color: Color(0xFFFF5722)),
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                if (discoverState.selectedCategory != 'Tümü' ||
                    discoverState.selectedCuisine != 'Tümü' ||
                    discoverState.maxMinutes != null ||
                    discoverState.difficulty != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ActionChip(
                      key: const Key('reset_filters_chip'),
                      avatar: const Icon(Icons.filter_alt_off_outlined, size: 16),
                      label: Text(strings.resetFilters),
                      onPressed: () {
                        final n = ref.read(discoverProvider.notifier);
                        n.setCategory('Tümü');
                        n.setCuisine('Tümü');
                        n.setMaxMinutes(null);
                        n.setDifficulty(null);
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ActionChip(
                    key: const Key('surprise_me'),
                    avatar: const Icon(Icons.casino_outlined, size: 16),
                    label: Text(strings.surpriseMe),
                    onPressed: () {
                      final all = ref.read(discoverProvider).recipes;
                      if (all.isEmpty) return;
                      // Prefer dishes the user has not cooked yet.
                      final cooked = ref.read(cookHistoryProvider);
                      final fresh = all.where((r) => (cooked[r.id]?.count ?? 0) == 0).toList();
                      final list = fresh.isNotEmpty ? fresh : all;
                      final pick = list[Random().nextInt(list.length)];
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: pick)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    key: const Key('saved_filter'),
                    avatar: const Icon(Icons.bookmark_rounded, size: 16),
                    label: Text(savedCount > 0 ? '${strings.savedOnly} ($savedCount)' : strings.savedOnly),
                    selected: _onlySaved,
                    selectedColor: const Color(0xFFFF5722).withValues(alpha: 0.18),
                    onSelected: (v) => setState(() {
                      _onlySaved = v;
                      if (v) {
                        _onlyCooked = false;
                        _onlyRated = false;
                      }
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    key: const Key('cooked_filter'),
                    avatar: const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: Text(cookedCount > 0 ? '${strings.cookedDishes} ($cookedCount)' : strings.cookedDishes),
                    selected: _onlyCooked,
                    selectedColor: const Color(0xFFFF5722).withValues(alpha: 0.18),
                    onSelected: (v) => setState(() {
                      _onlyCooked = v;
                      if (v) {
                        _onlySaved = false;
                        _onlyRated = false;
                      }
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    key: const Key('quick_easy'),
                    avatar: const Icon(Icons.bolt_rounded, size: 16),
                    label: Text(strings.quickEasy),
                    selected: discoverState.maxMinutes == 30 && discoverState.difficulty == 'easy',
                    selectedColor: const Color(0xFFFF5722).withValues(alpha: 0.18),
                    onSelected: (v) {
                      final n = ref.read(discoverProvider.notifier);
                      n.setMaxMinutes(v ? 30 : null);
                      n.setDifficulty(v ? 'easy' : null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    key: const Key('rated_filter'),
                    avatar: const Icon(Icons.star_rounded, size: 16),
                    label: Text(ratedCount > 0 ? '${strings.ratedDishes} ($ratedCount)' : strings.ratedDishes),
                    selected: _onlyRated,
                    selectedColor: const Color(0xFFFF5722).withValues(alpha: 0.18),
                    onSelected: (v) => setState(() {
                      _onlyRated = v;
                      if (v) {
                        _onlySaved = false;
                        _onlyCooked = false;
                      }
                    }),
                  ),
                ),
                for (final g in const ['easy', 'medium', 'hard'])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: FilterChip(
                      key: Key('difficulty_$g'),
                      label: Text(g == 'easy'
                          ? strings.diffFilterEasy
                          : g == 'medium'
                              ? strings.diffFilterMedium
                              : strings.diffFilterHard),
                      selected: discoverState.difficulty == g,
                      selectedColor: const Color(0xFFFF5722).withValues(alpha: 0.18),
                      onSelected: (v) => ref.read(discoverProvider.notifier).setDifficulty(v ? g : null),
                    ),
                  ),
                for (final m in const <int?>[null, 15, 30, 60])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      key: Key('time_filter_${m ?? 'any'}'),
                      avatar: m == null ? null : const Icon(Icons.timer_outlined, size: 16),
                      label: Text(m == null ? strings.timeAny : strings.timeUpTo(m)),
                      selected: discoverState.maxMinutes == m,
                      selectedColor: const Color(0xFFFF5722).withValues(alpha: 0.18),
                      onSelected: (_) => ref.read(discoverProvider.notifier).setMaxMinutes(m),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: cuisineFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final c = cuisineFilters[index];
                final isSelected = discoverState.selectedCuisine == c['id'];
                final flag = c['flag'] ?? '';
                final localizedLabel = flag.isNotEmpty
                    ? '$flag ${RecipeLocalization.localizeCuisine(c['id']!, strings)}'
                    : RecipeLocalization.localizeCuisine(c['id']!, strings);

                return Semantics(
                  button: true,
                  selected: isSelected,
                  child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: Key('cuisine_${c['id']}'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ref.read(discoverProvider.notifier).setCuisine(c['id']!);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF5722) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF5722) : Colors.transparent,
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF5722).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          localizedLabel,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showClearUndo(AppStrings strings, VoidCallback undo) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(strings.itemRemoved),
        action: SnackBarAction(key: const Key('clear_undo'), label: strings.undoLabel, onPressed: undo),
      ));
  }

  /// Recipes the user has cooked, most recent first. Resolved by id, so it also works offline for local recipes.
  Widget _buildCookedSliver(BuildContext context, AppStrings strings) {
    final history = ref.watch(cookHistoryProvider);
    final ids = history.keys.toList()
      ..sort((a, b) => (history[b]!.last ?? DateTime(0)).compareTo(history[a]!.last ?? DateTime(0)));
    return _buildIdsSliver(context, strings, ids,
        emptyText: strings.cookedFilterEmpty, emptyKey: 'cooked_empty', listKey: 'cooked_list');
  }

  /// Recipes the user rated, best rating first. Rated recipes are looked up by id, so this works offline.
  Widget _buildRatedSliver(BuildContext context, AppStrings strings) {
    final notes = ref.watch(recipeNotesProvider);
    final ids = [
      for (final e in notes.entries)
        if (e.value.rating > 0) e.key
    ]..sort((a, b) => notes[b]!.rating.compareTo(notes[a]!.rating));
    return _buildIdsSliver(context, strings, ids,
        emptyText: strings.ratedFilterEmpty, emptyKey: 'rated_empty', listKey: 'rated_list');
  }

  Widget _buildIdsSliver(BuildContext context, AppStrings strings, List<String> ids,
      {required String emptyText, required String emptyKey, required String listKey}) {
    final repo = ref.read(recipeRepositoryProvider);
    return SliverToBoxAdapter(
      child: FutureBuilder<List<Recipe>>(
        key: ValueKey(ids.join(',')),
        future: Future.wait(ids.map(repo.getRecipeById)).then((l) => [for (final r in l) ?r]),
        builder: (context, snap) {
          final query = RecipeRepository.normalizeSearch(_searchController.text).trim();
          final recipes = [
            for (final r in snap.data ?? const <Recipe>[])
              if (query.isEmpty || RecipeRepository.normalizeSearch(r.localizedTitle(strings.locale)).contains(query)) r,
          ];
          if (snap.connectionState != ConnectionState.done && recipes.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(color: Color(0xFFFF5722))),
            );
          }
          if (recipes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                emptyText,
                key: Key(emptyKey),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              key: Key(listKey),
              children: [
                for (final recipe in recipes)
                  _RecipeCard(
                    recipe: recipe,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Saved (bookmarked) recipes, narrowed by the search box. Works offline: they are stored on the device.
  Widget _buildSavedSliver(BuildContext context, AppStrings strings) {
    final query = RecipeRepository.normalizeSearch(_searchController.text).trim();
    final saved = ref.watch(savedRecipesProvider).recipes.where((r) {
      if (query.isEmpty) return true;
      return RecipeRepository.normalizeSearch(r.localizedTitle(strings.locale)).contains(query);
    }).toList();
    final ratings = ref.watch(recipeNotesProvider);
    if (_savedTopRated) {
      saved.sort((a, b) => (ratings[b.id]?.rating ?? 0).compareTo(ratings[a.id]?.rating ?? 0));
    } else if (_savedQuickest) {
      saved.sort((a, b) => a.totalTime.compareTo(b.totalTime));
    }
    if (saved.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              strings.savedFilterEmpty,
              key: const Key('saved_empty'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      key: const Key('saved_sort_quick'),
                      avatar: const Icon(Icons.bolt_rounded, size: 16),
                      label: Text(strings.savedSortQuick),
                      selected: _savedQuickest && !_savedTopRated,
                      onSelected: (v) {
                        setState(() {
                          _savedQuickest = v;
                          if (v) _savedTopRated = false;
                        });
                        _persistSavedSort();
                      },
                    ),
                    FilterChip(
                      key: const Key('saved_sort_rating'),
                      avatar: const Icon(Icons.star_rounded, size: 16),
                      label: Text(strings.savedSortRating),
                      selected: _savedTopRated,
                      onSelected: (v) {
                        setState(() {
                          _savedTopRated = v;
                          if (v) _savedQuickest = false;
                        });
                        _persistSavedSort();
                      },
                    ),
                  ],
                ),
              );
            }
            final recipe = saved[index - 1];
            return Semantics(
              button: true,
              excludeSemantics: true,
              label: _cardLabel(recipe, strings),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
              ),
              child: _RecipeCard(
                recipe: recipe,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                ),
              ),
            );
          },
          childCount: saved.length + 1,
        ),
      ),
    );
  }

  Widget _buildBottomLoader() {
    final strings = ref.watch(appStringsProvider);
    final failed = ref.watch(discoverProvider.select((d) => d.errorMessage != null && !d.isLoadingMore));
    if (failed) {
      // Loading the next batch failed (usually no connection): say so and let the user retry.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Icon(Icons.cloud_off_rounded, size: 18, color: Colors.grey.shade600),
            Text(strings.loadErrorTitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            TextButton(
              key: const Key('load_more_retry'),
              onPressed: () => ref.read(discoverProvider.notifier).loadMore(),
              child: Text(strings.retry),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF5722),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            strings.loadingMoreRecipes,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                strings.loadErrorTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              key: const Key('discover_retry'),
              onPressed: () => ref.read(discoverProvider.notifier).loadInitial(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(strings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            // Saved recipes live on the device, so they still open without a connection.
            TextButton.icon(
              key: const Key('error_open_saved'),
              onPressed: () => setState(() => _onlySaved = true),
              icon: const Icon(Icons.bookmark_rounded, size: 18),
              label: Text(strings.savedOnly),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Icon(CookingIcons.utensils, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                strings.noRecipesFound,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.tryDifferentFilter,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                strings.searchTip,
                key: const Key('search_tip'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(discoverProvider.notifier).setSearchQuery('');
                  ref.read(discoverProvider.notifier).setCategory('Tümü');
                  ref.read(discoverProvider.notifier).setCuisine('Tümü');
                  ref.read(discoverProvider.notifier).setMaxMinutes(null);
                  ref.read(discoverProvider.notifier).setDifficulty(null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, size: 16),
                      const SizedBox(width: 8),
                      Text(strings.resetFilters),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
  });

  Color _categoryColor(String category) {
    switch (category) {
      case 'Ana Yemek':
        return const Color(0xFFEF4444);
      case 'Tatlı':
        return const Color(0xFFEC4899);
      case 'Çorba':
        return const Color(0xFFF97316);
      case 'Kahvaltılık':
        return const Color(0xFFEAB308);
      case 'Pratik':
        return const Color(0xFF06B6D4);
      case 'Hamur İşi':
        return const Color(0xFF8B5CF6);
      case 'Salata':
        return const Color(0xFF10B981);
      case 'Vegan':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final catColor = _categoryColor(recipe.category);
    final myRating = ref.watch(recipeNotesProvider.select((m) => m[recipe.id]?.rating ?? 0));
    final cookedCount = ref.watch(cookHistoryProvider.select((m) => m[recipe.id]?.count ?? 0));
    final hasNote = ref.watch(recipeNotesProvider.select((m) => (m[recipe.id]?.note ?? '').trim().isNotEmpty));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image with floating badges
              Stack(
                children: [
                  RecipeImage(
                    imageUrl: recipe.imageUrl,
                    category: recipe.category,
                    height: 160,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            recipe.localizedCategory(strings),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5722),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            recipe.localizedCuisine(strings),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CookingIcons.gauge, size: 13, color: Colors.grey.shade800),
                          const SizedBox(width: 4),
                          Text(
                            recipe.localizedDifficulty(strings),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Consumer(builder: (context, ref, _) {
                      final isSaved = ref.watch(savedRecipesProvider.select((s) => s.isSaved(recipe.id)));
                      return Material(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: const CircleBorder(),
                        child: IconButton(
                          key: Key('card_save_${recipe.id}'),
                          tooltip: isSaved ? strings.removeFavorite : strings.a11ySave,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isSaved ? const Color(0xFFFF5722) : const Color(0xFF64748B),
                          ),
                          onPressed: () async {
                            final notifier = ref.read(savedRecipesProvider.notifier);
                            final nowSaved = await notifier.toggleSave(recipe);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                content: Text(nowSaved ? strings.addedToFavorites : strings.removedFromFavorites),
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  key: Key('card_save_undo_${recipe.id}'),
                                  label: strings.undoLabel,
                                  onPressed: () {
                                    if (ref.read(savedRecipesProvider).isSaved(recipe.id) == nowSaved) {
                                      notifier.toggleSave(recipe);
                                    }
                                  },
                                ),
                              ));
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.localizedTitle(strings.locale),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              if (cookedCount > 0)
                                _InfoBadge(
                                  key: const Key('cooked_badge'),
                                  icon: Icons.check_circle_outline_rounded,
                                  label: strings.cookedTimes(cookedCount),
                                ),
                              AvoidedBadge(recipe: recipe),
                              if (hasNote)
                                _InfoBadge(
                                  key: Key('note_badge_${recipe.id}'),
                                  icon: Icons.sticky_note_2_outlined,
                                  label: strings.myNotes,
                                ),
                              if (myRating > 0)
                                _InfoBadge(icon: Icons.star_rounded, label: '$myRating/5'),
                              _InfoBadge(
                                icon: CookingIcons.clock,
                                label: strings.minutesShort(recipe.totalTime),
                              ),
                              _InfoBadge(
                                icon: CookingIcons.users,
                                label: strings.servingsFormat(recipe.servings),
                              ),
                              _InfoBadge(
                                icon: CookingIcons.utensils,
                                label: strings.ingredientsCountFormat(recipe.ingredients.length),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Color(0xFFFF5722),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}
