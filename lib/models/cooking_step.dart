import '../l10n/recipe_localization.dart';

class CookingStep {
  final int order;
  final String title;
  final String instruction;
  final String toolIcon;
  final int timerSeconds;
  final String proTip;
  final List<String> stepIngredients;
  /// Hand-written English text (curated recipes). Null = fall back to generic localization.
  final String? titleEn;
  final String? instructionEn;
  final String? proTipEn;

  const CookingStep({
    required this.order,
    required this.title,
    required this.instruction,
    required this.toolIcon,
    this.timerSeconds = 0,
    this.proTip = '',
    this.stepIngredients = const [],
    this.titleEn,
    this.instructionEn,
    this.proTipEn,
  });

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'title': title,
      'instruction': instruction,
      'toolIcon': toolIcon,
      'timerSeconds': timerSeconds,
      'proTip': proTip,
      'stepIngredients': stepIngredients,
      if (titleEn != null) 'titleEn': titleEn,
      if (instructionEn != null) 'instructionEn': instructionEn,
      if (proTipEn != null) 'proTipEn': proTipEn,
    };
  }

  factory CookingStep.fromMap(Map<String, dynamic> map) {
    return CookingStep(
      order: (map['order'] as num?)?.toInt() ?? 1,
      title: map['title'] as String? ?? '',
      instruction: map['instruction'] as String? ?? '',
      toolIcon: map['toolIcon'] as String? ?? 'utensils',
      timerSeconds: (map['timerSeconds'] as num?)?.toInt() ?? 0,
      proTip: map['proTip'] as String? ?? '',
      stepIngredients: (map['stepIngredients'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      titleEn: map['titleEn'] as String?,
      instructionEn: map['instructionEn'] as String?,
      proTipEn: map['proTipEn'] as String?,
    );
  }

  CookingStep copyWith({
    int? order,
    String? title,
    String? instruction,
    String? toolIcon,
    int? timerSeconds,
    String? proTip,
    List<String>? stepIngredients,
  }) {
    return CookingStep(
      order: order ?? this.order,
      title: title ?? this.title,
      instruction: instruction ?? this.instruction,
      toolIcon: toolIcon ?? this.toolIcon,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      proTip: proTip ?? this.proTip,
      stepIngredients: stepIngredients ?? this.stepIngredients,
      titleEn: titleEn,
      instructionEn: instructionEn,
      proTipEn: proTipEn,
    );
  }

  bool _tr(String l) => RecipeLocalization.isTurkish(l);
  String localizedTitle(String locale) =>
      (!_tr(locale) && titleEn != null) ? titleEn! : RecipeLocalization.localizeStepTitle(title, locale);
  String localizedInstruction(String locale, [String? dishName]) =>
      (!_tr(locale) && instructionEn != null) ? instructionEn! : RecipeLocalization.localizeStepInstruction(instruction, locale, dishName);
  String localizedProTip(String locale) =>
      (!_tr(locale) && proTipEn != null) ? proTipEn! : RecipeLocalization.localizeProTip(proTip, locale);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CookingStep &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          title == other.title &&
          instruction == other.instruction &&
          toolIcon == other.toolIcon &&
          timerSeconds == other.timerSeconds &&
          proTip == other.proTip;

  @override
  int get hashCode =>
      order.hashCode ^
      title.hashCode ^
      instruction.hashCode ^
      toolIcon.hashCode ^
      timerSeconds.hashCode ^
      proTip.hashCode;
}
