import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

import '../../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';
import '../storage/media_storage_service.dart';
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
  static const int maxMediaFilesInZip = 25;

  final http.Client _client;
  final AnkiWebConfig _config;
  final AppLocalizations? _customL10n;

  AnkiWebMediaSyncService({
    http.Client? client,
    AnkiWebConfig? config,
    AppLocalizations? l10n,
  }) : _client = client ?? http.Client(),
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
    void Function(int downloaded, int total)? onProgress,
  }) async {
    try {
      // 1. Begin media sync
      final beginUri = Uri.parse('${_config.syncHost}/msync/begin');
      final beginReq = http.MultipartRequest('POST', beginUri);
      beginReq.headers['User-Agent'] = _config.effectiveUserAgent;
      beginReq.fields['k'] = hostKey;
      beginReq.fields['v'] = _config.effectiveClientVersion;

      final beginStreamed = await _client
          .send(beginReq)
          .timeout(_config.effectiveMetaTimeout);
      final beginRes = await http.Response.fromStream(beginStreamed);

      if (beginRes.statusCode >= 400) {
        return MediaSyncResult.fail(
          l10n.syncServerError(
            beginRes.statusCode,
            beginRes.reasonPhrase ?? '',
          ),
        );
      }

      final beginJson =
          jsonDecode(utf8.decode(beginRes.bodyBytes)) as Map<String, dynamic>;
      final err = beginJson['err'] as String?;
      if (err != null && err.isNotEmpty) {
        return MediaSyncResult.fail(l10n.syncMediaError(err));
      }

      final beginData = beginJson['data'] as Map<String, dynamic>? ?? {};
      final serverUsn = (beginData['usn'] as num?)?.toInt() ?? 0;
      final sessionKey = (beginData['sk'] as String?) ?? hostKey;

      // 2. Fetch media changes
      final changesUri = Uri.parse('${_config.syncHost}/msync/mediaChanges');
      final changesReq = http.MultipartRequest('POST', changesUri);
      changesReq.headers['User-Agent'] = _config.effectiveUserAgent;
      changesReq.fields['k'] = sessionKey.isNotEmpty ? sessionKey : hostKey;
      changesReq.fields['data'] = jsonEncode({'lastUsn': lastUsn});

      final changesStreamed = await _client
          .send(changesReq)
          .timeout(_config.effectiveMetaTimeout);
      final changesRes = await http.Response.fromStream(changesStreamed);

      if (changesRes.statusCode >= 400) {
        return MediaSyncResult.fail(
          l10n.syncServerError(
            changesRes.statusCode,
            changesRes.reasonPhrase ?? '',
          ),
        );
      }

      final changesJson =
          jsonDecode(utf8.decode(changesRes.bodyBytes)) as Map<String, dynamic>;
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
      for (int i = 0; i < filesToDownload.length; i += maxMediaFilesInZip) {
        final end = math.min(i + maxMediaFilesInZip, filesToDownload.length);
        final batch = filesToDownload.sublist(i, end);

        final downloadUri = Uri.parse(
          '${_config.syncHost}/msync/downloadFiles',
        );
        final downloadReq = http.MultipartRequest('POST', downloadUri);
        downloadReq.headers['User-Agent'] = _config.effectiveUserAgent;
        downloadReq.fields['k'] = sessionKey.isNotEmpty ? sessionKey : hostKey;
        downloadReq.fields['data'] = jsonEncode({'files': batch});

        final downloadStreamed = await _client
            .send(downloadReq)
            .timeout(_config.effectiveDownloadTimeout);
        final downloadRes = await http.Response.fromStream(downloadStreamed);

        if (downloadRes.statusCode == 200 && downloadRes.bodyBytes.isNotEmpty) {
          final extractedCount = _extractAndSaveZip(downloadRes.bodyBytes);
          downloadedCount += extractedCount;
          onProgress?.call(downloadedCount, totalFiles);
        } else {
          return MediaSyncResult.fail(
            l10n.syncMediaBatchError(
              '$i-$end',
              downloadRes.statusCode,
              downloadRes.reasonPhrase ?? '',
            ),
          );
        }
      }

      return MediaSyncResult.ok(
        message: l10n.syncMediaDownloadedSuccess(downloadedCount),
        downloadedCount: downloadedCount,
        serverUsn: serverUsn,
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
