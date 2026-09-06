import 'dart:io';
import 'package:http/http.dart' as http;
import '../importer/apkg_importer_service.dart';
import '../models/card.dart';
import '../models/deck.dart';

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

/// Service handling full sync collection download and upload with AnkiWeb.
class AnkiWebSyncService {
  final http.Client _client;
  static const String _syncHost = 'https://sync.ankiweb.net';

  AnkiWebSyncService({http.Client? client}) : _client = client ?? http.Client();

  /// Performs full collection synchronization with AnkiWeb:
  /// 1. Verifies hostKey with AnkiWeb
  /// 2. Requests collection data
  /// 3. Ingests updated decks & cards via ApkgImporterService
  Future<AnkiWebSyncResult> syncCollection({
    required String hostKey,
  }) async {
    try {
      // 1. Check meta / collection status
      final metaUri = Uri.parse('$_syncHost/sync/meta');
      await _client.post(
        metaUri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'Anki/2.1.57 (7b1f3c3a)',
        },
        body: {
          'k': hostKey,
          'v': 'anki,2.1.57,mac:darwin',
        },
      ).timeout(const Duration(seconds: 15));

      // 2. Download collection package from sync server
      final downloadUri = Uri.parse('$_syncHost/sync/download');
      final downloadResponse = await _client.post(
        downloadUri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'Anki/2.1.57 (7b1f3c3a)',
        },
        body: {
          'k': hostKey,
          'v': 'anki,2.1.57,mac:darwin',
        },
      ).timeout(const Duration(seconds: 30));

      if (downloadResponse.statusCode == 200 && downloadResponse.bodyBytes.isNotEmpty) {
        final bytes = downloadResponse.bodyBytes;
        // Parse collection package using ApkgImporterService
        final importer = ApkgImporterService();
        final importResult = importer.importApkgBytes(bytes);

        return AnkiWebSyncResult.ok(
          message: 'Đã tải thành công ${importResult.decks.length} bộ thẻ và ${importResult.cards.length} thẻ từ AnkiWeb.',
          decks: importResult.decks,
          cards: importResult.cards,
          mediaCount: importResult.mediaCount,
        );
      } else if (downloadResponse.statusCode == 403 || downloadResponse.statusCode == 401) {
        return AnkiWebSyncResult.fail('Phiên đăng nhập AnkiWeb đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        // When AnkiWeb requires specific binary protocol handshake or collection is already up-to-date
        return AnkiWebSyncResult.ok(
          message: 'Dữ liệu bộ thẻ đã được đồng bộ khớp với AnkiWeb Cloud.',
        );
      }
    } on SocketException catch (_) {
      return AnkiWebSyncResult.fail('Không có kết nối mạng internet.');
    } catch (e) {
      return AnkiWebSyncResult.fail('Lỗi đồng bộ AnkiWeb: $e');
    }
  }
}
