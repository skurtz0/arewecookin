import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/recipe_localization.dart';
import '../models/models.dart';
import '../providers/locale_provider.dart';
import '../providers/pantry_provider.dart';
import '../utils/cooking_icons.dart';
import '../widgets/recipe_image.dart';
import 'recipe_detail_screen.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final TextEditingController _customIngredientController = TextEditingController();

  static const List<Map<String, String>> cuisineFilters = [
    {'id': 'Tümü', 'label': '🌍 Tümü'},
    {'id': 'Türk Mutfağı', 'label': '🇹🇷 Türk Mutfağı'},
    {'id': 'İtalyan Mutfağı', 'label': '🇮🇹 İtalyan'},
    {'id': 'Asya & Uzak Doğu', 'label': '🥢 Asya & Uzak Doğu'},
    {'id': 'Meksika Mutfağı', 'label': '🇲🇽 Meksika'},
    {'id': 'Akdeniz Mutfağı', 'label': '🫒 Akdeniz'},
    {'id': 'Fransız & Dünya', 'label': '🇫🇷 Dünya / Tatlı'},
    {'id': 'Pratik & Sokak', 'label': '⚡ Pratik & Sokak'},
  ];

  static const Map<String, List<Map<String, String>>> stapleCategories = {
    'Temel Malzemeler': [
      {'key': 'un', 'label': 'Un 🌾'},
      {'key': 'seker', 'label': 'Şeker 🍬'},
      {'key': 'tuz', 'label': 'Tuz 🧂'},
      {'key': 'zeytinyagi', 'label': 'Zeytinyağı 🫒'},
      {'key': 'tereyagi', 'label': 'Tereyağı 🧈'},
      {'key': 'pirinc', 'label': 'Pirinç 🍚'},
      {'key': 'makarna', 'label': 'Makarna 🍝'},
      {'key': 'fasulye', 'label': 'Kuru Fasulye 🫘'},
      {'key': 'nohut', 'label': 'Nohut 🍲'},
      {'key': 'mercimek', 'label': 'Mercimek 🥣'},
      {'key': 'bulgur', 'label': 'Bulgur 🌾'},
      {'key': 'irmik', 'label': 'İrmik 🥣'},
    ],
    'Süt & Kahvaltılık': [
      {'key': 'yumurta', 'label': 'Yumurta 🥚'},
      {'key': 'sut', 'label': 'Süt 🥛'},
      {'key': 'peynir', 'label': 'Peynir / Kaşar 🧀'},
      {'key': 'yogurt', 'label': 'Yoğurt 🥣'},
    ],
    'Et & Balık': [
      {'key': 'kiyma', 'label': 'Kıyma 🥩'},
      {'key': 'tavuk', 'label': 'Tavuk 🍗'},
      {'key': 'et', 'label': 'Kuşbaşı Et 🍖'},
      {'key': 'balik', 'label': 'Balık / Somon 🐟'},
      {'key': 'sucuk', 'label': 'Sucuk 🌭'},
      {'key': 'ton baligi', 'label': 'Ton Balığı 🥫'},
    ],
    'Sebze & Taze': [
      {'key': 'domates', 'label': 'Domates 🍅'},
      {'key': 'biber', 'label': 'Biber 🌶️'},
      {'key': 'sogan', 'label': 'Soğan 🧅'},
      {'key': 'sarimsak', 'label': 'Sarımsak 🧄'},
      {'key': 'patates', 'label': 'Patates 🥔'},
      {'key': 'patlican', 'label': 'Patlıcan 🍆'},
      {'key': 'mantar', 'label': 'Mantar 🍄'},
      {'key': 'havuc', 'label': 'Havuç 🥕'},
      {'key': 'limon', 'label': 'Limon 🍋'},
      {'key': 'yesillik', 'label': 'Taze Yeşillik 🌿'},
      {'key': 'baharat', 'label': 'Baharatlar ✨'},
    ],
    'Dünya & Özel Malzemeler': [
      {'key': 'lavas', 'label': 'Lavaş / Tortilla 🌯'},
      {'key': 'noodle', 'label': 'Noodle 🍜'},
      {'key': 'avokado', 'label': 'Avokado 🥑'},
      {'key': 'tofu', 'label': 'Tofu 🥢'},
      {'key': 'kakao', 'label': 'Kakao / Çikolata 🍫'},
      {'key': 'ceviz', 'label': 'Ceviz 🌰'},
      {'key': 'yufka', 'label': 'Yufka 🫓'},
    ],
  };

  @override
  void dispose() {
    _customIngredientController.dispose();
    super.dispose();
  }

  void _handleAddCustom() {
    final text = _customIngredientController.text.trim();
    if (text.isNotEmpty) {
      ref.read(pantryProvider.notifier).addIngredient(text);
      _customIngredientController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final pantryState = ref.watch(pantryProvider);
    final userKeys = pantryState.selectedKeys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CookingIcons.pantry,
                color: Color(0xFF059669),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.smartPantry,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    strings.pantrySubtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (pantryState.selectedKeys.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => ref.read(pantryProvider.notifier).clearAll(),
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                label: Text(
                  strings.clearAll,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header description & Selection summary
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Dolabınızda Ne Var? (${pantryState.selectedKeys.length} Seçildi)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Elinizdeki malzemeleri seçin veya ekleyin. İstediğiniz mutfağı filtreleyerek anında 100% uyumlu tarifleri keşfedin.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          // Cuisine Selector Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu_rounded, size: 18, color: Color(0xFF065F46)),
                      const SizedBox(width: 6),
                      Text(
                        strings.whichCuisineQuestion,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      if (pantryState.selectedCuisine != 'Tümü')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            pantryState.selectedCuisine,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: cuisineFilters.map((c) {
                        final isSelected = pantryState.selectedCuisine == c['id'];
                        final emoji = c['label']!.split(' ').first;
                        final localizedLabel = '$emoji ${RecipeLocalization.localizeCuisine(c['id']!, strings)}';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(localizedLabel),
                            selected: isSelected,
                            onSelected: (_) {
                              ref.read(pantryProvider.notifier).setCuisine(c['id']!);
                            },
                            selectedColor: const Color(0xFF059669),
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF059669) : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom Ingredient Input
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customIngredientController,
                      onSubmitted: (_) => _handleAddCustom(),
                      decoration: InputDecoration(
                        hintText: 'Farklı malzeme ekle (örn: mantar, patlıcan, sucuk)...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleAddCustom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ingredient Pool Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: stapleCategories.entries.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: category.value.map((item) {
                            final key = item['key']!;
                            final label = item['label']!;
                            final isSelected = pantryState.selectedKeys.contains(key);

                            return FilterChip(
                              label: Text(label),
                              selected: isSelected,
                              onSelected: (_) {
                                ref.read(pantryProvider.notifier).toggleIngredient(key);
                              },
                              selectedColor: const Color(0xFF059669),
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF059669) : Colors.grey.shade200,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Section Title: Matched Recipes with Full-match toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    strings.matchingRecipes,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pantryState.matchedRecipes.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (pantryState.selectedKeys.isNotEmpty)
                    InkWell(
                      onTap: () => ref.read(pantryProvider.notifier).toggleOnlyFullMatches(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: pantryState.onlyFullMatches
                              ? const Color(0xFF059669)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: pantryState.onlyFullMatches
                                ? const Color(0xFF059669)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pantryState.onlyFullMatches
                                  ? Icons.check_circle_rounded
                                  : Icons.filter_alt_outlined,
                              size: 13,
                              color: pantryState.onlyFullMatches ? Colors.white : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              strings.locale.toLowerCase().startsWith('tr')
                                  ? 'Sadece %100 Hazır'
                                  : '100% Match Only',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: pantryState.onlyFullMatches ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Matches Result List
          if (pantryState.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF059669)),
                ),
              ),
            )
          else if (pantryState.selectedKeys.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CookingIcons.pantry, size: 54, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      strings.locale.toLowerCase().startsWith('tr')
                          ? 'Kileriniz boş görünüyor'
                          : 'Your pantry looks empty',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.locale.toLowerCase().startsWith('tr')
                          ? 'Yukarıdan elinizdeki malzemeleri seçin. Mutfak tercihinize göre anında en uygun yemekler sıralanacaktır.'
                          : 'Select ingredients from above. Best matching dishes will be listed instantly according to your cuisine preference.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else if (pantryState.matchedRecipes.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      pantryState.selectedCuisine != 'Tümü'
                          ? (strings.locale.toLowerCase().startsWith('tr')
                              ? '${pantryState.selectedCuisine} kategorisinde seçili malzemelerle eşleşen tarif bulunamadı.'
                              : 'No recipes found for ${RecipeLocalization.localizeCuisine(pantryState.selectedCuisine, strings)} with selected ingredients.')
                          : strings.noRecipesFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.locale.toLowerCase().startsWith('tr')
                          ? 'Farklı malzemeler seçebilir veya mutfak filtresini "Tümü" olarak değiştirebilirsiniz.'
                          : 'Try selecting different ingredients or set cuisine filter to "All".',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = pantryState.matchedRecipes[index];
                    final matchScore = recipe.calculateMatchScore(userKeys);
                    final missingKeys = recipe.getMissingKeys(userKeys);
                    final subs = recipe.getApplicableSubstitutions(userKeys);

                    return _PantryRecipeCard(
                      recipe: recipe,
                      matchScore: matchScore,
                      missingKeys: missingKeys,
                      substitutions: subs,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                    );
                  },
                  childCount: pantryState.matchedRecipes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PantryRecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final double matchScore;
  final List<String> missingKeys;
  final List<Substitution> substitutions;
  final VoidCallback onTap;

  const _PantryRecipeCard({
    required this.recipe,
    required this.matchScore,
    required this.missingKeys,
    required this.substitutions,
    required this.onTap,
  });

  Color _scoreColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final scoreColor = _scoreColor(matchScore);
    final isFullMatch = missingKeys.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFullMatch ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.grey.shade200,
          width: isFullMatch ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFullMatch
                ? const Color(0xFF10B981).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dish photo thumbnail
                    RecipeImage(
                      imageUrl: recipe.imageUrl,
                      category: recipe.category,
                      width: 82,
                      height: 82,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(width: 14),
                    // Details column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Match percentage badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: scoreColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isFullMatch ? Icons.check_circle : Icons.pie_chart_outline_rounded,
                                      size: 14,
                                      color: scoreColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '%${matchScore.toStringAsFixed(0)} ${strings.matchRate}',
                                      style: TextStyle(
                                        color: scoreColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Cuisine badge
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    recipe.localizedCuisine(strings),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF334155),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(CookingIcons.clock, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 3),
                              Text(
                                strings.minutesShort(recipe.totalTime),
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            recipe.localizedCleanTitle(strings.locale),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Full match vs missing ingredients indicator
                if (isFullMatch)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF059669)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            strings.cancel == 'İptal'
                                ? 'Tüm malzemeler dolabınızda hazır! Hemen pişirebilirsiniz.'
                                : 'All ingredients ready in your pantry! You can cook now.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF065F46),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${strings.cancel == 'İptal' ? 'Eksik' : 'Missing'} (${missingKeys.length}): ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: missingKeys.map((key) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                RecipeLocalization.localizeIngredientName(key, strings.locale),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],

                // Substitution suggestions if any missing item has a substitution
                if (substitutions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(CookingIcons.substitute, size: 14, color: Colors.amber.shade800),
                            const SizedBox(width: 4),
                            Text(
                              'İkame Önerisi (${substitutions.first.ingredient} yerine):',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${substitutions.first.alternative} - ${substitutions.first.tip}',
                          style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
