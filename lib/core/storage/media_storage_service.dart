import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Service to persist, locate, and rewrite Anki media assets (images, audio).
class MediaStorageService {
  static MediaStorageService? _instance;
  Directory? _mediaDir;

  MediaStorageService._();

  static MediaStorageService get instance {
    _instance ??= MediaStorageService._();
    return _instance!;
  }

  /// Initialize the media directory. Can specify a custom path for unit testing.
  Future<Directory> init({String? customPath}) async {
    if (customPath != null) {
      _mediaDir = Directory(customPath);
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      _mediaDir = Directory(p.join(docDir.path, 'flanki_media'));
    }

    if (!_mediaDir!.existsSync()) {
      _mediaDir!.createSync(recursive: true);
    }
    return _mediaDir!;
  }

  Directory get mediaDirectory {
    if (_mediaDir == null) {
      final temp = Directory(p.join(Directory.systemTemp.path, 'flanki_media'));
      if (!temp.existsSync()) {
        temp.createSync(recursive: true);
      }
      _mediaDir = temp;
    }
    return _mediaDir!;
  }

  String get mediaDirectoryPath => mediaDirectory.path;

  /// Save raw bytes for a media asset filename.
  Future<File> saveMediaFile(String filename, List<int> bytes) async {
    final sanitized = p.basename(filename);
    final file = File(p.join(mediaDirectoryPath, sanitized));
    return file.writeAsBytes(bytes);
  }

  /// Save raw bytes synchronously.
  File saveMediaFileSync(String filename, List<int> bytes) {
    final sanitized = p.basename(filename);
    final file = File(p.join(mediaDirectoryPath, sanitized));
    file.writeAsBytesSync(bytes);
    return file;
  }

  /// Get the full absolute file path for a media asset.
  String getMediaFilePath(String filename) {
    final sanitized = p.basename(filename);
    return p.join(mediaDirectoryPath, sanitized);
  }

  /// Check whether a media file exists on disk.
  bool mediaFileExists(String filename) {
    final sanitized = p.basename(filename);
    return File(p.join(mediaDirectoryPath, sanitized)).existsSync();
  }

  /// Normalizes `<img src="...">` paths, stripping any absolute `file://` temporary
  /// paths back to clean standard relative filenames.
  String resolveHtmlMedia(String html) {
    if (html.isEmpty) return html;

    final legacyImgRegex = RegExp(
      r'''(<img\s+[^>]*src\s*=\s*["'])file:\/\/[^"'>]*[\\\/]([^"'>]+)(["'][^>]*>)''',
      caseSensitive: false,
    );

    return html.replaceAllMapped(legacyImgRegex, (match) {
      final prefix = match.group(1)!;
      final filename = match.group(2)!;
      final suffix = match.group(3)!;
      return '$prefix$filename$suffix';
    });
  }
}
