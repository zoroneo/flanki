import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../services/desktop_window_service.dart';

class StudySettings {
  final bool fsrsEnabled;
  final double desiredRetention;
  final int newCardsPerDay;
  final int maxReviewsPerDay;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool streakSaverEnabled;
  final bool minimizeToTrayOnClose;
  final bool launchAtStartup;

  const StudySettings({
    this.fsrsEnabled = true,
    this.desiredRetention = AppConfig.defaultDesiredRetention,
    this.newCardsPerDay = AppConfig.defaultNewCardsPerDay,
    this.maxReviewsPerDay = AppConfig.defaultReviewsPerDay,
    this.reminderEnabled = true,
    this.reminderHour = AppConfig.defaultReminderHour,
    this.reminderMinute = AppConfig.defaultReminderMinute,
    this.streakSaverEnabled = true,
    this.minimizeToTrayOnClose = true,
    this.launchAtStartup = false,
  });

  StudySettings copyWith({
    bool? fsrsEnabled,
    double? desiredRetention,
    int? newCardsPerDay,
    int? maxReviewsPerDay,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? streakSaverEnabled,
    bool? minimizeToTrayOnClose,
    bool? launchAtStartup,
  }) {
    return StudySettings(
      fsrsEnabled: fsrsEnabled ?? this.fsrsEnabled,
      desiredRetention: desiredRetention ?? this.desiredRetention,
      newCardsPerDay: newCardsPerDay ?? this.newCardsPerDay,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      streakSaverEnabled: streakSaverEnabled ?? this.streakSaverEnabled,
      minimizeToTrayOnClose:
          minimizeToTrayOnClose ?? this.minimizeToTrayOnClose,
      launchAtStartup: launchAtStartup ?? this.launchAtStartup,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fsrsEnabled': fsrsEnabled,
      'desiredRetention': desiredRetention,
      'newCardsPerDay': newCardsPerDay,
      'maxReviewsPerDay': maxReviewsPerDay,
      'reminderEnabled': reminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'streakSaverEnabled': streakSaverEnabled,
      'minimizeToTrayOnClose': minimizeToTrayOnClose,
      'launchAtStartup': launchAtStartup,
    };
  }

  factory StudySettings.fromMap(Map<String, dynamic> map) {
    return StudySettings(
      fsrsEnabled: map['fsrsEnabled'] as bool? ?? true,
      desiredRetention: (map['desiredRetention'] as num?)?.toDouble() ??
          AppConfig.defaultDesiredRetention,
      newCardsPerDay: (map['newCardsPerDay'] as num?)?.toInt() ??
          AppConfig.defaultNewCardsPerDay,
      maxReviewsPerDay: (map['maxReviewsPerDay'] as num?)?.toInt() ??
          AppConfig.defaultReviewsPerDay,
      reminderEnabled: map['reminderEnabled'] as bool? ?? true,
      reminderHour: (map['reminderHour'] as num?)?.toInt() ??
          AppConfig.defaultReminderHour,
      reminderMinute: (map['reminderMinute'] as num?)?.toInt() ??
          AppConfig.defaultReminderMinute,
      streakSaverEnabled: map['streakSaverEnabled'] as bool? ?? true,
      minimizeToTrayOnClose: map['minimizeToTrayOnClose'] as bool? ?? true,
      launchAtStartup: map['launchAtStartup'] as bool? ?? false,
    );
  }
}

const String _kFsrsEnabledKey = 'settings_fsrs_enabled';
const String _kDesiredRetentionKey = 'settings_desired_retention';
const String _kNewCardsPerDayKey = 'settings_new_cards_per_day';
const String _kMaxReviewsPerDayKey = 'settings_max_reviews_per_day';
const String _kReminderEnabledKey = 'settings_reminder_enabled';
const String _kReminderHourKey = 'settings_reminder_hour';
const String _kReminderMinuteKey = 'settings_reminder_minute';
const String _kStreakSaverEnabledKey = 'settings_streak_saver_enabled';
const String _kMinimizeToTrayKey = 'settings_minimize_to_tray';
const String _kLaunchAtStartupKey = 'settings_launch_at_startup';

