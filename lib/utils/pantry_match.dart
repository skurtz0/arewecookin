import '../models/models.dart';

/// Light English plural folding so "tomato" and "tomatoes" match.
/// Applied to both sides of the comparison, so it only needs to be consistent.
String foldPlural(String s) {
  var t = s.trim().toLowerCase();
  if (t.length < 4) return t;
  // Turkish plural: domatesler -> domates, yumurtalar -> yumurta (long words only, to avoid false matches).
  if (t.length >= 7 && (t.endsWith('ler') || t.endsWith('lar'))) {
    t = t.substring(0, t.length - 3);
  }
  if (t.endsWith('ies')) return '${t.substring(0, t.length - 3)}y';
  if (t.endsWith('oes')) return t.substring(0, t.length - 2);
  if (t.endsWith('ss')) return t;
  if (t.endsWith('s')) return t.substring(0, t.length - 1);
  return t;
}

/// True when the ingredient's name (in any form the app knows) is one of the pantry [have] keys.
bool ingredientInPantry(Ingredient i, Set<String> have, String locale) {
  final folded = {for (final h in have) foldPlural(h)};
  return {
    i.name,
    i.localizedName(locale),
    if (i.nameEn != null) i.nameEn!,
  }.any((n) => folded.contains(foldPlural(n)));
}

/// How many of the recipe's ingredients are in the pantry.
int pantryCoverageCount(Recipe r, Set<String> have, String locale) =>
    r.ingredients.where((i) => ingredientInPantry(i, have, locale)).length;
