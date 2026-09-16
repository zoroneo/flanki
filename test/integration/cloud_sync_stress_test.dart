import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/models/card.dart' as app_card;
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/sync/supabase_sync_engine.dart';
import 'package:flanki/core/sync/sync_replicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/virtual_sync_cluster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseCloudHub cloudHub;
  late VirtualSyncNode nodeA;
  late VirtualSyncNode nodeB;

  setUp(() async {
    cloudHub = MockSupabaseCloudHub();
    cloudHub.user = const User(
      id: 'test_user_stress',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-09-16T12:00:00.000Z',
    );

    nodeA = VirtualSyncNode(nodeId: 'stress_node_A', cloudHub: cloudHub);
    nodeB = VirtualSyncNode(nodeId: 'stress_node_B', cloudHub: cloudHub);

    await nodeA.init();
    await nodeB.init();
  });

  tearDown(() async {
    await nodeA.close();
    await nodeB.close();
  });

  group('Cloud Sync Stress & High Throughput Tests', () {
    test('Batch chunking: 1,000 cards are segmented into 100-item chunks and fully drained', () async {
      const deck = DeckModel(id: 'deck_stress_1000', title: 'Stress Deck 1000');
      await nodeA.dbService.saveDeck(deck);

      // Generate 1,000 cards
      final cards = List.generate(
        1000,
        (i) => app_card.CardModel(
          id: 'card_stress_$i',
          deckId: deck.id,
          front: 'Question $i for stress testing',
          back: 'Answer $i for stress testing',
        ),
      );

      await nodeA.dbService.saveCards(cards);

      // Verify outbox has 1,001 entries (1 deck + 1,000 cards)
      final pendingBefore = await nodeA.dbService.getPendingOutboxCount();
      expect(pendingBefore, equals(1001));

      // Push mutations with batchLimit = 100
      final pushedCount = await nodeA.engine.pushMutations(batchLimit: 100);
      expect(pushedCount, equals(1001));

      // Cloud hub should have received 11 push batches (10 * 100 + 1)
      expect(cloudHub.pushCount, equals(11));
      expect(cloudHub.cards.length, equals(1000));
      expect(cloudHub.decks.length, equals(1));

      // Local outbox must be completely drained
      final pendingAfter = await nodeA.dbService.getPendingOutboxCount();
      expect(pendingAfter, equals(0));

      // Device B pulls all 1,000 cards
      final pulledCount = await nodeB.engine.pullDeltas();
      expect(pulledCount, equals(1001));

      final nodeBCards = nodeB.dbService.getCardsForDeck(deck.id);
      expect(nodeBCards.length, equals(1000));
    });

    test('Burst reviews debounce: 100 rapid mutations within 50ms trigger only 1 sync cycle', () async {
      int syncCycleCount = 0;

      final replicator = SyncReplicator(engine: nodeA.engine);
      replicator.onStatusChanged = (status, result) {
        if (status == SyncStatus.syncing) {
          syncCycleCount++;
        }
      };

      // Simulate 100 rapid study reviews firing every 1ms
      for (int i = 0; i < 100; i++) {
        replicator.notifyMutationEnqueued(
          debounce: const Duration(milliseconds: 40),
        );
        await Future.delayed(const Duration(milliseconds: 1));
      }

      // Before debounce window (40ms) expires: no sync should have run yet
      expect(syncCycleCount, equals(0));

      // Wait past debounce threshold
      await Future.delayed(const Duration(milliseconds: 70));

      // Exactly 1 sync cycle should have executed
      expect(syncCycleCount, equals(1));

      replicator.stop();
    });

    test('Massive review logs replication without data loss', () async {
      const deck = DeckModel(
        id: 'deck_revlog_stress',
        title: 'Revlog Stress Deck',
      );
      final card = app_card.CardModel(
        id: 'card_parent',
        deckId: deck.id,
        front: 'QP',
        back: 'AP',
      );
      await nodeA.dbService.saveDeck(deck);
      await nodeA.dbService.saveCard(card);
      await nodeA.engine.sync();

      // Generate 200 review logs
      final baseTime = DateTime.utc(2026, 9, 16, 0, 0, 0);
      for (int i = 0; i < 200; i++) {
        await nodeA.dbService.insertReviewLog(
          cardId: card.id,
          rating: app_card.ReviewRating.good,
          reviewTime: baseTime.add(Duration(minutes: i)),
          scheduledDays: i + 1,
          elapsedDays: 1,
        );
      }

      await nodeA.engine.sync();
      expect(cloudHub.reviewLogs.length, equals(200));

      // Device B pulls all review logs
      await nodeB.engine.sync();
      final nodeBLogs = nodeB.dbService.getAllReviewLogs();
      expect(nodeBLogs.length, equals(200));
    });
  });
}
