import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/logging/breadcrumb_tracker.dart';
import 'package:flanki/core/logging/error_logger.dart';
import 'package:flanki/core/logging/error_sanitizer.dart';
import 'package:flanki/core/logging/error_severity.dart';

void main() {
  group('ErrorSeverity', () {
    test('toDbValue returns correct lowercase identifier', () {
      expect(ErrorSeverity.debug.toDbValue(), 'debug');
      expect(ErrorSeverity.info.toDbValue(), 'info');
      expect(ErrorSeverity.warning.toDbValue(), 'warning');
      expect(ErrorSeverity.error.toDbValue(), 'error');
      expect(ErrorSeverity.fatal.toDbValue(), 'fatal');
    });

    test('fromString parses valid and fallback values', () {
      expect(ErrorSeverity.fromString('DEBUG'), ErrorSeverity.debug);
      expect(ErrorSeverity.fromString('warning'), ErrorSeverity.warning);
      expect(ErrorSeverity.fromString('FATAL'), ErrorSeverity.fatal);
      expect(ErrorSeverity.fromString('invalid'), ErrorSeverity.error);
      expect(ErrorSeverity.fromString(null), ErrorSeverity.error);
    });
  });

  group('ErrorSanitizer', () {
    test('sanitizes Bearer tokens and JWTs', () {
      const raw =
          'Error connecting with Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc123';
      final sanitized = ErrorSanitizer.sanitize(raw);
      expect(sanitized.contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'), isFalse);
      expect(sanitized, contains('[REDACTED_JWT]'));
    });

    test('sanitizes passwords, keys, and authorization patterns', () {
      const raw = 'Failed at url: https://api.example.com?apiKey=secret123&password="supersecret"';
      final sanitized = ErrorSanitizer.sanitize(raw);
      expect(sanitized, contains('password: [REDACTED]'));
      expect(sanitized.contains('supersecret'), isFalse);
    });

    test('masks email addresses', () {
      const raw = 'User testuser@flanki.app encountered null pointer exception';
      final sanitized = ErrorSanitizer.sanitize(raw);
      expect(sanitized.contains('testuser@flanki.app'), isFalse);
      expect(sanitized, contains('t***r@flanki.app'));
    });

    test('sanitizes local filesystem user paths', () {
      const macRaw = 'File /Users/tuthanhnguyen/Documents/flanki.db missing';
      expect(
        ErrorSanitizer.sanitize(macRaw),
        'File /Users/[USER]/Documents/flanki.db missing',
      );

      const winRaw = r'Path C:\Users\john_doe\AppData\flanki.db corrupted';
      expect(
        ErrorSanitizer.sanitize(winRaw),
        r'Path C:\Users\[USER]\AppData\flanki.db corrupted',
      );
    });

    test('sanitizeData recursively scrubs sensitive keys in maps', () {
      final input = {
        'status': 401,
        'accessToken': 'secret_token_value',
        'auth_header': 'Bearer 12345',
        'meta': {
          'user_email': 'dev@flanki.com',
          'nested_password': 'mypassword',
        },
      };

      final sanitized = ErrorSanitizer.sanitizeData(input) as Map<String, dynamic>;
      expect(sanitized['status'], 401);
      expect(sanitized['accessToken'], ErrorSanitizer.redactedPlaceholder);
      expect(sanitized['auth_header'], ErrorSanitizer.redactedPlaceholder);
      final meta = sanitized['meta'] as Map<String, dynamic>;
      expect(meta['nested_password'], ErrorSanitizer.redactedPlaceholder);
      expect(meta['user_email'], contains('d***v@flanki.com'));
    });
  });

  group('BreadcrumbTracker', () {
    late BreadcrumbTracker tracker;

    setUp(() {
      tracker = BreadcrumbTracker.test(capacity: 3);
    });

    test('maintains circular buffer capacity and evicts oldest items', () {
      tracker.addNavigation('home', 'decks');
      tracker.addAction('tap_card');
      tracker.addNetwork('GET', '/api/sync', statusCode: 200);

      expect(tracker.breadcrumbs.length, 3);
      expect(tracker.breadcrumbs.first.category, 'navigation');

      // Adding 4th item should evict the first ('navigation')
      tracker.addSync('sync_complete');
      expect(tracker.breadcrumbs.length, 3);
      expect(tracker.breadcrumbs.first.category, 'action');
      expect(tracker.breadcrumbs.last.category, 'sync');
    });

    test('toJsonList serializes breadcrumbs correctly', () {
      tracker.addNavigation('splash', 'decks');
      final jsonList = tracker.toJsonList();
      expect(jsonList.length, 1);
      expect(jsonList.first['category'], 'navigation');
      expect(jsonList.first['message'], 'Navigated from splash to decks');
    });
  });

  group('ErrorLogger', () {
    late Directory tempDir;
    late File testOfflineFile;
    late ErrorLogger logger;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('error_logger_test_');
      testOfflineFile = File('${tempDir.path}/pending_test_logs.json');
      logger = ErrorLogger.forTesting(offlineFile: testOfflineFile);
    });

    tearDown(() async {
      logger.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('deduplicates identical exceptions within the 60s window', () async {
      final error = StateError('Deck ID cannot be empty');
      final stack = StackTrace.fromString('#0 _checkDeck (deck_service.dart:42)\n#1 main (main.dart:10)');

      // Capture same exception 3 times
      await logger.captureException(error, stackTrace: stack);
      await logger.captureException(error, stackTrace: stack);
      await logger.captureException(error, stackTrace: stack);

      // Flush to offline file since no Supabase client is attached
      await logger.flush();

      expect(await testOfflineFile.exists(), isTrue);
      final content = await testOfflineFile.readAsString();
      expect(content, isNotEmpty);

      // Should only contain 1 item with occurrences = 3
      expect(content.contains('"occurrences":3'), isTrue);
    });

    test('fatal error triggers immediate flush to offline file', () async {
      final fatalError = Exception('Critical SQLite database corruption');

      await logger.captureException(
        fatalError,
        fatal: true,
      );

      // Should have flushed immediately without calling flush() manually
      expect(await testOfflineFile.exists(), isTrue);
      final content = await testOfflineFile.readAsString();
      expect(content, contains('"severity":"fatal"'));
      expect(content, contains('Critical SQLite database corruption'));
    });

    test('truncates oversized error messages and stack traces to avoid DOS payload explosion', () async {
      final hugeMessage = 'A' * 5000;
      final hugeError = Exception(hugeMessage);

      await logger.captureException(hugeError);
      await logger.flush();

      final content = await testOfflineFile.readAsString();
      expect(content.contains('A' * 5000), isFalse);
      expect(content.contains('A' * 2000), isTrue);
    });
  });
}

