import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:http/http.dart' as http;

import 'anki_web_config.dart';
import 'anki_web_media_sync_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../importer/apkg_importer_service.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../storage/database_service.dart';

class SyncProgressMessages {
  final String connecting;
  final String downloadingCollection;
  final String processingData;
  final String checkingMedia;
  final String compressingUpload;
  final String uploadingCloud;
  final String uploadComplete;
  final String sessionExpired;
  final String noInternet;
  final String conflictDetected;

  const SyncProgressMessages({
    this.connecting = 'Connecting to AnkiWeb...',
    this.downloadingCollection = 'Downloading collection data from AnkiWeb...',
    this.processingData = 'Processing cards & saving database...',
    this.checkingMedia = 'Checking media files (images & audio)...',
    this.compressingUpload = 'Compressing and preparing upload to AnkiWeb...',
    this.uploadingCloud = 'Uploading data to AnkiWeb Cloud...',
    this.uploadComplete = 'Upload complete!',
    this.sessionExpired = 'AnkiWeb session expired. Please log in again.',
    this.noInternet = 'No internet connection.',
    this.conflictDetected =
        'Conflict detected: Both AnkiWeb and this device have new study data.',
  });

  factory SyncProgressMessages.fromL10n(AppLocalizations l10n) {
    return SyncProgressMessages(
      connecting: l10n.syncConnecting,
      downloadingCollection: l10n.syncDownloadingCollection,
      processingData: l10n.syncProcessingData,
      checkingMedia: l10n.syncCheckingMedia,
      compressingUpload: l10n.syncCompressingUpload,
      uploadingCloud: l10n.syncUploadingCloud,
      uploadComplete: l10n.syncUploadComplete,
      sessionExpired: l10n.syncSessionExpired,
      noInternet: l10n.syncNoInternet,
      conflictDetected: l10n.syncConflictDetected,
    );
  }
}

enum SyncStage {
  connecting,
  downloadingCollection,
  processingData,
  checkingMedia,
  compressingUpload,
  uploadingCloud,
  uploadComplete,
  sessionExpired,
  noInternet,
  conflictDetected,
  error;

  String localizedMessage(SyncProgressMessages messages) {
    switch (this) {
      case SyncStage.connecting:
        return messages.connecting;
      case SyncStage.downloadingCollection:
        return messages.downloadingCollection;
      case SyncStage.processingData:
        return messages.processingData;
      case SyncStage.checkingMedia:
        return messages.checkingMedia;
      case SyncStage.compressingUpload:
        return messages.compressingUpload;
      case SyncStage.uploadingCloud:
        return messages.uploadingCloud;
      case SyncStage.uploadComplete:
        return messages.uploadComplete;
      case SyncStage.sessionExpired:
        return messages.sessionExpired;
      case SyncStage.noInternet:
        return messages.noInternet;
      case SyncStage.conflictDetected:
        return messages.conflictDetected;
      case SyncStage.error:
        return 'Sync Error';
    }
  }
}

enum SyncActionRequired { noChange, download, upload, conflict }

class SyncStatusCheckResult {
  final SyncActionRequired action;
  final String message;
  final DateTime? serverMod;
  final DateTime? localLastSync;
  final bool hasLocalChanges;

  const SyncStatusCheckResult({
    required this.action,
    required this.message,
    this.serverMod,
    this.localLastSync,
    this.hasLocalChanges = false,
  });
}

class AnkiWebSyncResult {
  final bool success;
  final String message;
  final List<DeckModel> decks;
  final List<CardModel> cards;
  final List<ReviewLogModel> reviewLogs;
  final int mediaCount;

  const AnkiWebSyncResult({
    required this.success,
    required this.message,
    this.decks = const [],
    this.cards = const [],
    this.reviewLogs = const [],
    this.mediaCount = 0,
  });

  factory AnkiWebSyncResult.ok({
    required String message,
    List<DeckModel> decks = const [],
    List<CardModel> cards = const [],
    List<ReviewLogModel> reviewLogs = const [],
    int mediaCount = 0,
  }) {
    return AnkiWebSyncResult(
      success: true,
      message: message,
      decks: decks,
      cards: cards,
      reviewLogs: reviewLogs,
      mediaCount: mediaCount,
    );
  }

  factory AnkiWebSyncResult.fail(String error) {
    return AnkiWebSyncResult(success: false, message: error);
  }
}

