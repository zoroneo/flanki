import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/database/media_storage_service.dart';
import 'package:flanki/features/sync/data/anki_web_config.dart';
import 'package:flanki/features/sync/data/anki_web_media_sync_service.dart';

class MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio createMockDio(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio();
  dio.httpClientAdapter = MockHttpAdapter(handler);
  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late MediaStorageService mediaStorage;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_test_msync_');
    mediaStorage = MediaStorageService.instance;
    await mediaStorage.init(customPath: tempDir.path);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Uint8List createMockMediaZip(Map<String, List<int>> files) {
    final archive = Archive();
    final metaMap = <String, String>{};

    int index = 0;
    for (final entry in files.entries) {
      final zipKey = index.toString();
      metaMap[zipKey] = entry.key;
      archive.addFile(ArchiveFile(zipKey, entry.value.length, entry.value));
      index++;
    }

    final metaJson = jsonEncode(metaMap);
    final metaBytes = utf8.encode(metaJson);
    archive.addFile(ArchiveFile('_meta', metaBytes.length, metaBytes));

    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  test('AnkiWebMediaSyncService performs begin, fetch changes, and downloads media files', () async {
    final mockZip = createMockMediaZip({
      '4000B1_008.jpg': [0xFF, 0xD8, 0xFF, 0xE0, 0x01, 0x02],
      'audio_sample.mp3': [0x49, 0x44, 0x33, 0x03, 0x00],
    });

    final dio = createMockDio((options) async {
      final path = options.path;

      if (path.endsWith('/msync/begin')) {
        return ResponseBody.fromString(
          jsonEncode({
            'data': {'usn': 100, 'sk': 'session_key_123'},
            'err': '',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      } else if (path.endsWith('/msync/mediaChanges')) {
        return ResponseBody.fromString(
          jsonEncode({
            'data': [
              ['4000B1_008.jpg', 1, 'mocksha1'],
              ['audio_sample.mp3', 2, 'mocksha2'],
            ],
            'err': '',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      } else if (path.endsWith('/msync/downloadFiles')) {
        return ResponseBody.fromBytes(
          mockZip,
          200,
          headers: {
            Headers.contentLengthHeader: ['${mockZip.length}'],
          },
        );
      }

      return ResponseBody.fromString('Not Found', 404);
    });

    final service = AnkiWebMediaSyncService(
      dio: dio,
      config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
    );

    int progressDownloaded = 0;
    int progressTotal = 0;
    int byteProgressCalls = 0;

    final result = await service.syncAllMedia(
      hostKey: 'test_host_key',
      onProgress: (downloaded, total) {
        progressDownloaded = downloaded;
        progressTotal = total;
      },
      onByteProgress: (batch, totalBatches, received, total) {
        byteProgressCalls++;
      },
    );

    expect(result.success, isTrue);
    expect(result.downloadedCount, equals(2));
    expect(progressDownloaded, equals(2));
    expect(progressTotal, equals(2));
    expect(byteProgressCalls, greaterThan(0));

    expect(mediaStorage.mediaFileExists('4000B1_008.jpg'), isTrue);
    expect(mediaStorage.mediaFileExists('audio_sample.mp3'), isTrue);

    final jpgFile = File(mediaStorage.getMediaFilePath('4000B1_008.jpg'));
    expect(
      jpgFile.readAsBytesSync(),
      equals([0xFF, 0xD8, 0xFF, 0xE0, 0x01, 0x02]),
    );
  });

  test(
    'AnkiWebMediaSyncService handles empty media changes gracefully',
    () async {
      final dio = createMockDio((options) async {
        if (options.path.endsWith('/msync/begin')) {
          return ResponseBody.fromString(
            jsonEncode({
              'data': {'usn': 50, 'sk': 'sk_test'},
              'err': '',
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (options.path.endsWith('/msync/mediaChanges')) {
          return ResponseBody.fromString(
            jsonEncode({'data': [], 'err': ''}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final service = AnkiWebMediaSyncService(
        dio: dio,
        config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
      );

      final result = await service.syncAllMedia(hostKey: 'test_host_key');
      expect(result.success, isTrue);
      expect(result.downloadedCount, equals(0));
    },
  );

  test(
    'AnkiWebMediaSyncService splits requests larger than 25 files into batches',
    () async {
      // Generate 30 files
      final fileNames = List.generate(30, (i) => 'img_$i.jpg');
      final changes = fileNames.map((name) => [name, 1, 'sha_$name']).toList();

      int downloadCallCount = 0;

      final dio = createMockDio((options) async {
        if (options.path.endsWith('/msync/begin')) {
          return ResponseBody.fromString(
            jsonEncode({
              'data': {'usn': 50, 'sk': 'sk_test'},
              'err': '',
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (options.path.endsWith('/msync/mediaChanges')) {
          return ResponseBody.fromString(
            jsonEncode({'data': changes, 'err': ''}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (options.path.endsWith('/msync/downloadFiles')) {
          downloadCallCount++;
          final mockZip = createMockMediaZip({
            'img_batch.jpg': [0x01],
          });
          return ResponseBody.fromBytes(
            mockZip,
            200,
            headers: {
              Headers.contentLengthHeader: ['${mockZip.length}'],
            },
          );
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final service = AnkiWebMediaSyncService(
        dio: dio,
        config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
      );

      final result = await service.syncAllMedia(hostKey: 'test_host_key');
      expect(result.success, isTrue);
      // 30 files with MAX_BATCH 25 -> 2 batches (25 and 5)
      expect(downloadCallCount, equals(2));
    },
  );
}
