import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../../l10n/generated/app_localizations.dart';
import '../gen/assets.gen.dart';

/// Centralized application configuration and metadata.
class AppConfig {
  static const String appName = 'Flanki';

  /// Returns display application name with prefix in debug/profile modes.
  static String get displayAppName {
    if (kDebugMode) return '[DEBUG] $appName';
    if (kProfileMode) return '[PROFILE] $appName';
    return appName;
  }

  static const String appDatabaseBaseName = 'flanki';
  static const String appMediaBaseDirectory = 'flanki_media';

  /// Isolated SQLite database name per build mode (Debug / Profile / Release)
  static String get databaseName {
    if (kDebugMode) return '${appDatabaseBaseName}_debug';
    if (kProfileMode) return '${appDatabaseBaseName}_profile';
    return appDatabaseBaseName;
  }

  /// Isolated media directory name per build mode (Debug / Profile / Release)
  static String get mediaDirectoryName {
    if (kDebugMode) return '${appMediaBaseDirectory}_debug';
    if (kProfileMode) return '${appMediaBaseDirectory}_profile';
    return appMediaBaseDirectory;
  }

  static const String defaultVersion = '1.1.5';
  static const int defaultBuildNumber = 14;

  /// Centralized supported locales and default fallback
  static const String localeCodeVi = 'vi';
  static const String localeCodeEn = 'en';
  static const Locale defaultLocale = Locale(localeCodeVi);
  static const List<Locale> supportedLocales = [
    Locale(localeCodeVi),
    Locale(localeCodeEn),
  ];

  /// Resolves standard language code ('vi' or 'en') from system platform.
  static String resolveSystemLocaleCode() {
    try {
      return Platform.localeName.toLowerCase().startsWith(localeCodeVi)
          ? localeCodeVi
          : localeCodeEn;
    } catch (_) {
      return defaultLocale.languageCode;
    }
  }

  /// Synchronously gets AppLocalizations without BuildContext (for background services)
  static AppLocalizations getL10n([String? localeCode]) {
    final code = localeCode ?? resolveSystemLocaleCode();
    try {
      return lookupAppLocalizations(Locale(code));
    } catch (_) {
      return lookupAppLocalizations(defaultLocale);
    }
  }

  /// Centralized timeouts and durations
  static const Duration updateCheckTimeout = Duration(seconds: 10);
  static const Duration toastLongDuration = Duration(seconds: 20);
  static const Duration toastDefaultDuration = Duration(seconds: 4);
  static const Duration defaultRelearnStep = Duration(minutes: 10);

  /// Centralized sync scheduling and clock drift thresholds
  static const Duration defaultSyncPeriodicInterval = Duration(minutes: 5);
  static const Duration defaultSyncDebounceDuration = Duration(seconds: 2);
  static const int defaultMaxClockDriftMillis = 60000;

  static String _version = defaultVersion;
  static int _buildNumber = defaultBuildNumber;

  static String get version => _version;
  static int get buildNumber => _buildNumber;

  /// Full version string (e.g. "1.0.6+7")
  static String get fullVersion => '$version+$buildNumber';

  /// Allows updating runtime version from platform package metadata
  static void updateRuntimeVersion({
    required String version,
    int? buildNumber,
  }) {
    _version = version;
    if (buildNumber != null) {
      _buildNumber = buildNumber;
    }
  }

  /// Resets version to defaults (useful for testing)
  static void resetVersion() {
    _version = defaultVersion;
    _buildNumber = defaultBuildNumber;
  }

  /// GitHub repository metadata for desktop update checks
  static const String githubRepoOwner = String.fromEnvironment(
    'GITHUB_REPO_OWNER',
    defaultValue: 'zoroneo',
  );
  static const String githubRepoName = String.fromEnvironment(
    'GITHUB_REPO_NAME',
    defaultValue: 'flanki',
  );

  /// GitHub Releases API URL
  static String get githubReleasesApiUrl =>
      'https://api.github.com/repos/$githubRepoOwner/$githubRepoName/releases/latest';

  /// GitHub Releases web page URL
  static String get githubReleasesUrl =>
      'https://github.com/$githubRepoOwner/$githubRepoName/releases';

