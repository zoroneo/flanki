import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flanki/core/sync/supabase_sync_engine.dart';
import 'package:flanki/core/sync/sync_replicator.dart';

class FakeRpcClient implements SupabaseRpcClient {
  @override
  User? get currentUser => null;

  @override
  Future<dynamic> rpc(String function, {Map<String, dynamic>? params}) async =>
      {};
}

class FakeSyncEngine extends SupabaseSyncEngine {
  int syncCallCount = 0;
  SyncResult nextResult = const SyncResult(
    isSuccess: true,
    pushedCount: 1,
    pulledCount: 2,
  );
  Duration delay = Duration.zero;

  FakeSyncEngine() : super(rpcClient: FakeRpcClient());

  @override
  Future<SyncResult> sync() async {
    syncCallCount++;
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    return nextResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSyncEngine fakeEngine;
  late SyncReplicator replicator;

  setUp(() {
    fakeEngine = FakeSyncEngine();
    replicator = SyncReplicator(engine: fakeEngine);
  });

  tearDown(() {
    replicator.dispose();
  });

  group('SyncReplicator Tests', () {
    test(
      'syncNow() triggers engine.sync and notifies status changes',
      () async {
        final statuses = <SyncStatus>[];
        replicator.onStatusChanged = (status, result) {
          statuses.add(status);
        };

        final result = await replicator.syncNow();

        expect(result.isSuccess, isTrue);
        expect(fakeEngine.syncCallCount, equals(1));
        expect(statuses, equals([SyncStatus.syncing, SyncStatus.synced]));
      },
    );

    test('syncNow() handles failure status notification', () async {
      fakeEngine.nextResult = SyncResult.failure('Server Error');

      final statuses = <SyncStatus>[];
      replicator.onStatusChanged = (status, result) {
        statuses.add(status);
      };

      final result = await replicator.syncNow();

      expect(result.isSuccess, isFalse);
      expect(statuses, equals([SyncStatus.syncing, SyncStatus.error]));
    });

    test('syncNow() handles offline status notification', () async {
      fakeEngine.nextResult = SyncResult.offline();

      final statuses = <SyncStatus>[];
      replicator.onStatusChanged = (status, result) {
        statuses.add(status);
      };

      final result = await replicator.syncNow();

      expect(result.isOffline, isTrue);
      expect(statuses, equals([SyncStatus.syncing, SyncStatus.offline]));
    });

    test('prevents concurrent sync executions', () async {
      fakeEngine.delay = const Duration(milliseconds: 50);

      final future1 = replicator.syncNow();
      final future2 = replicator.syncNow();

      final res2 = await future2;
      expect(res2.isSuccess, isFalse);
      expect(res2.error, contains('already in progress'));

      final res1 = await future1;
      expect(res1.isSuccess, isTrue);
      expect(fakeEngine.syncCallCount, equals(1));
    });

    test('notifyMutationEnqueued debounces rapid triggers', () async {
      replicator.notifyMutationEnqueued(
        debounce: const Duration(milliseconds: 30),
      );
      replicator.notifyMutationEnqueued(
        debounce: const Duration(milliseconds: 30),
      );
      replicator.notifyMutationEnqueued(
        debounce: const Duration(milliseconds: 30),
      );

      expect(fakeEngine.syncCallCount, equals(0));

      await Future.delayed(const Duration(milliseconds: 60));

      expect(fakeEngine.syncCallCount, equals(1));
    });

    test('start and stop manage periodic timer', () async {
      replicator.start(
        periodicInterval: const Duration(milliseconds: 25),
        attachLifecycle: false,
      );

      await Future.delayed(const Duration(milliseconds: 65));
      expect(fakeEngine.syncCallCount, greaterThanOrEqualTo(2));

      replicator.stop();
      final countAtStop = fakeEngine.syncCallCount;

      await Future.delayed(const Duration(milliseconds: 50));
      expect(fakeEngine.syncCallCount, equals(countAtStop));
    });
  });
}
