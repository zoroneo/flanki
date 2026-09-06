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
      // Fallback synchronous initialization to temporary dir if init wasn't awaited yet
      final temp = Directory.systemTemp.createTempSync('flanki_media_');
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

  /// Rewrites `<img src="...">` relative filenames to local `file:///` URLs
  /// so that HTML renderers can load them directly.
  String resolveHtmlMedia(String html) {
    if (html.isEmpty) return html;

    final mediaPath = mediaDirectoryPath;
    // Replace <img src="filename"> or <img src='filename'> (where src does not start with http/https/file/data)
    final imgRegex = RegExp(r'''(<img\s+[^>]*src\s*=\s*["'])(?!https?:\/\/|file:\/\/|data:)([^"'>]+)(["'][^>]*>)''', caseSensitive: false);

    return html.replaceAllMapped(imgRegex, (match) {
      final prefix = match.group(1)!;
      final rawSrc = match.group(2)!;
      final suffix = match.group(3)!;
      final filename = p.basename(rawSrc);
      final fileUri = 'file://${p.join(mediaPath, filename)}';
      return '$prefix$fileUri$suffix';
    });
  }
}
