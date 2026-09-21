import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../database/database_service.dart';
import '../database/media_storage_service.dart';

/// Aggregated breakdown of local and cloud storage usage.
class StorageStatsModel {
  final int localDeckCount;
  final int localCardCount;
  final int localMediaCount;
  final int localDatabaseBytes;
  final int localMediaBytes;

  final int cloudDeckCount;
  final int cloudCardCount;
  final int cloudMediaCount;
  final int cloudMediaBytes;
  final int cloudBackupCount;
  final int cloudBackupBytes;

  const StorageStatsModel({
    required this.localDeckCount,
    required this.localCardCount,
    required this.localMediaCount,
    required this.localDatabaseBytes,
    required this.localMediaBytes,
    this.cloudDeckCount = 0,
    this.cloudCardCount = 0,
    this.cloudMediaCount = 0,
    this.cloudMediaBytes = 0,
    this.cloudBackupCount = 0,
    this.cloudBackupBytes = 0,
  });

  int get totalLocalBytes => localDatabaseBytes + localMediaBytes;
  int get totalCloudBytes => cloudMediaBytes + cloudBackupBytes;

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Service calculating storage usage across local SQLite/media and Supabase Cloud.
class CloudStorageStatsService {
  final DatabaseService _dbService;
  final MediaStorageService _mediaStorage;
  final SupabaseClient? _client;

  CloudStorageStatsService({
    DatabaseService? dbService,
    MediaStorageService? mediaStorage,
    SupabaseClient? client,
  }) : _dbService = dbService ?? DatabaseService.instance,
       _mediaStorage = mediaStorage ?? MediaStorageService.instance,
       _client = client ?? _getSupabaseClientSafe();

  static SupabaseClient? _getSupabaseClientSafe() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Computes combined local and cloud storage statistics.
  Future<StorageStatsModel> getStats() async {
    // 1. Local statistics
    final decks = _dbService.getAllDecks();
    final cards = _dbService.getAllCards();
    final allMedia = await _dbService.getAllUserMedia();

    int localDbBytes = 0;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dbFile = File(
        p.join(docDir.path, '${AppConfig.databaseName}.sqlite'),
      );
      if (dbFile.existsSync()) {
        localDbBytes = dbFile.lengthSync();
      }
    } catch (_) {}

    int localMediaBytes = 0;
    try {
      final mediaDir = Directory(_mediaStorage.mediaDirectoryPath);
      if (mediaDir.existsSync()) {
        final entities = mediaDir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            localMediaBytes += entity.lengthSync();
          }
        }
      }
    } catch (_) {}

    // 2. Cloud statistics
    int cloudDecks = 0;
    int cloudCards = 0;
    int cloudMedia = 0;
    int cloudMediaBytes = 0;
    int cloudBackups = 0;
    int cloudBackupBytes = 0;

    final user = _client?.auth.currentUser;
    if (user != null) {
      try {
        final res = await _client?.rpc(SupabaseConfig.rpcGetCloudStorageStats);
        if (res is Map<String, dynamic>) {
          cloudDecks = res['deck_count'] as int? ?? 0;
          cloudCards = res['card_count'] as int? ?? 0;
          cloudMedia = res['media_count'] as int? ?? 0;
          cloudMediaBytes = (res['media_bytes'] as num?)?.toInt() ?? 0;
          cloudBackups = res['backup_count'] as int? ?? 0;
          cloudBackupBytes = (res['backup_bytes'] as num?)?.toInt() ?? 0;
        }
      } catch (e) {
        debugPrint('[StorageStats] Cloud stats fetch error (fallback): $e');
      }
    }

    return StorageStatsModel(
      localDeckCount: decks.length,
      localCardCount: cards.length,
      localMediaCount: allMedia.length,
      localDatabaseBytes: localDbBytes,
      localMediaBytes: localMediaBytes,
      cloudDeckCount: cloudDecks,
      cloudCardCount: cloudCards,
      cloudMediaCount: cloudMedia,
      cloudMediaBytes: cloudMediaBytes,
      cloudBackupCount: cloudBackups,
      cloudBackupBytes: cloudBackupBytes,
    );
  }
}
