/// Centralized application configuration and metadata.
class AppConfig {
  static const String appName = 'Flanki';
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  /// Full version string (e.g. "1.0.0+1")
  static const String fullVersion = '$version+$buildNumber';
}
