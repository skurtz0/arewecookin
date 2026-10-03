import '../l10n/recipe_localization.dart';

class Ingredient {
  final String name;
  final String amount;
  final String unit;
  final bool isOptional;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.isOptional = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'isOptional': isOptional,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String? ?? '',
      amount: map['amount']?.toString() ?? '',
      unit: map['unit'] as String? ?? '',
      isOptional: map['isOptional'] as bool? ?? false,
    );
  }

  Ingredient copyWith({
    String? name,
    String? amount,
    String? unit,
    bool? isOptional,
  }) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  String get displayText {
    final parts = [amount, unit, name].where((s) => s.isNotEmpty);
    return parts.join(' ');
  }

  String localizedName(String locale) => RecipeLocalization.localizeIngredientName(name, locale);
  String localizedUnit(String locale) => RecipeLocalization.localizeUnit(unit, locale);
  String localizedDisplayText(String locale) {
    final u = localizedUnit(locale);
    final n = localizedName(locale);
    final parts = [amount, u, n].where((s) => s.isNotEmpty);
    return parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          amount == other.amount &&
          unit == other.unit &&
          isOptional == other.isOptional;

  @override
  int get hashCode =>
      name.hashCode ^ amount.hashCode ^ unit.hashCode ^ isOptional.hashCode;
}
