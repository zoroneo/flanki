import 'dart:async';

import 'package:flutter/widgets.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../database/database_service.dart';
import 'backoff_strategy.dart';
import 'circuit_breaker.dart';
import 'supabase_realtime_service.dart';
import 'supabase_sync_engine.dart';
import 'sync_telemetry_service.dart';

/// Replicator service that coordinates background periodic sync, app lifecycle triggers,
/// WebSocket real-time push events, exponential backoff, circuit breaker protection,
/// and telemetry tracking.
class SyncReplicator {
  final SupabaseSyncEngine _engine;
  final SupabaseRealtimeService _realtimeService;
  final SyncCircuitBreaker _circuitBreaker;
  final BackoffStrategy _backoffStrategy;
  final SyncTelemetryService _telemetryService;

  Timer? _periodicTimer;
  Timer? _debounceTimer;
  AppLifecycleListener? _lifecycleListener;
  bool _isSyncing = false;
  String? _activeUserId;

  void Function(SyncStatus status, SyncResult? result)? onStatusChanged;
  void Function()? onRemoteDeltasApplied;

  SyncReplicator({
    SupabaseSyncEngine? engine,
    SupabaseRealtimeService? realtimeService,
    SyncCircuitBreaker? circuitBreaker,
    BackoffStrategy? backoffStrategy,
    SyncTelemetryService? telemetryService,
  }) : _engine = engine ?? SupabaseSyncEngine(),
       _realtimeService = realtimeService ?? SupabaseRealtimeService(),
       _circuitBreaker = circuitBreaker ?? SyncCircuitBreaker(),
       _backoffStrategy = backoffStrategy ?? BackoffStrategy(),
       _telemetryService = telemetryService ?? SyncTelemetryService.instance;

  bool get isSyncing => _isSyncing;
  bool get isRealtimeActive => _realtimeService.isSubscribed;
  SyncCircuitBreaker get circuitBreaker => _circuitBreaker;
  BackoffStrategy get backoffStrategy => _backoffStrategy;

  /// Starts periodic background synchronization and attaches app lifecycle listeners.
  void start({
    Duration periodicInterval = AppConfig.defaultSyncPeriodicInterval,
    bool attachLifecycle = true,
    String? userId,
  }) {
    stop();

    if (userId != null && userId.isNotEmpty) {
      startRealtime(userId);
    }

    DatabaseService.instance.onMutationEnqueued = () =>
        notifyMutationEnqueued();

    _periodicTimer = Timer.periodic(periodicInterval, (_) {
      syncNow();
    });

    if (attachLifecycle) {
      _lifecycleListener = AppLifecycleListener(
        onResume: () {
          // Re-subscribe realtime if active user was set
          if (_activeUserId != null) {
            _realtimeService.subscribe(
              _activeUserId!,
              onRemoteChange: () => _handleRemoteChangeNotification(),
            );
          }
          syncNow();
        },
        onPause: () {
          // Pause realtime socket to save battery and system resources
          _realtimeService.unsubscribe();
        },
      );
    }
  }

  /// Starts listening to real-time Postgres CDC notifications for [userId].
  void startRealtime(String userId) {
    _activeUserId = userId;
    _realtimeService.subscribe(
      userId,
      onRemoteChange: () => _handleRemoteChangeNotification(),
    );
  }

  /// Stops Realtime subscription.
  void stopRealtime() {
    _activeUserId = null;
    _realtimeService.unsubscribe();
  }

  /// Handler when Realtime WebSocket detects change from remote device.
  void _handleRemoteChangeNotification() {
    if (!_isSyncing) {
      syncNow();
    }
  }

  /// Called when a local database write occurs. Uses debouncing and backoff
  /// delays when prior network errors occurred.
  void notifyMutationEnqueued({
    Duration debounce = AppConfig.defaultSyncDebounceDuration,
  }) {
    final delay = _backoffStrategy.attempts > 0
        ? _backoffStrategy.getNextDelay()
        : debounce;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      syncNow();
    });
  }

  /// Triggers a synchronization cycle with circuit breaker & telemetry integration.
  Future<SyncResult> syncNow({bool isManual = false}) async {
    if (_isSyncing) {
      return const SyncResult(
        isSuccess: false,
        error: SupabaseConfig.errSyncAlreadyInProgress,
      );
    }

    if (isManual) {
      _circuitBreaker.forceReset();
      _backoffStrategy.recordSuccess();
    } else if (!_circuitBreaker.canExecute()) {
      const skipped = SyncResult(
        isSuccess: false,
        error: SupabaseConfig.errSyncPausedByCircuitBreaker,
      );
      onStatusChanged?.call(SyncStatus.error, skipped);
      return skipped;
    }

    _isSyncing = true;
    onStatusChanged?.call(SyncStatus.syncing, null);
    final stopwatch = Stopwatch()..start();

    try {
      final result = await _engine.sync();
      stopwatch.stop();

      if (result.isSuccess) {
        _circuitBreaker.recordSuccess();
        _backoffStrategy.recordSuccess();
        onStatusChanged?.call(SyncStatus.synced, result);
        if (result.pulledCount > 0 || result.mediaDownloadedCount > 0) {
          onRemoteDeltasApplied?.call();
        }
      } else if (result.isOffline) {
        _circuitBreaker.recordFailure();
        _backoffStrategy.recordFailure();
        onStatusChanged?.call(SyncStatus.offline, result);
      } else if (result.isUnauthenticated) {
        onStatusChanged?.call(SyncStatus.unauthenticated, result);
      } else {
        _circuitBreaker.recordFailure();
        _backoffStrategy.recordFailure();
        onStatusChanged?.call(SyncStatus.error, result);
      }

      _telemetryService.recordCycle(
        durationMs: stopwatch.elapsedMilliseconds,
        isSuccess: result.isSuccess,
        isOffline: result.isOffline,
        pushedCount: result.pushedCount,
        pulledCount: result.pulledCount,
        mediaTransferred:
            result.mediaUploadedCount + result.mediaDownloadedCount,
        circuitState: _circuitBreaker.state,
        error: result.error,
      );

      return result;
    } catch (e) {
      stopwatch.stop();
      _circuitBreaker.recordFailure();
      _backoffStrategy.recordFailure();
      final errorResult = SyncResult.failure(e.toString());
      onStatusChanged?.call(SyncStatus.error, errorResult);

      _telemetryService.recordCycle(
        durationMs: stopwatch.elapsedMilliseconds,
        isSuccess: false,
        circuitState: _circuitBreaker.state,
        error: e.toString(),
      );

      return errorResult;
    } finally {
      _isSyncing = false;
    }
  }

  /// Stops all timers, unsubscribes realtime, and detaches lifecycle listeners.
  void stop() {
    stopRealtime();
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
    _realtimeService.dispose();
  }
}
