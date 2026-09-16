// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GrammarProgressModel _$GrammarProgressModelFromJson(
  Map<String, dynamic> json,
) => _GrammarProgressModel(
  unitId: json['unit_id'] as String,
  exerciseId: json['exercise_id'] as String,
  stability: (json['stability'] as num?)?.toDouble() ?? 0.0,
  difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.0,
  due: json['due'] == null ? null : DateTime.parse(json['due'] as String),
  lastStudied: json['last_studied'] == null
      ? null
      : DateTime.parse(json['last_studied'] as String),
  reps: (json['reps'] as num?)?.toInt() ?? 0,
  lapses: (json['lapses'] as num?)?.toInt() ?? 0,
  state:
      $enumDecodeNullable(_$CardStateEnumMap, json['state']) ??
      CardState.newCard,
  isGhost: json['is_ghost'] as bool? ?? false,
  isCompleted: json['is_completed'] as bool? ?? false,
  lastUserAnswer: json['last_user_answer'] as String?,
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GrammarProgressModelToJson(
  _GrammarProgressModel instance,
) => <String, dynamic>{
  'unit_id': instance.unitId,
  'exercise_id': instance.exerciseId,
  'stability': instance.stability,
  'difficulty': instance.difficulty,
  'due': instance.due?.toIso8601String(),
  'last_studied': instance.lastStudied?.toIso8601String(),
  'reps': instance.reps,
  'lapses': instance.lapses,
  'state': _$CardStateEnumMap[instance.state]!,
  'is_ghost': instance.isGhost,
  'is_completed': instance.isCompleted,
  'last_user_answer': instance.lastUserAnswer,
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$CardStateEnumMap = {
  CardState.newCard: 0,
  CardState.learning: 1,
  CardState.review: 2,
  CardState.relearning: 3,
};
