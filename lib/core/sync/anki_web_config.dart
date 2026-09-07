/// Centralized configuration for AnkiWeb synchronization and authentication.
class AnkiWebConfig {
  static const String defaultSyncHost = 'https://sync.ankiweb.net';
  static const String userAgent = 'Anki/2.1.57 (7b1f3c3a)';
  static const int protocolVersion = 10;
  static const String clientVersion = 'anki,2.1.57,mac:darwin';

  static const Duration authTimeout = Duration(seconds: 15);
  static const Duration metaTimeout = Duration(seconds: 15);
  static const Duration downloadTimeout = Duration(seconds: 30);

  final String syncHost;

  const AnkiWebConfig({
    this.syncHost = defaultSyncHost,
  });
}