/// Service handling full sync collection download, upload, and media synchronization with AnkiWeb.
class AnkiWebSyncService {
  final http.Client _client;
  final AnkiWebConfig _config;
  final AnkiWebMediaSyncService _mediaSyncService;
  final SyncProgressMessages _messages;
  final AppLocalizations? _l10n;

  AnkiWebSyncService({
    http.Client? client,
    AnkiWebConfig? config,
    AnkiWebMediaSyncService? mediaSyncService,
    SyncProgressMessages? messages,
    AppLocalizations? l10n,
  }) : _client = client ?? http.Client(),
       _config = config ?? const AnkiWebConfig(),
       _l10n = l10n,
       _messages =
           messages ??
           (l10n != null
               ? SyncProgressMessages.fromL10n(l10n)
               : const SyncProgressMessages()),
       _mediaSyncService =
           mediaSyncService ??
           AnkiWebMediaSyncService(client: client, config: config, l10n: l10n);

  AppLocalizations get l10n {
    if (_l10n != null) return _l10n;
    try {
      final code = (Platform.localeName.toLowerCase().startsWith('vi'))
          ? 'vi'
          : 'en';
      return lookupAppLocalizations(Locale(code));
    } catch (_) {
      return lookupAppLocalizations(const Locale('vi'));
    }
  }

  /// Synchronizes media files (images, audio) via /msync/ protocol.
  Future<MediaSyncResult> syncMedia({
    required String hostKey,
    int lastUsn = 0,
    void Function(int downloaded, int total)? onProgress,
  }) {
    return _mediaSyncService.syncAllMedia(
      hostKey: hostKey,
      lastUsn: lastUsn,
      onProgress: onProgress,
    );
  }

  /// Performs full collection synchronization with AnkiWeb:
  /// 1. Verifies hostKey with AnkiWeb
  /// 2. Requests collection data
  /// 3. Ingests updated decks & cards via ApkgImporterService
  /// 4. Synchronizes media assets via /msync/ if [syncMediaFiles] is true
  Future<AnkiWebSyncResult> syncCollection({
    required String hostKey,
    bool syncMediaFiles = true,
    void Function(String stage, double progress)? onProgress,
    void Function(int downloaded, int total)? onMediaProgress,
  }) async {
    try {
      onProgress?.call(_messages.connecting, 0.1);

      // 1. Check meta / collection status
      final metaUri = Uri.parse('${_config.syncHost}/sync/meta');
      final metaReq = http.MultipartRequest('POST', metaUri);
      metaReq.headers['User-Agent'] = _config.effectiveUserAgent;
      metaReq.fields['c'] = '0';
      metaReq.fields['k'] = hostKey;
      metaReq.fields['data'] = jsonEncode({
        'v': AnkiWebConfig.protocolVersion,
        'cv': _config.effectiveClientVersion,
      });
      final metaStreamed = await _client
          .send(metaReq)
          .timeout(_config.effectiveMetaTimeout);
      final metaResponse = await http.Response.fromStream(metaStreamed);

      if (metaResponse.statusCode == 401 || metaResponse.statusCode == 403) {
        return AnkiWebSyncResult.fail(_messages.sessionExpired);
      } else if (metaResponse.statusCode >= 400) {
        return AnkiWebSyncResult.fail(
          l10n.syncServerError(
            metaResponse.statusCode,
            metaResponse.reasonPhrase ?? '',
          ),
        );
      }

      // 2. Download collection package from sync server
      onProgress?.call(_messages.downloadingCollection, 0.3);
      final downloadUri = Uri.parse('${_config.syncHost}/sync/download');
      final downloadReq = http.MultipartRequest('POST', downloadUri);
      downloadReq.headers['User-Agent'] = _config.effectiveUserAgent;
      downloadReq.fields['c'] = '0';
      downloadReq.fields['k'] = hostKey;
      downloadReq.fields['data'] = '{}';
      final downloadStreamed = await _client
          .send(downloadReq)
          .timeout(_config.effectiveDownloadTimeout);
      final downloadResponse = await http.Response.fromStream(downloadStreamed);

      if (downloadResponse.statusCode == 200 &&
          downloadResponse.bodyBytes.isNotEmpty) {
        onProgress?.call(_messages.processingData, 0.55);
        final bytes = downloadResponse.bodyBytes;
        // Parse collection package using ApkgImporterService
        final importer = ApkgImporterService();
        final importResult = importer.importApkgBytes(bytes);

        int mediaCount = importResult.mediaCount;
        if (syncMediaFiles) {
          onProgress?.call(_messages.checkingMedia, 0.65);
          final mediaRes = await syncMedia(
            hostKey: hostKey,
            onProgress: (downloaded, total) {
              onMediaProgress?.call(downloaded, total);
              if (total > 0) {
                final ratio = (downloaded / total).clamp(0.0, 1.0);
                final currentProgress = 0.65 + 0.3 * ratio;
                onProgress?.call(
                  l10n.syncDownloadingMediaProgress(downloaded, total),
                  currentProgress,
                );
              } else {
                onProgress?.call(_messages.checkingMedia, 0.7);
              }
            },
          );
          if (mediaRes.success) {
            mediaCount += mediaRes.downloadedCount;
          }
        }

        onProgress?.call(_messages.uploadComplete, 1.0);
        final mediaMsg = mediaCount > 0
            ? l10n.syncMediaCountPart(mediaCount)
            : '';
        return AnkiWebSyncResult.ok(
          message: l10n.syncSuccessWithMedia(
            importResult.decks.length,
            importResult.cards.length,
            mediaMsg,
          ),
          decks: importResult.decks,
          cards: importResult.cards,
          reviewLogs: importResult.reviewLogs,
          mediaCount: mediaCount,
        );
      } else if (downloadResponse.statusCode == 403 ||
          downloadResponse.statusCode == 401) {
        return AnkiWebSyncResult.fail(_messages.sessionExpired);
      } else if (downloadResponse.statusCode >= 400) {
        return AnkiWebSyncResult.fail(
          l10n.syncServerError(
            downloadResponse.statusCode,
            downloadResponse.reasonPhrase ?? '',
          ),
        );
      } else {
        int mediaCount = 0;
        if (syncMediaFiles) {
          onProgress?.call(_messages.checkingMedia, 0.65);
          final mediaRes = await syncMedia(
            hostKey: hostKey,
            onProgress: (downloaded, total) {
              onMediaProgress?.call(downloaded, total);
              if (total > 0) {
                final ratio = (downloaded / total).clamp(0.0, 1.0);
                final currentProgress = 0.65 + 0.3 * ratio;
                onProgress?.call(
                  l10n.syncDownloadingMediaProgress(downloaded, total),
                  currentProgress,
                );
              } else {
                onProgress?.call(_messages.checkingMedia, 0.7);
              }
            },
          );
          if (mediaRes.success) {
            mediaCount += mediaRes.downloadedCount;
          }
        }
        onProgress?.call(_messages.uploadComplete, 1.0);
        return AnkiWebSyncResult.ok(
          message: mediaCount > 0
              ? l10n.syncMediaSyncedSuccess(mediaCount)
              : l10n.syncCollectionAndMediaUpToDate,
          mediaCount: mediaCount,
        );
      }
    } on SocketException catch (_) {
      return AnkiWebSyncResult.fail(_messages.noInternet);
    } catch (e) {
      return AnkiWebSyncResult.fail(l10n.syncCollectionError(e.toString()));
    }
  }

