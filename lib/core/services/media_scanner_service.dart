import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../config/supabase_config.dart';
import '../database/database_service.dart';
import '../database/media_storage_service.dart';
import '../models/card.dart';

/// Scanner service that extracts media references from card fields,
/// auto-registers them into [DatabaseService], and identifies orphan media files.
class MediaScannerService {
  final DatabaseService _dbService;
  final MediaStorageService _mediaStorage;

  static const String _logTag = '[MediaScanner]';

  static final RegExp _soundRegex = RegExp(
    r'\[sound:([^\]]+)\]',
    caseSensitive: false,
  );
  static final RegExp _imgRegex = RegExp(
    r'''<img\s+[^>]*src\s*=\s*["']([^"'>]+)["'][^>]*>''',
    caseSensitive: false,
  );

  MediaScannerService({
    DatabaseService? dbService,
    MediaStorageService? mediaStorage,
  }) : _dbService = dbService ?? DatabaseService.instance,
       _mediaStorage = mediaStorage ?? MediaStorageService.instance;

  /// Extracts all referenced media filenames from HTML/text content.
  static Set<String> extractMediaFilenames(String content) {
    final filenames = <String>{};
    if (content.isEmpty) return filenames;

    for (final match in _soundRegex.allMatches(content)) {
      final name = match.group(1)?.trim();
      if (name != null && name.isNotEmpty) {
        filenames.add(p.basename(name));
      }
    }

    for (final match in _imgRegex.allMatches(content)) {
      final src = match.group(1)?.trim();
      if (src != null &&
          src.isNotEmpty &&
          !src.startsWith(SupabaseConfig.schemeHttp) &&
          !src.startsWith(SupabaseConfig.schemeHttps)) {
        filenames.add(
          p.basename(src.replaceAll(SupabaseConfig.schemeFile, '')),
        );
      }
    }

    return filenames;
  }

  /// Extracts all media filenames referenced across an entire card collection.
  static Set<String> extractAllMediaFromCards(Iterable<CardModel> cards) {
    final allMedia = <String>{};
    for (final card in cards) {
      allMedia.addAll(extractMediaFilenames(card.front));
      allMedia.addAll(extractMediaFilenames(card.back));
      if (card.hint != null) {
        allMedia.addAll(extractMediaFilenames(card.hint!));
      }
    }
    return allMedia;
  }

  /// Scans cards and registers any referenced local files that are not yet tracked
  /// in the [UserMedia] registry into SQLite and the sync outbox.
  Future<int> autoRegisterCardMedia(Iterable<CardModel> cards) async {
    final referenced = extractAllMediaFromCards(cards);
    if (referenced.isEmpty) return 0;

    int registered = 0;
    for (final filename in referenced) {
      final existing = await _dbService.getUserMedia(filename);
      if (existing != null) continue;

      final file = _mediaStorage.resolveMediaFile(filename);
      if (file != null && file.existsSync() && file.lengthSync() > 0) {
        try {
          final bytes = await file.readAsBytes();
          await _dbService.registerLocalMedia(filename: filename, bytes: bytes);
          registered++;
        } catch (e) {
          debugPrint('$_logTag Failed to auto-register $filename: $e');
        }
      }
    }

    return registered;
  }

  /// Finds files in the local media directory that are no longer referenced by any card.
  Future<List<File>> findOrphanMediaFiles(Iterable<CardModel> cards) async {
    final referenced = extractAllMediaFromCards(cards)
        .map((f) => f.toLowerCase())
        .toSet();
    final orphans = <File>[];

    final dir = _mediaStorage.mediaDirectory;
    if (!dir.existsSync()) return orphans;

    final entries = dir.listSync(followLinks: false);
    for (final entry in entries) {
      if (entry is File) {
        final name = p.basename(entry.path).toLowerCase();
        if (!referenced.contains(name)) {
          orphans.add(entry);
        }
      }
    }

    return orphans;
  }

  /// Deletes orphan media files from local disk.
  Future<int> cleanOrphanMediaFiles(Iterable<CardModel> cards) async {
    final orphans = await findOrphanMediaFiles(cards);
    int deleted = 0;

    for (final file in orphans) {
      try {
        await file.delete();
        deleted++;
      } catch (e) {
        debugPrint('$_logTag Failed to delete orphan file ${file.path}: $e');
      }
    }

    return deleted;
  }
}
