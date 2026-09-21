import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/sync/circuit_breaker.dart';

void main() {
  group('SyncCircuitBreaker', () {
    test('transitions Closed -> Open after reaching failureThreshold', () {
      final transitions = <CircuitState>[];
      final breaker = SyncCircuitBreaker(
        failureThreshold: 3,
        cooldownDuration: const Duration(seconds: 1),
        onStateChanged: (oldS, newS) => transitions.add(newS),
      );

      expect(breaker.state, CircuitState.closed);
      expect(breaker.canExecute(), isTrue);

      breaker.recordFailure();
      expect(breaker.state, CircuitState.closed);
      expect(breaker.canExecute(), isTrue);

      breaker.recordFailure();
      expect(breaker.state, CircuitState.closed);

      // 3rd failure trips the breaker
      breaker.recordFailure();
      expect(breaker.state, CircuitState.open);
      expect(transitions, [CircuitState.open]);
      expect(breaker.canExecute(), isFalse);
    });

    test('transitions Open -> HalfOpen after cooldown passes', () async {
      final breaker = SyncCircuitBreaker(
        failureThreshold: 2,
        cooldownDuration: const Duration(milliseconds: 50),
      );

      breaker.recordFailure();
      breaker.recordFailure();
      expect(breaker.state, CircuitState.open);
      expect(breaker.canExecute(), isFalse);

      await Future.delayed(const Duration(milliseconds: 60));

      // After cooldown expires, canExecute permits probe and shifts to HalfOpen
      expect(breaker.canExecute(), isTrue);
      expect(breaker.state, CircuitState.halfOpen);

      // Successful probe resets to closed
      breaker.recordSuccess();
      expect(breaker.state, CircuitState.closed);
      expect(breaker.consecutiveFailures, 0);
    });

    test('forceReset returns breaker immediately to Closed', () {
      final breaker = SyncCircuitBreaker(failureThreshold: 1);
      breaker.recordFailure();
      expect(breaker.state, CircuitState.open);

      breaker.forceReset();
      expect(breaker.state, CircuitState.closed);
      expect(breaker.canExecute(), isTrue);
    });
  });
}
