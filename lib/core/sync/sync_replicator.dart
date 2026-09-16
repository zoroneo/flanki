import 'dart:async';

import 'package:flutter/widgets.dart';

import '../config/app_config.dart';
import '../database/database_service.dart';
import 'supabase_sync_engine.dart';

/// Replicator service that coordinates background periodic sync, app lifecycle triggers,
/// and debounced sync execution upon local mutations.
class SyncReplicator {
  final SupabaseSyncEngine _engine;

  Timer? _periodicTimer;
  Timer? _debounceTimer;
  AppLifecycleListener? _lifecycleListener;
  bool _isSyncing = false;

  void Function(SyncStatus status, SyncResult? result)? onStatusChanged;

  SyncReplicator({SupabaseSyncEngine? engine})
    : _engine = engine ?? SupabaseSyncEngine();

  bool get isSyncing => _isSyncing;

  /// Starts periodic background synchronization and attaches app lifecycle listeners.
  void start({
    Duration periodicInterval = AppConfig.defaultSyncPeriodicInterval,
    bool attachLifecycle = true,
  }) {
    stop();

    DatabaseService.instance.onMutationEnqueued = () =>
        notifyMutationEnqueued();

    _periodicTimer = Timer.periodic(periodicInterval, (_) {
      syncNow();
    });

    if (attachLifecycle) {
      _lifecycleListener = AppLifecycleListener(
        onResume: () {
          syncNow();
        },
      );
    }
  }

  /// Called when a local database write occurs. Debounces sync by [debounce]
  /// to avoid network thrashing during rapid review sessions.
  void notifyMutationEnqueued({
    Duration debounce = AppConfig.defaultSyncDebounceDuration,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      syncNow();
    });
  }

  /// Triggers an immediate synchronization cycle.
  Future<SyncResult> syncNow() async {
    if (_isSyncing) {
      return const SyncResult(
        isSuccess: false,
        error: 'Sync already in progress',
      );
    }

    _isSyncing = true;
    onStatusChanged?.call(SyncStatus.syncing, null);

    try {
      final result = await _engine.sync();

      if (result.isSuccess) {
        onStatusChanged?.call(SyncStatus.synced, result);
      } else if (result.isOffline) {
        onStatusChanged?.call(SyncStatus.offline, result);
      } else if (result.isUnauthenticated) {
        onStatusChanged?.call(SyncStatus.unauthenticated, result);
      } else {
        onStatusChanged?.call(SyncStatus.error, result);
      }

      return result;
    } catch (e) {
      final errorResult = SyncResult.failure(e.toString());
      onStatusChanged?.call(SyncStatus.error, errorResult);
      return errorResult;
    } finally {
      _isSyncing = false;
    }
  }

  /// Stops all timers and detaches lifecycle listeners.
  void stop() {
    DatabaseService.instance.onMutationEnqueued = null;
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
  }

  void dispose() {
    stop();
  }
}
