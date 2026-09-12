import 'package:json_annotation/json_annotation.dart';

import 'grammar_enums.dart';

part 'grammar_exercise.g.dart';

Object? _readExplanation(Map json, String key) =>
    json['explanation'] ?? const <String, dynamic>{};

@JsonSerializable()
class GrammarExplanation {
  static const empty = GrammarExplanation(
    translation: '',
    keySignal: '',
    rule: '',
    whyCorrect: '',
  );

  @JsonKey(defaultValue: '')
  final String translation;
  @JsonKey(defaultValue: '')
  final String keySignal;
  @JsonKey(defaultValue: '')
  final String rule;
  @JsonKey(defaultValue: '')
  final String whyCorrect;
  final Map<String, String> distractorBreakdown;

  const GrammarExplanation({
    required this.translation,
    required this.keySignal,
    required this.rule,
    required this.whyCorrect,
    this.distractorBreakdown = const {},
  });

  factory GrammarExplanation.fromJson(Map<String, dynamic> json) =>
      _$GrammarExplanationFromJson(json);

  Map<String, dynamic> toJson() => _$GrammarExplanationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GrammarExercise {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(unknownEnumValue: GrammarExerciseType.choice)
  final GrammarExerciseType type;
  @JsonKey(unknownEnumValue: GrammarDifficulty.recognition)
  final GrammarDifficulty difficulty;
  @JsonKey(defaultValue: '')
  final String prompt;
  @JsonKey(defaultValue: [])
  final List<String> options;
  @JsonKey(defaultValue: '')
  final String correctAnswer;
  @JsonKey(readValue: _readExplanation)
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

  factory GrammarExercise.fromJson(Map<String, dynamic> json) =>
      _$GrammarExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$GrammarExerciseToJson(this);
}
