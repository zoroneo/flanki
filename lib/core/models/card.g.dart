// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardModel _$CardModelFromJson(Map<String, dynamic> json) => _CardModel(
  id: json['id'] as String,
  deckId: json['deck_id'] as String? ?? '',
  front: json['front'] as String? ?? '',
  back: json['back'] as String? ?? '',
  hint: json['hint'] as String?,
  noteType:
      $enumDecodeNullable(_$NoteTypeEnumMap, json['note_type']) ??
      NoteType.basic,
  flag: $enumDecodeNullable(_$CardFlagEnumMap, json['flag']) ?? CardFlag.none,
  isSuspended: json['is_suspended'] as bool? ?? false,
  isBuried: json['is_buried'] as bool? ?? false,
  tags: json['tags'] == null
      ? const []
      : const CardTagsConverter().fromJson(json['tags']),
  intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,
  stability: (json['stability'] as num?)?.toDouble() ?? 0.0,
  difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.0,
  reps: (json['reps'] as num?)?.toInt() ?? 0,
  lapses: (json['lapses'] as num?)?.toInt() ?? 0,
  due: json['due'] == null ? null : DateTime.parse(json['due'] as String),
  lastStudied: json['last_studied'] == null
      ? null
      : DateTime.parse(json['last_studied'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CardModelToJson(_CardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'front': instance.front,
      'back': instance.back,
      'hint': instance.hint,
      'note_type': _$NoteTypeEnumMap[instance.noteType]!,
      'flag': _$CardFlagEnumMap[instance.flag]!,
      'is_suspended': instance.isSuspended,
      'is_buried': instance.isBuried,
      'tags': const CardTagsConverter().toJson(instance.tags),
      'interval_days': instance.intervalDays,
      'stability': instance.stability,
      'difficulty': instance.difficulty,
      'reps': instance.reps,
      'lapses': instance.lapses,
      'due': instance.due?.toIso8601String(),
      'last_studied': instance.lastStudied?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$NoteTypeEnumMap = {
  NoteType.basic: 'basic',
  NoteType.cloze: 'cloze',
  NoteType.reversed: 'reversed',
};

const _$CardFlagEnumMap = {
  CardFlag.none: 0,
  CardFlag.red: 1,
  CardFlag.orange: 2,
  CardFlag.green: 3,
  CardFlag.blue: 4,
  CardFlag.pink: 5,
  CardFlag.turquoise: 6,
  CardFlag.purple: 7,
};
