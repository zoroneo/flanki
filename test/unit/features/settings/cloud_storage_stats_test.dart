import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/services/cloud_storage_stats_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;
  late CloudStorageStatsService statsService;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_stats_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );

    dbPath = '${tempDir.path}/test_stats.db';
    await DatabaseService.instance.init(customPath: dbPath);

    statsService = CloudStorageStatsService();
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test(
    'StorageStatsModel.formatBytes produces correct human-readable units',
    () {
      expect(StorageStatsModel.formatBytes(500), '500 B');
      expect(StorageStatsModel.formatBytes(2048), '2.0 KB');
      expect(StorageStatsModel.formatBytes(5 * 1024 * 1024), '5.0 MB');
      expect(StorageStatsModel.formatBytes(2 * 1024 * 1024 * 1024), '2.00 GB');
    },
  );

  test(
    'CloudStorageStatsService calculates local decks and cards counts',
    () async {
      const deck = DeckModel(id: 'deck_stat_1', title: 'Stat Deck');
      await DatabaseService.instance.saveDeck(deck);

      const card = CardModel(
        id: 'card_stat_1',
        deckId: 'deck_stat_1',
        front: 'Front',
        back: 'Back',
      );
      await DatabaseService.instance.saveCard(card);

      final stats = await statsService.getStats();

      expect(stats.localDeckCount, greaterThanOrEqualTo(1));
      expect(stats.localCardCount, greaterThanOrEqualTo(1));
      expect(stats.totalLocalBytes, greaterThanOrEqualTo(0));
    },
  );
}