  /// GitHub API headers and user agents
  static const String desktopUpdaterUserAgent = 'Flanki-Desktop-Updater';
  static const String githubApiAcceptHeader = 'application/vnd.github+json';

  /// Default study session limits & retention
  static const int defaultNewCardsPerDay = 20;
  static const int defaultReviewsPerDay = 100;
  static const int defaultCramLimit = 50;
  static const double defaultDesiredRetention = 0.90;
  static const double minDesiredRetention = 0.70;
  static const double maxDesiredRetention = 0.97;
  static const int minNewCardsPerDay = 1;
  static const int maxNewCardsPerDay = 200;
  static const int minReviewsPerDay = 5;
  static const int maxReviewsPerDay = 1000;
  static const int defaultReminderHour = 20;
  static const int defaultReminderMinute = 0;

  /// Default streak saver time (Tier 2 evening reminder)
  static const int defaultStreakSaverHour = 22;
  static const int defaultStreakSaverMinute = 30;

  /// Fallback study time calculation (seconds per card)
  static const int fallbackSecondsPerCard = 15;

  /// Card study duration tracking boundaries (in seconds)
  static const int minTrackedStudySeconds = 1;
  static const int maxTrackedStudySeconds = 120;

  /// Activity heatmap thresholds (reviews per day)
  static const int heatmapLevel1Threshold = 1;
  static const int heatmapLevel2Threshold = 4;
  static const int heatmapLevel3Threshold = 10;
  static const int heatmapTotalWeeks = 16;

  /// Anki SQLite schema and scheduling constants
  static const int ankiColSchemaVersion = 11;
  static const int defaultAnkiFactor = 2500;
  static const int minAnkiFactor = 1300;
  static const int maxAnkiFactor = 3000;
  static const int ankiRevlogTypeReview = 1;
  static const int ankiSyncUsnModified = -1;

  /// Asset paths
  static String get desktopIconWindows => Assets.icons.appIconIco;
  static String get desktopIconDefault => Assets.icons.appIconPng.path;
  static String get sampleMockExamAssetPath => Assets.data.exams.jlptN3Mock01;
  static const String grammarAssetDir = 'assets/data/grammar';

  /// Temp and database file markers
  static const String tempApkgPrefix = 'flanki_apkg_';
  static const String tempExportPrefix = 'flanki_export_';
  static const String anki2DbFileName = 'collection.anki2';
  static const String anki21DbFileName = 'collection.anki21';
  static const String ankiMediaFileName = 'media';
  static const String ankiSyncTemplateFileName = 'sync_template.anki2';
  static const String sqliteHeaderMarker = 'SQLite format 3';

  /// Local Drift Database schema and defaults
  static const int currentDatabaseSchemaVersion = 4;
  static const String defaultNoteType = 'basic';
  static const String defaultQuestionStatus = 'new';

  /// Notification and OS integration metadata
  static const String androidNotificationIcon = '@mipmap/ic_launcher';
  static const String linuxNotificationActionName = 'Open Flanki';
  static const String windowsNotificationGuid =
      'a413114b-d67f-4a01-8b22-7f07a57623bf';
  static const String windowsNotificationAppUserModelId = 'com.flanki.app';
  static const String defaultNotificationPayload = '/decks';

  /// Secure Storage keys
  static const String storageKeyUserLocale = 'user_selected_locale';
  static const String storageKeyThemeMode = 'user_selected_theme_mode';
  static const String storageKeyAnkiWebHostKey = 'flanki_ankiweb_hostkey';
  static const String storageKeyAnkiWebEmail = 'flanki_ankiweb_email';
  static const String storageKeyAnkiWebLastSync = 'flanki_ankiweb_last_sync';
  static const String storageKeyFsrsEnabled = 'settings_fsrs_enabled';
  static const String storageKeyDesiredRetention = 'settings_desired_retention';
  static const String storageKeyNewCardsPerDay = 'settings_new_cards_per_day';
  static const String storageKeyMaxReviewsPerDay =
      'settings_max_reviews_per_day';
  static const String storageKeyReminderEnabled = 'settings_reminder_enabled';
  static const String storageKeyReminderHour = 'settings_reminder_hour';
  static const String storageKeyReminderMinute = 'settings_reminder_minute';
  static const String storageKeyStreakSaverEnabled =
      'settings_streak_saver_enabled';
  static const String storageKeyMinimizeToTray = 'settings_minimize_to_tray';
  static const String storageKeyLaunchAtStartup = 'settings_launch_at_startup';

