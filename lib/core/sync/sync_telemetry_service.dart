import 'dart:async';

import '../../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';
import '../config/supabase_config.dart';
import 'circuit_breaker.dart';
import 'payload_optimizer.dart';

/// Single historical record of a sync execution cycle.
class SyncTelemetryRecord {
  final String id;
  final DateTime timestamp;
  final int durationMs;
  final bool isSuccess;
  final bool isOffline;
  final int pushedCount;
  final int pulledCount;
  final int mediaTransferred;
  final int bytesTransferred;
  final CircuitState circuitState;
  final String? error;

  const SyncTelemetryRecord({
    required this.id,
    required this.timestamp,
    required this.durationMs,
    required this.isSuccess,
    this.isOffline = false,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.mediaTransferred = 0,
    this.bytesTransferred = 0,
    required this.circuitState,
    this.error,
  });

  /// Default unlocalized summary description.
  String get summaryDescription => resolveSummary(null);

  /// Resolves human-readable summary, localizing network/failure messages if [l10n] is provided.
  String resolveSummary(AppLocalizations? l10n) {
    if (isSuccess) {
      return 'Pushed: $pushedCount | Pulled: $pulledCount | Media: $mediaTransferred';
    }
    if (isOffline) {
      return l10n?.networkUnavailable ?? SupabaseConfig.errNetworkOffline;
    }
    return error ?? l10n?.syncFailed ?? SupabaseConfig.errSyncFailed;
  }
}

/// Aggregated metrics view for diagnostics and monitoring dashboards.
class SyncTelemetrySnapshot {
  final List<SyncTelemetryRecord> records;
  final int totalSyncCycles;
  final double successRatePercent;
  final double averageLatencyMs;
  final int totalBytesTransferred;
  final int totalBytesSaved;
  final CircuitState circuitState;

  const SyncTelemetrySnapshot({
    this.records = const [],
    this.totalSyncCycles = 0,
    this.successRatePercent = 100.0,
    this.averageLatencyMs = 0.0,
    this.totalBytesTransferred = 0,
    this.totalBytesSaved = 0,
    this.circuitState = CircuitState.closed,
  });

  bool get isHealthy =>
      circuitState == CircuitState.closed &&
      successRatePercent >= AppConfig.syncHealthyMinSuccessRate;
}

/// Service that maintains a rolling circular log of sync operations and metrics.
class SyncTelemetryService {
  static final SyncTelemetryService instance = SyncTelemetryService._();

  static const int maxCapacity = AppConfig.syncTelemetryMaxCapacity;

  final List<SyncTelemetryRecord> _records = [];
  final StreamController<SyncTelemetrySnapshot> _streamController =
      StreamController<SyncTelemetrySnapshot>.broadcast();

  SyncTelemetryService._();

  Stream<SyncTelemetrySnapshot> get stream => _streamController.stream;

  List<SyncTelemetryRecord> get records => List.unmodifiable(_records);

  /// Records the completion of a sync cycle and updates telemetry snapshot.
  void recordCycle({
    required int durationMs,
    required bool isSuccess,
    bool isOffline = false,
    int pushedCount = 0,
    int pulledCount = 0,
    int mediaTransferred = 0,
    int bytesTransferred = 0,
    required CircuitState circuitState,
    String? error,
  }) {
    final record = SyncTelemetryRecord(
      id: 'sync_${DateTime.now().microsecondsSinceEpoch}',
      timestamp: DateTime.now(),
      durationMs: durationMs,
      isSuccess: isSuccess,
      isOffline: isOffline,
      pushedCount: pushedCount,
      pulledCount: pulledCount,
      mediaTransferred: mediaTransferred,
      bytesTransferred: bytesTransferred,
      circuitState: circuitState,
      error: error,
    );

    _records.insert(0, record);
    if (_records.length > maxCapacity) {
      _records.removeLast();
    }

    _streamController.add(getSnapshot(currentCircuitState: circuitState));
  }

  /// Computes aggregated metrics over the stored records.
  SyncTelemetrySnapshot getSnapshot({
    CircuitState currentCircuitState = CircuitState.closed,
  }) {
    if (_records.isEmpty) {
      return SyncTelemetrySnapshot(circuitState: currentCircuitState);
    }

    final totalCycles = _records.length;
    final successCount = _records.where((r) => r.isSuccess).length;
    final successRate = (successCount / totalCycles) * 100.0;

    final totalLatency = _records.fold<int>(0, (sum, r) => sum + r.durationMs);
    final avgLatency = totalLatency / totalCycles;

    final bandwidthTracker = SyncBandwidthTracker.instance;

    return SyncTelemetrySnapshot(
      records: List.unmodifiable(_records),
      totalSyncCycles: totalCycles,
      successRatePercent: successRate,
      averageLatencyMs: avgLatency,
      totalBytesTransferred: bandwidthTracker.totalTransferred,
      totalBytesSaved: bandwidthTracker.bytesSaved,
      circuitState: currentCircuitState,
    );
  }

  /// Clears stored telemetry history.
  void clear() {
    _records.clear();
    _streamController.add(const SyncTelemetrySnapshot());
  }
}
