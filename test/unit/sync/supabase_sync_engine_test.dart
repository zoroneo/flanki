import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/sync/supabase_sync_engine.dart';

class FakeSupabaseRpcClient implements SupabaseRpcClient {
  @override
  User? currentUser;

  Future<dynamic> Function(String function, Map<String, dynamic>? params)?
  rpcHandler;

  FakeSupabaseRpcClient({this.currentUser, this.rpcHandler});

  @override
  Future<dynamic> rpc(String function, {Map<String, dynamic>? params}) {
    if (rpcHandler != null) {
      return rpcHandler!(function, params);
    }
    return Future.value(<String, dynamic>{});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;
  late FakeSupabaseRpcClient fakeRpcClient;
  late SupabaseSyncEngine syncEngine;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_sync_engine_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
    dbPath = '${tempDir.path}/test_engine.db';
    await DatabaseService.instance.init(customPath: dbPath);

    fakeRpcClient = FakeSupabaseRpcClient(
      currentUser: const User(
        id: 'user_123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-09-16T00:00:00.000Z',
      ),
    );

    syncEngine = SupabaseSyncEngine(
      rpcClient: fakeRpcClient,
      dbService: DatabaseService.instance,
    );
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('SupabaseSyncEngine Tests', () {
    test('sync() returns unauthenticated when no user is logged in', () async {
      fakeRpcClient.currentUser = null;
      final result = await syncEngine.sync();
      expect(result.isSuccess, isFalse);
      expect(result.isUnauthenticated, isTrue);
      expect(result.error, contains('not authenticated'));
    });

    test(
      'pushMutations() sends outbox to RPC and removes acknowledged entries',
      () async {
        // Create local deck to populate outbox
        const deck = DeckModel(
          id: 'deck_push_1',
          title: 'Biology 101',
          description: 'Cells',
          dueCount: 0,
          newCount: 0,
          totalCount: 0,
        );
        await DatabaseService.instance.saveDeck(deck);

        expect(
          await DatabaseService.instance.getPendingOutboxCount(),
          equals(1),
        );

        String? capturedFunction;
        Map<String, dynamic>? capturedParams;

        fakeRpcClient.rpcHandler = (function, params) async {
          capturedFunction = function;
          capturedParams = params;
          final mutations = params?['mutations'] as List<dynamic>;
          final ackIds = mutations
              .map((m) => (m as Map)['id'] as String)
              .toList();
          return {
            'status': 'success',
            'processed_count': ackIds.length,
            'rejected_count': 0,
            'ack_ids': ackIds,
            'server_timestamp': '2026-09-16T12:00:00.000Z',
          };
        };

        final pushedCount = await syncEngine.pushMutations();

        expect(pushedCount, equals(1));
        expect(capturedFunction, equals('sync_push_mutations'));
        expect(capturedParams, isNotNull);
        final sentMutations = capturedParams!['mutations'] as List<dynamic>;
        expect(sentMutations.length, equals(1));
        expect(
          (sentMutations.first as Map)['entity_id'],
          equals('deck_push_1'),
        );

        // Verify outbox was cleared
        expect(
          await DatabaseService.instance.getPendingOutboxCount(),
          equals(0),
        );
      },
    );

    test('pullDeltas() passes stored cursors, applies deltas, and advances cursors', () async {
      // Set initial cursor
      await DatabaseService.instance.setSyncCursor(
        'deck',
        '2026-09-16T08:00:00.000Z_0000_node0',
      );

      fakeRpcClient.rpcHandler = (function, params) async {
        if (function == 'sync_pull_deltas') {
          final cursors = params?['cursors'] as Map<String, dynamic>;
          expect(
            cursors['deck'],
            equals('2026-09-16T08:00:00.000Z_0000_node0'),
          );

          return {
            'decks': [
              {
                'id': 'remote_deck_99',
                'title': 'Anatomy',
                'description': 'Human body',
                'due_count': 2,
                'new_count': 5,
                'total_count': 7,
                'updated_at_hlc': '2026-09-16T11:30:00.000Z_0005_server',
                'is_deleted': false,
              },
            ],
            'cards': [],
            'review_logs': [],
            'grammar_progress': [],
          };
        }
        return {};
      };

      final pulledCount = await syncEngine.pullDeltas();
      expect(pulledCount, equals(1));

      // Verify deck is in database
      final decks = DatabaseService.instance.getAllDecks();
      expect(decks.any((d) => d.id == 'remote_deck_99'), isTrue);

      // Verify cursor advanced to new HLC
      final newCursor = await DatabaseService.instance.getSyncCursor('deck');
      expect(newCursor, equals('2026-09-16T11:30:00.000Z_0005_server'));
    });

    test('sync() handles network exceptions safely and returns SyncResult.offline()', () async {
      fakeRpcClient.rpcHandler = (function, params) async {
        throw const SocketException('Failed host lookup: db.supabase.co');
      };

      final result = await syncEngine.sync();
      expect(result.isSuccess, isFalse);
      expect(result.isOffline, isTrue);
      expect(result.error, contains('Network unavailable'));
    });

    test('sync() full cycle executes push then pull successfully', () async {
      const deck = DeckModel(
        id: 'deck_cycle_1',
        title: 'Chemistry',
        description: 'Periodic table',
        dueCount: 0,
        newCount: 0,
        totalCount: 0,
      );
      await DatabaseService.instance.saveDeck(deck);

      final rpcCalls = <String>[];

      fakeRpcClient.rpcHandler = (function, params) async {
        rpcCalls.add(function);
        if (function == 'sync_push_mutations') {
          final mutations = params?['mutations'] as List<dynamic>;
          return {
            'status': 'success',
            'processed_count': mutations.length,
            'ack_ids': mutations.map((m) => (m as Map)['id']).toList(),
          };
        } else if (function == 'sync_pull_deltas') {
          return {
            'decks': [],
            'cards': [],
            'review_logs': [],
            'grammar_progress': [],
          };
        }
        return {};
      };

      final result = await syncEngine.sync();
      expect(result.isSuccess, isTrue);
      expect(result.pushedCount, equals(1));
      expect(result.pulledCount, equals(0));
      expect(rpcCalls, equals(['sync_push_mutations', 'sync_pull_deltas']));
    });
  });
}
