import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/data_change_bus.dart';
import '../../../core/database/database_service.dart';
import '../../../core/sync/supabase_sync_engine.dart';
import '../../../core/sync/sync_replicator.dart';
import '../models/sync_ui_state.dart';
import 'supabase_auth_notifier.dart';

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
        mediaUploadedCount:
            result?.mediaUploadedCount ?? state.mediaUploadedCount,
        mediaDownloadedCount:
            result?.mediaDownloadedCount ?? state.mediaDownloadedCount,
      );
      refreshPendingCount();
    };

    // When remote deltas (decks/cards/reviews) are pulled and applied, auto-refresh UI
    _replicator.onRemoteDeltasApplied = () {
      DataChangeBus.instance.notifyAll();
    };

    // Listen to Supabase auth state to automatically connect/disconnect Realtime channel
    ref.listen<SupabaseAuthState>(supabaseAuthNotifierProvider, (
      previous,
      next,
    ) {
      if (next.isAuthenticated && next.user != null) {
        _replicator.startRealtime(next.user!.id);
      } else {
        _replicator.stopRealtime();
      }
    });

    final currentAuth = ref.read(supabaseAuthNotifierProvider);
    if (currentAuth.isAuthenticated && currentAuth.user != null) {
      _replicator.startRealtime(currentAuth.user!.id);
    }

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
