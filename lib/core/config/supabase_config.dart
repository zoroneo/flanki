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
  static const String mediaBucket = String.fromEnvironment(
    'SUPABASE_MEDIA_BUCKET',
    defaultValue: 'flanki_media',
  );

  /// Fallback mock credentials for offline testing and uninitialized states.
  static const String mockUrl = 'https://mock.supabase.co';
  static const String mockAnonKey = 'mock-key';

  /// Default batch limit for pushing mutations.
  static const int defaultPushBatchLimit = 100;

  /// Default batch limit for pulling deltas.
  static const int defaultPullBatchLimit = 500;

  /// Initial fallback timestamp cursor for delta synchronization.
  static const String initialSyncCursorEpoch = '1970-01-01T00:00:00.000Z';

  /// Remote Postgres RPC function names.
  static const String rpcPushMutations = 'sync_push_mutations';
  static const String rpcPullDeltas = 'sync_pull_deltas';
  static const String rpcFetchExamCatalog = 'fetch_exam_catalog';
  static const String rpcDownloadExamPaper = 'download_exam_paper';

  /// Remote RPC parameter identifiers.
  static const String paramMutations = 'mutations';
  static const String paramCursors = 'cursors';
  static const String paramBatchLimit = 'batch_limit';
  static const String paramCategory = 'p_category';
  static const String paramLevel = 'p_level';
  static const String paramExamId = 'p_exam_id';

  /// Standard sync entity type names.
  static const String entityDeck = 'deck';
  static const String entityCard = 'card';
  static const String entityGrammarProgress = 'grammar_progress';
  static const String entityReviewLog = 'review_log';
  static const String entityExamSubmission = 'exam_submission';
  static const String entityWrongQuestion = 'wrong_question';

  /// Standard sync mutation operation codes.
  static const String opUpsert = 'UPSERT';
  static const String opInsert = 'INSERT';
  static const String opDelete = 'DELETE';
}
