import '../models/models.dart';

/// True when the ingredient's name (in any form the app knows) is one of the pantry [have] keys.
bool ingredientInPantry(Ingredient i, Set<String> have, String locale) => {
      i.name.trim().toLowerCase(),
      i.localizedName(locale).trim().toLowerCase(),
      if (i.nameEn != null) i.nameEn!.trim().toLowerCase(),
    }.any(have.contains);

/// How many of the recipe's ingredients are in the pantry.
int pantryCoverageCount(Recipe r, Set<String> have, String locale) =>
    r.ingredients.where((i) => ingredientInPantry(i, have, locale)).length;
