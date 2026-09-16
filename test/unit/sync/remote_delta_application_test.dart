import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/database/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_remote_delta_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
    dbPath = '${tempDir.path}/test_remote.db';
    await DatabaseService.instance.init(customPath: dbPath);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Remote Delta Application Tests (Drift SQLite)', () {
    test('applyRemoteDeltasBatch inserts remote decks & cards without polluting outbox', () async {
      expect(await DatabaseService.instance.getPendingOutboxCount(), equals(0));

      final remoteDecks = [
        {
          'id': 'remote_deck_1',
          'title': 'Remote Spanish',
          'description': 'From Cloud',
          'due_count': 5,
          'new_count': 10,
          'total_count': 15,
          'last_studied': '2026-09-16T10:00:00.000Z',
          'updated_at_hlc': '2026-09-16T10:00:00.000Z_0001_node_server',
          'is_deleted': false,
        },
      ];

      final remoteCards = [
        {
          'id': 'remote_card_1',
          'deck_id': 'remote_deck_1',
          'front': 'Hola',
          'back': 'Hello',
          'reps': 3,
          'interval_days': 7,
          'stability': 4.2,
          'difficulty': 0.25,
          'updated_at_hlc': '2026-09-16T10:00:00.000Z_0001_node_server',
          'is_deleted': false,
        },
      ];

      await DatabaseService.instance.applyRemoteDeltasBatch(
        decks: remoteDecks,
        cards: remoteCards,
      );

      // Verify caches contain the new items
      final decks = DatabaseService.instance.getAllDecks();
      expect(decks.length, equals(1));
      expect(decks.first.id, equals('remote_deck_1'));
      expect(decks.first.title, equals('Remote Spanish'));

      final cards = DatabaseService.instance.getAllCards();
      expect(cards.length, equals(1));
      expect(cards.first.id, equals('remote_card_1'));
      expect(cards.first.front, equals('Hola'));

      // Crucial assertion: Outbox MUST remain 0! Remote deltas must NOT trigger local outbox mutations!
      final outboxCount = await DatabaseService.instance
          .getPendingOutboxCount();
      expect(outboxCount, equals(0));
    });

    test(
      'applyRemoteDeltasBatch handles remote soft-deletes (tombstones)',
      () async {
        // 1. Insert active card first
        await DatabaseService.instance.applyRemoteDeltasBatch(
          cards: [
            {
              'id': 'remote_card_del',
              'deck_id': 'remote_deck_1',
              'front': 'Will be deleted',
              'back': '...',
              'updated_at_hlc': '2026-09-16T10:00:00.000Z_0001_node_server',
              'is_deleted': false,
            },
          ],
        );
        expect(DatabaseService.instance.getAllCards().length, equals(1));

        // 2. Receive deletion tombstone from another device
        await DatabaseService.instance.applyRemoteDeltasBatch(
          cards: [
            {
              'id': 'remote_card_del',
              'deck_id': 'remote_deck_1',
              'front': 'Will be deleted',
              'back': '...',
              'updated_at_hlc': '2026-09-16T11:00:00.000Z_0001_other_device',
              'is_deleted': true,
            },
          ],
        );

        // Cache excludes deleted items
        expect(DatabaseService.instance.getAllCards().isEmpty, isTrue);

        // Raw DB retains tombstone row
        final rawCards = await DatabaseService.instance.db
            .select(DatabaseService.instance.db.cards)
            .get();
        final tombstone = rawCards.firstWhere((c) => c.id == 'remote_card_del');
        expect(tombstone.isDeleted, isTrue);

        // Outbox remains clean
        expect(
          await DatabaseService.instance.getPendingOutboxCount(),
          equals(0),
        );
      },
    );

    test(
      'applyRemoteDeltasBatch applies review logs with idempotency',
      () async {
        final remoteLogs = [
          {
            'card_id': 'card_123',
            'rating': 3,
            'review_time': '2026-09-16T10:30:00.000Z',
            'scheduled_days': 4,
            'elapsed_days': 1,
            'client_log_id': 'log_unique_client_1',
          },
        ];

        await DatabaseService.instance.applyRemoteDeltasBatch(
          reviewLogs: remoteLogs,
        );

        final logs = DatabaseService.instance.getAllReviewLogs();
        expect(logs.length, equals(1));
        expect(logs.first.cardId, equals('card_123'));

        // Apply the same log again (replay/duplicate)
        await DatabaseService.instance.applyRemoteDeltasBatch(
          reviewLogs: remoteLogs,
        );

        // Must not duplicate
        final logsAfter = DatabaseService.instance.getAllReviewLogs();
        expect(logsAfter.length, equals(1));
        expect(
          await DatabaseService.instance.getPendingOutboxCount(),
          equals(0),
        );
      },
    );

    test('applyRemoteDeltasBatch applies grammar progress entries', () async {
      final remoteGrammar = [
        {
          'unit_id': 'unit_cloud_1',
          'exercise_id': 'ex_cloud_1',
          'stability': 3.5,
          'difficulty': 0.2,
          'due': '2026-09-20T00:00:00.000Z',
          'last_studied': '2026-09-16T10:00:00.000Z',
          'reps': 2,
          'lapses': 0,
          'state': 1,
          'is_ghost': false,
          'is_completed': true,
          'last_user_answer': 'has gone',
          'updated_at': '2026-09-16T10:00:00.000Z',
          'updated_at_hlc': '2026-09-16T10:00:00.000Z_0001_server',
          'is_deleted': false,
        },
      ];

      await DatabaseService.instance.applyRemoteDeltasBatch(
        grammarProgress: remoteGrammar,
      );

      final entries = await DatabaseService.instance.db
          .select(DatabaseService.instance.db.grammarProgressEntries)
          .get();
      expect(entries.length, equals(1));
      expect(entries.first.unitId, equals('unit_cloud_1'));
      expect(entries.first.exerciseId, equals('ex_cloud_1'));
      expect(entries.first.lastUserAnswer, equals('has gone'));
      expect(await DatabaseService.instance.getPendingOutboxCount(), equals(0));
    });
  });
}
