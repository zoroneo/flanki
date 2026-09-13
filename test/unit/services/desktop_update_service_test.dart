import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flanki/core/config/app_config.dart';
import 'package:flanki/features/settings/providers/update_notifier.dart';
import 'package:flanki/features/settings/data/desktop_update_service.dart';
import 'package:flanki/core/services/desktop_window_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (cancelFuture != null) {
      final completer = Completer<ResponseBody>();
      cancelFuture.then((_) {
        if (!completer.isCompleted) {
          completer.completeError(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              message: 'Request cancelled',
            ),
          );
        }
      });
      handler(options)
          .then((res) {
            if (!completer.isCompleted) {
              completer.complete(res);
            }
          })
          .catchError((err) {
            if (!completer.isCompleted) {
              completer.completeError(err);
            }
          });
      return completer.future;
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio createMockDio(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio();
  dio.httpClientAdapter = MockHttpAdapter(handler);
  return dio;
}

void main() {
  group('DesktopUpdateService Version Comparison Tests', () {
    test('Correctly compares higher and lower semver strings', () {
      expect(
        DesktopUpdateService.compareVersions('1.0.1', '1.0.0'),
        greaterThan(0),
      );
      expect(
        DesktopUpdateService.compareVersions('1.1.0', '1.0.9'),
        greaterThan(0),
      );
      expect(
        DesktopUpdateService.compareVersions('2.0.0', '1.99.99'),
        greaterThan(0),
      );
      expect(
        DesktopUpdateService.compareVersions('1.0.0', '1.0.1'),
        lessThan(0),
      );
      expect(
        DesktopUpdateService.compareVersions('0.9.9', '1.0.0'),
        lessThan(0),
      );
    });

    test('Handles v prefix and build metadata gracefully', () {
      expect(
        DesktopUpdateService.compareVersions('v1.0.0', '1.0.0'),
        equals(0),
      );
      expect(
        DesktopUpdateService.compareVersions('v1.2.0', 'v1.1.9'),
        greaterThan(0),
      );
      expect(
        DesktopUpdateService.compareVersions('1.0.0+1', '1.0.0+2'),
        equals(0),
      );
    });
  });

  group('DesktopUpdateService Asset Selection Tests', () {
    final assets = [
      {
        'name': 'flanki-1.1.0-mac.dmg',
        'browser_download_url': 'https://download/mac.dmg',
      },
      {
        'name': 'flanki-setup-1.1.0-windows.exe',
        'browser_download_url': 'https://download/windows.exe',
      },
      {
        'name': 'flanki-1.1.0-linux.AppImage',
        'browser_download_url': 'https://download/linux.AppImage',
      },
      {
        'name': 'flanki-1.1.0-android.apk',
        'browser_download_url': 'https://download/android.apk',
      },
    ];

    test('Finds matching asset for current platform', () {
      final asset = DesktopUpdateService.findPlatformAsset(assets);
      expect(asset, isNotNull);
      expect(asset!['name'], isA<String>());
    });

    test('Finds matching asset for specific AppPlatform target', () {
      final win = DesktopUpdateService.findPlatformAsset(
        assets,
        targetPlatform: AppPlatform.windows,
      );
      expect(win?['name'], 'flanki-setup-1.1.0-windows.exe');

      final mac = DesktopUpdateService.findPlatformAsset(
        assets,
        targetPlatform: AppPlatform.macos,
      );
      expect(mac?['name'], 'flanki-1.1.0-mac.dmg');

      final lin = DesktopUpdateService.findPlatformAsset(
        assets,
        targetPlatform: AppPlatform.linux,
      );
      expect(lin?['name'], 'flanki-1.1.0-linux.AppImage');

      final apk = DesktopUpdateService.findPlatformAsset(
        assets,
        targetPlatform: AppPlatform.android,
      );
      expect(apk?['name'], 'flanki-1.1.0-android.apk');
    });

    test('Returns null when assets list is empty', () {
      final asset = DesktopUpdateService.findPlatformAsset([]);
      expect(asset, isNull);
    });
  });

  group('DesktopUpdateService API Check Tests', () {
    test('Parses GitHub Releases JSON into UpdateInfo', () async {
      final mockResponse = {
        'tag_name': 'v1.1.0',
        'html_url': 'https://github.com/zoroneo/flanki/releases/tag/v1.1.0',
        'body': '### Improvements\n- Added auto update feature',
        'published_at': '2026-09-07T00:00:00Z',
        'assets': [
          {
            'name': 'flanki-setup-windows.exe',
            'size': 25000000,
            'browser_download_url': 'https://github.com/zoroneo/flanki/releases/download/v1.1.0/flanki-setup-windows.exe',
          },
        ],
      };

      final dio = createMockDio((request) async {
        return ResponseBody.fromString(
          jsonEncode(mockResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final service = DesktopUpdateService(dio: dio);
      final updateInfo = await service.checkForUpdates(currentVersion: '1.0.0');

      expect(updateInfo.hasUpdate, isTrue);
      expect(updateInfo.latestVersion, equals('1.1.0'));
      expect(updateInfo.currentVersion, equals('1.0.0'));
      expect(updateInfo.releaseNotes, contains('Added auto update feature'));
      expect(updateInfo.releaseUrl, contains('v1.1.0'));
    });

    test(
      'Returns hasUpdate=false when current version is latest or newer',
      () async {
        final mockResponse = {
          'tag_name': 'v1.0.0',
          'html_url': 'https://github.com/zoroneo/flanki/releases/tag/v1.0.0',
          'body': 'Initial release',
          'assets': [],
        };

        final dio = createMockDio((request) async {
          return ResponseBody.fromString(
            jsonEncode(mockResponse),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        final service = DesktopUpdateService(dio: dio);
        final updateInfo = await service.checkForUpdates(
          currentVersion: '1.0.0',
        );

        expect(updateInfo.hasUpdate, isFalse);
        expect(updateInfo.latestVersion, equals('1.0.0'));
      },
    );

    test(
      'Handles network failure gracefully without throwing exceptions',
      () async {
        final dio = createMockDio((request) async {
          return ResponseBody.fromString('Server Error', 500);
        });

        final service = DesktopUpdateService(dio: dio);
        final updateInfo = await service.checkForUpdates(
          currentVersion: '1.0.0',
        );

        expect(updateInfo.hasUpdate, isFalse);
        expect(updateInfo.currentVersion, equals('1.0.0'));
        expect(updateInfo.releaseUrl, equals(AppConfig.githubReleasesUrl));
      },
    );
  });

  group('Enum-safe Type Standardization Tests', () {
    test('DesktopTrayAction correctly maps keys to actions', () {
      expect(
        DesktopTrayAction.fromKey('show_window'),
        DesktopTrayAction.showWindow,
      );
      expect(
        DesktopTrayAction.fromKey('open_study'),
        DesktopTrayAction.openStudy,
      );
      expect(DesktopTrayAction.fromKey('exit_app'), DesktopTrayAction.exitApp);
      expect(DesktopTrayAction.fromKey('unknown_action'), isNull);
    });

    test('UpdateErrorType supports all expected failure modes', () {
      expect(
        UpdateErrorType.values,
        containsAll([
          UpdateErrorType.checkFailed,
          UpdateErrorType.downloadFailed,
          UpdateErrorType.installFailed,
        ]),
      );
    });
  });

  group('DesktopUpdateService Download & Cancellation Tests', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('flanki_download_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('downloadUpdate reports progress and completes', () async {
      final dio = createMockDio((request) async {
        return ResponseBody.fromBytes(
          [1, 2, 3, 4, 5, 6, 7, 8],
          200,
          headers: {
            Headers.contentLengthHeader: ['8'],
          },
        );
      });

      final service = DesktopUpdateService(dio: dio);
      final progresses = <double>[];
      final path = await service.downloadUpdate(
        'https://example.com/update.zip',
        fileName: 'test_update_file.zip',
        targetDirectoryPath: tempDir.path,
        onProgress: progresses.add,
      );

      expect(path, isNotNull);
      expect(progresses, isNotEmpty);
      expect(progresses.last, equals(1.0));
      expect(File(path!).existsSync(), isTrue);
    });

    test('cancelDownload aborts stream and cleans up file', () async {
      final dio = createMockDio((request) async {
        final stream = (() async* {
          for (int i = 0; i < 1000; i++) {
            yield Uint8List.fromList([i % 256]);
            await Future<void>.delayed(const Duration(milliseconds: 5));
          }
        })();

        return ResponseBody(
          stream,
          200,
          headers: {
            Headers.contentLengthHeader: ['1000'],
          },
        );
      });

      final service = DesktopUpdateService(dio: dio);
      final downloadFuture = service.downloadUpdate(
        'https://example.com/cancelled.zip',
        fileName: 'test_cancelled_file.zip',
        targetDirectoryPath: tempDir.path,
        onProgress: (p) {
          service.cancelDownload();
        },
      );

      final path = await downloadFuture;
      expect(path, isNull);
      expect(
        File('${tempDir.path}/test_cancelled_file.zip').existsSync(),
        isFalse,
      );
    });
  });
}
