import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_service.dart';
import '../../../core/sync/supabase_sync_engine.dart';
import '../../../core/sync/sync_replicator.dart';

import '../models/sync_ui_state.dart';

export '../models/sync_ui_state.dart';

final syncEngineProvider = Provider<SupabaseSyncEngine>((ref) {
  return SupabaseSyncEngine();
});

final syncReplicatorProvider = Provider<SyncReplicator>((ref) {
  final engine = ref.read(syncEngineProvider);
  final replicator = SyncReplicator(engine: engine);
  ref.onDispose(() {
    replicator.dispose();
  });
  return replicator;
});

final syncStateNotifierProvider =
    NotifierProvider<SyncStateNotifier, SyncUiState>(SyncStateNotifier.new);

class SyncStateNotifier extends Notifier<SyncUiState> {
  late final SyncReplicator _replicator;

  @override
  SyncUiState build() {
    _replicator = ref.read(syncReplicatorProvider);

    _replicator.onStatusChanged = (status, result) {
      final now = status == SyncStatus.synced
          ? DateTime.now()
          : state.lastSyncedAt;
      state = state.copyWith(
        status: status,
        lastSyncedAt: now,
        errorMessage: result?.error,
      );
      refreshPendingCount();
    };

    refreshPendingCount();

    return const SyncUiState();
  }

  Future<void> refreshPendingCount() async {
    final count = await DatabaseService.instance.getPendingOutboxCount();
    state = state.copyWith(pendingCount: count);
  }

  Future<SyncResult> syncNow() async {
    return _replicator.syncNow();
  }
}
