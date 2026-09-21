import 'dart:io';

import 'package:flanki/core/anki/anki_bridge.dart';
import 'package:flanki/core/config/app_config.dart';
import 'package:flanki/core/config/supabase_config.dart';
import 'package:flanki/core/sync/hlc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig Tests', () {
    test('AppConfig constants match application specification and pubspec', () {
      expect(AppConfig.appName, equals('Flanki'));
      expect(AppConfig.version, matches(RegExp(r'^\d+\.\d+\.\d+$')));
      expect(AppConfig.buildNumber, isPositive);
      expect(
        AppConfig.fullVersion,
        equals('${AppConfig.version}+${AppConfig.buildNumber}'),
      );

      final pubspecFile = File('pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        expect(content, contains('version: ${AppConfig.fullVersion}'));
      }

      expect(AppConfig.defaultNewCardsPerDay, equals(20));
      expect(AppConfig.defaultReviewsPerDay, equals(100));
      expect(AppConfig.defaultCramLimit, equals(50));
      expect(AppConfig.defaultDesiredRetention, equals(0.90));
      expect(AppConfig.defaultReminderHour, equals(20));
      expect(AppConfig.defaultReminderMinute, equals(0));
      // In test runner (kDebugMode is true), displayAppName adds [DEBUG] prefix
      expect(AppConfig.displayAppName, equals('[DEBUG] Flanki'));
      expect(AppConfig.databaseName, equals('flanki_debug'));
      expect(AppConfig.mediaDirectoryName, equals('flanki_media_debug'));
    });

    test('AppConfig allows dynamic runtime version override and reset', () {
      AppConfig.updateRuntimeVersion(version: '2.0.0', buildNumber: 99);
      expect(AppConfig.version, equals('2.0.0'));
      expect(AppConfig.buildNumber, equals(99));
      expect(AppConfig.fullVersion, equals('2.0.0+99'));

      AppConfig.resetVersion();
      expect(AppConfig.version, equals(AppConfig.defaultVersion));
      expect(AppConfig.buildNumber, equals(AppConfig.defaultBuildNumber));
    });

    test('AppConfig provides centralized locale resolution, fallback, and duration constants', () {
      expect(AppConfig.defaultLocale.languageCode, equals('vi'));
      expect(
        AppConfig.supportedLocales.map((l) => l.languageCode),
        containsAll(['vi', 'en']),
      );

      final systemCode = AppConfig.resolveSystemLocaleCode();
      expect(systemCode, isIn(['vi', 'en']));

      // Test synchronous AppLocalizations retrieval
      final viL10n = AppConfig.getL10n('vi');
      expect(viL10n.appTitle, equals('Flanki'));
      expect(viL10n.studyNow, equals('Học ngay'));

      final enL10n = AppConfig.getL10n('en');
      expect(enL10n.appTitle, equals('Flanki'));
      expect(enL10n.studyNow, equals('Study Now'));

      // Test fallback on unknown locale code
      final fallbackL10n = AppConfig.getL10n('xx_unknown');
      expect(fallbackL10n, isNotNull);
      expect(fallbackL10n.studyNow, equals('Học ngay'));

      // Centralized durations
      expect(AppConfig.updateCheckTimeout, equals(const Duration(seconds: 10)));
      expect(AppConfig.toastLongDuration, equals(const Duration(seconds: 20)));
      expect(
        AppConfig.toastDefaultDuration,
        equals(const Duration(seconds: 4)),
      );
      expect(
        AppConfig.toastSuccessDismissDelay,
        equals(const Duration(seconds: 4)),
      );
      expect(
        AppConfig.toastErrorDismissDelay,
        equals(const Duration(seconds: 5)),
      );
      expect(
        AppConfig.toastExtendedDuration,
        equals(const Duration(minutes: 5)),
      );
      expect(
        AppConfig.toastPersistentDuration,
        equals(const Duration(hours: 1)),
      );
      expect(AppConfig.defaultRelearnStep, equals(const Duration(minutes: 10)));
      expect(
        AppConfig.desktopReminderCheckInterval,
        equals(const Duration(minutes: 1)),
      );
      expect(
        AppConfig.desktopUpdatePollInterval,
        equals(const Duration(hours: 4)),
      );
      expect(
        AppConfig.desktopUpdateInitialDelay,
        equals(const Duration(seconds: 4)),
      );
      expect(
        AppConfig.examTimerTickInterval,
        equals(const Duration(seconds: 1)),
      );
      expect(
        AppConfig.defaultSyncPeriodicInterval,
        equals(const Duration(minutes: 5)),
      );
      expect(
        AppConfig.defaultSyncDebounceDuration,
        equals(const Duration(seconds: 2)),
      );
      expect(
        AppConfig.syncClockSkewTolerance,
        equals(const Duration(seconds: 2)),
      );
      expect(AppConfig.defaultMaxClockDriftMillis, equals(60000));

      // Centralized GitHub repo parameters
      expect(AppConfig.githubRepoOwner, equals('zoroneo'));
      expect(AppConfig.githubRepoName, equals('flanki'));
      expect(
        AppConfig.githubReleasesApiUrl,
        equals('https://api.github.com/repos/zoroneo/flanki/releases/latest'),
      );
      expect(
        AppConfig.githubReleasesUrl,
        equals('https://github.com/zoroneo/flanki/releases'),
      );

      // Business logic constants and helpers
      expect(AppConfig.cramLimitOptions, equals([10, 20, 50, 100]));
      expect(AppConfig.deckHierarchyDelimiter, equals('::'));
      expect(AppConfig.deckHierarchyBreadcrumbSeparator, equals(' › '));
      expect(AppConfig.tagPrefix, equals('#'));
      expect(
        AppConfig.formatDayKey(DateTime(2026, 9, 20)),
        equals('2026-09-20'),
      );
      expect(
        AppConfig.formatDayKey(DateTime(2026, 1, 5)),
        equals('2026-01-05'),
      );
      expect(IdHelper.newDeckId(123456789), equals('deck_123456789'));
      expect(IdHelper.newDeckId(), startsWith('deck_'));
    });
  });

  group('SupabaseConfig & HLC Configuration Tests', () {
    test('SupabaseConfig provides valid defaults, mock credentials, and batch limits', () {
      expect(SupabaseConfig.mediaBucket, equals('flanki_media'));
      expect(SupabaseConfig.mockUrl, equals('https://mock.supabase.co'));
      expect(SupabaseConfig.mockAnonKey, equals('mock-key'));
      expect(SupabaseConfig.defaultPushBatchLimit, equals(100));
      expect(SupabaseConfig.defaultPullBatchLimit, equals(500));
      expect(
        Hlc.defaultMaxDriftMillis,
        equals(AppConfig.defaultMaxClockDriftMillis),
      );
    });
  });

  group('AnkiBridge Safe Runtime Detection Tests', () {
    test(
      'AnkiBridge.isAvailable safely evaluates without throwing exceptions',
      () {
        // In CI / standard development where anki_bridge dynamic lib is not compiled,
        // isAvailable must return false gracefully rather than crashing.
        expect(() => AnkiBridge.isAvailable, returnsNormally);
        expect(AnkiBridge.isAvailable, isA<bool>());
      },
    );

    test(
      'AnkiBridge.tryCreate returns null when native binary is unavailable',
      () {
        final bridge = AnkiBridge.tryCreate(
          libraryPath: 'non_existent_anki_library.dll',
        );
        expect(bridge, isNull);
      },
    );
  });
}
