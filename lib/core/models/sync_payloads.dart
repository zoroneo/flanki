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
