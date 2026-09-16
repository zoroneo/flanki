// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_payloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncIdPayload _$SyncIdPayloadFromJson(Map<String, dynamic> json) =>
    _SyncIdPayload(id: json['id'] as String);

Map<String, dynamic> _$SyncIdPayloadToJson(_SyncIdPayload instance) =>
    <String, dynamic>{'id': instance.id};

_GrammarUnitDeletePayload _$GrammarUnitDeletePayloadFromJson(
  Map<String, dynamic> json,
) => _GrammarUnitDeletePayload(
  unitId: json['unit_id'] as String,
  exerciseId: json['exercise_id'] as String,
);

Map<String, dynamic> _$GrammarUnitDeletePayloadToJson(
  _GrammarUnitDeletePayload instance,
) => <String, dynamic>{
  'unit_id': instance.unitId,
  'exercise_id': instance.exerciseId,
};

_WrongQuestionStatusPayload _$WrongQuestionStatusPayloadFromJson(
  Map<String, dynamic> json,
) => _WrongQuestionStatusPayload(
  id: json['id'] as String,
  status: json['status'] as String,
  updatedAt: json['updated_at'] as String,
  explanation: json['explanation'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$WrongQuestionStatusPayloadToJson(
  _WrongQuestionStatusPayload instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'updated_at': instance.updatedAt,
  'explanation': instance.explanation,
  'notes': instance.notes,
};
