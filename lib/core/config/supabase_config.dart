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

  /// Backups bucket name in Supabase Storage.
  static const String backupBucket = String.fromEnvironment(
    'SUPABASE_BACKUP_BUCKET',
    defaultValue: 'flanki_backups',
  );

  /// Standard default MIME type for raw binary assets.
  static const String defaultBinaryContentType = 'application/octet-stream';

  /// Standard URL and file URI schemes.
  static const String schemeHttp = 'http://';
  static const String schemeHttps = 'https://';
  static const String schemeFile = 'file://';

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
  static const String rpcGetCloudStorageStats = 'get_cloud_storage_stats';

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
  static const String entityUserMedia = 'user_media';

  /// Database schemas and core column identifiers.
  static const String schemaPublic = 'public';
  static const String columnUserId = 'user_id';

  /// Standard Postgres table names for Realtime CDC synchronization.
  static const String tableDecks = 'decks';
  static const String tableCards = 'cards';
  static const String tableReviewLogs = 'review_logs';
  static const String tableGrammarProgress = 'grammar_progress';
  static const String tableUserMedia = 'user_media';

  /// Tables subscribed by default for Realtime push synchronization.
  static const List<String> realtimeSubscribedTables = [
    tableDecks,
    tableCards,
    tableReviewLogs,
    tableGrammarProgress,
    tableUserMedia,
  ];

  /// Media sync concurrency limit.
  static const int defaultMediaConcurrentTransfers = 4;

  /// Supabase Realtime channel and debounce config
  static const String realtimeSyncChannel = 'flanki_realtime_sync';
  static const Duration defaultRealtimeDebounce = Duration(milliseconds: 1500);

  /// OAuth callback redirect URL for deep linking.
  static const String authCallbackUrl = 'flanki://auth-callback';

  /// Key identifier for encrypted session in secure storage.
  static const String sessionStorageKey = 'supabase_session';

  /// Standard authentication exception message strings.
  static const String errSupabaseNotInitialized = 'Supabase is not initialized';
  static const String errOAuthInitiationFailed = 'OAuth flow initiation failed';

  /// Standard cloud backup exception message strings.
  static const String errSnapshotEmptyOrMissing =
      'Snapshot file is empty or does not exist';
  static const String errInvalidSnapshotPackage =
      'Invalid Flanki snapshot package: manifest or data missing';
  static const String errUserMustBeLoggedInToUpload =
      'User must be logged in to upload backups';

  /// Standard sync replicator and engine error message strings.
  static const String errSyncAlreadyInProgress = 'Sync already in progress';
  static const String errSyncPausedByCircuitBreaker =
      'Sync paused by circuit breaker (cooldown active)';
  static const String errNetworkUnavailable = 'Network unavailable';
  static const String errUserNotAuthenticated = 'User is not authenticated';
  static const String errUserMustBeLoggedInToPush =
      'User must be logged in to push mutations';
  static const String errUserMustBeLoggedInToPull =
      'User must be logged in to pull deltas';
  static const String errSyncFailed = 'Sync Failed';
  static const String errNetworkOffline = 'Network Offline';
  static const String errAuthPrefix = 'Auth error: ';

  /// Standard sync mutation operation codes.
  static const String opUpsert = 'UPSERT';
  static const String opInsert = 'INSERT';
  static const String opDelete = 'DELETE';
}
