import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../config/app_config.dart';
import '../../database/media_storage_service.dart';
import '../../network/dio_client.dart';
import 'anki_web_config.dart';

class MediaSyncResult {
  final bool success;
  final String message;
  final int downloadedCount;
  final int serverUsn;

  const MediaSyncResult({
    required this.success,
    required this.message,
    this.downloadedCount = 0,
    this.serverUsn = 0,
  });

  factory MediaSyncResult.ok({
    required String message,
    int downloadedCount = 0,
    int serverUsn = 0,
  }) {
    return MediaSyncResult(
      success: true,
      message: message,
      downloadedCount: downloadedCount,
      serverUsn: serverUsn,
    );
  }

  factory MediaSyncResult.fail(String error) {
    return MediaSyncResult(success: false, message: error);
  }
}

/// Service implementing AnkiWeb Media Sync Protocol (/msync/).
/// Downloads media assets (images, audio) directly from AnkiWeb sync servers.
class AnkiWebMediaSyncService {
  static const int maxMediaFilesInZip = AnkiWebConfig.defaultMediaBatchLimit;

  final Dio _dio;
  final AnkiWebConfig _config;
  final AppLocalizations? _customL10n;

  AnkiWebMediaSyncService({
    Dio? dio,
    AnkiWebConfig? config,
    AppLocalizations? l10n,
  }) : _dio = dio ?? DioClient.defaultInstance,
       _config = config ?? const AnkiWebConfig(),
       _customL10n = l10n;

  AppLocalizations get l10n => _customL10n ?? AppConfig.getL10n();

  /// Executes full media synchronization with AnkiWeb:
  /// 1. POST /msync/begin -> receives serverUsn & sessionKey
  /// 2. POST /msync/mediaChanges -> receives list of changed files
  /// 3. POST /msync/downloadFiles in batches of 25 files -> unzips & persists files
  Future<MediaSyncResult> syncAllMedia({
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
  }) async {
    try {
      // 1. Begin media sync
      final beginFormData = FormData.fromMap({
        'k': hostKey,
        'v': _config.effectiveClientVersion,
      });

      final beginRes = await _dio.post<dynamic>(
        _config.msyncBeginUrl,
        data: beginFormData,
        cancelToken: cancelToken,
        options: Options(
          headers: {'User-Agent': _config.effectiveUserAgent},
          receiveTimeout: _config.effectiveMetaTimeout,
        ),
      );

      final beginJson = beginRes.data is Map<String, dynamic>
          ? beginRes.data as Map<String, dynamic>
          : jsonDecode(beginRes.data.toString()) as Map<String, dynamic>;

      final err = beginJson['err'] as String?;
      if (err != null && err.isNotEmpty) {
        return MediaSyncResult.fail(l10n.syncMediaError(err));
      }

      final beginData = beginJson['data'] as Map<String, dynamic>? ?? {};
      final serverUsn = (beginData['usn'] as num?)?.toInt() ?? 0;
      final sessionKey = (beginData['sk'] as String?) ?? hostKey;

      // 2. Fetch media changes
      final changesFormData = FormData.fromMap({
        'k': sessionKey.isNotEmpty ? sessionKey : hostKey,
        'data': jsonEncode({'lastUsn': lastUsn}),
      });

      final changesRes = await _dio.post<dynamic>(
        _config.msyncChangesUrl,
        data: changesFormData,
        cancelToken: cancelToken,
        options: Options(
          headers: {'User-Agent': _config.effectiveUserAgent},
          receiveTimeout: _config.effectiveMetaTimeout,
        ),
      );

      final changesJson = changesRes.data is Map<String, dynamic>
          ? changesRes.data as Map<String, dynamic>
          : jsonDecode(changesRes.data.toString()) as Map<String, dynamic>;

      final changesData = changesJson['data'];
      if (changesData is! List) {
        return MediaSyncResult.ok(
          message: l10n.syncNoMediaChanges,
          serverUsn: serverUsn,
        );
      }

      // Filter files that need download (sha1 is non-empty)
      final filesToDownload = <String>[];
      for (final item in changesData) {
        if (item is List && item.isNotEmpty) {
          final fname = item[0]?.toString() ?? '';
          final sha1 = item.length > 2 ? item[2]?.toString() ?? '' : '';
          // If sha1 is non-empty, the file exists on server
          if (fname.isNotEmpty && sha1.isNotEmpty) {
            // Only download if we don't already have it
            if (!MediaStorageService.instance.mediaFileExists(fname)) {
              filesToDownload.add(fname);
            }
          }
        }
      }

      if (filesToDownload.isEmpty) {
        onProgress?.call(0, 0);
        return MediaSyncResult.ok(
          message: l10n.syncAllMediaUpToDate,
          downloadedCount: 0,
          serverUsn: serverUsn,
        );
      }

      final totalFiles = filesToDownload.length;
      int downloadedCount = 0;
      onProgress?.call(0, totalFiles);

      // 3. Download in batches of maxMediaFilesInZip
      final totalBatches = (filesToDownload.length / maxMediaFilesInZip).ceil();
      for (int i = 0; i < filesToDownload.length; i += maxMediaFilesInZip) {
        final end = math.min(i + maxMediaFilesInZip, filesToDownload.length);
        final batch = filesToDownload.sublist(i, end);
        final currentBatchIndex = (i ~/ maxMediaFilesInZip) + 1;

        final downloadFormData = FormData.fromMap({
          'k': sessionKey.isNotEmpty ? sessionKey : hostKey,
          'data': jsonEncode({'files': batch}),
        });

        final downloadRes = await _dio.post<List<int>>(
          _config.msyncDownloadUrl,
          data: downloadFormData,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'User-Agent': _config.effectiveUserAgent},
            receiveTimeout: _config.effectiveDownloadTimeout,
          ),
          onReceiveProgress: (receivedBytes, totalBytes) {
            if (totalBytes > 0) {
              onByteProgress?.call(
                currentBatchIndex,
                totalBatches,
                receivedBytes,
                totalBytes,
              );
            }
          },
        );

        if (downloadRes.statusCode == 200 &&
            downloadRes.data != null &&
            downloadRes.data!.isNotEmpty) {
          final extractedCount = _extractAndSaveZip(
            Uint8List.fromList(downloadRes.data!),
          );
          downloadedCount += extractedCount;
          onProgress?.call(downloadedCount, totalFiles);
        } else {
          return MediaSyncResult.fail(
            l10n.syncMediaBatchError(
              '$i-$end',
              downloadRes.statusCode ?? 500,
              downloadRes.statusMessage ?? '',
            ),
          );
        }
      }

