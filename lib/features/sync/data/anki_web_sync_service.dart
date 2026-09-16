import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'anki_web_config.dart';
import 'anki_web_media_sync_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/anki/apkg_importer_service.dart';
import '../../../core/models/card.dart';
import '../../../core/models/deck.dart';
import '../../../core/database/database_service.dart';

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
  final String syncError;

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
    this.syncError = 'Sync failed',
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
      syncError: l10n.syncFailed,
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
        return messages.syncError;
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
  final Dio _dio;
  final AnkiWebConfig _config;
  final AnkiWebMediaSyncService _mediaSyncService;
  final SyncProgressMessages _messages;
  final AppLocalizations? _l10n;

  AnkiWebSyncService({
    Dio? dio,
    AnkiWebConfig? config,
    AnkiWebMediaSyncService? mediaSyncService,
    SyncProgressMessages? messages,
    AppLocalizations? l10n,
  }) : _dio = dio ?? DioClient.defaultInstance,
       _config = config ?? const AnkiWebConfig(),
       _l10n = l10n,
       _messages =
           messages ??
           (l10n != null
               ? SyncProgressMessages.fromL10n(l10n)
               : const SyncProgressMessages()),
       _mediaSyncService =
           mediaSyncService ??
           AnkiWebMediaSyncService(dio: dio, config: config, l10n: l10n);

  AppLocalizations get l10n => _l10n ?? AppConfig.getL10n();

  /// Synchronizes media files (images, audio) via /msync/ protocol.
  Future<MediaSyncResult> syncMedia({
    required String hostKey,
    int lastUsn = 0,
    CancelToken? cancelToken,
    void Function(int downloaded, int total)? onProgress,
    void Function(
      int currentBatch,
      int totalBatches,
      int bytesReceived,
      int totalBytes,
    )?
    onByteProgress,
  }) {
    return _mediaSyncService.syncAllMedia(
      hostKey: hostKey,
      lastUsn: lastUsn,
      cancelToken: cancelToken,
      onProgress: onProgress,
      onByteProgress: onByteProgress,
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
    CancelToken? cancelToken,
    void Function(String stage, double progress)? onProgress,
    void Function(int downloaded, int total)? onMediaProgress,
  }) async {
    try {
      onProgress?.call(_messages.connecting, 0.1);

      // 1. Check meta / collection status
      final metaFormData = FormData.fromMap({
        'c': '0',
        'k': hostKey,
        'data': jsonEncode({
          'v': AnkiWebConfig.protocolVersion,
          'cv': _config.effectiveClientVersion,
        }),
      });

      final metaResponse = await _dio.post<dynamic>(
        _config.metaUrl,
        data: metaFormData,
        cancelToken: cancelToken,
        options: Options(
          headers: {'User-Agent': _config.effectiveUserAgent},
          receiveTimeout: _config.effectiveMetaTimeout,
        ),
      );

      if (metaResponse.statusCode == 401 || metaResponse.statusCode == 403) {
        return AnkiWebSyncResult.fail(_messages.sessionExpired);
      } else if (metaResponse.statusCode != null &&
          metaResponse.statusCode! >= 400) {
        return AnkiWebSyncResult.fail(
          l10n.syncServerError(
            metaResponse.statusCode!,
            metaResponse.statusMessage ?? '',
          ),
        );
      }

      // 2. Download collection package from sync server
      onProgress?.call(_messages.downloadingCollection, 0.3);
      final downloadFormData = FormData.fromMap({
        'c': '0',
        'k': hostKey,
        'data': '{}',
      });

      final downloadResponse = await _dio.post<List<int>>(
        _config.downloadUrl,
        data: downloadFormData,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'User-Agent': _config.effectiveUserAgent},
          receiveTimeout: _config.effectiveDownloadTimeout,
        ),
      );

      if (downloadResponse.statusCode == 200 &&
          downloadResponse.data != null &&
          downloadResponse.data!.isNotEmpty) {
        onProgress?.call(_messages.processingData, 0.55);
        final bytes = Uint8List.fromList(downloadResponse.data!);
        // Parse collection package using ApkgImporterService
        final importer = ApkgImporterService();
        final importResult = importer.importApkgBytes(bytes);

        int mediaCount = importResult.mediaCount;
        if (syncMediaFiles) {
          onProgress?.call(_messages.checkingMedia, 0.65);
          final mediaRes = await syncMedia(
            hostKey: hostKey,
            cancelToken: cancelToken,
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
      } else if (downloadResponse.statusCode != null &&
          downloadResponse.statusCode! >= 400) {
        return AnkiWebSyncResult.fail(
          l10n.syncServerError(
            downloadResponse.statusCode!,
            downloadResponse.statusMessage ?? '',
          ),
        );
      } else {
        int mediaCount = 0;
        if (syncMediaFiles) {
          onProgress?.call(_messages.checkingMedia, 0.65);
          final mediaRes = await syncMedia(
            hostKey: hostKey,
            cancelToken: cancelToken,
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return AnkiWebSyncResult.fail(_messages.syncError);
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return AnkiWebSyncResult.fail(_messages.sessionExpired);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return AnkiWebSyncResult.fail(_messages.noInternet);
      }
      return AnkiWebSyncResult.fail(
        l10n.syncCollectionError(e.message ?? e.toString()),
      );
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
    CancelToken? cancelToken,
  }) async {
    try {
      final metaFormData = FormData.fromMap({
        'c': '0',
        'k': hostKey,
        'data': jsonEncode({
          'v': AnkiWebConfig.protocolVersion,
          'cv': _config.effectiveClientVersion,
        }),
      });

      final metaResponse = await _dio.post<dynamic>(
        _config.metaUrl,
        data: metaFormData,
        cancelToken: cancelToken,
        options: Options(
          headers: {'User-Agent': _config.effectiveUserAgent},
          receiveTimeout: _config.effectiveMetaTimeout,
        ),
      );

      if (metaResponse.statusCode == 401 || metaResponse.statusCode == 403) {
        return SyncStatusCheckResult(
          action: SyncActionRequired.noChange,
          message: _messages.sessionExpired,
        );
      } else if (metaResponse.statusCode != null &&
          metaResponse.statusCode! >= 400) {
        return SyncStatusCheckResult(
          action: SyncActionRequired.noChange,
          message: l10n.syncCheckStatusServerError(metaResponse.statusCode!),
        );
      }

      DateTime? serverMod;
      try {
        final decoded = metaResponse.data is Map<String, dynamic>
            ? metaResponse.data as Map<String, dynamic>
            : jsonDecode(metaResponse.data.toString()) as Map<String, dynamic>;
        final Map<String, dynamic> data =
            decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : decoded;

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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return SyncStatusCheckResult(
          action: SyncActionRequired.noChange,
          message: _messages.syncError,
        );
      }
      return SyncStatusCheckResult(
        action: SyncActionRequired.noChange,
        message: l10n.syncCheckError(e.message ?? e.toString()),
      );
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
    CancelToken? cancelToken,
    void Function(String stage, double progress)? onProgress,
    void Function(int downloaded, int total)? onMediaProgress,
  }) async {
    try {
      onProgress?.call(_messages.compressingUpload, 0.3);

      final uploadFormData = FormData.fromMap({
        'c': '0',
        'k': hostKey,
        'data': MultipartFile.fromBytes(dbBytes, filename: 'collection.anki2'),
      });

      onProgress?.call(_messages.uploadingCloud, 0.6);
      final response = await _dio.post<dynamic>(
        _config.uploadUrl,
        data: uploadFormData,
        cancelToken: cancelToken,
        options: Options(
          headers: {'User-Agent': _config.effectiveUserAgent},
          receiveTimeout: _config.effectiveUploadTimeout,
        ),
      );

      if (response.statusCode == 200) {
        int mediaCount = 0;
        if (syncMediaFiles) {
          onProgress?.call(_messages.checkingMedia, 0.8);
          final mediaRes = await syncMedia(
            hostKey: hostKey,
            cancelToken: cancelToken,
            onProgress: (downloaded, total) {
              onMediaProgress?.call(downloaded, total);
              if (total > 0) {
                final ratio = (downloaded / total).clamp(0.0, 1.0);
                final currentProgress = 0.8 + 0.18 * ratio;
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
          message: l10n.syncUploadSuccess,
          mediaCount: mediaCount,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return AnkiWebSyncResult.fail(_messages.sessionExpired);
      } else {
        return AnkiWebSyncResult.fail(
          l10n.syncServerError(
            response.statusCode ?? 500,
            response.data?.toString() ?? '',
          ),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return AnkiWebSyncResult.fail(_messages.syncError);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return AnkiWebSyncResult.fail(_messages.noInternet);
      }
      return AnkiWebSyncResult.fail(
        l10n.syncUploadError(e.message ?? e.toString()),
      );
    } on SocketException catch (_) {
      return AnkiWebSyncResult.fail(_messages.noInternet);
    } catch (e) {
      return AnkiWebSyncResult.fail(l10n.syncUploadError(e.toString()));
    }
  }
}
