import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../utils/cooking_icons.dart';
import '../widgets/recipe_image.dart';
import '../providers/user_recipes_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/avoided_ingredients_provider.dart';
import '../providers/household_servings_provider.dart';
import '../providers/pantry_provider.dart';
import '../repositories/recipe_repository.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/recent_recipes_provider.dart';
import '../providers/recipe_notes_provider.dart';
import '../providers/cook_history_provider.dart';
import '../providers/recipe_progress_provider.dart';
import '../providers/discover_provider.dart';
import '../providers/unit_system_provider.dart';
import '../utils/pantry_match.dart';
import '../utils/unit_converter.dart';
import '../l10n/recipe_localization.dart';
import 'cooking_mode_screen.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

bool _inPantry(Ingredient i, Set<String> have, String locale) => ingredientInPantry(i, have, locale);

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late int _servings;
  bool _servingsTouched = false;
  bool _checkedTouched = false;
  final Set<int> _checkedIngredientIndices = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings > 0 ? widget.recipe.servings : 4;
    // Restore the servings the user chose last time (arrives asynchronously).
    ref.listenManual(recipeProgressProvider, (prev, next) {
      final saved = next[widget.recipe.id]?.servings;
      if (!_servingsTouched && saved != null && saved != _servings && mounted) {
        setState(() => _servings = saved);
      }
      final savedChecked = next[widget.recipe.id]?.checked;
      if (!_checkedTouched && savedChecked != null && savedChecked.isNotEmpty && mounted) {
        setState(() => _checkedIngredientIndices.addAll(savedChecked));
      }
    }, fireImmediately: true);
    // Without a number chosen for this recipe, open it scaled to the household size from the account.
    ref.listenManual(householdServingsProvider, (prev, next) {
      final hasOwn = ref.read(recipeProgressProvider)[widget.recipe.id]?.servings != null;
      if (!_servingsTouched && !hasOwn && next != null && widget.recipe.servings > 0 && next != _servings && mounted) {
        setState(() => _servings = next);
      }
    }, fireImmediately: true);
    Future.microtask(() {
      if (mounted) ref.read(recentRecipesProvider.notifier).add(widget.recipe);
    });
  }

  void _changeServings(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _servingsTouched = true;
      _servings = (_servings + delta).clamp(1, 99);
    });
    ref.read(recipeProgressProvider.notifier).setServings(widget.recipe.id, _servings);
  }

  /// Plain-text recipe (title, scaled ingredients, steps) for pasting into notes or chats.
  /// True when the ingredient's name contains one of the words the user avoids.
  bool _isAvoided(Ingredient i, List<String> avoid) {
    if (avoid.isEmpty) return false;
    final name = RecipeRepository.normalizeSearch('${i.name} ${i.nameEn ?? ''}');
    return avoid.any((w) => w.trim().isNotEmpty && name.contains(RecipeRepository.normalizeSearch(w)));
  }

  String recipeAsText(String locale) {
    final r = widget.recipe;
    final b = StringBuffer(r.localizedTitle(locale))
      ..writeln()
      ..writeln('${r.totalTime} min | $_servings')
      ..writeln();
    for (final i in r.ingredients) {
      b.writeln(
        '- ${i.localizedName(locale)}: ${_qty(i, locale).amount} ${_qty(i, locale).unit}'
            .trimRight(),
      );
    }
    b.writeln();
    for (var n = 0; n < r.steps.length; n++) {
      b.writeln('${n + 1}. ${r.steps[n].localizedInstruction(locale)}');
    }
    // My own note travels with the copied recipe.
    final note = (ref.read(recipeNotesProvider)[r.id]?.note ?? '').trim();
    if (note.isNotEmpty) {
      b
        ..writeln()
        ..writeln('${ref.read(appStringsProvider).myNotes}: $note');
    }
    return b.toString().trimRight();
  }

  void _toggleIngredient(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_checkedIngredientIndices.contains(index)) {
        _checkedIngredientIndices.remove(index);
      } else {
        _checkedIngredientIndices.add(index);
      }
    });
    _persistChecked();
  }

  void _persistChecked() {
    _checkedTouched = true;
    ref.read(recipeProgressProvider.notifier).setChecked(widget.recipe.id, _checkedIngredientIndices);
  }

  void _toggleAllIngredients() {
    final before = Set<int>.from(_checkedIngredientIndices);
    final clearing = before.length == widget.recipe.ingredients.length;
    if (clearing) {
      final strings = ref.read(appStringsProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(strings.ticksCleared),
          action: SnackBarAction(
            key: const Key('ticks_undo'),
            label: strings.undoLabel,
            onPressed: () {
              if (!mounted) return;
              setState(() => _checkedIngredientIndices.addAll(before));
              _persistChecked();
            },
          ),
        ));
    }
    setState(() {
      if (_checkedIngredientIndices.length ==
          widget.recipe.ingredients.length) {
        _checkedIngredientIndices.clear();
      } else {
        _checkedIngredientIndices.addAll(
          List.generate(widget.recipe.ingredients.length, (i) => i),
        );
      }
    });
    _persistChecked();
  }

  /// Scaled amount + unit, converted to US units when the user chose them.
  ({String amount, String unit}) _qty(Ingredient i, String locale, {bool fractions = true}) {
    final scaled = _scaledNumber(i.amount);
    final unit = i.localizedUnit(locale);
    if (scaled == null) return (amount: i.amount, unit: unit);
    if (ref.read(imperialUnitsProvider)) {
      final conv = UnitConverter.toImperial(scaled, i.unit.trim().isEmpty ? unit : i.unit);
      if (conv != null) return (amount: UnitConverter.format(conv.amount), unit: conv.unit);
    }
    return (amount: fractions ? AmountFormat.fraction(scaled) : _plain(scaled), unit: unit);
  }

  /// Amount multiplied by the chosen servings, or null when the amount is not a plain number.
  double? _scaledNumber(String rawAmount) {
    final original = AmountFormat.parse(rawAmount);
    if (original == null || widget.recipe.servings <= 0) return null;
    return original * (_servings / widget.recipe.servings);
  }

  String _plain(double v) => v == v.toInt() ? v.toInt().toString() : v.toStringAsFixed(1);

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
    final pantryKeys = ref.watch(pantryProvider.select((p) => p.selectedKeys));
    final imperial = ref.watch(imperialUnitsProvider);
    final recipe = widget.recipe;
    final savedStep = ref.watch(recipeProgressProvider.select((m) => m[widget.recipe.id]?.step ?? 0));
    final totalIngredients = recipe.ingredients.length;
    final checkedCount = _checkedIngredientIndices.length;
    final progress = totalIngredients > 0
        ? checkedCount / totalIngredients
        : 1.0;
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
          Builder(
            builder: (context) {
              final strings = ref.read(appStringsProvider);
              return IconButton(
                key: const Key('copy_recipe'),
                tooltip: strings.copyRecipe,
                icon: const Icon(
                  Icons.copy_rounded,
                  size: 22,
                  color: Color(0xFF64748B),
                ),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: recipeAsText(strings.locale)),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(strings.recipeCopied)),
                    );
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final savedState = ref.watch(savedRecipesProvider);
              final isSaved = savedState.isSaved(recipe.id);
              final strings = ref.watch(appStringsProvider);
              return IconButton(
                key: const Key('save_toggle'),
                tooltip: isSaved ? strings.removeFavorite : strings.a11ySave,
                isSelected: isSaved,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved
                      ? const Color(0xFFFF5722)
                      : const Color(0xFF64748B),
                  size: 24,
                ),
                onPressed: () async {
                  final nowSaved = await ref
                      .read(savedRecipesProvider.notifier)
                      .toggleSave(recipe);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          nowSaved
                              ? strings.addedToFavorites
                              : strings.removedFromFavorites,
                        ),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          key: const Key('save_toggle_undo'),
                          label: strings.undoLabel,
                          onPressed: () {
                            final saved = ref.read(savedRecipesProvider).isSaved(recipe.id);
                            if (saved == nowSaved) {
                              ref.read(savedRecipesProvider.notifier).toggleSave(recipe);
                            }
                          },
                        ),
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
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
                  const Icon(
                    CookingIcons.users,
                    color: Color(0xFFFF5722),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${strings.servings}:',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: strings.a11yFewer,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: _servings > 1
                        ? const Color(0xFFFF5722)
                        : Colors.grey.shade300,
                    onPressed: _servings > 1
                        ? () => _changeServings(-1)
                        : null,
                  ),
                  Flexible(
                    child: Semantics(
                      liveRegion: true,
                      child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        strings.servingsFormat(_servings),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    )),
                  ),
                  IconButton(
                    tooltip: strings.a11yMore,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: const Color(0xFFFF5722),
                    onPressed: _servings < 99 ? () => _changeServings(1) : null,
                  ),
                ],
              ),
            ),

            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                spacing: 4,
                children: [
                  Tooltip(
                    message: strings.servingsFormat((_servings + 1) ~/ 2),
                    child: TextButton(
                      key: const Key('servings_half'),
                      onPressed: _servings > 1 ? () => _changeServings(-(_servings - (_servings + 1) ~/ 2)) : null,
                      child: const Text('½×'),
                    ),
                  ),
                  Tooltip(
                    message: strings.servingsFormat((_servings * 2).clamp(1, 99)),
                    child: TextButton(
                      key: const Key('servings_double'),
                      onPressed: _servings < 99 ? () => _changeServings(_servings) : null,
                      child: const Text('2×'),
                    ),
                  ),
                  if (widget.recipe.servings > 0 && _servings != widget.recipe.servings)
                    TextButton.icon(
                      key: const Key('servings_reset'),
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: Text(strings.servingsReset),
                      onPressed: () => _changeServings(widget.recipe.servings - _servings),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SegmentedButton<bool>(
                key: const Key('unit_system_toggle'),
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: [
                  ButtonSegment(value: false, label: Text(strings.unitMetric)),
                  ButtonSegment(value: true, label: Text(strings.unitImperial)),
                ],
                selected: {imperial},
                onSelectionChanged: (v) => ref.read(imperialUnitsProvider.notifier).set(v.first),
              ),
            ),
            const SizedBox(height: 14),

            // Ingredient Readiness Checklist Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(header: true, child: Text(
                        strings.ingredientsTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      )),
                      const SizedBox(height: 4),
                      Text(
                        '$checkedCount / $totalIngredients ${strings.ready} (${(progress * 100).toInt()}%)',
                        style: TextStyle(
                          fontSize: 13,
                          color: progress == 1.0
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  key: const Key('toggle_all_ingredients'),
                  onPressed: _toggleAllIngredients,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  child: Text(
                    checkedCount == totalIngredients
                        ? strings.clearAll
                        : strings.selectAll,
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
                color: progress == 1.0
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFF5722),
              ),
            ),

            // Shown until the user has an avoided list: how to build it from this screen.
            if (ref.watch(avoidedIngredientsProvider).isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  strings.ingredientHoldHint,
                  key: const Key('avoid_hint'),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),

            const SizedBox(height: 16),

            Builder(builder: (_) {
              final hits = [
                for (final w in ref.watch(avoidedIngredientsProvider))
                  if (RecipeRepository.mentionsWord(recipe, w)) w,
              ];
              if (hits.isEmpty) return const SizedBox.shrink();
              return Container(
                key: const Key('avoided_warning'),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.avoidedWarning(hits.join(', ')),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Builder(builder: (_) {
              final have = recipe.ingredients
                  .where((i) => _inPantry(i, pantryKeys, strings.locale))
                  .length;
              if (have == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  strings.pantryCoverage(have, recipe.ingredients.length),
                  key: const Key('pantry_coverage'),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              );
            }),

            if (recipe.ingredients.asMap().entries.any((e) =>
                !_checkedIngredientIndices.contains(e.key) && _inPantry(e.value, pantryKeys, strings.locale)))
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  key: const Key('tick_pantry_ingredients'),
                  icon: const Icon(Icons.kitchen_rounded, size: 18),
                  label: Text(strings.tickPantryIngredients),
                  onPressed: () {
                    setState(() {
                      for (var n = 0; n < recipe.ingredients.length; n++) {
                        if (_inPantry(recipe.ingredients[n], pantryKeys, strings.locale)) {
                          _checkedIngredientIndices.add(n);
                        }
                      }
                    });
                    _persistChecked();
                  },
                ),
              ),

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
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final ing = recipe.ingredients[index];
                  final isChecked = _checkedIngredientIndices.contains(index);
                  final qty = _qty(ing, strings.locale);
                  final havePantry = _inPantry(ing, pantryKeys, strings.locale);

                  // Long press (or the screen reader action) adds this ingredient to "Ingredients I avoid".
                  void avoidIngredient() {
                    final name = ing.localizedName(strings.locale);
                    final notifier = ref.read(avoidedIngredientsProvider.notifier);
                    final before = [...ref.read(avoidedIngredientsProvider)];
                    final added = notifier.add(name);
                    final words = ref.read(avoidedIngredientsProvider).where((w) => !before.contains(w)).toList();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(added == 0
                            ? strings.pantryNothingNew
                            : '${strings.avoidedTitle}: ${words.join(', ')}'),
                        action: added == 0
                            ? null
                            : SnackBarAction(
                                key: const Key('avoid_undo'),
                                label: strings.undoLabel,
                                onPressed: () {
                                  for (final w in words) {
                                    notifier.remove(w);
                                  }
                                },
                              ),
                      ));
                  }

                  return Semantics(
                    key: Key('ingredient_$index'),
                    checked: isChecked,
                    container: true,
                    customSemanticsActions: {
                      CustomSemanticsAction(label: strings.avoidedTitle): avoidIngredient,
                    },
                    child: InkWell(
                    onTap: () => _toggleIngredient(index),
                    onLongPress: avoidIngredient,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isChecked
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isChecked
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade400,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              ing.localizedName(strings.locale),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isChecked
                                    ? Colors.grey.shade400
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (_isAvoided(ing, ref.watch(avoidedIngredientsProvider)))
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                key: Key('ingredient_avoided_$index'),
                                size: 16,
                                color: const Color(0xFFDC2626),
                                semanticLabel: strings.avoidedTitle,
                              ),
                            ),
                          if (havePantry)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: Tooltip(
                                message: strings.inPantryLabel,
                                child: Icon(
                                  Icons.kitchen_rounded,
                                  key: Key('ingredient_pantry_$index'),
                                  size: 16,
                                  color: const Color(0xFF059669),
                                  semanticLabel: strings.inPantryLabel,
                                ),
                              ),
                            ),
                          Text(
                            '${qty.amount} ${qty.unit}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isChecked
                                  ? Colors.grey.shade400
                                  : const Color(0xFFFF5722),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('add_to_shopping_list'),
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(strings.shoppingAdd),
                onPressed: () {
                  // Ingredients already ticked as "have it" are not added to the list.
                  // Ingredients whose name exactly matches a pantry item are skipped too.
                  final have = ref.read(pantryProvider).selectedKeys;
                  bool inPantry(Ingredient i) => _inPantry(i, have, strings.locale);
                  final needed = <Ingredient>[
                    for (var n = 0; n < recipe.ingredients.length; n++)
                      if (!_checkedIngredientIndices.contains(n) &&
                          !inPantry(recipe.ingredients[n]))
                        recipe.ingredients[n],
                  ];
                  final before = List.of(ref.read(shoppingListProvider));
                  final added = ref
                      .read(shoppingListProvider.notifier)
                      .addAll(
                        needed
                            .where((i) => !i.isOptional)
                            .map(
                              (i) => ShoppingItem(
                                name: i.localizedName(strings.locale),
                                amount: _qty(i, strings.locale, fractions: false).amount,
                                unit: _qty(i, strings.locale, fractions: false).unit,
                                recipeTitle: recipe.localizedTitle(
                                  strings.locale,
                                ),
                              ),
                            ),
                      );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          added == 0
                              ? strings.shoppingNothingNew
                              : strings.shoppingAdded(added),
                        ),
                        action: added == 0
                            ? null
                            : SnackBarAction(
                                key: const Key('shopping_add_undo'),
                                label: strings.undoLabel,
                                onPressed: () => ref
                                    .read(shoppingListProvider.notifier)
                                    .restore(before),
                              ),
                      ),
                    );
                },
              ),
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('add_to_meal_plan'),
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(strings.mealPlanAdd),
                onPressed: () async {
                  final day = await showModalBottomSheet<int>(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              strings.mealPlanPickDay,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          for (var d = 1; d <= 7; d++)
                            ListTile(
                              key: Key('plan_day_$d'),
                              title: Text(d == DateTime.now().weekday
                                  ? '${strings.weekdayName(d)} · ${strings.todayLabel}'
                                  : strings.weekdayName(d)),
                              trailing: (ref.read(mealPlanProvider)[d] ?? const <Recipe>[])
                                      .any((r) => r.id == recipe.id)
                                  ? const Icon(Icons.check_circle_rounded,
                                      key: Key('plan_day_has_recipe'), color: Color(0xFF10B981))
                                  : null,
                              onTap: () => Navigator.of(ctx).pop(d),
                            ),
                        ],
                      ),
                      ),
                    ),
                  );
                  if (day == null || !context.mounted) return;
                  final ok = ref
                      .read(mealPlanProvider.notifier)
                      .add(day, recipe);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? strings.mealPlanAddedTo(
                                  strings.weekdayName(day),
                                )
                              : strings.mealPlanAlready,
                        ),
                        action: ok
                            ? SnackBarAction(
                                key: const Key('plan_add_undo'),
                                label: strings.undoLabel,
                                onPressed: () => ref
                                    .read(mealPlanProvider.notifier)
                                    .remove(day, recipe.id),
                              )
                            : null,
                      ),
                    );
                },
              ),
            ),
            Builder(builder: (context) {
              final plan = ref.watch(mealPlanProvider);
              final days = [
                for (var d = 1; d <= 7; d++)
                  if ((plan[d] ?? const <Recipe>[]).any((r) => r.id == recipe.id)) strings.weekdayName(d),
              ];
              if (days.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  strings.plannedOn(days.join(', ')),
                  key: const Key('planned_on'),
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                ),
              );
            }),

            Builder(builder: (context) {
              final similar = ref
                  .watch(discoverProvider.select((s) => s.recipes))
                  .where((r) => r.id != recipe.id && r.category == recipe.category)
                  .take(6)
                  .toList();
              if (similar.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Semantics(header: true, child: Text(strings.similarRecipes,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
                  const SizedBox(height: 8),
                  Wrap(
                    key: const Key('similar_recipes'),
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final r in similar)
                        ActionChip(
                          key: Key('similar_${r.id}'),
                          label: Text(r.localizedTitle(strings.locale), overflow: TextOverflow.ellipsis),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r)),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),

            // Personal rating and notes (stored on the device)
            const SizedBox(height: 24),
            Semantics(header: true, child: Text(strings.myNotes,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final note = ref.watch(recipeNotesProvider)[recipe.id] ?? const RecipeNote();
              // Fill the field once when the stored note arrives (never while the user is typing).
              if (_noteController.text.isEmpty && note.note.isNotEmpty) _noteController.text = note.note;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var n = 1; n <= 5; n++)
                        IconButton(
                          key: Key('rate_$n'),
                          tooltip: strings.rateStarFor(n),
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            n <= note.rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                          onPressed: () => ref.read(recipeNotesProvider.notifier).setRating(recipe.id, n),
                        ),
                    ],
                  ),
                  Builder(builder: (context) {
                    final rec = ref.watch(cookHistoryProvider)[recipe.id];
                    if (rec == null || rec.count == 0) return const SizedBox.shrink();
                    final last = rec.last;
                    final date = last == null
                        ? ''
                        : ' · ${last.day.toString().padLeft(2, '0')}.${last.month.toString().padLeft(2, '0')}.${last.year}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${strings.cookedTimes(rec.count)}$date',
                              key: const Key('cooked_times'),
                              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            key: const Key('undo_cooked'),
                            tooltip: strings.undoLabel,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.undo_rounded, size: 18),
                            onPressed: () => ref.read(cookHistoryProvider.notifier).undoCooked(recipe.id),
                          ),
                        ],
                      ),
                    );
                  }),
                  TextField(
                    key: const Key('recipe_note_field'),
                    controller: _noteController,
                    minLines: 2,
                    maxLines: 6,
                    onChanged: (v) => ref.read(recipeNotesProvider.notifier).setNote(recipe.id, v),
                    decoration: InputDecoration(
                      hintText: strings.myNotesHint,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              );
            }),

            // Substitutions Section
            if (recipe.substitutions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    CookingIcons.substitute,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Semantics(header: true, child: Text(
                    strings.substitutionsTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  )),
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
                              '${RecipeLocalization.localizeIngredientName(sub.ingredient, strings.locale).toUpperCase()} ${strings.insteadOf}: ${RecipeLocalization.localizeSubstitutionAlternative(sub.alternative, strings.locale)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              RecipeLocalization.localizeSubstitutionTip(
                                sub.tip,
                                strings.locale,
                              ),
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
                  child: Semantics(header: true, child: Text(
                    strings.stepsTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  )),
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
                final toolName = CookingIcons.getToolLabel(
                  step.toolIcon,
                  strings.locale,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Semantics(
                  button: true,
                  child: InkWell(
                  key: Key('step_preview_$index'),
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CookingModeScreen(recipe: recipe, initialStep: index),
                    ),
                  ),
                  child: Container(
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
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          toolIcon,
                                          size: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            toolName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          size: 12,
                                          color: Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            RecipeLocalization.localizeIngredientName(
                                              item,
                                              strings.locale,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569),
                                              fontWeight: FontWeight.w600,
                                            ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      CookingIcons.proTip,
                                      size: 14,
                                      color: Color(0xFFD97706),
                                    ),
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
                ))));
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
                      savedStep > 0 && savedStep < recipe.steps.length
                          ? '${strings.resumeCooking(savedStep + 1)} 🍳'
                          : '${strings.startCooking} 🍳',
                      key: const Key('start_cooking_label'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
    // One spoken phrase ("Prep Time: 5 min") instead of a loose value and a loose label.
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '$label: $value',
      child: Column(
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
    ));
  }
}
