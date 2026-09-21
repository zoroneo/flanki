// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_payloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushMutationsResponseDto _$PushMutationsResponseDtoFromJson(
  Map<String, dynamic> json,
) => PushMutationsResponseDto(
  ackIds:
      (json['ack_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  serverTimestamp: json['server_timestamp'] as String?,
  processedCount: (json['processed_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$PushMutationsResponseDtoToJson(
  PushMutationsResponseDto instance,
) => <String, dynamic>{
  'ack_ids': instance.ackIds,
  'server_timestamp': instance.serverTimestamp,
  'processed_count': instance.processedCount,
};

PullDeltasResponseDto _$PullDeltasResponseDtoFromJson(
  Map<String, dynamic> json,
) => PullDeltasResponseDto(
  decks:
      (json['decks'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      [],
  cards:
      (json['cards'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      [],
  reviewLogs:
      (json['review_logs'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      [],
  grammarProgress:
      (json['grammar_progress'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      [],
  examSubmissions:
      (json['exam_submissions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      [],
  wrongQuestions:
      (json['wrong_questions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      [],
  userMedia:
      (json['user_media'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      [],
);

Map<String, dynamic> _$PullDeltasResponseDtoToJson(
  PullDeltasResponseDto instance,
) => <String, dynamic>{
  'decks': instance.decks,
  'cards': instance.cards,
  'review_logs': instance.reviewLogs,
  'grammar_progress': instance.grammarProgress,
  'exam_submissions': instance.examSubmissions,
  'wrong_questions': instance.wrongQuestions,
  'user_media': instance.userMedia,
};

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

_OutboxItemPayload _$OutboxItemPayloadFromJson(Map<String, dynamic> json) =>
    _OutboxItemPayload(
      id: json['id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      op: json['op'] as String,
      isDeleted: json['is_deleted'] as bool,
      payload: json['payload'],
      hlc: json['hlc'] as String,
    );

Map<String, dynamic> _$OutboxItemPayloadToJson(_OutboxItemPayload instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entity_type': instance.entityType,
      'entity_id': instance.entityId,
      'op': instance.op,
      'is_deleted': instance.isDeleted,
      'payload': instance.payload,
      'hlc': instance.hlc,
    };
