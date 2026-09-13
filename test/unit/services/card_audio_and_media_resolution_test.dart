import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:flanki/core/database/media_storage_service.dart';
import 'package:flanki/core/services/card_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempMediaDir;

  setUp(() async {
    tempMediaDir = await Directory.systemTemp.createTemp('flanki_media_test_');
    await MediaStorageService.instance.init(customPath: tempMediaDir.path);
  });

  tearDown(() async {
    if (tempMediaDir.existsSync()) {
      tempMediaDir.deleteSync(recursive: true);
    }
  });

  group('MediaStorageService.resolveMediaFile tests', () {
    test('resolves exact filename', () {
      final file = File(p.join(tempMediaDir.path, 'sample.mp3'))
        ..writeAsBytesSync([1, 2, 3]);
      final resolved = MediaStorageService.instance.resolveMediaFile(
        'sample.mp3',
      );

      expect(resolved, isNotNull);
      expect(resolved!.path, equals(file.path));
      expect(
        MediaStorageService.instance.mediaFileExists('sample.mp3'),
        isTrue,
      );
    });

    test('resolves URL-encoded filename (e.g. %20 -> space)', () {
      // File saved on disk with actual space
      final file = File(p.join(tempMediaDir.path, 'audio with space.mp3'))
        ..writeAsBytesSync([1, 2, 3]);

      // Card tag contains URL-encoded name
      final resolved = MediaStorageService.instance.resolveMediaFile(
        'audio%20with%20space.mp3',
      );

      expect(resolved, isNotNull);
      expect(resolved!.path, equals(file.path));
      expect(
        MediaStorageService.instance.mediaFileExists(
          'audio%20with%20space.mp3',
        ),
        isTrue,
      );
    });

    test(
      'resolves case-insensitive filename on Android/Linux ext4 filesystem',
      () {
        // File saved on disk as lowercase
        final file = File(p.join(tempMediaDir.path, 'vocab_agree.mp3'))
          ..writeAsBytesSync([1, 2, 3]);

        // Card requests uppercase or mixed case
        final resolved = MediaStorageService.instance.resolveMediaFile(
          'VOCAB_AGREE.MP3',
        );

        expect(resolved, isNotNull);
        expect(resolved!.path.toLowerCase(), equals(file.path.toLowerCase()));
        expect(
          MediaStorageService.instance.mediaFileExists('VOCAB_AGREE.MP3'),
          isTrue,
        );
      },
    );

    test('strips surrounding quotes in sound tags', () {
      final file = File(p.join(tempMediaDir.path, 'quoted.mp3'))
        ..writeAsBytesSync([1, 2, 3]);

      final resolvedDoubleQuote = MediaStorageService.instance.resolveMediaFile(
        '"quoted.mp3"',
      );
      expect(resolvedDoubleQuote, isNotNull);
      expect(resolvedDoubleQuote!.path, equals(file.path));

      final resolvedSingleQuote = MediaStorageService.instance.resolveMediaFile(
        "'quoted.mp3'",
      );
      expect(resolvedSingleQuote, isNotNull);
      expect(resolvedSingleQuote!.path, equals(file.path));
    });

    test('returns null for non-existent file', () {
      final resolved = MediaStorageService.instance.resolveMediaFile(
        'non_existent.mp3',
      );
      expect(resolved, isNull);
      expect(
        MediaStorageService.instance.mediaFileExists('non_existent.mp3'),
        isFalse,
      );
    });

    test('returns null for 0-byte corrupted file', () {
      File(p.join(tempMediaDir.path, 'corrupted.mp3')).writeAsBytesSync([]);

      final resolved = MediaStorageService.instance.resolveMediaFile(
        'corrupted.mp3',
      );
      expect(resolved, isNull);
      expect(
        MediaStorageService.instance.mediaFileExists('corrupted.mp3'),
        isFalse,
      );
    });
  });

  group('CardAudioService state tests', () {
    test('stop clears playingFilenameNotifier safely', () async {
      final service = CardAudioService.instance;
      await service.stop();
      expect(service.currentPlayingFilename, isNull);
    });

    test(
      'playMedia with non-existent file does not throw and keeps state null',
      () async {
        final service = CardAudioService.instance;
        await service.playMedia('missing_sound.mp3');
        expect(service.currentPlayingFilename, isNull);
      },
    );
  });
}
