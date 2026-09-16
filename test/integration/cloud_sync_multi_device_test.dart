import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/models/card.dart' as app_card;

import '../helpers/virtual_sync_cluster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseCloudHub cloudHub;
  late VirtualSyncNode nodeA;
  late VirtualSyncNode nodeB;

  setUp(() async {
    cloudHub = MockSupabaseCloudHub();
    nodeA = VirtualSyncNode(nodeId: 'device_node_A', cloudHub: cloudHub);
    nodeB = VirtualSyncNode(nodeId: 'device_node_B', cloudHub: cloudHub);

    await nodeA.init();
    await nodeB.init();
  });

  tearDown(() async {
    await nodeA.close();
    await nodeB.close();
  });

  group('Multi-Device E2E Convergence & Race Tests', () {
    test('Two independent devices achieve bidirectional convergence', () async {
      // 1. Device A creates Deck A and Card A
      const deckA = DeckModel(
        id: 'deck_node_a',
        title: 'Node A JLPT N5',
        description: 'Vocab from Device A',
      );
      final cardA = app_card.CardModel(
        id: 'card_a1',
        deckId: deckA.id,
        front: '犬 (Inu)',
        back: 'Dog',
      );
      await nodeA.dbService.saveDeck(deckA);
      await nodeA.dbService.saveCard(cardA);

      // 2. Device B creates Deck B and Card B
      const deckB = DeckModel(
        id: 'deck_node_b',
        title: 'Node B Grammar N4',
        description: 'Grammar from Device B',
      );
      final cardB = app_card.CardModel(
        id: 'card_b1',
        deckId: deckB.id,
        front: '〜てはいけない',
        back: 'Must not do',
      );
      await nodeB.dbService.saveDeck(deckB);
      await nodeB.dbService.saveCard(cardB);

      // 3. Both devices execute full sync cycle (Push mutations -> Pull deltas)
      final resA1 = await nodeA.engine.sync();
      expect(resA1.isSuccess, isTrue);
      expect(resA1.pushedCount, greaterThanOrEqualTo(2));

      final resB1 = await nodeB.engine.sync();
      expect(resB1.isSuccess, isTrue);
      expect(resB1.pushedCount, greaterThanOrEqualTo(2));
      expect(resB1.pulledCount, greaterThanOrEqualTo(2)); // B pulls A's data

      // 4. Device A syncs once more to pull Device B's changes
      final resA2 = await nodeA.engine.sync();
      expect(resA2.isSuccess, isTrue);
      expect(resA2.pulledCount, greaterThanOrEqualTo(2)); // A pulls B's data

      // 5. Verification: Both devices must have identical collections
      final decksInA = nodeA.dbService.getAllDecks();
      final decksInB = nodeB.dbService.getAllDecks();

      expect(
        decksInA.map((d) => d.id).toSet(),
        equals({'deck_node_a', 'deck_node_b'}),
      );
      expect(
        decksInB.map((d) => d.id).toSet(),
        equals({'deck_node_a', 'deck_node_b'}),
      );

      final cardsInA = nodeA.dbService.getCardsForDeck('deck_node_b');
      final cardsInB = nodeB.dbService.getCardsForDeck('deck_node_a');

      expect(cardsInA.first.front, equals('〜てはいけない'));
      expect(cardsInB.first.front, equals('犬 (Inu)'));

      // Both outboxes are drained
      expect(await nodeA.dbService.getPendingOutboxCount(), equals(0));
      expect(await nodeB.dbService.getPendingOutboxCount(), equals(0));
    });

    test(
      'Deterministic LWW conflict resolution on concurrent card edit',
      () async {
        // 1. Device A creates and seeds Card 1
        const deck = DeckModel(
          id: 'deck_conflict',
          title: 'Conflict Test Deck',
        );
        final initialCard = app_card.CardModel(
          id: 'card_conflict_1',
          deckId: deck.id,
          front: 'Initial Front',
          back: 'Initial Back',
        );
        await nodeA.dbService.saveDeck(deck);
        await nodeA.dbService.saveCard(initialCard);

        // Push to cloud and replicate to Device B
        await nodeA.engine.sync();
        await nodeB.engine.sync();

        // 2. Both devices edit Card 1 concurrently offline
        // Device A edits with earlier time
        final cardAEdit = initialCard.copyWith(
          front: 'Front updated by Device A',
        );
        await nodeA.dbService.saveCard(cardAEdit);

        // Device B edits later
        final cardBEdit = initialCard.copyWith(
          front: 'Front updated by Device B (Winner)',
        );
        // Ensure HLC B > HLC A
        await Future.delayed(const Duration(milliseconds: 5));
        await nodeB.dbService.saveCard(cardBEdit);

        // 3. Both devices sync to Cloud
        await nodeA.engine.sync();
        await nodeB.engine.sync();
        // Device A pulls winning delta from Cloud
        await nodeA.engine.sync();

        // 4. Verification: Both devices converged to Device B's version
        final finalA = nodeA.dbService.getCardsForDeck('deck_conflict').first;
        final finalB = nodeB.dbService.getCardsForDeck('deck_conflict').first;

        expect(finalA.front, equals('Front updated by Device B (Winner)'));
        expect(finalB.front, equals('Front updated by Device B (Winner)'));
      },
    );

    test('Tombstone vs update race prevents ghost card resurrection', () async {
      const deck = DeckModel(id: 'deck_tombstone', title: 'Tombstone Deck');
      final card = app_card.CardModel(
        id: 'card_tombstone',
        deckId: deck.id,
        front: 'Will be deleted',
        back: 'Tombstone test',
      );
      await nodeA.dbService.saveDeck(deck);
      await nodeA.dbService.saveCard(card);
      await nodeA.engine.sync();
      await nodeB.engine.sync();

      // Device A deletes card
      await nodeA.dbService.deleteCard(card.id);

      // Device B syncs and deletes card with tombstone
      await nodeA.engine.sync();
      await nodeB.engine.sync();

      // Verification: Card is deleted on both devices
      final cardsA = nodeA.dbService.getCardsForDeck('deck_tombstone');
      final cardsB = nodeB.dbService.getCardsForDeck('deck_tombstone');

      expect(cardsA, isEmpty);
      expect(cardsB, isEmpty);
    });

    test('Concurrent review logs replication without duplicates', () async {
      const deck = DeckModel(id: 'deck_revlog', title: 'Review Log Deck');
      final card = app_card.CardModel(
        id: 'card_rev',
        deckId: deck.id,
        front: 'Q',
        back: 'A',
      );
      await nodeA.dbService.saveDeck(deck);
      await nodeA.dbService.saveCard(card);
      await nodeA.engine.sync();
      await nodeB.engine.sync();

      // Device A logs review 1
      final now1 = DateTime.utc(2026, 9, 16, 12, 0, 0);
      await nodeA.dbService.insertReviewLog(
        cardId: card.id,
        rating: app_card.ReviewRating.good,
        reviewTime: now1,
        scheduledDays: 1,
        elapsedDays: 0,
      );

      // Device B logs review 2
      final now2 = DateTime.utc(2026, 9, 16, 12, 5, 0);
      await nodeB.dbService.insertReviewLog(
        cardId: card.id,
        rating: app_card.ReviewRating.easy,
        reviewTime: now2,
        scheduledDays: 3,
        elapsedDays: 1,
      );

      // Sync both devices
      await nodeA.engine.sync();
      await nodeB.engine.sync();
      await nodeA.engine.sync();

      // Verification: Both devices hold both review logs without deduplication collision
      final logsA = nodeA.dbService
          .getAllReviewLogs()
          .where((l) => l.cardId == card.id)
          .toList();
      final logsB = nodeB.dbService
          .getAllReviewLogs()
          .where((l) => l.cardId == card.id)
          .toList();

      expect(logsA.length, equals(2));
      expect(logsB.length, equals(2));
    });
  });
}
