class CookingStep {
  final int order;
  final String title;
  final String instruction;
  final String toolIcon;
  final int timerSeconds;
  final String proTip;

  const CookingStep({
    required this.order,
    required this.title,
    required this.instruction,
    required this.toolIcon,
    this.timerSeconds = 0,
    this.proTip = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'title': title,
      'instruction': instruction,
      'toolIcon': toolIcon,
      'timerSeconds': timerSeconds,
      'proTip': proTip,
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
    );
  }

  CookingStep copyWith({
    int? order,
    String? title,
    String? instruction,
    String? toolIcon,
    int? timerSeconds,
    String? proTip,
  }) {
    return CookingStep(
      order: order ?? this.order,
      title: title ?? this.title,
      instruction: instruction ?? this.instruction,
      toolIcon: toolIcon ?? this.toolIcon,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      proTip: proTip ?? this.proTip,
    );
  }

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
