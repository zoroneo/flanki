import 'grammar_enums.dart';

class GrammarExplanation {
  final String translation;
  final String keySignal;
  final String rule;
  final String whyCorrect;
  final Map<String, String> distractorBreakdown;

  const GrammarExplanation({
    required this.translation,
    required this.keySignal,
    required this.rule,
    required this.whyCorrect,
    this.distractorBreakdown = const {},
  });

  factory GrammarExplanation.fromJson(Map<String, dynamic> json) {
    final rawDistractors = json['distractorBreakdown'];
    final breakdown = <String, String>{};
    if (rawDistractors is Map) {
      rawDistractors.forEach((key, value) {
        breakdown[key.toString()] = value?.toString() ?? '';
      });
    }

    return GrammarExplanation(
      translation: json['translation'] as String? ?? '',
      keySignal: json['keySignal'] as String? ?? '',
      rule: json['rule'] as String? ?? '',
      whyCorrect: json['whyCorrect'] as String? ?? '',
      distractorBreakdown: breakdown,
    );
  }

  Map<String, dynamic> toJson() => {
        'translation': translation,
        'keySignal': keySignal,
        'rule': rule,
        'whyCorrect': whyCorrect,
        'distractorBreakdown': distractorBreakdown,
      };
}

class GrammarExercise {
  final String id;
  final GrammarExerciseType type;
  final GrammarDifficulty difficulty;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final GrammarExplanation explanation;

  const GrammarExercise({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory GrammarExercise.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final optionsList = <String>[];
    if (rawOptions is List) {
      for (final opt in rawOptions) {
        optionsList.add(opt?.toString() ?? '');
      }
    }

    return GrammarExercise(
      id: json['id'] as String? ?? '',
      type: GrammarExerciseType.fromString(json['type'] as String?),
      difficulty: GrammarDifficulty.fromValue(json['difficulty']),
      prompt: json['prompt'] as String? ?? '',
      options: optionsList,
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: GrammarExplanation.fromJson(
        json['explanation'] is Map<String, dynamic>
            ? json['explanation'] as Map<String, dynamic>
            : {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.value,
        'difficulty': difficulty.value,
        'prompt': prompt,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation.toJson(),
      };
}
