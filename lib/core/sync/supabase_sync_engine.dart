import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../database/database_service.dart';
import '../../features/exam/models/exam_models.dart';
import '../../l10n/generated/app_localizations.dart';
import 'payload_optimizer.dart';
import 'supabase_media_sync_service.dart';

/// Status of the sync operation.
enum SyncStatus { idle, syncing, synced, offline, unauthenticated, error }

/// Result metadata returned by a full sync cycle.
class SyncResult {
  final bool isSuccess;
  final bool isOffline;
  final bool isUnauthenticated;
  final int pushedCount;
  final int pulledCount;
  final int mediaUploadedCount;
  final int mediaDownloadedCount;
  final String? error;

  const SyncResult({
    required this.isSuccess,
    this.isOffline = false,
    this.isUnauthenticated = false,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.mediaUploadedCount = 0,
    this.mediaDownloadedCount = 0,
    this.error,
  });

  factory SyncResult.success({
    int pushed = 0,
    int pulled = 0,
    int mediaUploaded = 0,
    int mediaDownloaded = 0,
  }) => SyncResult(
    isSuccess: true,
    pushedCount: pushed,
    pulledCount: pulled,
    mediaUploadedCount: mediaUploaded,
    mediaDownloadedCount: mediaDownloaded,
  );

  factory SyncResult.offline() => const SyncResult(
    isSuccess: false,
    isOffline: true,
    error: SupabaseConfig.errNetworkUnavailable,
  );

  factory SyncResult.unauthenticated() => const SyncResult(
    isSuccess: false,
    isUnauthenticated: true,
    error: SupabaseConfig.errUserNotAuthenticated,
  );

  factory SyncResult.failure(String message) =>
      SyncResult(isSuccess: false, error: message);

  String? getLocalizedError(AppLocalizations l10n) {
    if (isSuccess) return null;
    if (isOffline) return l10n.networkUnavailable;
    if (isUnauthenticated) return l10n.authInvalidCredentials;
    return error;
  }

  @override
  String toString() =>
      'SyncResult(success: $isSuccess, offline: $isOffline, pushed: $pushedCount, pulled: $pulledCount, mediaUp: $mediaUploadedCount, mediaDown: $mediaDownloadedCount, error: $error)';
}

abstract class SupabaseRpcClient {
  User? get currentUser;
  Future<dynamic> rpc(String function, {Map<String, dynamic>? params});
}

class DefaultSupabaseRpcClient implements SupabaseRpcClient {
  final SupabaseClient _client;
  DefaultSupabaseRpcClient(this._client);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<dynamic> rpc(String function, {Map<String, dynamic>? params}) =>
      _client.rpc(function, params: params);
}

/// Core sync engine responsible for pushing local outbox mutations and pulling
/// remote deltas via Supabase RPCs.
class SupabaseSyncEngine {
  final SupabaseRpcClient _client;
  final DatabaseService _dbService;
  final SupabaseMediaSyncService _mediaSyncService;

  SupabaseSyncEngine({
    SupabaseClient? client,
    SupabaseRpcClient? rpcClient,
    DatabaseService? dbService,
    SupabaseMediaSyncService? mediaSyncService,
  }) : _client =
           rpcClient ??
           DefaultSupabaseRpcClient(client ?? _getSupabaseClientSafe()),
       _dbService = dbService ?? DatabaseService.instance,
       _mediaSyncService =
           mediaSyncService ??
           SupabaseMediaSyncService(
             client: client,
             dbService: dbService ?? DatabaseService.instance,
             userIdProvider: () =>
                 (rpcClient?.currentUser ?? client?.auth.currentUser)?.id,
           );

