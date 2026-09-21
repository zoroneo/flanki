import 'package:freezed_annotation/freezed_annotation.dart';

import '../config/app_config.dart';

part 'deck.freezed.dart';
part 'deck.g.dart';

@freezed
abstract class DeckModel with _$DeckModel {
  const DeckModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DeckModel({
    required String id,
    @Default('Untitled Deck') String title,
    @Default('') String description,
    @Default(0) int dueCount,
    @Default(0) int newCount,
    @Default(0) int totalCount,
    DateTime? lastStudied,
    @Default(true) bool isSyncEnabled,
  }) = _DeckModel;

  factory DeckModel.fromJson(Map<String, dynamic> json) =>
      _$DeckModelFromJson(json);

  bool get isCram =>
      id.startsWith(IdHelper.prefixCram) ||
      title.startsWith('⚡') ||
      title.toLowerCase().contains(IdHelper.prefixCram);
}
