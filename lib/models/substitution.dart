class Substitution {
  final String ingredient;
  final String alternative;
  final String tip;

  const Substitution({
    required this.ingredient,
    required this.alternative,
    required this.tip,
  });

  Map<String, dynamic> toMap() {
    return {
      'ingredient': ingredient,
      'alternative': alternative,
      'tip': tip,
    };
  }

  factory Substitution.fromMap(Map<String, dynamic> map) {
    return Substitution(
      ingredient: map['ingredient'] as String? ?? '',
      alternative: map['alternative'] as String? ?? '',
      tip: map['tip'] as String? ?? '',
    );
  }

  Substitution copyWith({
    String? ingredient,
    String? alternative,
    String? tip,
  }) {
    return Substitution(
      ingredient: ingredient ?? this.ingredient,
      alternative: alternative ?? this.alternative,
      tip: tip ?? this.tip,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Substitution &&
          runtimeType == other.runtimeType &&
          ingredient == other.ingredient &&
          alternative == other.alternative &&
          tip == other.tip;

  @override
  int get hashCode =>
      ingredient.hashCode ^ alternative.hashCode ^ tip.hashCode;
}
