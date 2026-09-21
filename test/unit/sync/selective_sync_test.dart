import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/deck.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'flanki_selective_sync_test_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
    dbPath = '${tempDir.path}/test_selective.db';
    await DatabaseService.instance.init(customPath: dbPath);

    // Clear existing outbox and cache
    final pending = await DatabaseService.instance.getPendingOutboxBatch(
      limit: 1000,
    );
    await DatabaseService.instance.acknowledgeOutboxBatch(
      pending.map((p) => p.id).toList(),
    );
  });

  tearDown(() async {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test(
    'Deck defaults to isSyncEnabled = true and creates outbox on save',
    () async {
      const deck = DeckModel(
        id: 'deck_enabled',
        title: 'Synced Deck',
        isSyncEnabled: true,
      );
      await DatabaseService.instance.saveDeck(deck);

      final outbox = await DatabaseService.instance.getPendingOutboxBatch();
      expect(outbox.any((m) => m.entityId == 'deck_enabled'), isTrue);

      // Add card to this synced deck -> should mark outbox
      const card = CardModel(
        id: 'card_1',
        deckId: 'deck_enabled',
        front: 'Front',
        back: 'Back',
      );
      await DatabaseService.instance.saveCard(card);

      final outbox2 = await DatabaseService.instance.getPendingOutboxBatch();
      expect(outbox2.any((m) => m.entityId == 'card_1'), isTrue);
    },
  );

  test(
    'Deck with isSyncEnabled = false excludes cards from outbox mutations',
    () async {
      const deck = DeckModel(
        id: 'deck_disabled',
        title: 'Local Only Deck',
        isSyncEnabled: false,
      );
      await DatabaseService.instance.saveDeck(deck);

      // Clear outbox from deck creation
      final initialOutbox = await DatabaseService.instance
          .getPendingOutboxBatch();
      await DatabaseService.instance.acknowledgeOutboxBatch(
        initialOutbox.map((p) => p.id).toList(),
      );

      // Save single card into local-only deck
      const card = CardModel(
        id: 'card_local_1',
        deckId: 'deck_disabled',
        front: 'Front Local',
        back: 'Back Local',
      );
      await DatabaseService.instance.saveCard(card);

      final outboxAfterCard = await DatabaseService.instance
          .getPendingOutboxBatch();
      expect(outboxAfterCard.any((m) => m.entityId == 'card_local_1'), isFalse);

      // Save batch cards into local-only deck
      const card2 = CardModel(
        id: 'card_local_2',
        deckId: 'deck_disabled',
        front: 'Front Local 2',
        back: 'Back Local 2',
      );
      await DatabaseService.instance.saveCards([card2]);

      final outboxAfterBatch = await DatabaseService.instance
          .getPendingOutboxBatch();
      expect(
        outboxAfterBatch.any((m) => m.entityId == 'card_local_2'),
        isFalse,
      );

      // Delete card in local-only deck -> no outbox
      await DatabaseService.instance.deleteCard('card_local_1');
      final outboxAfterDelete = await DatabaseService.instance
          .getPendingOutboxBatch();
      expect(
        outboxAfterDelete.any((m) => m.entityId == 'card_local_1'),
        isFalse,
      );
    },
  );

  test(
    'toggleDeckSync(deckId, true) enqueues deck and all cards into outbox',
    () async {
      const deck = DeckModel(
        id: 'deck_toggle',
        title: 'Toggled Deck',
        isSyncEnabled: false,
      );
      await DatabaseService.instance.saveDeck(deck);

      const card1 = CardModel(
        id: 'card_t1',
        deckId: 'deck_toggle',
        front: 'Q1',
        back: 'A1',
      );
      const card2 = CardModel(
        id: 'card_t2',
        deckId: 'deck_toggle',
        front: 'Q2',
        back: 'A2',
      );
      await DatabaseService.instance.saveCards([card1, card2]);

      // Clear any outbox
      final initialOutbox = await DatabaseService.instance
          .getPendingOutboxBatch();
      await DatabaseService.instance.acknowledgeOutboxBatch(
        initialOutbox.map((p) => p.id).toList(),
      );

      // Toggle sync from false to true
      await DatabaseService.instance.toggleDeckSync('deck_toggle', true);

      final outboxAfterToggle = await DatabaseService.instance
          .getPendingOutboxBatch();
      expect(outboxAfterToggle.any((m) => m.entityId == 'deck_toggle'), isTrue);
      expect(outboxAfterToggle.any((m) => m.entityId == 'card_t1'), isTrue);
      expect(outboxAfterToggle.any((m) => m.entityId == 'card_t2'), isTrue);

      // Verify deck model reflects sync status
      final refreshedDeck = DatabaseService.instance.getAllDecks().firstWhere(
        (d) => d.id == 'deck_toggle',
      );
      expect(refreshedDeck.isSyncEnabled, isTrue);
    },
  );
}
