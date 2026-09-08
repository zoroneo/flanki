import 'dart:convert';

import 'package:flanki/core/config/app_config.dart';
import 'package:flanki/core/services/desktop_update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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
    test('Finds matching asset from assets list', () {
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
      ];

      final asset = DesktopUpdateService.findPlatformAsset(assets);
      expect(asset, isNotNull);
      expect(asset!['name'], isA<String>());
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

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = DesktopUpdateService(client: client);
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

        final client = MockClient((request) async {
          return http.Response(jsonEncode(mockResponse), 200);
        });

        final service = DesktopUpdateService(client: client);
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
        final client = MockClient((request) async {
          return http.Response('Server Error', 500);
        });

        final service = DesktopUpdateService(client: client);
        final updateInfo = await service.checkForUpdates(
          currentVersion: '1.0.0',
        );

        expect(updateInfo.hasUpdate, isFalse);
        expect(updateInfo.currentVersion, equals('1.0.0'));
        expect(updateInfo.releaseUrl, equals(AppConfig.githubReleasesUrl));
      },
    );
  });
}
