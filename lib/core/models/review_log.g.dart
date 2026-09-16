// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewLogModel _$ReviewLogModelFromJson(Map<String, dynamic> json) =>
    _ReviewLogModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      cardId: json['card_id'] as String,
      rating: $enumDecode(_$ReviewRatingEnumMap, json['rating']),
      reviewTime: DateTime.parse(json['review_time'] as String),
      scheduledDays: (json['scheduled_days'] as num?)?.toInt() ?? 0,
      elapsedDays: (json['elapsed_days'] as num?)?.toInt() ?? 0,
      clientLogId: json['client_log_id'] as String? ?? '',
    );

Map<String, dynamic> _$ReviewLogModelToJson(_ReviewLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'card_id': instance.cardId,
      'rating': _$ReviewRatingEnumMap[instance.rating]!,
      'review_time': instance.reviewTime.toIso8601String(),
      'scheduled_days': instance.scheduledDays,
      'elapsed_days': instance.elapsedDays,
      'client_log_id': instance.clientLogId,
    };

const _$ReviewRatingEnumMap = {
  ReviewRating.again: 1,
  ReviewRating.hard: 2,
  ReviewRating.good: 3,
  ReviewRating.easy: 4,
};
