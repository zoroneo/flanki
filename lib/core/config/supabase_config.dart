/// Supabase Cloud configuration for Flanki sync engine.
///
/// Values can be supplied at build/run time via:
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
/// ```
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Returns true if valid credentials are configured.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Media bucket name in Supabase Storage.
  static const String mediaBucket = 'flanki_media';
}