final studySettingsProvider =
    NotifierProvider<StudySettingsNotifier, StudySettings>(
  StudySettingsNotifier.new,
);

class StudySettingsNotifier extends Notifier<StudySettings> {
  final _storage = const FlutterSecureStorage();

  @override
  StudySettings build() {
    _loadPreferences();
    return const StudySettings();
  }

  Future<void> _loadPreferences() async {
    try {
      final fsrsVal = await _storage.read(key: _kFsrsEnabledKey);
      final retVal = await _storage.read(key: _kDesiredRetentionKey);
      final newCardsVal = await _storage.read(key: _kNewCardsPerDayKey);
      final maxReviewsVal = await _storage.read(key: _kMaxReviewsPerDayKey);
      final remEnabledVal = await _storage.read(key: _kReminderEnabledKey);
      final remHourVal = await _storage.read(key: _kReminderHourKey);
      final remMinVal = await _storage.read(key: _kReminderMinuteKey);
      final streakSaverVal = await _storage.read(key: _kStreakSaverEnabledKey);
      final minTrayVal = await _storage.read(key: _kMinimizeToTrayKey);
      final launchStartupVal = await _storage.read(key: _kLaunchAtStartupKey);

      final minTray = minTrayVal != null ? minTrayVal == 'true' : true;
      final launchStartup =
          launchStartupVal != null ? launchStartupVal == 'true' : false;

      state = StudySettings(
        fsrsEnabled: fsrsVal != null ? fsrsVal == 'true' : true,
        desiredRetention: retVal != null
            ? (double.tryParse(retVal) ?? AppConfig.defaultDesiredRetention)
            : AppConfig.defaultDesiredRetention,
        newCardsPerDay: newCardsVal != null
            ? (int.tryParse(newCardsVal) ?? AppConfig.defaultNewCardsPerDay)
            : AppConfig.defaultNewCardsPerDay,
        maxReviewsPerDay: maxReviewsVal != null
            ? (int.tryParse(maxReviewsVal) ?? AppConfig.defaultReviewsPerDay)
            : AppConfig.defaultReviewsPerDay,
        reminderEnabled: remEnabledVal != null ? remEnabledVal == 'true' : true,
        reminderHour: remHourVal != null
            ? (int.tryParse(remHourVal) ?? AppConfig.defaultReminderHour)
            : AppConfig.defaultReminderHour,
        reminderMinute: remMinVal != null
            ? (int.tryParse(remMinVal) ?? AppConfig.defaultReminderMinute)
            : AppConfig.defaultReminderMinute,
        streakSaverEnabled:
            streakSaverVal != null ? streakSaverVal == 'true' : true,
        minimizeToTrayOnClose: minTray,
        launchAtStartup: launchStartup,
      );

      DesktopWindowService.instance.minimizeToTrayOnClose = minTray;
      await DesktopWindowService.instance.setAutoStart(launchStartup);
    } catch (_) {}
  }

  Future<void> toggleFsrs(bool enabled) async {
    state = state.copyWith(fsrsEnabled: enabled);
    try {
      await _storage.write(
        key: _kFsrsEnabledKey,
        value: enabled ? 'true' : 'false',
      );
    } catch (_) {}
  }

  Future<void> setDesiredRetention(double retention) async {
    final clamped = retention.clamp(0.70, 0.97);
    state = state.copyWith(desiredRetention: clamped);
    try {
      await _storage.write(
        key: _kDesiredRetentionKey,
        value: clamped.toStringAsFixed(2),
      );
    } catch (_) {}
  }

  Future<void> setNewCardsPerDay(int count) async {
    final clamped = count.clamp(1, 200);
    state = state.copyWith(newCardsPerDay: clamped);
    try {
      await _storage.write(key: _kNewCardsPerDayKey, value: clamped.toString());
    } catch (_) {}
  }

