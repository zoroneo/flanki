import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_payloads.freezed.dart';
part 'sync_payloads.g.dart';

@freezed
abstract class SyncIdPayload with _$SyncIdPayload {
  const SyncIdPayload._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SyncIdPayload({required String id}) = _SyncIdPayload;

  factory SyncIdPayload.fromJson(Map<String, dynamic> json) =>
      _$SyncIdPayloadFromJson(json);
}

@freezed
abstract class GrammarUnitDeletePayload with _$GrammarUnitDeletePayload {
  const GrammarUnitDeletePayload._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory GrammarUnitDeletePayload({
    required String unitId,
    required String exerciseId,
  }) = _GrammarUnitDeletePayload;

  factory GrammarUnitDeletePayload.fromJson(Map<String, dynamic> json) =>
      _$GrammarUnitDeletePayloadFromJson(json);
}

@freezed
abstract class WrongQuestionStatusPayload with _$WrongQuestionStatusPayload {
  const WrongQuestionStatusPayload._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory WrongQuestionStatusPayload({
    required String id,
    required String status,
    required String updatedAt,
    String? explanation,
    String? notes,
  }) = _WrongQuestionStatusPayload;

  factory WrongQuestionStatusPayload.fromJson(Map<String, dynamic> json) =>
      _$WrongQuestionStatusPayloadFromJson(json);
}

@freezed
abstract class OutboxItemPayload with _$OutboxItemPayload {
  const OutboxItemPayload._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OutboxItemPayload({
    required String id,
    required String entityType,
    required String entityId,
    required String op,
    required bool isDeleted,
    required dynamic payload,
    required String hlc,
  }) = _OutboxItemPayload;

  factory OutboxItemPayload.fromJson(Map<String, dynamic> json) =>
      _$OutboxItemPayloadFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PushMutationsResponseDto {
  final List<String> ackIds;
  final String? serverTimestamp;
  final int? processedCount;

  const PushMutationsResponseDto({
    this.ackIds = const [],
    this.serverTimestamp,
    this.processedCount,
  });

  factory PushMutationsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PushMutationsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PushMutationsResponseDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PullDeltasResponseDto {
  @JsonKey(defaultValue: [])
  final List<Map<String, dynamic>> decks;
  @JsonKey(defaultValue: [])
  final List<Map<String, dynamic>> cards;
  @JsonKey(defaultValue: [])
  final List<Map<String, dynamic>> reviewLogs;
  @JsonKey(defaultValue: [])
  final List<Map<String, dynamic>> grammarProgress;
  @JsonKey(defaultValue: [])
  final List<Map<String, dynamic>> examSubmissions;
  @JsonKey(defaultValue: [])
  final List<Map<String, dynamic>> wrongQuestions;
  @JsonKey(defaultValue: [])
  final List<Map<String, dynamic>> userMedia;

  const PullDeltasResponseDto({
    this.decks = const [],
    this.cards = const [],
    this.reviewLogs = const [],
    this.grammarProgress = const [],
    this.examSubmissions = const [],
    this.wrongQuestions = const [],
    this.userMedia = const [],
  });

  factory PullDeltasResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PullDeltasResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PullDeltasResponseDtoToJson(this);
}
