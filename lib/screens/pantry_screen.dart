import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/pantry_provider.dart';
import '../utils/cooking_icons.dart';
import 'recipe_detail_screen.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final TextEditingController _customIngredientController = TextEditingController();

  static const Map<String, List<Map<String, String>>> stapleCategories = {
    'Temel Malzemeler': [
      {'key': 'un', 'label': 'Un 🌾'},
      {'key': 'seker', 'label': 'Şeker 🍬'},
      {'key': 'tuz', 'label': 'Tuz 🧂'},
      {'key': 'zeytinyagi', 'label': 'Zeytinyağı 🫒'},
      {'key': 'tereyagi', 'label': 'Tereyağı 🧈'},
    ],
    'Süt & Kahvaltılık': [
      {'key': 'yumurta', 'label': 'Yumurta 🥚'},
      {'key': 'sut', 'label': 'Süt 🥛'},
      {'key': 'peynir', 'label': 'Peynir 🧀'},
      {'key': 'yogurt', 'label': 'Yoğurt 🥣'},
    ],
    'Sebze & Taze': [
      {'key': 'domates', 'label': 'Domates 🍅'},
      {'key': 'biber', 'label': 'Biber 🌶️'},
      {'key': 'sogan', 'label': 'Soğan 🧅'},
      {'key': 'sarimsak', 'label': 'Sarımsak 🧄'},
      {'key': 'patates', 'label': 'Patates 🥔'},
    ],
    'Et & Bakliyat': [
      {'key': 'kiyma', 'label': 'Kıyma 🥩'},
      {'key': 'tavuk', 'label': 'Tavuk 🍗'},
      {'key': 'mercimek', 'label': 'Mercimek 🍲'},
      {'key': 'pirinc', 'label': 'Pirinç 🍚'},
      {'key': 'makarna', 'label': 'Makarna 🍝'},
      {'key': 'baharat', 'label': 'Baharatlar 🌿'},
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akıllı Kiler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Dolaptaki Malzemelerle Pişir',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (pantryState.selectedKeys.isNotEmpty)
            TextButton.icon(
              onPressed: () => ref.read(pantryProvider.notifier).clearAll(),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              label: const Text(
                'Temizle',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
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
                    'Aşağıdaki malzemelerden elinizde olanlara dokunun. 10.000+ tarif arasından anlık uyum skoru hesaplanacaktır.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          // Custom Ingredient Input
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customIngredientController,
                      onSubmitted: (_) => _handleAddCustom(),
                      decoration: InputDecoration(
                        hintText: 'Farklı malzeme ekle (örn: mantar, zencefil)...',
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
                    child: const Text('Ekle'),
                  ),
                ],
              ),
            ),
          ),

          // Ingredient Pool Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

          // Section Title: Matched Recipes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Eşleşen Tarifler',
                    style: TextStyle(
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
                    const Text(
                      'Kileriniz boş görünüyor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yukarıdan en az 1-2 malzeme seçin. Elinizdeki malzemelere en yakın tarifleri anında sıralayalım.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else if (pantryState.matchedRecipes.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Seçili malzemelerle eşleşen tarif bulunamadı.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
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

class _PantryRecipeCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(matchScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Match percentage badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16, color: scoreColor),
                          const SizedBox(width: 4),
                          Text(
                            '%${matchScore.toStringAsFixed(0)} Uyum',
                            style: TextStyle(
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recipe.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(CookingIcons.clock, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.totalTime} dk',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),

                // Missing ingredients info
                if (missingKeys.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '🎉 Tüm malzemeler dolabınızda mevcut! Hemen pişirebilirsiniz.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF065F46), fontWeight: FontWeight.w500),
                    ),
                  )
                else
                  Text(
                    'Eksik (${missingKeys.length}): ${missingKeys.join(', ')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

                // Substitution suggestions if any missing item has a substitution
                if (substitutions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
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