  Future<void> setMaxReviewsPerDay(int count) async {
    final clamped = count.clamp(5, 1000);
    state = state.copyWith(maxReviewsPerDay: clamped);
    try {
      await _storage.write(
        key: _kMaxReviewsPerDayKey,
        value: clamped.toString(),
      );
    } catch (_) {}
  }

  Future<void> toggleReminder(bool enabled) async {
    state = state.copyWith(reminderEnabled: enabled);
    try {
      await _storage.write(
        key: _kReminderEnabledKey,
        value: enabled ? 'true' : 'false',
      );
    } catch (_) {}
  }

  Future<void> setReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    try {
      await _storage.write(key: _kReminderHourKey, value: hour.toString());
      await _storage.write(key: _kReminderMinuteKey, value: minute.toString());
    } catch (_) {}
  }

  Future<void> toggleStreakSaver(bool enabled) async {
    state = state.copyWith(streakSaverEnabled: enabled);
    try {
      await _storage.write(
        key: _kStreakSaverEnabledKey,
        value: enabled ? 'true' : 'false',
      );
    } catch (_) {}
  }

  Future<void> toggleMinimizeToTray(bool enabled) async {
    state = state.copyWith(minimizeToTrayOnClose: enabled);
    DesktopWindowService.instance.minimizeToTrayOnClose = enabled;
    try {
      await _storage.write(
        key: _kMinimizeToTrayKey,
        value: enabled ? 'true' : 'false',
      );
    } catch (_) {}
  }

  Future<void> toggleLaunchAtStartup(bool enabled) async {
    state = state.copyWith(launchAtStartup: enabled);
    await DesktopWindowService.instance.setAutoStart(enabled);
    try {
      await _storage.write(
        key: _kLaunchAtStartupKey,
        value: enabled ? 'true' : 'false',
      );
    } catch (_) {}
  }

  Future<void> updateSettings(StudySettings settings) async {
    state = settings;
    DesktopWindowService.instance.minimizeToTrayOnClose =
        settings.minimizeToTrayOnClose;
    await DesktopWindowService.instance.setAutoStart(settings.launchAtStartup);
    try {
      await _storage.write(
        key: _kFsrsEnabledKey,
        value: settings.fsrsEnabled ? 'true' : 'false',
      );
      await _storage.write(
        key: _kDesiredRetentionKey,
        value: settings.desiredRetention.toStringAsFixed(2),
      );
      await _storage.write(
        key: _kNewCardsPerDayKey,
        value: settings.newCardsPerDay.toString(),
      );
      await _storage.write(
        key: _kMaxReviewsPerDayKey,
        value: settings.maxReviewsPerDay.toString(),
      );
      await _storage.write(
        key: _kReminderEnabledKey,
        value: settings.reminderEnabled ? 'true' : 'false',
      );
      await _storage.write(
        key: _kReminderHourKey,
        value: settings.reminderHour.toString(),
      );
      await _storage.write(
        key: _kReminderMinuteKey,
        value: settings.reminderMinute.toString(),
      );
      await _storage.write(
        key: _kStreakSaverEnabledKey,
        value: settings.streakSaverEnabled ? 'true' : 'false',
      );
      await _storage.write(
        key: _kMinimizeToTrayKey,
        value: settings.minimizeToTrayOnClose ? 'true' : 'false',
      );
      await _storage.write(
        key: _kLaunchAtStartupKey,
        value: settings.launchAtStartup ? 'true' : 'false',
      );
    } catch (_) {}
  }
}

final fsrsEnabledProvider = NotifierProvider<FsrsEnabledNotifier, bool>(
  FsrsEnabledNotifier.new,
);

class FsrsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(studySettingsProvider).fsrsEnabled;
  }

  Future<void> toggle(bool enabled) async {
    await ref.read(studySettingsProvider.notifier).toggleFsrs(enabled);
  }
}
