// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudySettings _$StudySettingsFromJson(Map<String, dynamic> json) =>
    _StudySettings(
      fsrsEnabled: json['fsrsEnabled'] as bool? ?? true,
      desiredRetention:
          (json['desiredRetention'] as num?)?.toDouble() ??
          AppConfig.defaultDesiredRetention,
      newCardsPerDay:
          (json['newCardsPerDay'] as num?)?.toInt() ??
          AppConfig.defaultNewCardsPerDay,
      maxReviewsPerDay:
          (json['maxReviewsPerDay'] as num?)?.toInt() ??
          AppConfig.defaultReviewsPerDay,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderHour:
          (json['reminderHour'] as num?)?.toInt() ??
          AppConfig.defaultReminderHour,
      reminderMinute:
          (json['reminderMinute'] as num?)?.toInt() ??
          AppConfig.defaultReminderMinute,
      streakSaverEnabled: json['streakSaverEnabled'] as bool? ?? true,
      minimizeToTrayOnClose: json['minimizeToTrayOnClose'] as bool? ?? true,
      launchAtStartup: json['launchAtStartup'] as bool? ?? false,
    );

Map<String, dynamic> _$StudySettingsToJson(_StudySettings instance) =>
    <String, dynamic>{
      'fsrsEnabled': instance.fsrsEnabled,
      'desiredRetention': instance.desiredRetention,
      'newCardsPerDay': instance.newCardsPerDay,
      'maxReviewsPerDay': instance.maxReviewsPerDay,
      'reminderEnabled': instance.reminderEnabled,
      'reminderHour': instance.reminderHour,
      'reminderMinute': instance.reminderMinute,
      'streakSaverEnabled': instance.streakSaverEnabled,
      'minimizeToTrayOnClose': instance.minimizeToTrayOnClose,
      'launchAtStartup': instance.launchAtStartup,
    };
