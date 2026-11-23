import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/locale_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../providers/user_recipes_provider.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  /// When set, the screen edits this (own) recipe instead of creating a new one.
  final Recipe? recipe;
  const AddRecipeScreen({super.key, this.recipe});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _IngredientDraft {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String unit = 'adet';

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _StepDraft {
  final TextEditingController instructionController = TextEditingController();
  final TextEditingController timerController = TextEditingController();

  void dispose() {
    instructionController.dispose();
    timerController.dispose();
  }
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '15');
  final _cookTimeController = TextEditingController(text: '30');
  final _servingsController = TextEditingController(text: '4');

  String _selectedCategory = 'Ana Yemek';
  String _selectedCuisine = 'Türk Mutfağı';
  String _selectedDifficulty = 'Kolay';

  final List<_IngredientDraft> _ingredients = [];
  final List<_StepDraft> _steps = [];

  final List<String> _categories = [
    'Ana Yemek',
    'Tatlı',
    'Çorba',
    'Kahvaltılık',
    'Pratik',
    'Hamur İşi',
    'Salata',
    'Vegan',
  ];

  final List<String> _cuisines = [
    'Türk Mutfağı',
    'İtalyan',
    'Asya & Uzak Doğu',
    'Meksika',
    'Akdeniz',
    'Fransız & Dünya',
    'Pratik & Sokak',
  ];

  final List<String> _difficulties = ['Kolay', 'Orta', 'Zor'];

  final List<String> _units = [
    'adet',
    'su bardağı',
    'çay bardağı',
    'yemek kaşığı',
    'tatlı kaşığı',
    'çay kaşığı',
    'gram',
    'kg',
    'ml',
    'litre',
    'tutam',
    'diş',
    'paket',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    if (r != null) {
      _prefill(r);
      return;
    }
    // Pre-populate with 2 ingredients and 2 steps
    _addIngredient();
    _addIngredient();
    _addStep();
    _addStep();
  }

  void _prefill(Recipe r) {
    _titleController.text = r.title;
    _imageUrlController.text = r.imageUrl ?? '';
    _prepTimeController.text = '${r.prepTime}';
    _cookTimeController.text = '${r.cookTime}';
    _servingsController.text = '${r.servings}';
    if (!_categories.contains(r.category)) _categories.add(r.category);
    if (!_cuisines.contains(r.cuisine)) _cuisines.add(r.cuisine);
    if (!_difficulties.contains(r.difficulty)) _difficulties.add(r.difficulty);
    _selectedCategory = r.category;
    _selectedCuisine = r.cuisine;
    _selectedDifficulty = r.difficulty;
    for (final i in r.ingredients) {
      final d = _IngredientDraft();
      d.nameController.text = i.name;
      d.amountController.text = i.amount;
      if (!_units.contains(i.unit)) _units.add(i.unit);
      d.unit = i.unit;
      _ingredients.add(d);
    }
    for (final st in r.steps) {
      final d = _StepDraft();
      d.instructionController.text = st.instruction;
      if (st.timerSeconds > 0) d.timerController.text = '${(st.timerSeconds / 60).ceil()}';
      _steps.add(d);
    }
    if (_ingredients.isEmpty) _addIngredient();
    if (_steps.isEmpty) _addStep();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientDraft());
    });
  }

  bool get _isDirty =>
      _titleController.text.trim().isNotEmpty ||
      _ingredients.any((i) => i.nameController.text.trim().isNotEmpty) ||
      _steps.any((st) => st.instructionController.text.trim().isNotEmpty);

  /// Leaving with typed-in content asks first, so a half-written recipe is not lost by a stray back tap.
  Future<void> _confirmLeave(AppStrings strings) async {
    if (!mounted) return;
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.discardRecipeTitle),
        actions: [
          TextButton(
            key: const Key('discard_keep'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            key: const Key('discard_leave'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(strings.discardRecipeAction),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  // Removed rows stay alive (not disposed) until the screen closes so "Undo" can put them back.
  final List<Object> _removedDrafts = [];

  void _showUndo(VoidCallback undo) {
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(strings.itemRemoved),
        action: SnackBarAction(
          key: const Key('remove_undo'),
          label: strings.undoLabel,
          onPressed: undo,
        ),
      ));
  }

  void _removeIngredient(int index) {
    if (_ingredients.length > 1) {
      final removed = _ingredients[index];
      setState(() {
        _ingredients.removeAt(index);
        _removedDrafts.add(removed);
      });
      if (removed.nameController.text.trim().isNotEmpty ||
          removed.amountController.text.trim().isNotEmpty) {
        _showUndo(() {
          if (!mounted) return;
          setState(() {
            _removedDrafts.remove(removed);
            _ingredients.insert(index.clamp(0, _ingredients.length), removed);
          });
        });
      }
    }
  }

  void _addStep() {
    setState(() {
      _steps.add(_StepDraft());
    });
  }

  void _removeStep(int index) {
    if (_steps.length > 1) {
      final removed = _steps[index];
      setState(() {
        _steps.removeAt(index);
        _removedDrafts.add(removed);
      });
      if (removed.instructionController.text.trim().isNotEmpty) {
        _showUndo(() {
          if (!mounted) return;
          setState(() {
            _removedDrafts.remove(removed);
            _steps.insert(index.clamp(0, _steps.length), removed);
          });
        });
      }
    }
  }

  @override
  void dispose() {
    for (final d in _removedDrafts) {
      if (d is _IngredientDraft) d.dispose();
      if (d is _StepDraft) d.dispose();
    }
    _titleController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    for (final ing in _ingredients) {
      ing.dispose();
    }
    for (final step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) return;

    final strings = ref.read(appStringsProvider);
    final title = _titleController.text.trim();
    // Odd input (0, negative, huge) is kept in a sane range: servings of 0 would break scaling.
    final prepTime = (int.tryParse(_prepTimeController.text.trim()) ?? 15).clamp(0, 1440);
    final cookTime = (int.tryParse(_cookTimeController.text.trim()) ?? 25).clamp(0, 1440);
    final servings = (int.tryParse(_servingsController.text.trim()) ?? 4).clamp(1, 99);
    final imageUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : null;

    final List<Ingredient> parsedIngredients = [];
    final List<String> ingredientKeys = [];

    for (final draft in _ingredients) {
      final name = draft.nameController.text.trim();
      final amount = draft.amountController.text.trim();
      if (name.isNotEmpty) {
        parsedIngredients.add(
          Ingredient(
            name: name,
            amount: amount.isNotEmpty ? amount : '1',
            unit: draft.unit,
          ),
        );
        ingredientKeys.add(name.toLowerCase());
      }
    }

    if (parsedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(appStringsProvider).needIngredient)),
      );
      return;
    }

    final List<CookingStep> parsedSteps = [];
    int stepNumber = 1;
    for (final draft in _steps) {
      final instruction = draft.instructionController.text.trim();
      if (instruction.isNotEmpty) {
        final timer = (int.tryParse(draft.timerController.text.trim()) ?? 0).clamp(0, 600);
        final currentOrder = stepNumber++;
        parsedSteps.add(
          CookingStep(
            order: currentOrder,
            title: 'Adım $currentOrder',
            instruction: instruction,
            toolIcon: 'chefHat',
            timerSeconds: timer * 60,
            proTip: currentOrder == 1
                ? 'Kısık ateşte pişirerek lezzetini katlayabilirsiniz.'
                : '',
          ),
        );
      }
    }

    if (parsedSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(appStringsProvider).needStep)),
      );
      return;
    }

    final recipeId = widget.recipe?.id ?? 'custom_rec_${DateTime.now().millisecondsSinceEpoch}';
    final newRecipe = Recipe(
      id: recipeId,
      title: title,
      category: _selectedCategory,
      cuisine: _selectedCuisine,
      difficulty: _selectedDifficulty,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      imageUrl: imageUrl,
      ingredientKeys: ingredientKeys,
      ingredients: parsedIngredients,
      substitutions: widget.recipe?.substitutions ?? const [],
      steps: parsedSteps,
    );

    ref.read(customRecipesProvider.notifier).addRecipe(newRecipe);
    if (widget.recipe != null) {
      // An edit also updates the copies kept in Saved and in the meal plan.
      ref.read(savedRecipesProvider.notifier).refresh(newRecipe);
      ref.read(mealPlanProvider.notifier).refresh(newRecipe);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.recipePublishedSuccess),
        backgroundColor: const Color(0xFF059669),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Future.microtask(() => _confirmLeave(strings));
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.recipe == null ? strings.newRecipe : strings.editRecipe,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _saveRecipe,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(strings.publishRecipe),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // General Info Card
            _buildSectionCard(
              title: 'Temel Bilgiler',
              icon: Icons.restaurant_menu_rounded,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: strings.recipeTitle,
                    hintText: strings.enterRecipeTitle,
                    prefixIcon: const Icon(Icons.title_rounded, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? strings.recipeTitleRequired
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: strings.recipeCategory,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCategory = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCuisine,
                        decoration: InputDecoration(
                          labelText: strings.recipeCuisine,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _cuisines
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCuisine = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: strings.prepTimeMinutes,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _cookTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: strings.cookTimeMinutes,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: strings.servingsCount,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${strings.difficulty}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ..._difficulties.map((diff) {
                      final isSelected = _selectedDifficulty == diff;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            diff,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFFF5722),
                          onSelected: (val) {
                            if (val) setState(() => _selectedDifficulty = diff);
                          },
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: strings.imageUrlOptional,
                    prefixIcon: const Icon(Icons.image_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Ingredients Card
            _buildSectionCard(
              title: strings.ingredientsTitle,
              icon: Icons.egg_outlined,
              action: TextButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add, size: 16),
                label: Text(strings.addIngredient),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5722),
                ),
              ),
              children: [
                for (int i = 0; i < _ingredients.length; i++) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          controller: _ingredients[i].amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: strings.amountHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 125,
                        child: DropdownButtonFormField<String>(
                          isDense: true,
                          isExpanded: true,
                          initialValue: _ingredients[i].unit,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          items: _units
                              .map(
                                (u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(
                                    u,
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _ingredients[i].unit = v);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          controller: _ingredients[i].nameController,
                          decoration: InputDecoration(
                            hintText: strings.ingredientName,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      if (_ingredients.length > 1)
                        IconButton(
                          tooltip: ref
                              .read(appStringsProvider)
                              .shoppingDeleteItem,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () => _removeIngredient(i),
                        ),
                    ],
                  ),
                  if (i < _ingredients.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),

            const SizedBox(height: 18),

            // Cooking Steps Card
            _buildSectionCard(
              title: strings.stepsTitle,
              icon: Icons.format_list_numbered_rounded,
              action: TextButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add, size: 16),
                label: Text(strings.addStep),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5722),
                ),
              ),
              children: [
                for (int i = 0; i < _steps.length; i++) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFFF5722),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${strings.step} ${i + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            if (_steps.length > 1)
                              IconButton(
                                tooltip: ref
                                    .read(appStringsProvider)
                                    .shoppingDeleteItem,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeStep(i),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _steps[i].instructionController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: strings.stepInstruction,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.all(10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 140,
                              child: TextFormField(
                                controller: _steps[i].timerController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: strings.stepTimerOptional,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (i < _steps.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                strings.publishRecipe,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFFF5722)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: action,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
