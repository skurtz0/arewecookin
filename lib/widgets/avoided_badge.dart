import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../models/models.dart';
import '../providers/avoided_ingredients_provider.dart';
import '../repositories/recipe_repository.dart';

/// Small red warning shown when a recipe contains a word from "Ingredients I avoid".
/// Renders nothing otherwise, so it is safe to drop into any card or row.
class AvoidedBadge extends ConsumerWidget {
  final Recipe recipe;
  const AvoidedBadge({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hits = [
      for (final w in ref.watch(avoidedIngredientsProvider))
        if (RecipeRepository.mentionsWord(recipe, w)) w,
    ];
    if (hits.isEmpty) return const SizedBox.shrink();
    final strings = ref.watch(appStringsProvider);
    final text = hits.join(', ');
    return Semantics(
      label: strings.avoidedWarning(text),
      excludeSemantics: true,
      child: Row(
        key: Key('avoided_badge_${recipe.id}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
