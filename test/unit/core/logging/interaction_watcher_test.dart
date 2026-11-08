import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flanki/core/logging/breadcrumb_tracker.dart';
import 'package:flanki/core/logging/error_logger.dart';
import 'package:flanki/core/logging/error_severity.dart';
import 'package:flanki/core/logging/interaction_watcher.dart';

class MockErrorLogger implements ErrorLogger {
  final List<Map<String, dynamic>> captured = [];

  @override
  Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? extra,
    bool fatal = false,
  }) async {
    captured.add({
      'exception': exception,
      'context': context,
      'severity': severity,
      'extra': extra,
      'fatal': fatal,
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockErrorLogger mockLogger;
  late BreadcrumbTracker breadcrumbs;
  late InteractionWatcher watcher;

  setUp(() {
    mockLogger = MockErrorLogger();
    breadcrumbs = BreadcrumbTracker.test(capacity: 20);
    watcher = InteractionWatcher.forTesting(
      errorLogger: mockLogger,
      breadcrumbTracker: breadcrumbs,
    );
  });

  tearDown(() {
    watcher.reset();
  });

  test('Single tap records action breadcrumb', () {
    const event = PointerDownEvent(position: Offset(100, 200));

    watcher.onPointerDown(event, currentRoute: '/grammar');

    final list = breadcrumbs.toJsonList();
    expect(list.length, equals(1));
    expect(list.first['category'], equals('action'));
    expect(list.first['message'], equals('tap'));
    expect(list.first['data']['route'], equals('/grammar'));
    expect(list.first['data']['x'], equals('100.0'));
    expect(list.first['data']['y'], equals('200.0'));
  });

  test(
    'Rage tap triggers UnresponsiveInteraction warning after delay',
    () async {
      const p1 = PointerDownEvent(position: Offset(150, 300));
      const p2 = PointerDownEvent(position: Offset(152, 302));
      const p3 = PointerDownEvent(position: Offset(148, 298));

      watcher.onPointerDown(p1, currentRoute: '/grammar');
      watcher.onPointerDown(p2, currentRoute: '/grammar');
      watcher.onPointerDown(p3, currentRoute: '/grammar');

      // Initially before timeout, no log should have fired yet
      expect(mockLogger.captured, isEmpty);

      // Wait past the deadClickEvaluationDuration (900ms + margin)
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      expect(mockLogger.captured.length, equals(1));
      final log = mockLogger.captured.first;
      expect(log['context'], equals('InteractionWatcher.unresponsiveTap'));
      expect(log['severity'], equals(ErrorSeverity.warning));
      expect(log['extra']['screen_route'], equals('/grammar'));
      expect(log['extra']['recent_tap_count'], equals(3));
    },
  );

  test('Navigation cancels dead click alarm before it fires', () async {
    const p1 = PointerDownEvent(position: Offset(150, 300));
    const p2 = PointerDownEvent(position: Offset(152, 302));
    const p3 = PointerDownEvent(position: Offset(148, 298));

    watcher.onPointerDown(p1, currentRoute: '/grammar');
    watcher.onPointerDown(p2, currentRoute: '/grammar');
    watcher.onPointerDown(p3, currentRoute: '/grammar');

    // Simulate navigation transition within 300ms
    await Future<void>.delayed(const Duration(milliseconds: 300));
    watcher.notifyNavigationOccurred();

    // Wait past the evaluation timer
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Alarm should have been cancelled by navigation
    expect(mockLogger.captured, isEmpty);
  });

  test('Taps far apart (> 48px) do not trigger rage tap warning', () async {
    const p1 = PointerDownEvent(position: Offset(50, 50));
    const p2 = PointerDownEvent(position: Offset(150, 250));
    const p3 = PointerDownEvent(position: Offset(300, 600));

    watcher.onPointerDown(p1, currentRoute: '/decks');
    watcher.onPointerDown(p2, currentRoute: '/decks');
    watcher.onPointerDown(p3, currentRoute: '/decks');

    await Future<void>.delayed(const Duration(milliseconds: 1000));

    expect(mockLogger.captured, isEmpty);
  });
}