      return MediaSyncResult.ok(
        message: l10n.syncMediaDownloadedSuccess(downloadedCount),
        downloadedCount: downloadedCount,
        serverUsn: serverUsn,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return MediaSyncResult.fail(l10n.syncFailed);
      }
      if (e.response != null) {
        return MediaSyncResult.fail(
          l10n.syncServerError(
            e.response!.statusCode ?? 500,
            e.response!.statusMessage ?? e.message ?? '',
          ),
        );
      }
      return MediaSyncResult.fail(
        l10n.syncMediaError(e.message ?? e.toString()),
      );
    } catch (e) {
      return MediaSyncResult.fail(l10n.syncMediaError(e.toString()));
    }
  }

  int _extractAndSaveZip(Uint8List zipBytes) {
    int count = 0;
    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);
      ArchiveFile? metaFile;
      final fileMap = <String, ArchiveFile>{};

      for (final file in archive) {
        if (file.name == '_meta') {
          metaFile = file;
        } else {
          fileMap[file.name] = file;
        }
      }

      if (metaFile == null) return 0;

      final metaContent = utf8.decode(metaFile.content as List<int>);
      final fmap = jsonDecode(metaContent) as Map<String, dynamic>;

      for (final entry in fmap.entries) {
        final zipIndexName = entry.key;
        final realFilename = entry.value as String;
        final af = fileMap[zipIndexName];
        if (af != null) {
          MediaStorageService.instance.saveMediaFileSync(
            realFilename,
            af.content as List<int>,
          );
          count++;
        }
      }
    } catch (_) {}
    return count;
  }
}
