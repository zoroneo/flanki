import 'dart:io';
import 'dart:ui' show Locale;

import '../../l10n/generated/app_localizations.dart';

/// Centralized application configuration and metadata.
class AppConfig {
  static const String appName = 'Flanki';
  static const String defaultVersion = '1.1.2';
  static const int defaultBuildNumber = 11;

  /// Centralized supported locales and default fallback
  static const Locale defaultLocale = Locale('vi');
  static const List<Locale> supportedLocales = [Locale('vi'), Locale('en')];

  /// Resolves standard language code ('vi' or 'en') from system platform.
  static String resolveSystemLocaleCode() {
    try {
      return Platform.localeName.toLowerCase().startsWith('vi') ? 'vi' : 'en';
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
  static const String githubRepoOwner = 'zoroneo';
  static const String githubRepoName = 'flanki';

  /// GitHub Releases API URL
  static String get githubReleasesApiUrl =>
      'https://api.github.com/repos/$githubRepoOwner/$githubRepoName/releases/latest';

  /// GitHub Releases web page URL
  static String get githubReleasesUrl =>
      'https://github.com/$githubRepoOwner/$githubRepoName/releases';

  /// Default study session limits & retention
  static const int defaultNewCardsPerDay = 20;
  static const int defaultReviewsPerDay = 100;
  static const int defaultCramLimit = 50;
  static const double defaultDesiredRetention = 0.90;
  static const int defaultReminderHour = 20;
  static const int defaultReminderMinute = 0;

  /// Default streak saver time (Tier 2 evening reminder)
  static const int defaultStreakSaverHour = 22;
  static const int defaultStreakSaverMinute = 30;

  /// Fallback study time calculation (seconds per card)
  static const int fallbackSecondsPerCard = 15;

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
}
