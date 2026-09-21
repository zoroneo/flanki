import 'dart:io';
import 'dart:math';

import '../config/app_config.dart';

/// Exponential backoff calculation using the AWS/Google SRE recommended
/// Full Jitter algorithm: `random_between(0, min(maxDelay, baseDelay * 2^attempt))`.
class BackoffStrategy {
  final Duration baseDelay;
  final Duration maxDelay;
  int _attempts = 0;

  BackoffStrategy({
    this.baseDelay = AppConfig.syncBackoffBaseDelay,
    this.maxDelay = AppConfig.syncBackoffMaxDelay,
  });

  int get attempts => _attempts;

  /// Calculates the next delay duration with full randomized jitter.
  Duration getNextDelay({Random? random}) {
    final rand = random ?? Random();
    final baseMs = baseDelay.inMilliseconds;
    final maxMs = maxDelay.inMilliseconds;

    // Guard against integer overflow in shift
    final effectiveAttempt = min(
      _attempts,
      AppConfig.syncBackoffMaxShiftAttempts,
    );
    final exponentialMs = baseMs * (1 << effectiveAttempt);
    final ceilingMs = min(maxMs, exponentialMs);

    final jitteredMs = rand.nextInt(max(1, ceilingMs + 1));
    _attempts++;

    return Duration(milliseconds: jitteredMs);
  }

  /// Resets backoff progression to zero after a successful operation.
  void recordSuccess() {
    _attempts = 0;
  }

  /// Increments attempts counter on failure.
  void recordFailure() {
    _attempts++;
  }

  /// Determines if an error is transient and should trigger backoff retry.
  static bool isTransientError(Object error) {
    if (error is SocketException) return true;
    final errStr = error.toString().toLowerCase();
    return errStr.contains('429') || // Rate limit
        errStr.contains('503') || // Service unavailable
        errStr.contains('502') || // Bad gateway
        errStr.contains('504') || // Gateway timeout
        errStr.contains('timeout') ||
        errStr.contains('network') ||
        errStr.contains('connection');
  }
}
