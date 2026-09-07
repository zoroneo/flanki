/// Centralized application configuration and metadata.
class AppConfig {
  static const String appName = 'Flanki';
  static const String version = '1.0.1';
  static const int buildNumber = 2;

  /// Full version string (e.g. "1.0.0+1")
  static const String fullVersion = '$version+$buildNumber';

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
}
