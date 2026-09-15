import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

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
      _mediaDir = Directory(p.join(docDir.path, AppConfig.mediaDirectoryName));
    }

    if (!_mediaDir!.existsSync()) {
      _mediaDir!.createSync(recursive: true);
    }
    return _mediaDir!;
  }

  Directory get mediaDirectory {
    if (_mediaDir == null) {
      final temp = Directory(
        p.join(Directory.systemTemp.path, AppConfig.mediaDirectoryName),
      );
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

  /// Resolves a media asset file, handling URL-encoding, enclosing quotes,
  /// zero-byte corruptions, and case-insensitivity on Android/Linux ext4 filesystems.
  File? resolveMediaFile(String rawFilename) {
    var clean = rawFilename.trim();
    if (clean.isEmpty) return null;

    // Strip enclosing double or single quotes
    if ((clean.startsWith('"') && clean.endsWith('"')) ||
        (clean.startsWith("'") && clean.endsWith("'"))) {
      if (clean.length >= 2) {
        clean = clean.substring(1, clean.length - 1).trim();
      }
    }

    // 1. Try direct exact filename
    final directSanitized = p.basename(clean);
    final directFile = File(p.join(mediaDirectoryPath, directSanitized));
    if (directFile.existsSync() && directFile.lengthSync() > 0) {
      return directFile;
    }

    // 2. Try URL-decoded filename (e.g. "sound%2001.mp3" -> "sound 01.mp3")
    try {
      final decoded = Uri.decodeComponent(clean);
      if (decoded != clean) {
        final decodedSanitized = p.basename(decoded);
        final decodedFile = File(p.join(mediaDirectoryPath, decodedSanitized));
        if (decodedFile.existsSync() && decodedFile.lengthSync() > 0) {
          return decodedFile;
        }
      }
    } catch (_) {}

    // 3. Fallback for case-sensitive filesystems (Android / Linux):
    // Search the directory for a case-insensitive match
    final targetLower = directSanitized.toLowerCase();
    try {
      final dir = mediaDirectory;
      if (dir.existsSync()) {
        final entries = dir.listSync(followLinks: false);
        for (final entry in entries) {
          if (entry is File) {
            final entryName = p.basename(entry.path);
            if (entryName.toLowerCase() == targetLower) {
              if (entry.lengthSync() > 0) {
                return entry;
              }
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Get the full absolute file path for a media asset.
  String getMediaFilePath(String filename) {
    final resolved = resolveMediaFile(filename);
    if (resolved != null) {
      return resolved.path;
    }
    final sanitized = p.basename(filename.trim());
    return p.join(mediaDirectoryPath, sanitized);
  }

  /// Check whether a media file exists on disk.
  bool mediaFileExists(String filename) {
    return resolveMediaFile(filename) != null;
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