  /// Checks whether local, remote, or both have changed since [lastSyncTime].
  Future<SyncStatusCheckResult> checkSyncStatus({
    required String hostKey,
    required DateTime? lastSyncTime,
    required bool hasLocalChanges,
  }) async {
    try {
      final metaUri = Uri.parse('${_config.syncHost}/sync/meta');
      final metaReq = http.MultipartRequest('POST', metaUri);
      metaReq.headers['User-Agent'] = _config.effectiveUserAgent;
      metaReq.fields['c'] = '0';
      metaReq.fields['k'] = hostKey;
      metaReq.fields['data'] = jsonEncode({
        'v': AnkiWebConfig.protocolVersion,
        'cv': _config.effectiveClientVersion,
      });
      final metaStreamed = await _client
          .send(metaReq)
          .timeout(_config.effectiveMetaTimeout);
      final metaResponse = await http.Response.fromStream(metaStreamed);

      if (metaResponse.statusCode == 401 || metaResponse.statusCode == 403) {
        return SyncStatusCheckResult(
          action: SyncActionRequired.noChange,
          message: _messages.sessionExpired,
        );
      } else if (metaResponse.statusCode >= 400) {
        return SyncStatusCheckResult(
          action: SyncActionRequired.noChange,
          message: l10n.syncCheckStatusServerError(metaResponse.statusCode),
        );
      }

      DateTime? serverMod;
      try {
        final decoded = jsonDecode(metaResponse.body);
        final Map<String, dynamic> data =
            (decoded is Map<String, dynamic> &&
                decoded['data'] is Map<String, dynamic>)
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : {});

        final modNum = data['mod'] as num? ?? data['scm'] as num?;
        if (modNum != null) {
          final modInt = modNum.toInt();
          serverMod = modInt > 10000000000
              ? DateTime.fromMillisecondsSinceEpoch(modInt)
              : DateTime.fromMillisecondsSinceEpoch(modInt * 1000);
        }
      } catch (_) {}

      // If never synced before
      if (lastSyncTime == null) {
        return SyncStatusCheckResult(
          action: hasLocalChanges
              ? SyncActionRequired.conflict
              : SyncActionRequired.download,
          message: l10n.syncFirstTime,
          serverMod: serverMod,
          localLastSync: lastSyncTime,
          hasLocalChanges: hasLocalChanges,
        );
      }

      final isServerNewer =
          serverMod != null &&
          serverMod.isAfter(lastSyncTime.add(const Duration(seconds: 2)));

      if (isServerNewer && hasLocalChanges) {
        return SyncStatusCheckResult(
          action: SyncActionRequired.conflict,
          message: _messages.conflictDetected,
          serverMod: serverMod,
          localLastSync: lastSyncTime,
          hasLocalChanges: true,
        );
      } else if (hasLocalChanges) {
        return SyncStatusCheckResult(
          action: SyncActionRequired.upload,
          message: l10n.syncLocalChangesToPush,
          serverMod: serverMod,
          localLastSync: lastSyncTime,
          hasLocalChanges: true,
        );
      } else if (isServerNewer) {
        return SyncStatusCheckResult(
          action: SyncActionRequired.download,
          message: l10n.syncRemoteChangesToPull,
          serverMod: serverMod,
          localLastSync: lastSyncTime,
          hasLocalChanges: false,
        );
      } else {
        return SyncStatusCheckResult(
          action: SyncActionRequired.noChange,
          message: l10n.syncAlreadyFullySynced,
          serverMod: serverMod,
          localLastSync: lastSyncTime,
          hasLocalChanges: false,
        );
      }
    } catch (e) {
      return SyncStatusCheckResult(
        action: SyncActionRequired.noChange,
        message: l10n.syncCheckError(e.toString()),
      );
    }
  }

  /// Uploads local collection database binary to AnkiWeb via /sync/upload.
  Future<AnkiWebSyncResult> uploadCollection({
    required String hostKey,
    required Uint8List dbBytes,
    bool syncMediaFiles = true,
    void Function(String stage, double progress)? onProgress,
    void Function(int downloaded, int total)? onMediaProgress,
  }) async {
    try {
      onProgress?.call(_messages.compressingUpload, 0.3);

      final uploadUri = Uri.parse('${_config.syncHost}/sync/upload');
      final uploadReq = http.MultipartRequest('POST', uploadUri);
      uploadReq.headers['User-Agent'] = _config.effectiveUserAgent;
      uploadReq.fields['c'] = '0';
      uploadReq.fields['k'] = hostKey;
      uploadReq.files.add(
        http.MultipartFile.fromBytes(
          'data',
          dbBytes,
          filename: 'collection.anki2',
        ),
      );

      onProgress?.call(_messages.uploadingCloud, 0.6);
      final streamed = await _client
          .send(uploadReq)
          .timeout(_config.effectiveUploadTimeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        int mediaCount = 0;
        if (syncMediaFiles) {
          onProgress?.call(_messages.checkingMedia, 0.8);
          final mediaRes = await syncMedia(
            hostKey: hostKey,
            onProgress: (downloaded, total) {
              onMediaProgress?.call(downloaded, total);
              if (total > 0) {
                final ratio = (downloaded / total).clamp(0.0, 1.0);
                final currentProgress = 0.8 + 0.18 * ratio;
                onProgress?.call(
                  l10n.syncDownloadingMediaProgress(downloaded, total),
                  currentProgress,
                );
              }
            },
          );
          if (mediaRes.success) {
            mediaCount += mediaRes.downloadedCount;
          }
        }

        onProgress?.call(_messages.uploadComplete, 1.0);
        return AnkiWebSyncResult.ok(
          message: l10n.syncUploadSuccess,
          mediaCount: mediaCount,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return AnkiWebSyncResult.fail(_messages.sessionExpired);
      } else {
        return AnkiWebSyncResult.fail(
          l10n.syncServerError(response.statusCode, response.body),
        );
      }
    } on SocketException catch (_) {
      return AnkiWebSyncResult.fail(_messages.noInternet);
    } catch (e) {
      return AnkiWebSyncResult.fail(l10n.syncUploadError(e.toString()));
    }
  }
}
