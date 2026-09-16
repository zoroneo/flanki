import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/models/card.dart' as app_card;
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/sync/hlc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/virtual_sync_cluster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HLC Clock Drift & Chaos Fault Hardening Tests', () {
    test('Clock Backward Drift: 30 days rewound clock maintains strict monotonicity', () {
      final t0 = DateTime.utc(2026, 9, 16, 12, 0, 0).millisecondsSinceEpoch;
      final hlc0 = Hlc.now('node1', wallTime: t0);

      // System clock is rewound 30 days back into the past
      final tPast = t0 - const Duration(days: 30).inMilliseconds;

      final hlc1 = Hlc.send(hlc0, 'node1', wallTime: tPast);
      final hlc2 = Hlc.send(hlc1, 'node1', wallTime: tPast);
      final hlc3 = Hlc.send(hlc2, 'node1', wallTime: tPast);

      // Physical millis must freeze at t0 (highest wallTime seen)
      expect(hlc1.millis, equals(t0));
      expect(hlc2.millis, equals(t0));
      expect(hlc3.millis, equals(t0));

      // Logical counters must increment monotonically
      expect(hlc1.counter, equals(1));
      expect(hlc2.counter, equals(2));
      expect(hlc3.counter, equals(3));

      // String packing preserves lexicographical comparison
      expect(hlc1.compareTo(hlc0), greaterThan(0));
      expect(hlc2.compareTo(hlc1), greaterThan(0));
      expect(hlc3.compareTo(hlc2), greaterThan(0));
      expect(hlc3.pack().compareTo(hlc2.pack()), greaterThan(0));
    });

    test('Clock Forward Drift: throws ClockDriftException when remote HLC exceeds threshold', () {
      final now = DateTime.utc(2026, 9, 16, 12, 0, 0).millisecondsSinceEpoch;
      final localHlc = Hlc.now('node1', wallTime: now);

      // Remote message from 1 year in the future (365 days)
      final futureOneYear = now + const Duration(days: 365).inMilliseconds;
      final remoteHlcFuture = Hlc(futureOneYear, 0, 'remote_node');

      expect(
        () => Hlc.recv(localHlc, remoteHlcFuture, 'node1', wallTime: now),
        throwsA(isA<ClockDriftException>()),
      );

      // Within allowable threshold (e.g. 15 seconds drift with 60s max drift)
      final acceptableFuture = now + const Duration(seconds: 15).inMilliseconds;
      final remoteAcceptable = Hlc(acceptableFuture, 0, 'remote_node');

      final mergedHlc = Hlc.recv(
        localHlc,
        remoteAcceptable,
        'node1',
        wallTime: now,
      );
      expect(mergedHlc.millis, equals(acceptableFuture));
      expect(mergedHlc.compareTo(localHlc), greaterThan(0));
    });

    test('Chaos network: commit-before-ACK drop retries idempotently without duplicate records', () async {
      final cloudHub = MockSupabaseCloudHub();
      cloudHub.user = const User(
        id: 'test_user_chaos',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-09-16T12:00:00.000Z',
      );

      final nodeA = VirtualSyncNode(nodeId: 'chaos_node_A', cloudHub: cloudHub);
      final nodeB = VirtualSyncNode(nodeId: 'chaos_node_B', cloudHub: cloudHub);
      await nodeA.init();
      await nodeB.init();

      try {
        const deck = DeckModel(id: 'deck_chaos', title: 'Chaos Deck');
        final card = app_card.CardModel(
          id: 'card_chaos_1',
          deckId: deck.id,
          front: 'Network failure front',
          back: 'Network failure back',
        );

        await nodeA.dbService.saveDeck(deck);
        await nodeA.dbService.saveCard(card);

        expect(await nodeA.dbService.getPendingOutboxCount(), equals(2));

        // Inject network drop after server commits mutation
        cloudHub.failPushAfterCommit = true;

        // Node A attempts sync -> fails due to network drop before receiving ACK
        final firstResult = await nodeA.engine.sync();
        expect(firstResult.isSuccess, isFalse);

        // Server already has the records
        expect(cloudHub.decks.containsKey('deck_chaos'), isTrue);
        expect(cloudHub.cards.containsKey('card_chaos_1'), isTrue);

        // Local Outbox must still have 2 pending mutations (since client never got ACK)
        expect(await nodeA.dbService.getPendingOutboxCount(), equals(2));

        // Node A retries sync under restored network
        final retryResult = await nodeA.engine.sync();
        expect(retryResult.isSuccess, isTrue);

        // Local outbox is now cleared
        expect(await nodeA.dbService.getPendingOutboxCount(), equals(0));

        // Server still has exactly 1 deck and 1 card (idempotent, no duplicates)
        expect(cloudHub.decks.length, equals(1));
        expect(cloudHub.cards.length, equals(1));

        // Device B pulls successfully
        await nodeB.engine.sync();
        final nodeBCards = nodeB.dbService.getCardsForDeck('deck_chaos');
        expect(nodeBCards.length, equals(1));
        expect(nodeBCards.first.front, equals('Network failure front'));
      } finally {
        await nodeA.close();
        await nodeB.close();
      }
    });
  });
}
