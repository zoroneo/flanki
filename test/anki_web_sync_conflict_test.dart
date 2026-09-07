import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flanki/core/sync/anki_web_config.dart';
import 'package:flanki/core/sync/anki_web_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnkiWebSyncService - checkSyncStatus & Conflict Detection', () {
    test('detects conflict when serverMod > lastSync and hasLocalChanges is true', () async {
      final lastSync = DateTime.utc(2026, 9, 1, 10, 0, 0);
      final serverModSeconds = DateTime.utc(2026, 9, 2, 12, 0, 0).millisecondsSinceEpoch ~/ 1000;

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/sync/meta')) {
          return http.Response(
            jsonEncode({
              'mod': serverModSeconds,
              'usn': 120,
              'msg': '',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = AnkiWebSyncService(
        client: mockClient,
        config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
      );

      final result = await service.checkSyncStatus(
        hostKey: 'test_key',
        lastSyncTime: lastSync,
        hasLocalChanges: true,
      );

      expect(result.action, equals(SyncActionRequired.conflict));
      expect(result.hasLocalChanges, isTrue);
      expect(result.serverMod, isNotNull);
      expect(result.serverMod!.isAfter(lastSync), isTrue);
    });

    test('recommends download when serverMod > lastSync and hasLocalChanges is false', () async {
      final lastSync = DateTime.utc(2026, 9, 1, 10, 0, 0);
      final serverModSeconds = DateTime.utc(2026, 9, 2, 12, 0, 0).millisecondsSinceEpoch ~/ 1000;

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/sync/meta')) {
          return http.Response(
            jsonEncode({
              'mod': serverModSeconds,
              'usn': 120,
              'msg': '',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = AnkiWebSyncService(
        client: mockClient,
        config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
      );

      final result = await service.checkSyncStatus(
        hostKey: 'test_key',
        lastSyncTime: lastSync,
        hasLocalChanges: false,
      );

      expect(result.action, equals(SyncActionRequired.download));
    });

    test('recommends upload when server has no newer changes but local has changes', () async {
      final lastSync = DateTime.utc(2026, 9, 5, 10, 0, 0);
      final serverModSeconds = DateTime.utc(2026, 9, 5, 10, 0, 0).millisecondsSinceEpoch ~/ 1000;

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/sync/meta')) {
          return http.Response(
            jsonEncode({
              'mod': serverModSeconds,
              'usn': 120,
              'msg': '',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = AnkiWebSyncService(
        client: mockClient,
        config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
      );

      final result = await service.checkSyncStatus(
        hostKey: 'test_key',
        lastSyncTime: lastSync,
        hasLocalChanges: true,
      );

      expect(result.action, equals(SyncActionRequired.upload));
    });

    test('reports noChange when neither local nor server has changes', () async {
      final lastSync = DateTime.utc(2026, 9, 5, 10, 0, 0);
      final serverModSeconds = DateTime.utc(2026, 9, 5, 10, 0, 0).millisecondsSinceEpoch ~/ 1000;

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/sync/meta')) {
          return http.Response(
            jsonEncode({
              'mod': serverModSeconds,
              'usn': 120,
              'msg': '',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = AnkiWebSyncService(
        client: mockClient,
        config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
      );

      final result = await service.checkSyncStatus(
        hostKey: 'test_key',
        lastSyncTime: lastSync,
        hasLocalChanges: false,
      );

      expect(result.action, equals(SyncActionRequired.noChange));
    });
  });

  group('AnkiWebSyncService - uploadCollection', () {
    test('sends binary collection to /sync/upload successfully', () async {
      final dummyDb = Uint8List.fromList([0x53, 0x51, 0x4C, 0x69, 0x74, 0x65]); // "SQLite"

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/sync/upload')) {
          expect(request.method, equals('POST'));
          return http.Response('OK', 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = AnkiWebSyncService(
        client: mockClient,
        config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
      );

      final result = await service.uploadCollection(
        hostKey: 'test_host_key',
        dbBytes: dummyDb,
      );

      expect(result.success, isTrue);
      expect(result.message, anyOf(contains('lên AnkiWeb Cloud'), contains('AnkiWeb Cloud')));
    });

    test('handles upload error gracefully', () async {
      final dummyDb = Uint8List.fromList([1, 2, 3, 4]);

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/sync/upload')) {
          return http.Response('server error: corrupt database', 500);
        }
        return http.Response('Not Found', 404);
      });

      final service = AnkiWebSyncService(
        client: mockClient,
        config: const AnkiWebConfig(syncHost: 'https://sync.ankiweb.net'),
      );

      final result = await service.uploadCollection(
        hostKey: 'test_host_key',
        dbBytes: dummyDb,
      );

      expect(result.success, isFalse);
      expect(result.message, contains('500'));
    });
  });
}