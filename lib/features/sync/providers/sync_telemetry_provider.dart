import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/circuit_breaker.dart';
import '../../../core/sync/sync_telemetry_service.dart';

final syncTelemetryServiceProvider = Provider<SyncTelemetryService>((ref) {
  return SyncTelemetryService.instance;
});

class SyncTelemetryNotifier extends Notifier<SyncTelemetrySnapshot> {
  late final SyncTelemetryService _service;

  @override
  SyncTelemetrySnapshot build() {
    _service = ref.watch(syncTelemetryServiceProvider);
    final sub = _service.stream.listen((snapshot) {
      state = snapshot;
    });
    ref.onDispose(sub.cancel);
    return _service.getSnapshot();
  }

  void updateCircuitState(CircuitState state) {
    this.state = _service.getSnapshot(currentCircuitState: state);
  }

  void clearLogs() {
    _service.clear();
    state = const SyncTelemetrySnapshot();
  }
}

final syncTelemetryNotifierProvider =
    NotifierProvider<SyncTelemetryNotifier, SyncTelemetrySnapshot>(() {
      return SyncTelemetryNotifier();
    });
