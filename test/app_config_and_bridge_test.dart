import 'package:flanki/core/anki_bridge.dart';
import 'package:flanki/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig Tests', () {
    test('AppConfig constants match application specification and pubspec', () {
      expect(AppConfig.appName, equals('Flanki'));
      expect(AppConfig.version, equals('1.0.0'));
      expect(AppConfig.buildNumber, equals(1));
      expect(AppConfig.fullVersion, equals('1.0.0+1'));
    });
  });

  group('AnkiBridge Safe Runtime Detection Tests', () {
    test('AnkiBridge.isAvailable safely evaluates without throwing exceptions', () {
      // In CI / standard development where anki_bridge dynamic lib is not compiled,
      // isAvailable must return false gracefully rather than crashing.
      expect(() => AnkiBridge.isAvailable, returnsNormally);
      expect(AnkiBridge.isAvailable, isA<bool>());
    });

    test('AnkiBridge.tryCreate returns null when native binary is unavailable', () {
      final bridge = AnkiBridge.tryCreate(libraryPath: 'non_existent_anki_library.dll');
      expect(bridge, isNull);
    });
  });
}
