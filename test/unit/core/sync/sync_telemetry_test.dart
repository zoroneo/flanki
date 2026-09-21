import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/sync/circuit_breaker.dart';
import 'package:flanki/core/sync/sync_telemetry_service.dart';

void main() {
  group('SyncTelemetryService', () {
    final telemetry = SyncTelemetryService.instance;

    setUp(() {
      telemetry.clear();
    });

    test('records cycles and computes accurate metrics', () {
      expect(telemetry.records.isEmpty, isTrue);

      telemetry.recordCycle(
        durationMs: 120,
        isSuccess: true,
        pushedCount: 5,
        pulledCount: 2,
        circuitState: CircuitState.closed,
      );

      telemetry.recordCycle(
        durationMs: 80,
        isSuccess: true,
        pushedCount: 0,
        pulledCount: 1,
        circuitState: CircuitState.closed,
      );

      telemetry.recordCycle(
        durationMs: 200,
        isSuccess: false,
        error: 'Timeout error',
        circuitState: CircuitState.open,
      );

      expect(telemetry.records.length, 3);
      final snapshot = telemetry.getSnapshot(
        currentCircuitState: CircuitState.open,
      );

      expect(snapshot.totalSyncCycles, 3);
      // 2 successes out of 3 = 66.66%
      expect(snapshot.successRatePercent, closeTo(66.66, 0.1));
      // Average latency = (120 + 80 + 200) / 3 = 133.33ms
      expect(snapshot.averageLatencyMs, closeTo(133.33, 0.1));
      expect(snapshot.circuitState, CircuitState.open);
      expect(snapshot.isHealthy, isFalse);
    });

    test('caps at maxCapacity (50 records)', () {
      for (int i = 0; i < 60; i++) {
        telemetry.recordCycle(
          durationMs: 10 + i,
          isSuccess: true,
          circuitState: CircuitState.closed,
        );
      }

      expect(telemetry.records.length, SyncTelemetryService.maxCapacity);
    });

    test('clear resets records and snapshot', () {
      telemetry.recordCycle(
        durationMs: 100,
        isSuccess: true,
        circuitState: CircuitState.closed,
      );
      expect(telemetry.records.length, 1);

      telemetry.clear();
      expect(telemetry.records.isEmpty, isTrue);
      expect(telemetry.getSnapshot().totalSyncCycles, 0);
    });
  });
}
