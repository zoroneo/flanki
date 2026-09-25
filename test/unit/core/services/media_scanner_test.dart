import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/database/media_storage_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/services/media_scanner_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;
  late MediaScannerService scanner;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_scanner_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );

    dbPath = '${tempDir.path}/test_scanner.db';
    await DatabaseService.instance.init(customPath: dbPath);
    await MediaStorageService.instance.init(
      customPath: '${tempDir.path}/media',
    );

    scanner = MediaScannerService(
      dbService: DatabaseService.instance,
      mediaStorage: MediaStorageService.instance,
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

  group('MediaScannerService - extractMediaFilenames', () {
    test('extracts [sound:filename.mp3] and <img src="filename.png">', () {
      const html = '''
        <div>Hello [sound:pronounce.mp3]</div>
        <img src="cat.png" alt="cat" />
        <img src='sub/dog.jpg' />
        <p>[sound:bell.wav]</p>
        <img src="https://example.com/remote.png" />
      ''';

      final filenames = MediaScannerService.extractMediaFilenames(html);
      expect(filenames, contains('pronounce.mp3'));
      expect(filenames, contains('cat.png'));
      expect(filenames, contains('dog.jpg'));
      expect(filenames, contains('bell.wav'));
      // Should exclude remote HTTP URLs
      expect(filenames.contains('remote.png'), isFalse);
    });
  });

  group('MediaScannerService - autoRegisterCardMedia', () {
    test(
      'registers local disk media referenced in cards into UserMedia registry',
      () async {
        // 1. Create file on disk
        final sampleBytes = Uint8List.fromList([1, 2, 3]);
        await MediaStorageService.instance.saveMediaFile(
          'flag.png',
          sampleBytes,
        );

        // 2. Prepare card referencing it
        final card = CardModel(
          id: 'c1',
          deckId: 'd1',
          front: 'What flag is this? <img src="flag.png">',
          back: 'Vietnam [sound:anthem.mp3]',
          createdAt: DateTime.now(),
        );

        // 3. Run auto-register
        final registered = await scanner.autoRegisterCardMedia([card]);
        expect(
          registered,
          equals(1),
        ); // flag.png exists on disk, anthem.mp3 does not

        // Verify flag.png is in UserMedia
        final media = await DatabaseService.instance.getUserMedia('flag.png');
        expect(media, isNotNull);
        expect(media!.sizeBytes, equals(sampleBytes.length));
      },
    );
  });

  group('MediaScannerService - orphan detection & cleanup', () {
    test('finds and cleans orphan files', () async {
      // Create 2 files
      await MediaStorageService.instance.saveMediaFile('used.png', [1, 2]);
      await MediaStorageService.instance.saveMediaFile('orphan.png', [3, 4]);

      // Only used.png is referenced
      final card = CardModel(
        id: 'c2',
        deckId: 'd1',
        front: '<img src="used.png">',
        back: 'Used answer',
        createdAt: DateTime.now(),
      );

      final orphans = await scanner.findOrphanMediaFiles([card]);
      expect(orphans.length, equals(1));
      expect(orphans.first.path.endsWith('orphan.png'), isTrue);

      final cleanedCount = await scanner.cleanOrphanMediaFiles([card]);
      expect(cleanedCount, equals(1));

      final orphansAfter = await scanner.findOrphanMediaFiles([card]);
      expect(orphansAfter, isEmpty);
    });
  });
}
