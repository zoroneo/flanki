import 'dart:async';

import 'package:flutter/gestures.dart';

import 'breadcrumb_tracker.dart';
import 'error_logger.dart';
import 'error_severity.dart';

/// Recorded entry of a recent tap for cluster and frequency analysis.
class _TapRecord {
  final Offset position;
  final DateTime timestamp;

  const _TapRecord({required this.position, required this.timestamp});
}

/// Watches user interactions globally to identify dead clicks, rage taps,
/// and unhandled UI states where the app fails to respond to user gestures.
class InteractionWatcher {
  static final InteractionWatcher instance = InteractionWatcher._();

  InteractionWatcher._();

  /// Factory for isolated testing.
  factory InteractionWatcher.forTesting({
    ErrorLogger? errorLogger,
    BreadcrumbTracker? breadcrumbTracker,
  }) {
    final watcher = InteractionWatcher._();
    if (errorLogger != null) watcher._injectedLogger = errorLogger;
    if (breadcrumbTracker != null) {
      watcher._injectedBreadcrumbTracker = breadcrumbTracker;
    }
    return watcher;
  }

  ErrorLogger? _injectedLogger;
  BreadcrumbTracker? _injectedBreadcrumbTracker;

  ErrorLogger get _logger => _injectedLogger ?? ErrorLogger.instance;
  BreadcrumbTracker get _breadcrumbs =>
      _injectedBreadcrumbTracker ?? BreadcrumbTracker.instance;

  final List<_TapRecord> _recentTaps = [];
  Timer? _deadClickEvaluationTimer;
  DateTime? _lastBreadcrumbTime;

  /// Cluster distance threshold in logical pixels.
  static const double clusterRadiusPx = 48.0;

  /// Time window to aggregate repeated taps for rage-click detection.
  static const Duration rageTapWindow = Duration(milliseconds: 1500);

  /// Settle duration after the last tap to evaluate if UI responded.
  static const Duration deadClickEvaluationDuration = Duration(
    milliseconds: 900,
  );

  /// Minimum duration between raw tap breadcrumbs to prevent queue saturation.
  static const Duration breadcrumbThrottle = Duration(milliseconds: 300);

  /// Minimum taps in the cluster required to classify as a rage click.
  static const int minRageTaps = 3;

  /// Handles incoming pointer down events from the root listener.
  void onPointerDown(PointerDownEvent event, {String? currentRoute}) {
    final now = DateTime.now();
    final routeName = currentRoute ?? 'unknown';

    // 1. Throttled breadcrumb recording for user interaction trail
    if (_lastBreadcrumbTime == null ||
        now.difference(_lastBreadcrumbTime!) >= breadcrumbThrottle) {
      _lastBreadcrumbTime = now;
      _breadcrumbs.addAction(
        'tap',
        details: {
          'x': event.position.dx.toStringAsFixed(1),
          'y': event.position.dy.toStringAsFixed(1),
          'route': routeName,
        },
      );
    }

    // 2. Prune expired taps outside the rage tap detection window
    _recentTaps.removeWhere(
      (tap) => now.difference(tap.timestamp) > rageTapWindow,
    );
    _recentTaps.add(_TapRecord(position: event.position, timestamp: now));

    // 3. Cluster evaluation: are the taps clustered in the same area?
    if (_recentTaps.length >= minRageTaps) {
      final firstPos = _recentTaps.first.position;
      final isClustered = _recentTaps.every(
        (tap) => (tap.position - firstPos).distance <= clusterRadiusPx,
      );

      if (isClustered) {
        _deadClickEvaluationTimer?.cancel();
        _deadClickEvaluationTimer = Timer(deadClickEvaluationDuration, () {
          _reportUnresponsiveInteraction(firstPos, routeName);
        });
      }
    }
  }

  /// Cancels pending dead-click alarms whenever navigation or route changes occur.
  void notifyNavigationOccurred() {
    _deadClickEvaluationTimer?.cancel();
    _recentTaps.clear();
  }

  /// Dispatches warning telemetry to Supabase if taps produced no transition or response.
  void _reportUnresponsiveInteraction(Offset position, String route) {
    final message =
        'Tương tác không phản hồi (Dead Click / Rage Tap) tại '
        '(${position.dx.toStringAsFixed(0)}, ${position.dy.toStringAsFixed(0)}) '
        'trên màn hình: $route';

    _logger.captureException(
      message,
      context: 'InteractionWatcher.unresponsiveTap',
      severity: ErrorSeverity.warning,
      extra: {
        'tap_x': position.dx,
        'tap_y': position.dy,
        'screen_route': route,
        'recent_tap_count': _recentTaps.length,
      },
    );

    _recentTaps.clear();
  }

  /// Resets internal state for unit testing.
  void reset() {
    _deadClickEvaluationTimer?.cancel();
    _recentTaps.clear();
    _lastBreadcrumbTime = null;
  }
}
