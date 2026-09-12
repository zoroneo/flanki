// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrammarExplanation _$GrammarExplanationFromJson(Map<String, dynamic> json) =>
    GrammarExplanation(
      translation: json['translation'] as String? ?? '',
      keySignal: json['keySignal'] as String? ?? '',
      rule: json['rule'] as String? ?? '',
      whyCorrect: json['whyCorrect'] as String? ?? '',
      distractorBreakdown:
          (json['distractorBreakdown'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$GrammarExplanationToJson(GrammarExplanation instance) =>
    <String, dynamic>{
      'translation': instance.translation,
      'keySignal': instance.keySignal,
      'rule': instance.rule,
      'whyCorrect': instance.whyCorrect,
      'distractorBreakdown': instance.distractorBreakdown,
    };

GrammarExercise _$GrammarExerciseFromJson(Map<String, dynamic> json) =>
    GrammarExercise(
      id: json['id'] as String? ?? '',
      type: $enumDecode(
        _$GrammarExerciseTypeEnumMap,
        json['type'],
        unknownValue: GrammarExerciseType.choice,
      ),
      difficulty: $enumDecode(
        _$GrammarDifficultyEnumMap,
        json['difficulty'],
        unknownValue: GrammarDifficulty.recognition,
      ),
      prompt: json['prompt'] as String? ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      correctAnswer: json['correctAnswer'] as String? ?? '',
      explanation: GrammarExplanation.fromJson(
        _readExplanation(json, 'explanation') as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$GrammarExerciseToJson(GrammarExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$GrammarExerciseTypeEnumMap[instance.type]!,
      'difficulty': _$GrammarDifficultyEnumMap[instance.difficulty]!,
      'prompt': instance.prompt,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation.toJson(),
    };

const _$GrammarExerciseTypeEnumMap = {
  GrammarExerciseType.choice: 'choice',
  GrammarExerciseType.errorId: 'error_id',
  GrammarExerciseType.cloze: 'cloze',
};

const _$GrammarDifficultyEnumMap = {
  GrammarDifficulty.recognition: 1,
  GrammarDifficulty.analysis: 2,
  GrammarDifficulty.production: 3,
};
