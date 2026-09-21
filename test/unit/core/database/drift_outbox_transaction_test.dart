import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/features/grammar/data/grammar_repository.dart';
import 'package:flanki/features/grammar/models/grammar_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_outbox_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
    dbPath = '${tempDir.path}/test_outbox.db';
    await DatabaseService.instance.init(customPath: dbPath);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Transactional Outbox Tests', () {
    test('saveDeck enqueues UPSERT mutation in sync_outbox', () async {
      const deck = DeckModel(
        id: 'deck_outbox_1',
        title: 'Spanish Basics',
        description: 'Common verbs',
        dueCount: 0,
        newCount: 0,
        totalCount: 0,
      );

      await DatabaseService.instance.saveDeck(deck);

      final count = await DatabaseService.instance.getPendingOutboxCount();
      expect(count, equals(1));

      final batch = await DatabaseService.instance.getPendingOutboxBatch();
      expect(batch.length, equals(1));
      final outboxItem = batch.first;
      expect(outboxItem.entityType, equals('deck'));
      expect(outboxItem.entityId, equals('deck_outbox_1'));
      expect(outboxItem.operation, equals('UPSERT'));
      expect(outboxItem.hlc, isNotEmpty);

      final payload =
          jsonDecode(outboxItem.payloadJson) as Map<String, dynamic>;
      expect(payload['id'], equals('deck_outbox_1'));
      expect(payload['title'], equals('Spanish Basics'));
    });

    test('deleteDeck soft deletes deck and enqueues DELETE mutation', () async {
      const deck = DeckModel(
        id: 'deck_outbox_2',
        title: 'To Delete',
        description: 'Will be deleted',
        dueCount: 0,
        newCount: 0,
        totalCount: 0,
      );
      await DatabaseService.instance.saveDeck(deck);

      // Delete deck
      await DatabaseService.instance.deleteDeck('deck_outbox_2');

      // Cache should no longer have the deck
      expect(
        DatabaseService.instance.getAllDecks().any(
          (d) => d.id == 'deck_outbox_2',
        ),
        isFalse,
      );

      // In DB, deck row still exists as tombstone (is_deleted = true)
      final rawDecks = await DatabaseService.instance.db
          .select(DatabaseService.instance.db.decks)
          .get();
      final deletedDeckRow = rawDecks.firstWhere(
        (d) => d.id == 'deck_outbox_2',
      );
      expect(deletedDeckRow.isDeleted, isTrue);

      final batch = await DatabaseService.instance.getPendingOutboxBatch();
      final deleteItem = batch.firstWhere(
        (b) => b.operation == 'DELETE' && b.entityId == 'deck_outbox_2',
      );
      expect(deleteItem.entityType, equals('deck'));
    });

    test('saveCard enqueues UPSERT mutation in sync_outbox', () async {
      const card = CardModel(
        id: 'card_outbox_1',
        deckId: 'deck_1',
        front: 'Front text',
        back: 'Back text',
      );

      await DatabaseService.instance.saveCard(card);

      final batch = await DatabaseService.instance.getPendingOutboxBatch();
      final outboxCard = batch.firstWhere((b) => b.entityId == 'card_outbox_1');
      expect(outboxCard.entityType, equals('card'));
      expect(outboxCard.operation, equals('UPSERT'));

      final payload =
          jsonDecode(outboxCard.payloadJson) as Map<String, dynamic>;
      expect(payload['front'], equals('Front text'));
      expect(payload['back'], equals('Back text'));
    });

    test('deleteCard soft deletes card and enqueues DELETE mutation', () async {
      const card = CardModel(
        id: 'card_to_del_1',
        deckId: 'deck_1',
        front: 'Delete me',
        back: 'Now',
      );
      await DatabaseService.instance.saveCard(card);

      await DatabaseService.instance.deleteCard('card_to_del_1');

      // Cache does not return deleted card
      expect(
        DatabaseService.instance.getAllCards().any(
          (c) => c.id == 'card_to_del_1',
        ),
        isFalse,
      );

      // In DB, card row still exists with isDeleted = true
      final rawCards = await DatabaseService.instance.db
          .select(DatabaseService.instance.db.cards)
          .get();
      final deletedRow = rawCards.firstWhere((c) => c.id == 'card_to_del_1');
      expect(deletedRow.isDeleted, isTrue);

      final batch = await DatabaseService.instance.getPendingOutboxBatch();
      final deleteItem = batch.firstWhere(
        (b) => b.operation == 'DELETE' && b.entityId == 'card_to_del_1',
      );
      expect(deleteItem.entityType, equals('card'));
    });

    test('insertReviewLog enqueues INSERT mutation with clientLogId', () async {
      final reviewTime = DateTime.utc(2026, 9, 16, 10, 0, 0);
      await DatabaseService.instance.insertReviewLog(
        cardId: 'card_rev_1',
        rating: ReviewRating.good,
        reviewTime: reviewTime,
        scheduledDays: 3,
        elapsedDays: 1,
      );

      final batch = await DatabaseService.instance.getPendingOutboxBatch();
      final revlogItem = batch.firstWhere((b) => b.entityType == 'review_log');
      expect(revlogItem.operation, equals('INSERT'));

      final payload =
          jsonDecode(revlogItem.payloadJson) as Map<String, dynamic>;
      expect(payload['card_id'], equals('card_rev_1'));
      expect(payload['rating'], equals(ReviewRating.good.value));
      expect(payload['scheduled_days'], equals(3));
      expect(payload['client_log_id'], isNotEmpty);
    });

    test('acknowledgeOutboxBatch removes acknowledged entries', () async {
      const deck = DeckModel(
        id: 'deck_ack_1',
        title: 'Ack Test',
        description: '',
        dueCount: 0,
        newCount: 0,
        totalCount: 0,
      );
      await DatabaseService.instance.saveDeck(deck);

      var batch = await DatabaseService.instance.getPendingOutboxBatch();
      expect(batch.isNotEmpty, isTrue);

      final idsToAck = batch.map((b) => b.id).toList();
      await DatabaseService.instance.acknowledgeOutboxBatch(idsToAck);

      final count = await DatabaseService.instance.getPendingOutboxCount();
      expect(count, equals(0));
    });

    test('sync cursors store and update cursor per entity', () async {
      expect(await DatabaseService.instance.getSyncCursor('deck'), isNull);

      const sampleHlc = '2026-09-16T12:00:00.000Z_0000_node1';
      await DatabaseService.instance.setSyncCursor('deck', sampleHlc);

      expect(
        await DatabaseService.instance.getSyncCursor('deck'),
        equals(sampleHlc),
      );
      expect(await DatabaseService.instance.getSyncCursor('card'), isNull);
    });

    test('GrammarRepository enqueues progress into sync_outbox', () async {
      final repo = GrammarRepository(DatabaseService.instance.db);
      await repo.init();

      final model = GrammarProgressModel(
        unitId: 'unit_01',
        exerciseId: 'ex_01',
        stability: 2.5,
        difficulty: 0.3,
        due: DateTime.utc(2026, 9, 20),
        lastStudied: DateTime.utc(2026, 9, 16),
        reps: 1,
        lapses: 0,
        state: CardState.review,
        isGhost: false,
        isCompleted: true,
        lastUserAnswer: 'is',
        updatedAt: DateTime.utc(2026, 9, 16),
      );

      await repo.saveProgress(model);

      final batch = await DatabaseService.instance.getPendingOutboxBatch();
      final grammarItem = batch.firstWhere(
        (b) => b.entityType == 'grammar_progress',
      );
      expect(grammarItem.operation, equals('UPSERT'));
      expect(grammarItem.entityId, equals('unit_01_ex_01'));

      final payload =
          jsonDecode(grammarItem.payloadJson) as Map<String, dynamic>;
      expect(payload['unit_id'], equals('unit_01'));
      expect(payload['exercise_id'], equals('ex_01'));
      expect(payload['is_completed'], isTrue);
    });
  });
}