  /// Anki Reverse-Engineering and parser heuristics
  static const int ankiDueEpochThreshold = 1000000000;
  static const int ankiDefaultHintFieldIndex = 2;
  static const String clozeTypeMarker = 'cloze';
  static const String clozeDeletionTag = '{{c';
  static const String customTagAnkiSound = 'anki-sound';
  static const String customTagAnkiTypeResult = 'anki-type-result';

  /// Notification IDs
  static const int testNotificationId = 9999;

  /// Responsive screen breakpoint thresholds
  static const double desktopBreakpoint = 1024;
  static const double tabletBreakpoint = 600;
  static const double watchBreakpoint = 200;

  /// Native FFI dynamic library names (Anki Rust Bridge)
  static const String nativeLibWindows = 'anki_bridge.dll';
  static const String nativeLibDarwin = 'libanki_bridge.dylib';
  static const String nativeLibLinux = 'libanki_bridge.so';

  /// Platform method channel & updater calls
  static const String appUpdaterMethodChannel = 'com.flanki.flanki/app_updater';
  static const String methodOpenUrl = 'openUrl';
  static const String methodInstallApk = 'installApk';
  static const String paramUrl = 'url';
  static const String paramFilePath = 'filePath';

  /// System CLI executables & launch arguments
  static const String cliCmd = 'cmd';
  static const List<String> cliCmdStartArgs = ['/c', 'start', ''];
  static const String cliExplorer = 'explorer.exe';
  static const String cliSelectArg = '/select,';
  static const String cliOpen = 'open';
  static const String cliXdgOpen = 'xdg-open';

  /// Package file extensions & platform matching tokens for updates
  static const String extExe = '.exe';
  static const String extMsi = '.msi';
  static const String extZip = '.zip';
  static const String extDmg = '.dmg';
  static const String extAppImage = '.appimage';
  static const String extDeb = '.deb';
  static const String extTarGz = '.tar.gz';
  static const String extApk = '.apk';

  static const String tokenWin = 'win';
  static const String tokenMac = 'mac';
  static const String tokenLinux = 'linux';
}

/// Standardized entity, outbox, and sync ID formats
abstract final class IdHelper {
  const IdHelper._();

  static const String prefixNode = 'node_';
  static const String prefixCram = 'cram';
  static const String prefixCramUnderscore = 'cram_';
  static const String prefixOutbox = 'outbox_';
  static const String prefixWrongQuestion = 'wrong_';
  static const String prefixExamSubmission = 'sub_';
  static const String prefixAnkiCard = 'c_';
  static const String prefixAnkiDeck = 'deck-';
  static const String hlcSeparator = '_';
  static const int hlcCounterHexWidth = 4;

  static String generateNodeId([int? microseconds]) =>
      '$prefixNode${(microseconds ?? DateTime.now().microsecondsSinceEpoch).toRadixString(16)}';

  static String cramDeckId({
    required String mode,
    required String encodedTag,
    required int cardLimit,
    int? timestamp,
  }) =>
      '${prefixCram}_${mode}_${encodedTag}_${cardLimit}_${timestamp ?? DateTime.now().millisecondsSinceEpoch}';

  static String examSubmissionId(String paperId, [int? timestamp]) =>
      '$prefixExamSubmission${paperId}_${timestamp ?? DateTime.now().millisecondsSinceEpoch}';

  static String wrongQuestionId(
    String examId,
    String questionId, [
    int? timestamp,
  ]) =>
      '$prefixWrongQuestion${examId}_${questionId}_${timestamp ?? DateTime.now().millisecondsSinceEpoch}';

  static String ankiCardId(dynamic cid) => '$prefixAnkiCard$cid';
  static String ankiDeckId(dynamic did) => '$prefixAnkiDeck$did';

  static String outboxId({
    required String prefix,
    required String entityId,
    required String hlc,
  }) => '$prefixOutbox${prefix}_${entityId}_$hlc';
}
