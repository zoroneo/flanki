import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/sync/backoff_strategy.dart';

void main() {
  group('BackoffStrategy', () {
    test('calculates jittered delay within exponential bounds', () {
      final backoff = BackoffStrategy(
        baseDelay: const Duration(seconds: 1),
        maxDelay: const Duration(seconds: 16),
      );

      final fakeRandom = Random(42);

      // Attempt 0: bound = min(16, 1 * 2^0) = 1s
      final d0 = backoff.getNextDelay(random: fakeRandom);
      expect(d0.inSeconds, inInclusiveRange(0, 1));
      expect(backoff.attempts, 1);

      // Attempt 1: bound = min(16, 1 * 2^1) = 2s
      final d1 = backoff.getNextDelay(random: fakeRandom);
      expect(d1.inSeconds, inInclusiveRange(0, 2));
      expect(backoff.attempts, 2);

      // Advance attempts to cap at maxDelay
      for (int i = 0; i < 10; i++) {
        final d = backoff.getNextDelay(random: fakeRandom);
        expect(d.inSeconds, inInclusiveRange(0, 16));
      }

      // Record success resets attempts
      backoff.recordSuccess();
      expect(backoff.attempts, 0);
    });

    test('isTransientError detects 429, 503, timeouts and socket errors', () {
      expect(
        BackoffStrategy.isTransientError('Exception: 429 Too Many Requests'),
        isTrue,
      );
      expect(
        BackoffStrategy.isTransientError('HTTP 503 Service Unavailable'),
        isTrue,
      );
      expect(
        BackoffStrategy.isTransientError('SocketException: connection refused'),
        isTrue,
      );
      expect(
        BackoffStrategy.isTransientError(
          'TimeoutException after 0:00:10.000000',
        ),
        isTrue,
      );
      expect(
        BackoffStrategy.isTransientError('FormatException: Invalid JSON'),
        isFalse,
      );
    });
  });
}
