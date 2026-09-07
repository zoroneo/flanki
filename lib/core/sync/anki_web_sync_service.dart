import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'anki_web_config.dart';
import '../importer/apkg_importer_service.dart';
import '../models/card.dart';
import '../models/deck.dart';
import 'anki_web_media_sync_service.dart';

class AnkiWebSyncResult {
  final bool success;
  final String message;
  final List<DeckModel> decks;
  final List<CardModel> cards;
  final int mediaCount;

  const AnkiWebSyncResult({
    required this.success,
    required this.message,
    this.decks = const [],
    this.cards = const [],
    this.mediaCount = 0,
  });

  factory AnkiWebSyncResult.ok({
    required String message,
    List<DeckModel> decks = const [],
    List<CardModel> cards = const [],
    int mediaCount = 0,
  }) {
    return AnkiWebSyncResult(
      success: true,
      message: message,
      decks: decks,
      cards: cards,
      mediaCount: mediaCount,
    );
  }

  factory AnkiWebSyncResult.fail(String error) {
    return AnkiWebSyncResult(
      success: false,
      message: error,
    );
  }
}

/// Service handling full sync collection download, upload, and media synchronization with AnkiWeb.
class AnkiWebSyncService {
  final http.Client _client;
  final AnkiWebConfig _config;
  final AnkiWebMediaSyncService _mediaSyncService;

  AnkiWebSyncService({
    http.Client? client,
    AnkiWebConfig? config,
    AnkiWebMediaSyncService? mediaSyncService,
  })  : _client = client ?? http.Client(),
        _config = config ?? const AnkiWebConfig(),
        _mediaSyncService = mediaSyncService ??
            AnkiWebMediaSyncService(
              client: client,
              config: config,
            );

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
      onProgress?.call('Đang kết nối AnkiWeb...', 0.1);

      // 1. Check meta / collection status
      final metaUri = Uri.parse('${_config.syncHost}/sync/meta');
      final metaReq = http.MultipartRequest('POST', metaUri);
      metaReq.headers['User-Agent'] = AnkiWebConfig.userAgent;
      metaReq.fields['c'] = '0';
      metaReq.fields['k'] = hostKey;
      metaReq.fields['data'] = jsonEncode({
        'v': AnkiWebConfig.protocolVersion,
        'cv': AnkiWebConfig.clientVersion,
      });
      final metaStreamed = await _client.send(metaReq).timeout(AnkiWebConfig.metaTimeout);
      final metaResponse = await http.Response.fromStream(metaStreamed);

      if (metaResponse.statusCode == 401 || metaResponse.statusCode == 403) {
        return AnkiWebSyncResult.fail('Phiên đăng nhập AnkiWeb đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (metaResponse.statusCode >= 400) {
        return AnkiWebSyncResult.fail(
          'Lỗi máy chủ AnkiWeb (${metaResponse.statusCode}): ${metaResponse.reasonPhrase ?? "Lỗi không xác định"}',
        );
      }

      // 2. Download collection package from sync server
      onProgress?.call('Đang tải dữ liệu bộ thẻ từ AnkiWeb...', 0.3);
      final downloadUri = Uri.parse('${_config.syncHost}/sync/download');
      final downloadReq = http.MultipartRequest('POST', downloadUri);
      downloadReq.headers['User-Agent'] = AnkiWebConfig.userAgent;
      downloadReq.fields['c'] = '0';
      downloadReq.fields['k'] = hostKey;
      downloadReq.fields['data'] = '{}';
      final downloadStreamed = await _client.send(downloadReq).timeout(AnkiWebConfig.downloadTimeout);
      final downloadResponse = await http.Response.fromStream(downloadStreamed);

      if (downloadResponse.statusCode == 200 && downloadResponse.bodyBytes.isNotEmpty) {
        onProgress?.call('Đang xử lý thẻ & lưu cơ sở dữ liệu...', 0.55);
        final bytes = downloadResponse.bodyBytes;
        // Parse collection package using ApkgImporterService
        final importer = ApkgImporterService();
        final importResult = importer.importApkgBytes(bytes);

        int mediaCount = importResult.mediaCount;
        if (syncMediaFiles) {
          onProgress?.call('Đang kiểm tra tệp media (ảnh & âm thanh)...', 0.65);
          final mediaRes = await syncMedia(
            hostKey: hostKey,
            onProgress: (downloaded, total) {
              onMediaProgress?.call(downloaded, total);
              if (total > 0) {
                final ratio = (downloaded / total).clamp(0.0, 1.0);
                final currentProgress = 0.65 + 0.3 * ratio;
                onProgress?.call('Đang tải media ($downloaded/$total)...', currentProgress);
              } else {
                onProgress?.call('Đang kiểm tra tệp media...', 0.7);
              }
            },
          );
          if (mediaRes.success) {
            mediaCount += mediaRes.downloadedCount;
          }
        }

        onProgress?.call('Đồng bộ hoàn tất!', 1.0);
        final mediaMsg = mediaCount > 0 ? ' và $mediaCount tệp media' : '';
        return AnkiWebSyncResult.ok(
          message: 'Đã tải thành công ${importResult.decks.length} bộ thẻ, ${importResult.cards.length} thẻ$mediaMsg từ AnkiWeb.',
          decks: importResult.decks,
          cards: importResult.cards,
          mediaCount: mediaCount,
        );
      } else if (downloadResponse.statusCode == 403 || downloadResponse.statusCode == 401) {
        return AnkiWebSyncResult.fail('Phiên đăng nhập AnkiWeb đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (downloadResponse.statusCode >= 400) {
        return AnkiWebSyncResult.fail(
          'Lỗi máy chủ AnkiWeb (${downloadResponse.statusCode}): ${downloadResponse.reasonPhrase ?? "Lỗi không xác định"}',
        );
      } else {
        int mediaCount = 0;
        if (syncMediaFiles) {
          onProgress?.call('Đang kiểm tra tệp media (ảnh & âm thanh)...', 0.65);
          final mediaRes = await syncMedia(
            hostKey: hostKey,
            onProgress: (downloaded, total) {
              onMediaProgress?.call(downloaded, total);
              if (total > 0) {
                final ratio = (downloaded / total).clamp(0.0, 1.0);
                final currentProgress = 0.65 + 0.3 * ratio;
                onProgress?.call('Đang tải media ($downloaded/$total)...', currentProgress);
              } else {
                onProgress?.call('Đang kiểm tra tệp media...', 0.7);
              }
            },
          );
          if (mediaRes.success) {
            mediaCount = mediaRes.downloadedCount;
          }
        }
        onProgress?.call('Đồng bộ hoàn tất!', 1.0);
        return AnkiWebSyncResult.ok(
          message: mediaCount > 0
              ? 'Đã đồng bộ thành công $mediaCount tệp media từ AnkiWeb.'
              : 'Dữ liệu bộ thẻ và media đã khớp với AnkiWeb Cloud.',
          mediaCount: mediaCount,
        );
      }
    } on SocketException catch (_) {
      return AnkiWebSyncResult.fail('Không có kết nối mạng internet.');
    } catch (e) {
      return AnkiWebSyncResult.fail('Lỗi đồng bộ AnkiWeb: $e');
    }
  }
}
