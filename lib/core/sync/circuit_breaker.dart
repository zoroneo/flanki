import 'dart:math';

import '../config/app_config.dart';

/// Lifecycle states of the sync circuit breaker.
enum CircuitState {
  /// Normal operation: requests pass through.
  closed,

  /// Tripped: requests are blocked to conserve resources and avoid server overload.
  open,

  /// Testing recovery: allows a single probe request to determine if the server is healthy.
  halfOpen,
}

/// Circuit Breaker to prevent resource exhaustion and thundering herd problems
/// when Supabase Cloud or the network connection suffers consecutive failures.
class SyncCircuitBreaker {
  final int failureThreshold;
  final Duration cooldownDuration;
  final void Function(CircuitState oldState, CircuitState newState)?
  onStateChanged;

  CircuitState _state = CircuitState.closed;
  int _consecutiveFailures = 0;
  DateTime? _lastFailureTime;
  DateTime? _nextProbeTime;

  SyncCircuitBreaker({
    this.failureThreshold = AppConfig.circuitBreakerFailureThreshold,
    this.cooldownDuration = AppConfig.circuitBreakerCooldown,
    this.onStateChanged,
  });

  CircuitState get state => _state;
  int get consecutiveFailures => _consecutiveFailures;
  DateTime? get lastFailureTime => _lastFailureTime;
  DateTime? get nextProbeTime => _nextProbeTime;

  /// Checks whether an operation is permitted to execute under the current state.
  bool canExecute() {
    final now = DateTime.now();

    switch (_state) {
      case CircuitState.closed:
        return true;

      case CircuitState.open:
        if (_nextProbeTime != null && now.isAfter(_nextProbeTime!)) {
          _transitionTo(CircuitState.halfOpen);
          return true;
        }
        return false;

      case CircuitState.halfOpen:
        // In half-open, we allow the single probe trial
        return true;
    }
  }

  /// Records a successful sync, resetting the circuit back to [CircuitState.closed].
  void recordSuccess() {
    _consecutiveFailures = 0;
    _lastFailureTime = null;
    _nextProbeTime = null;
    if (_state != CircuitState.closed) {
      _transitionTo(CircuitState.closed);
    }
  }

  /// Records an operation failure. Trips to [CircuitState.open] if [failureThreshold] is reached.
  void recordFailure() {
    _consecutiveFailures++;
    _lastFailureTime = DateTime.now();

    if (_state == CircuitState.halfOpen ||
        _consecutiveFailures >= failureThreshold) {
      final tripCount = max(1, _consecutiveFailures - failureThreshold + 1);
      final multiplier = min(tripCount, AppConfig.circuitBreakerMaxMultiplier);
      _nextProbeTime = DateTime.now().add(cooldownDuration * multiplier);
      _transitionTo(CircuitState.open);
    }
  }

  /// Forcibly resets the circuit breaker to closed state (e.g. on manual user action).
  void forceReset() {
    _consecutiveFailures = 0;
    _lastFailureTime = null;
    _nextProbeTime = null;
    _transitionTo(CircuitState.closed);
  }

  void _transitionTo(CircuitState newState) {
    if (_state == newState) return;
    final oldState = _state;
    _state = newState;
    onStateChanged?.call(oldState, newState);
  }
}
