import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../utils/cooking_icons.dart';
import '../widgets/recipe_image.dart';
import '../providers/user_recipes_provider.dart';
import '../providers/locale_provider.dart';
import 'cooking_mode_screen.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late int _servings;
  final Set<int> _checkedIngredientIndices = {};

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings > 0 ? widget.recipe.servings : 4;
  }

  void _toggleIngredient(int index) {
    setState(() {
      if (_checkedIngredientIndices.contains(index)) {
        _checkedIngredientIndices.remove(index);
      } else {
        _checkedIngredientIndices.add(index);
      }
    });
  }

  void _toggleAllIngredients() {
    setState(() {
      if (_checkedIngredientIndices.length == widget.recipe.ingredients.length) {
        _checkedIngredientIndices.clear();
      } else {
        _checkedIngredientIndices.addAll(
          List.generate(widget.recipe.ingredients.length, (i) => i),
        );
      }
    });
  }

  String _formatScaledAmount(String rawAmount) {
    final originalAmount = double.tryParse(rawAmount);
    if (originalAmount == null || widget.recipe.servings <= 0) {
      return rawAmount;
    }
    final factor = _servings / widget.recipe.servings;
    final scaled = originalAmount * factor;
    // Format nicely without trailing zeros
    if (scaled == scaled.toInt()) {
      return scaled.toInt().toString();
    }
    return scaled.toStringAsFixed(1);
  }

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
        return const Color(0xFFFF5722);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final recipe = widget.recipe;
    final totalIngredients = recipe.ingredients.length;
    final checkedCount = _checkedIngredientIndices.length;
    final progress = totalIngredients > 0 ? checkedCount / totalIngredients : 1.0;
    final catColor = _categoryColor(recipe.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          recipe.localizedTitle(strings.locale),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final savedState = ref.watch(savedRecipesProvider);
              final isSaved = savedState.isSaved(recipe.id);
              final strings = ref.watch(appStringsProvider);
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isSaved ? const Color(0xFFFF5722) : const Color(0xFF64748B),
                  size: 24,
                ),
                onPressed: () async {
                  final nowSaved =
                      await ref.read(savedRecipesProvider.notifier).toggleSave(recipe);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          nowSaved
                              ? strings.addedToFavorites
                              : strings.removedFromFavorites,
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Hero Image Banner
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: RecipeImage(
                imageUrl: recipe.imageUrl,
                category: recipe.category,
                height: 200,
                width: double.infinity,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Hero Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          recipe.localizedCategory(strings),
                          style: TextStyle(
                            color: catColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          recipe.localizedDifficulty(strings),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    recipe.localizedTitle(strings.locale),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _StatColumn(
                          icon: CookingIcons.clock,
                          value: strings.minutesShort(recipe.prepTime),
                          label: strings.prepTime,
                        ),
                      ),
                      Expanded(
                        child: _StatColumn(
                          icon: CookingIcons.fire,
                          value: strings.minutesShort(recipe.cookTime),
                          label: strings.cookTime,
                        ),
                      ),
                      Expanded(
                        child: _StatColumn(
                          icon: CookingIcons.timer,
                          value: strings.minutesShort(recipe.totalTime),
                          label: strings.totalTime,
                        ),
                      ),
                      Expanded(
                        child: _StatColumn(
                          icon: CookingIcons.users,
                          value: strings.servingsFormat(_servings),
                          label: strings.servings,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Servings Scaler
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(CookingIcons.users, color: Color(0xFFFF5722), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${strings.servings}:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: _servings > 1 ? const Color(0xFFFF5722) : Colors.grey.shade300,
                    onPressed: _servings > 1
                        ? () => setState(() => _servings--)
                        : null,
                  ),
                  Text(
                    strings.servingsFormat(_servings),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: const Color(0xFFFF5722),
                    onPressed: () => setState(() => _servings++),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ingredient Readiness Checklist Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.ingredientsTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$checkedCount / $totalIngredients ${strings.locale.toLowerCase().startsWith('tr') ? 'hazır' : 'ready'} (${(progress * 100).toInt()}%)',
                        style: TextStyle(
                          fontSize: 13,
                          color: progress == 1.0 ? Colors.green.shade700 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _toggleAllIngredients,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: Text(
                    checkedCount == totalIngredients
                        ? strings.clearAll
                        : (strings.locale.toLowerCase().startsWith('tr') ? 'Tümünü Seç' : 'Select All'),
                    style: const TextStyle(
                      color: Color(0xFFFF5722),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: progress == 1.0 ? const Color(0xFF10B981) : const Color(0xFFFF5722),
              ),
            ),

            const SizedBox(height: 16),

            // Ingredients Interactive List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: recipe.ingredients.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final ing = recipe.ingredients[index];
                  final isChecked = _checkedIngredientIndices.contains(index);
                  final scaledAmount = _formatScaledAmount(ing.amount);

                  return InkWell(
                    onTap: () => _toggleIngredient(index),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isChecked
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isChecked ? const Color(0xFF10B981) : Colors.grey.shade400,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              ing.localizedName(strings.locale),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: isChecked ? TextDecoration.lineThrough : null,
                                color: isChecked ? Colors.grey.shade400 : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Text(
                            '$scaledAmount ${ing.localizedUnit(strings.locale)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isChecked ? Colors.grey.shade400 : const Color(0xFFFF5722),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Substitutions Section
            if (recipe.substitutions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(CookingIcons.substitute, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Akıllı İkame Önerileri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...recipe.substitutions.map((sub) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CookingIcons.proTip,
                          color: Color(0xFFD97706),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${sub.ingredient.toUpperCase()} yerine: ${sub.alternative}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sub.tip,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB45309),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Cooking Steps Preview
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.stepsTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Text(
                  '${recipe.steps.length} ${strings.step}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recipe.steps.length,
              itemBuilder: (context, index) {
                final step = recipe.steps[index];
                final toolIcon = CookingIcons.getToolIcon(step.toolIcon);
                final toolName = CookingIcons.getToolLabel(step.toolIcon, strings.locale);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFFFF5722),
                        child: Text(
                          '${step.order}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    step.localizedTitle(strings.locale),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(toolIcon, size: 13, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        toolName,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step.localizedInstruction(strings.locale),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF334155),
                                height: 1.45,
                              ),
                            ),
                            if (step.stepIngredients.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: step.stepIngredients.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
                                        const SizedBox(width: 4),
                                        Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF475569),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (step.proTip.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(CookingIcons.proTip, size: 14, color: Color(0xFFD97706)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        step.localizedProTip(strings.locale),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF92400E),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CookingModeScreen(recipe: recipe),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CookingIcons.play, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '${strings.startCooking} 🍳',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF5722)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
