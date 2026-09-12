import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/config/app_config.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

@freezed
abstract class StudySettings with _$StudySettings {
  const StudySettings._();

  const factory StudySettings({
    @Default(true) bool fsrsEnabled,
    @Default(AppConfig.defaultDesiredRetention) double desiredRetention,
    @Default(AppConfig.defaultNewCardsPerDay) int newCardsPerDay,
    @Default(AppConfig.defaultReviewsPerDay) int maxReviewsPerDay,
    @Default(true) bool reminderEnabled,
    @Default(AppConfig.defaultReminderHour) int reminderHour,
    @Default(AppConfig.defaultReminderMinute) int reminderMinute,
    @Default(true) bool streakSaverEnabled,
    @Default(true) bool minimizeToTrayOnClose,
    @Default(false) bool launchAtStartup,
  }) = _StudySettings;

  factory StudySettings.fromJson(Map<String, dynamic> json) =>
      _$StudySettingsFromJson(json);

  Map<String, dynamic> toMap() => toJson();

  factory StudySettings.fromMap(Map<String, dynamic> map) =>
      StudySettings.fromJson(map);
}
