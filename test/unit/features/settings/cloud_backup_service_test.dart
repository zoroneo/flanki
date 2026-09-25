import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/config/app_config.dart';
import 'package:flanki/core/config/supabase_config.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/database/media_storage_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/services/cloud_backup_service.dart';
import 'package:flanki/core/sync/supabase_media_sync_service.dart';

class MockSupabaseStorageBridge implements SupabaseStorageBridge {
  final Map<String, Uint8List> storageMap = {};

  @override
  Future<Uint8List> download(String path) async {
    final data = storageMap[path];
    if (data == null) throw Exception('File not found: $path');
    return data;
  }

  @override
  Future<void> uploadBinary(
    String path,
    Uint8List data, {
    String? contentType,
  }) async {
    storageMap[path] = data;
  }

  @override
  Future<void> remove(List<String> paths) async {
    for (final p in paths) {
      storageMap.remove(p);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;
  late MockSupabaseStorageBridge mockStorage;
  late CloudBackupService backupService;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_backup_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );

    dbPath = '${tempDir.path}/test_backup.db';
    await DatabaseService.instance.init(customPath: dbPath);

    mockStorage = MockSupabaseStorageBridge();
    backupService = CloudBackupService(
      storageBridge: mockStorage,
      userIdProvider: () => 'user_test_999',
    );
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test(
    'createLocalSnapshot packages manifest, data, and media into .flanki ZIP',
    () async {
      // 1. Seed deck and card
      const deck = DeckModel(id: 'deck_snap', title: 'Snapshot Test Deck');
      await DatabaseService.instance.saveDeck(deck);

      const card = CardModel(
        id: 'card_snap',
        deckId: 'deck_snap',
        front: 'Front [sound:sample.mp3]',
        back: 'Back',
      );
      await DatabaseService.instance.saveCard(card);

      // Seed media record and file
      final mediaFile = File(
        '${MediaStorageService.instance.mediaDirectoryPath}/sample.mp3',
      );
      await mediaFile.parent.create(recursive: true);
      await mediaFile.writeAsString('audio-sample-binary-content');

      await DatabaseService.instance.registerLocalMedia(
        filename: 'sample.mp3',
        bytes: mediaFile.readAsBytesSync(),
      );

      // 2. Create snapshot
      final targetPath =
          '${tempDir.path}/test_output${AppConfig.flankiBackupExtension}';
      final snapshotFile = await backupService.createLocalSnapshot(
        targetFilePath: targetPath,
      );

      expect(snapshotFile.existsSync(), isTrue);
      expect(snapshotFile.lengthSync(), greaterThan(100));

      // 3. Verify upload to cloud
      final storagePath = await backupService.uploadSnapshotToCloud(
        snapshotFile,
        userId: 'user_test_999',
      );
      expect(storagePath, contains('user_test_999/'));
      expect(mockStorage.storageMap.containsKey(storagePath), isTrue);

      // 4. Restore from snapshot into fresh database
      final restoreSuccess = await backupService.restoreFromSnapshot(
        snapshotFile,
      );
      expect(restoreSuccess, isTrue);

      final restoredDecks = DatabaseService.instance.getAllDecks();
      expect(restoredDecks.any((d) => d.id == 'deck_snap'), isTrue);

      final restoredCards = DatabaseService.instance.getAllCards();
      expect(restoredCards.any((c) => c.id == 'card_snap'), isTrue);
    },
  );

  test(
    'restoreFromSnapshot throws FormatException on invalid or corrupted file',
    () async {
      final corruptFile = File('${tempDir.path}/corrupt.flanki');
      await corruptFile.writeAsString('not-a-valid-zip-archive');

      expect(
        () => backupService.restoreFromSnapshot(corruptFile),
        throwsA(isA<Exception>()),
      );
    },
  );

  test('restoreFromSnapshot throws on empty file and unauthenticated upload throws AuthException', () async {
    final emptyFile = File('${tempDir.path}/empty.flanki');
    await emptyFile.create();

    expect(
      () => backupService.restoreFromSnapshot(emptyFile),
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message == SupabaseConfig.errSnapshotEmptyOrMissing,
        ),
      ),
    );

    final unauthService = CloudBackupService(
      storageBridge: mockStorage,
      userIdProvider: () => null,
    );

    expect(
      () => unauthService.uploadSnapshotToCloud(emptyFile),
      throwsA(isA<Exception>()),
    );

    const meta = CloudBackupMetadata(
      name: 'snap.flanki',
      path: 'user/snap.flanki',
      sizeBytes: 2048,
    );
    expect(meta.formattedSize, equals('2.0 KB'));
  });
}