  static SupabaseClient _getSupabaseClientSafe() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return SupabaseClient(
        SupabaseConfig.mockUrl,
        SupabaseConfig.mockAnonKey,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
    }
  }

  /// Pushes all pending mutations in the local outbox to Supabase Cloud in batches.
  Future<int> pushMutations({
    int batchLimit = SupabaseConfig.defaultPushBatchLimit,
  }) async {
    final user = _client.currentUser;
    if (user == null) {
      throw const AuthException(SupabaseConfig.errUserMustBeLoggedInToPush);
    }

    int totalPushed = 0;

    while (true) {
      final batch = await _dbService.getPendingOutboxBatch(limit: batchLimit);
      if (batch.isEmpty) break;

      final mutationsPayload = batch.map((item) {
        return OutboxItemPayload(
          id: item.id,
          entityType: item.entityType,
          entityId: item.entityId,
          op: item.operation,
          isDeleted: item.operation == SupabaseConfig.opDelete,
          payload: jsonDecode(item.payloadJson),
          hlc: item.hlc,
        ).toJson();
      }).toList();

      final rawBytes = utf8.encode(jsonEncode(mutationsPayload)).length;
      final optimizedPayload = SparsePayloadOptimizer.cleanMutations(
        mutationsPayload,
      );
      final sentBytes = utf8.encode(jsonEncode(optimizedPayload)).length;
      final savedBytes = rawBytes > sentBytes ? rawBytes - sentBytes : 0;

      final response = await _client.rpc(
        SupabaseConfig.rpcPushMutations,
        params: {SupabaseConfig.paramMutations: optimizedPayload},
      );

      final respBytes = response != null
          ? utf8.encode(jsonEncode(response)).length
          : 0;
      SyncBandwidthTracker.instance.recordTransfer(
        sent: sentBytes,
        received: respBytes,
        saved: savedBytes,
      );

      final respMap = response is Map<String, dynamic>
          ? response
          : (response is String
                ? jsonDecode(response) as Map<String, dynamic>
                : <String, dynamic>{});

      final pushResponse = PushMutationsResponseDto.fromJson(respMap);
      final ackIds = pushResponse.ackIds.isNotEmpty
          ? pushResponse.ackIds
          : batch.map((b) => b.id).toList();

      await _dbService.acknowledgeOutboxBatch(ackIds);

      final serverTimestampStr = pushResponse.serverTimestamp;
      if (serverTimestampStr != null) {
        final serverTime = DateTime.tryParse(serverTimestampStr);
        if (serverTime != null) {
          _dbService.advanceHlc(wallTime: serverTime.millisecondsSinceEpoch);
        }
      }

      final processed = pushResponse.processedCount ?? ackIds.length;
      totalPushed += processed;

      if (batch.length < batchLimit) break;
    }

    return totalPushed;
  }

  /// Pulls deltas for all registered entities that have occurred after the stored cursors.
  Future<int> pullDeltas({
    int batchLimit = SupabaseConfig.defaultPullBatchLimit,
  }) async {
    final user = _client.currentUser;
    if (user == null) {
      throw const AuthException(SupabaseConfig.errUserMustBeLoggedInToPull);
    }

    final deckCursor =
        await _dbService.getSyncCursor(SupabaseConfig.entityDeck) ?? '';
    final cardCursor =
        await _dbService.getSyncCursor(SupabaseConfig.entityCard) ?? '';
    final grammarCursor =
        await _dbService.getSyncCursor(SupabaseConfig.entityGrammarProgress) ??
        '';
    final revlogCursor =
        await _dbService.getSyncCursor(SupabaseConfig.entityReviewLog) ??
        SupabaseConfig.initialSyncCursorEpoch;
    final examCursor =
        await _dbService.getSyncCursor(SupabaseConfig.entityExamSubmission) ??
        '';
    final wrongCursor =
        await _dbService.getSyncCursor(SupabaseConfig.entityWrongQuestion) ??
        '';
    final mediaCursor =
        await _dbService.getSyncCursor(SupabaseConfig.entityUserMedia) ?? '';

    final cursorsPayload = {
      SupabaseConfig.entityDeck: deckCursor,
      SupabaseConfig.entityCard: cardCursor,
      SupabaseConfig.entityGrammarProgress: grammarCursor,
      SupabaseConfig.entityReviewLog: revlogCursor,
      SupabaseConfig.entityExamSubmission: examCursor,
      SupabaseConfig.entityWrongQuestion: wrongCursor,
      SupabaseConfig.entityUserMedia: mediaCursor,
    };

    final response = await _client.rpc(
      SupabaseConfig.rpcPullDeltas,
      params: {
        SupabaseConfig.paramCursors: cursorsPayload,
        SupabaseConfig.paramBatchLimit: batchLimit,
      },
    );

    final respBytes = response != null
        ? utf8.encode(jsonEncode(response)).length
        : 0;
    SyncBandwidthTracker.instance.recordTransfer(received: respBytes);

    final respMap = response is Map<String, dynamic>
        ? response
        : (response is String
              ? jsonDecode(response) as Map<String, dynamic>
              : <String, dynamic>{});

    final pullResponse = PullDeltasResponseDto.fromJson(respMap);
    final decks = pullResponse.decks;
    final cards = pullResponse.cards;
    final reviewLogs = pullResponse.reviewLogs;
    final grammarProgress = pullResponse.grammarProgress;
    final examSubmissions = pullResponse.examSubmissions;
    final wrongQuestions = pullResponse.wrongQuestions;
    final userMedia = pullResponse.userMedia;

    await _dbService.applyRemoteDeltasBatch(
      decks: decks,
      cards: cards,
      reviewLogs: reviewLogs,
      grammarProgress: grammarProgress,
      examSubmissions: examSubmissions,
      wrongQuestions: wrongQuestions,
      userMedia: userMedia,
    );

    // Advance cursors to the latest HLC / timestamp received
    if (decks.isNotEmpty) {
      final maxHlc = decks
          .map((d) => d['updated_at_hlc'] as String? ?? '')
          .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      if (maxHlc.isNotEmpty) {
        await _dbService.setSyncCursor(SupabaseConfig.entityDeck, maxHlc);
      }
    }

    if (cards.isNotEmpty) {
      final maxHlc = cards
          .map((c) => c['updated_at_hlc'] as String? ?? '')
          .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      if (maxHlc.isNotEmpty) {
        await _dbService.setSyncCursor(SupabaseConfig.entityCard, maxHlc);
      }
    }

    if (grammarProgress.isNotEmpty) {
      final maxHlc = grammarProgress
          .map((g) => g['updated_at_hlc'] as String? ?? '')
          .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      if (maxHlc.isNotEmpty) {
        await _dbService.setSyncCursor(
          SupabaseConfig.entityGrammarProgress,
          maxHlc,
        );
      }
    }

    if (reviewLogs.isNotEmpty) {
      final maxReviewTime = reviewLogs
          .map((r) => r['review_time'] as String? ?? '')
          .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      if (maxReviewTime.isNotEmpty) {
        await _dbService.setSyncCursor(
          SupabaseConfig.entityReviewLog,
          maxReviewTime,
        );
      }
    }

    if (examSubmissions.isNotEmpty) {
      final maxHlc = examSubmissions
          .map((s) => s['updated_at_hlc'] as String? ?? '')
          .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      if (maxHlc.isNotEmpty) {
        await _dbService.setSyncCursor(
          SupabaseConfig.entityExamSubmission,
          maxHlc,
        );
      }
    }

    if (wrongQuestions.isNotEmpty) {
      final maxHlc = wrongQuestions
          .map((w) => w['updated_at_hlc'] as String? ?? '')
          .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      if (maxHlc.isNotEmpty) {
        await _dbService.setSyncCursor(
          SupabaseConfig.entityWrongQuestion,
          maxHlc,
        );
      }
    }

    if (userMedia.isNotEmpty) {
      final maxHlc = userMedia
          .map((m) => m['updated_at_hlc'] as String? ?? '')
          .reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      if (maxHlc.isNotEmpty) {
        await _dbService.setSyncCursor(SupabaseConfig.entityUserMedia, maxHlc);
      }
    }

    return decks.length +
        cards.length +
        reviewLogs.length +
        grammarProgress.length +
        examSubmissions.length +
        wrongQuestions.length +
        userMedia.length;
  }

  // --- Sparse Sync Operations (On-Demand Fetching) ---

  /// Fetches online exam catalog metadata from Supabase and caches it into Drift SQLite.
  Future<List<ExamPaperModel>> fetchExamCatalogOnline({
    ExamCategory? category,
    String? level,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (category != null) {
        params[SupabaseConfig.paramCategory] = category.code;
      }
      if (level != null) {
        params[SupabaseConfig.paramLevel] = level;
      }

      final response = await _client.rpc(
        SupabaseConfig.rpcFetchExamCatalog,
        params: params,
      );

      final list = (response as List<dynamic>?) ?? [];
      final papers = list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return ExamPaperModel.fromJson(map);
      }).toList();

      if (papers.isNotEmpty) {
        await _dbService.saveExamCatalog(papers);
      }
      return papers;
    } catch (_) {
      // Fall back to local cached catalog
      return _dbService.getExamCatalog(category: category, level: level);
    }
  }

  /// Downloads full questions & sections for an exam paper on-demand and saves into SQLite.
  Future<ExamPaperModel> downloadExamPaperOffline(String examId) async {
    final response = await _client.rpc(
      SupabaseConfig.rpcDownloadExamPaper,
      params: {SupabaseConfig.paramExamId: examId},
    );

    final respMap = response is Map<String, dynamic>
        ? response
        : (response is String
              ? jsonDecode(response) as Map<String, dynamic>
              : <String, dynamic>{});

    final details = ExamPaperDetailsDto.fromJson(respMap);
    final paper = details.paper.copyWith(isDownloaded: true);

    await _dbService.saveExamPaperWithQuestions(
      paper,
      details.sections,
      details.questions,
    );
    return paper;
  }

  /// Executes a full synchronization cycle: Push local outbox -> Pull remote deltas.
  Future<SyncResult> sync() async {
    if (_client.currentUser == null) {
      return SyncResult.unauthenticated();
    }

    try {
      final pushedCount = await pushMutations();
      final pulledCount = await pullDeltas();

      // Binary media transfer with Supabase Storage
      final mediaSummary = await _mediaSyncService.syncMedia(
        userId: _client.currentUser?.id,
      );

      return SyncResult.success(
        pushed: pushedCount,
        pulled: pulledCount,
        mediaUploaded: mediaSummary.uploadedCount,
        mediaDownloaded: mediaSummary.downloadedCount,
      );
    } on SocketException {
      return SyncResult.offline();
    } on TimeoutException {
      return SyncResult.offline();
    } on AuthException catch (e) {
      return SyncResult.failure('${SupabaseConfig.errAuthPrefix}${e.message}');
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socket') ||
          errStr.contains('network') ||
          errStr.contains('connection refused') ||
          errStr.contains('failed host lookup') ||
          errStr.contains('clientexception')) {
        return SyncResult.offline();
      }
      return SyncResult.failure(e.toString());
    }
  }
}
