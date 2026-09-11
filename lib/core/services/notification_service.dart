import 'dart:async';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyReminderId = 1001;
  static const int streakSaverId = 1002;

  static const String dailyChannelId = 'flanki_daily_reminder';
  static const String streakChannelId = 'flanki_streak_saver';

  bool _isInitialized = false;
  void Function(String? payload)? _onNotificationClick;

  String currentLocaleCode = AppConfig.resolveSystemLocaleCode();

  /// Updates current locale for notification text generation.
  void updateLocale(String? code) {
    if (code != null && code.isNotEmpty) {
      currentLocaleCode = code.toLowerCase().startsWith('vi') ? 'vi' : 'en';
    }
  }

  /// Resolves AppLocalizations synchronously for any locale without BuildContext
  AppLocalizations getL10n([String? localeCode]) {
    return AppConfig.getL10n(localeCode ?? currentLocaleCode);
  }

  Timer? _desktopTimer;
  int? _lastDailyNotificationDay;
  int? _lastStreakSaverNotificationDay;

  /// Initializes timezones, notification channels, and notification plugins
  Future<void> init({
    void Function(String? payload)? onNotificationClick,
  }) async {
    if (_isInitialized) return;
    _onNotificationClick = onNotificationClick;

    // 1. Timezone setup
    try {
      tz_data.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('[NotificationService] Timezone init fallback: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Plugin settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Flanki',
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Flanki',
      appUserModelId: 'com.flanki.app',
      guid: 'a413114b-d67f-4a01-8b22-7f07a57623bf',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
          '[NotificationService] Notification tapped payload: ${response.payload}',
        );
        _onNotificationClick?.call(response.payload);
      },
    );

    _isInitialized = true;
  }

  /// Request permissions for Android 13+ and iOS/macOS
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final grantedNotif =
            await android?.requestNotificationsPermission() ?? false;
        await android?.requestExactAlarmsPermission();
        return grantedNotif;
      } else if (Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      } else if (Platform.isMacOS) {
        final macos = _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        final granted = await macos?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (_) {
      return false;
    }
    return true;
  }

  tz.Location get _safeLocation {
    try {
      return tz.local;
    } catch (_) {
      try {
        tz_data.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('UTC'));
        return tz.local;
      } catch (_) {
        return tz.UTC;
      }
    }
  }

  /// Calculates the next TZDateTime for the given hour & minute
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final location = _safeLocation;
    final tz.TZDateTime now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Duolingo Habit Reminder (Tier 1: Daily Reminder)
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required int dueCardsCount,
    String? localeCode,
  }) async {
    if (kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS)) {
      return;
    }

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    final l10n = getL10n(localeCode);
    final title = l10n.notificationDailyTitle;
    final body = dueCardsCount > 0
        ? l10n.notificationDailyBodyDue(dueCardsCount)
        : l10n.notificationDailyBodyGeneric;

    final androidDetails = AndroidNotificationDetails(
      dailyChannelId,
      l10n.notificationDailyChannelName,
      channelDescription: l10n.notificationDailyChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      windows: const WindowsNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id: dailyReminderId,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/decks',
      );
    } catch (e) {
      debugPrint('[NotificationService] scheduleDailyReminder error: $e');
    }
  }

  /// Duolingo Streak Saver (Tier 2: Urgent notification before midnight)
  Future<void> scheduleStreakSaver({
    required int streakDays,
    int hour = AppConfig.defaultStreakSaverHour,
    int minute = AppConfig.defaultStreakSaverMinute,
    String? localeCode,
  }) async {
    if (kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS)) {
      return;
    }

    final scheduledTime = _nextInstanceOfTime(hour, minute);
    final l10n = getL10n(localeCode);
    final title = streakDays > 0
        ? l10n.notificationStreakTitleActive(streakDays)
        : l10n.notificationStreakTitleInactive;
    final body = streakDays > 0
        ? l10n.notificationStreakBodyActive
        : l10n.notificationStreakBodyInactive;

    final androidDetails = AndroidNotificationDetails(
      streakChannelId,
      l10n.notificationStreakChannelName,
      channelDescription: l10n.notificationStreakChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      windows: const WindowsNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id: streakSaverId,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/decks',
      );
    } catch (e) {
      debugPrint('[NotificationService] scheduleStreakSaver error: $e');
    }
  }

  /// Called when user completes a study session today.
  /// Cancels tonight's Streak Saver alert immediately (Zero spam principle).
  Future<void> onStudyCompletedToday() async {
    try {
      await _plugin.cancel(id: streakSaverId);
      debugPrint(
        '[NotificationService] User studied today. Cancelled streak saver notification for tonight.',
      );
    } catch (e) {
      debugPrint('[NotificationService] Cancel streak saver error: $e');
    }
  }

  /// Cancel all scheduled study notifications
  Future<void> cancelAll() async {
    await _plugin.cancel(id: dailyReminderId);
    await _plugin.cancel(id: streakSaverId);
  }

  /// Starts periodic background timer for Desktop (Windows & Linux)
  void startDesktopScheduler({
    required ValueGetter<bool> isReminderEnabled,
    required ValueGetter<int> getReminderHour,
    required ValueGetter<int> getReminderMinute,
    required ValueGetter<bool> isStreakSaverEnabled,
    required ValueGetter<int> getStreakDays,
    required ValueGetter<int> getDueCardsCount,
    required ValueGetter<bool> hasStudiedToday,
    ValueGetter<int>? getStreakSaverHour,
    ValueGetter<int>? getStreakSaverMinute,
  }) {
    if (kIsWeb || (!Platform.isWindows && !Platform.isLinux)) return;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    _desktopTimer?.cancel();
    _desktopTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (!isReminderEnabled()) return;

      final now = DateTime.now();

      // 1. Check daily reminder
      final remHour = getReminderHour();
      final remMin = getReminderMinute();
      if (now.hour == remHour &&
          now.minute == remMin &&
          _lastDailyNotificationDay != now.day) {
        _lastDailyNotificationDay = now.day;
        final due = getDueCardsCount();
        final l10n = getL10n();
        await showInstantTestNotification(
          id: dailyReminderId,
          title: l10n.notificationDailyTitle,
          body: due > 0
              ? l10n.notificationDailyBodyDue(due)
              : l10n.notificationDailyBodyGeneric,
        );
      }

      // 2. Check streak saver
      final streakHour =
          getStreakSaverHour?.call() ?? AppConfig.defaultStreakSaverHour;
      final streakMin =
          getStreakSaverMinute?.call() ?? AppConfig.defaultStreakSaverMinute;
      if (isStreakSaverEnabled() &&
          now.hour == streakHour &&
          now.minute == streakMin &&
          _lastStreakSaverNotificationDay != now.day) {
        _lastStreakSaverNotificationDay = now.day;
        if (!hasStudiedToday()) {
          final streak = getStreakDays();
          final l10n = getL10n();
          await showInstantTestNotification(
            id: streakSaverId,
            title: streak > 0
                ? l10n.notificationStreakTitleActive(streak)
                : l10n.notificationStreakTitleInactive,
            body: streak > 0
                ? l10n.notificationStreakBodyActive
                : l10n.notificationStreakBodyInactive,
          );
        }
      }
    });
  }

  /// Stops desktop timer
  void stopDesktopScheduler() {
    _desktopTimer?.cancel();
    _desktopTimer = null;
  }

  /// Instant test notification for developer verification & desktop toasts
  Future<void> showInstantTestNotification({
    int id = 9999,
    String? title,
    String? body,
    String? localeCode,
  }) async {
    final l10n = getL10n(localeCode);
    final effectiveTitle = title ?? l10n.notificationTestTitle;
    final effectiveBody = body ?? l10n.notificationTestBody;

    final androidDetails = AndroidNotificationDetails(
      dailyChannelId,
      l10n.notificationDailyChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      windows: const WindowsNotificationDetails(),
    );

    await _plugin.show(
      id: id,
      title: effectiveTitle,
      body: effectiveBody,
      notificationDetails: details,
      payload: '/decks',
    );
  }
}
