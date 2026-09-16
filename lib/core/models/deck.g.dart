// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeckModel _$DeckModelFromJson(Map<String, dynamic> json) => _DeckModel(
  id: json['id'] as String,
  title: json['title'] as String? ?? 'Untitled Deck',
  description: json['description'] as String? ?? '',
  dueCount: (json['due_count'] as num?)?.toInt() ?? 0,
  newCount: (json['new_count'] as num?)?.toInt() ?? 0,
  totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
  lastStudied: json['last_studied'] == null
      ? null
      : DateTime.parse(json['last_studied'] as String),
);

Map<String, dynamic> _$DeckModelToJson(_DeckModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'due_count': instance.dueCount,
      'new_count': instance.newCount,
      'total_count': instance.totalCount,
      'last_studied': instance.lastStudied?.toIso8601String(),
    };
