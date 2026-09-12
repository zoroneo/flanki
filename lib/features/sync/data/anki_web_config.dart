import 'dart:io';

/// Centralized configuration for AnkiWeb synchronization and authentication.
class AnkiWebConfig {
  static const String defaultSyncHost = 'https://sync.ankiweb.net';
  static const String ankiVersion = '2.1.57';
  static const String ankiBuild = '7b1f3c3a';
  static const String defaultUserAgent = 'Anki/$ankiVersion ($ankiBuild)';
  static const String userAgent = defaultUserAgent;
  static const int protocolVersion = 10;

  static const Duration defaultAuthTimeout = Duration(seconds: 15);
  static const Duration defaultMetaTimeout = Duration(seconds: 15);
  static const Duration defaultDownloadTimeout = Duration(seconds: 30);
  static const Duration defaultUploadTimeout = Duration(seconds: 60);

  // Backward compatible static getters
  static Duration get authTimeout => defaultAuthTimeout;
  static Duration get metaTimeout => defaultMetaTimeout;
  static Duration get downloadTimeout => defaultDownloadTimeout;
  static Duration get uploadTimeout => defaultUploadTimeout;

  /// Dynamically resolved platform identifier conforming to Anki protocol:
  /// macOS: mac:darwin, Windows: win:nt, Linux: lin:linux, iOS: ios:darwin, Android: and:android
  static String get platformIdentifier {
    try {
      if (Platform.isMacOS) return 'mac:darwin';
      if (Platform.isWindows) return 'win:nt';
      if (Platform.isLinux) return 'lin:linux';
      if (Platform.isAndroid) return 'and:android';
      if (Platform.isIOS) return 'ios:darwin';
    } catch (_) {}
    return 'mac:darwin';
  }

  /// Client version string sent to AnkiWeb (cv / v field)
  static String get clientVersion => 'anki,$ankiVersion,$platformIdentifier';

  final String syncHost;
  final Duration customAuthTimeout;
  final Duration customMetaTimeout;
  final Duration customDownloadTimeout;
  final Duration customUploadTimeout;
  final String? customClientVersion;
  final String? customUserAgent;

  const AnkiWebConfig({
    this.syncHost = defaultSyncHost,
    this.customAuthTimeout = defaultAuthTimeout,
    this.customMetaTimeout = defaultMetaTimeout,
    this.customDownloadTimeout = defaultDownloadTimeout,
    this.customUploadTimeout = defaultUploadTimeout,
    this.customClientVersion,
    this.customUserAgent,
  });

  Duration get effectiveAuthTimeout => customAuthTimeout;
  Duration get effectiveMetaTimeout => customMetaTimeout;
  Duration get effectiveDownloadTimeout => customDownloadTimeout;
  Duration get effectiveUploadTimeout => customUploadTimeout;
  String get effectiveClientVersion => customClientVersion ?? clientVersion;
  String get effectiveUserAgent => customUserAgent ?? userAgent;
}
