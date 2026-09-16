import 'package:freezed_annotation/freezed_annotation.dart';

import 'card.dart';

part 'review_log.freezed.dart';
part 'review_log.g.dart';

@freezed
abstract class ReviewLogModel with _$ReviewLogModel {
  const ReviewLogModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ReviewLogModel({
    @Default(0) int id,
    required String cardId,
    required ReviewRating rating,
    required DateTime reviewTime,
    @Default(0) int scheduledDays,
    @Default(0) int elapsedDays,
    @Default('') String clientLogId,
  }) = _ReviewLogModel;

  factory ReviewLogModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewLogModelFromJson(json);
}
