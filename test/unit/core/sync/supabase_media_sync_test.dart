import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/database/media_storage_service.dart';
import 'package:flanki/core/sync/supabase_media_sync_service.dart';

class FakeStorageBridge implements SupabaseStorageBridge {
  final Map<String, Uint8List> storage = {};
  final List<String> uploadCalls = [];
  final List<String> downloadCalls = [];

  @override
  Future<void> uploadBinary(
    String path,
    Uint8List data, {
    String? contentType,
  }) async {
    uploadCalls.add(path);
    storage[path] = data;
  }

  @override
  Future<Uint8List> download(String path) async {
    downloadCalls.add(path);
    final data = storage[path];
    if (data == null) {
      throw Exception('Object not found: $path');
    }
    return data;
  }

  @override
  Future<void> remove(List<String> paths) async {
    for (final p in paths) {
      storage.remove(p);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;
  late FakeStorageBridge fakeStorage;
  late SupabaseMediaSyncService mediaSyncService;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_media_sync_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );

    dbPath = '${tempDir.path}/test_media_sync.db';
    await DatabaseService.instance.init(customPath: dbPath);
    await MediaStorageService.instance.init(
      customPath: '${tempDir.path}/media',
    );

    fakeStorage = FakeStorageBridge();
    mediaSyncService = SupabaseMediaSyncService(
      storageBridge: fakeStorage,
      dbService: DatabaseService.instance,
      mediaStorage: MediaStorageService.instance,
      userIdProvider: () => 'test_user_456',
    );
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('SupabaseMediaSyncService', () {
    test(
      'uploadPendingMedia uploads unsynced media to user bucket path',
      () async {
        // 1. Save local media file and register in DB
        final fileData = Uint8List.fromList([1, 2, 3, 4, 5]);
        await MediaStorageService.instance.saveMediaFile(
          'card_image.png',
          fileData,
        );
        await DatabaseService.instance.registerLocalMedia(
          filename: 'card_image.png',
          bytes: fileData,
          mimeType: 'image/png',
        );

        // Verify pending in DB
        final pending = await DatabaseService.instance.getPendingUploadMedia();
        expect(pending.length, equals(1));
        expect(pending.first.filename, equals('card_image.png'));

        // 2. Execute upload
        final uploadedCount = await mediaSyncService.uploadPendingMedia();
        expect(uploadedCount, equals(1));

        // 3. Verify upload called with correct namespace: <userId>/<filename>
        expect(
          fakeStorage.uploadCalls,
          contains('test_user_456/card_image.png'),
        );
        expect(
          fakeStorage.storage['test_user_456/card_image.png'],
          equals(fileData),
        );

        // 4. Verify DB marked as uploaded
        final pendingAfter = await DatabaseService.instance
            .getPendingUploadMedia();
        expect(pendingAfter, isEmpty);
      },
    );

    test('downloadMissingMedia downloads missing files from remote', () async {
      // Remote has audio file
      final audioData = Uint8List.fromList([10, 20, 30, 40]);
      fakeStorage.storage['test_user_456/sound_01.mp3'] = audioData;

      // Apply delta indicating user has this media
      await DatabaseService.instance.applyRemoteDeltasBatch(
        userMedia: [
          {
            'filename': 'sound_01.mp3',
            'file_size': audioData.length,
            'sha256_hash': 'dummy_hash',
            'mime_type': 'audio/mpeg',
            'created_at': DateTime.now().toIso8601String(),
          },
        ],
      );

      // Verify file does not exist locally yet
      final resolvedBefore = MediaStorageService.instance.resolveMediaFile(
        'sound_01.mp3',
      );
      expect(resolvedBefore, isNull);

      // Execute download
      final downloadedCount = await mediaSyncService.downloadMissingMedia();
      expect(downloadedCount, equals(1));
      expect(fakeStorage.downloadCalls, contains('test_user_456/sound_01.mp3'));

      // Verify file saved locally
      final resolvedAfter = MediaStorageService.instance.resolveMediaFile(
        'sound_01.mp3',
      );
      expect(resolvedAfter, isNotNull);
      expect(resolvedAfter!.existsSync(), isTrue);
      expect(resolvedAfter.readAsBytesSync(), equals(audioData));
    });

    test(
      'syncMedia runs two-way sync (upload pending + download missing)',
      () async {
        // Setup 1 pending upload
        final imgData = Uint8List.fromList([100, 101, 202]);
        await MediaStorageService.instance.saveMediaFile('photo.jpg', imgData);
        await DatabaseService.instance.registerLocalMedia(
          filename: 'photo.jpg',
          bytes: imgData,
          mimeType: 'image/jpeg',
        );

        // Setup 1 remote missing item
        final remoteData = Uint8List.fromList([200, 201]);
        fakeStorage.storage['test_user_456/pronounce.mp3'] = remoteData;
        await DatabaseService.instance.applyRemoteDeltasBatch(
          userMedia: [
            {
              'filename': 'pronounce.mp3',
              'file_size': remoteData.length,
              'sha256_hash': 'hash_200',
              'mime_type': 'audio/mpeg',
              'created_at': DateTime.now().toIso8601String(),
            },
          ],
        );

        final summary = await mediaSyncService.syncMedia();
        expect(summary.uploadedCount, equals(1));
        expect(summary.downloadedCount, equals(1));
        expect(summary.hasActivity, isTrue);

        expect(fakeStorage.uploadCalls, contains('test_user_456/photo.jpg'));
        expect(
          fakeStorage.downloadCalls,
          contains('test_user_456/pronounce.mp3'),
        );
      },
    );

    test(
      'uploadPendingMedia processes files concurrently with progress reporting',
      () async {
        // Create concurrent service with maxConcurrent = 2
        final concurrentService = SupabaseMediaSyncService(
          storageBridge: fakeStorage,
          dbService: DatabaseService.instance,
          mediaStorage: MediaStorageService.instance,
          userIdProvider: () => 'test_user_456',
          maxConcurrent: 2,
        );

        // Save 5 files
        for (int i = 1; i <= 5; i++) {
          final filename = 'test_item_$i.png';
          final data = Uint8List.fromList([i, i + 1]);
          await MediaStorageService.instance.saveMediaFile(filename, data);
          await DatabaseService.instance.registerLocalMedia(
            filename: filename,
            bytes: data,
            mimeType: 'image/png',
          );
        }

        final progressSnapshots = <int>[];
        final count = await concurrentService.uploadPendingMedia(
          onProgress: (done, total) {
            progressSnapshots.add(done);
          },
        );

        expect(count, equals(5));
        expect(progressSnapshots.length, equals(5));
        expect(progressSnapshots.last, equals(5));
        for (int i = 1; i <= 5; i++) {
          expect(
            fakeStorage.uploadCalls,
            contains('test_user_456/test_item_$i.png'),
          );
        }
      },
    );
  });
}
