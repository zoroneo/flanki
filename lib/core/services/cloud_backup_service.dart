import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../database/database_service.dart';
import '../database/media_storage_service.dart';
import '../sync/payload_optimizer.dart';
import '../sync/supabase_media_sync_service.dart';

/// Metadata for a cloud backup archive file.
class CloudBackupMetadata {
  final String name;
  final String path;
  final int sizeBytes;
  final DateTime? createdAt;

  const CloudBackupMetadata({
    required this.name,
    required this.path,
    required this.sizeBytes,
    this.createdAt,
  });

  String get formattedSize => SyncBandwidthTracker.formatBytes(sizeBytes);
}

/// Service managing creation, cloud upload, listing, download, and restoration
/// of comprehensive `.flanki` snapshot packages.
class CloudBackupService {
  final DatabaseService _dbService;
  final MediaStorageService _mediaStorage;
  final SupabaseStorageBridge _storage;
  final String? Function()? _userIdProvider;

  CloudBackupService({
    DatabaseService? dbService,
    MediaStorageService? mediaStorage,
    SupabaseStorageBridge? storageBridge,
    SupabaseClient? client,
    String? Function()? userIdProvider,
  }) : _dbService = dbService ?? DatabaseService.instance,
       _mediaStorage = mediaStorage ?? MediaStorageService.instance,
       _storage =
           storageBridge ??
           DefaultSupabaseStorageBridge(
             client ?? _getSupabaseClientSafe(),
             bucket: SupabaseConfig.backupBucket,
           ),
       _userIdProvider =
           userIdProvider ??
           (() {
             try {
               return Supabase.instance.client.auth.currentUser?.id;
             } catch (_) {
               return null;
             }
           });

  static SupabaseClient _getSupabaseClientSafe() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return SupabaseClient(
        SupabaseConfig.mockUrl,
        SupabaseConfig.mockAnonKey,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
    }
  }

  String? get currentUserId => _userIdProvider?.call();

  /// Creates a local `.flanki` snapshot package containing serialized database records
  /// and binary media assets.
  Future<File> createLocalSnapshot({
    String? targetFilePath,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.1);

    final dbData = await _dbService.exportDatabaseSnapshot();
    onProgress?.call(0.3);

    final archive = Archive();

    // 1. Add data.json
    final dataBytes = utf8.encode(jsonEncode(dbData));
    archive.addFile(
      ArchiveFile(
        AppConfig.backupDataFileName,
        dataBytes.length,
        Uint8List.fromList(dataBytes),
      ),
    );
    onProgress?.call(0.5);

    // 2. Add media files
    final mediaRecords = (dbData['user_media'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    for (final m in mediaRecords) {
      final filename = m['filename'] as String? ?? '';
      if (filename.isEmpty) continue;
      final file = _mediaStorage.resolveMediaFile(filename);
      if (file != null && file.existsSync()) {
        final bytes = file.readAsBytesSync();
        archive.addFile(
          ArchiveFile(
            '${AppConfig.backupMediaDirectoryName}/$filename',
            bytes.length,
            bytes,
          ),
        );
      }
    }
    onProgress?.call(0.7);

    // 3. Add manifest.json
    final manifest = {
      'app': AppConfig.appName,
      'version': AppConfig.defaultVersion,
      'schema_version': AppConfig.currentDatabaseSchemaVersion,
      'created_at': DateTime.now().toIso8601String(),
      'deck_count': (dbData['decks'] as List<dynamic>? ?? []).length,
      'card_count': (dbData['cards'] as List<dynamic>? ?? []).length,
      'media_count': mediaRecords.length,
    };
    final manifestBytes = utf8.encode(jsonEncode(manifest));
    archive.addFile(
      ArchiveFile(
        AppConfig.backupManifestFileName,
        manifestBytes.length,
        Uint8List.fromList(manifestBytes),
      ),
    );

    // 4. Encode ZIP archive
    final zipEncoder = ZipEncoder();
    final encoded = zipEncoder.encode(archive);
    onProgress?.call(0.9);

    // 5. Output file
    late File targetFile;
    if (targetFilePath != null) {
      targetFile = File(targetFilePath);
    } else {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      targetFile = File(
        p.join(
          tempDir.path,
          'backup_$timestamp${AppConfig.flankiBackupExtension}',
        ),
      );
    }

    await targetFile.writeAsBytes(encoded);
    onProgress?.call(1.0);
    return targetFile;
  }

  /// Restores complete state from a `.flanki` archive file.
  Future<bool> restoreFromSnapshot(
    File snapshotFile, {
    void Function(double progress)? onProgress,
  }) async {
    if (!snapshotFile.existsSync() || snapshotFile.lengthSync() == 0) {
      throw const FormatException(SupabaseConfig.errSnapshotEmptyOrMissing);
    }

    onProgress?.call(0.1);
    final bytes = await snapshotFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    onProgress?.call(0.3);

    ArchiveFile? manifestFile;
    ArchiveFile? dataFile;
    final mediaFiles = <ArchiveFile>[];

    for (final file in archive) {
      if (file.name == AppConfig.backupManifestFileName) {
        manifestFile = file;
      } else if (file.name == AppConfig.backupDataFileName) {
        dataFile = file;
      } else if (file.name.startsWith(
        '${AppConfig.backupMediaDirectoryName}/',
      )) {
        mediaFiles.add(file);
      }
    }

    if (manifestFile == null || dataFile == null) {
      throw const FormatException(SupabaseConfig.errInvalidSnapshotPackage);
    }

    onProgress?.call(0.5);

    // 1. Restore media files
    for (final mf in mediaFiles) {
      final filename = p.basename(mf.name);
      final destPath = _mediaStorage.getMediaFilePath(filename);
      final destFile = File(destPath);
      final content = mf.content as List<int>;
      await destFile.writeAsBytes(content);
    }
    onProgress?.call(0.7);

    // 2. Restore database records
    final dataString = utf8.decode(dataFile.content as List<int>);
    final dataMap = jsonDecode(dataString) as Map<String, dynamic>;

    await _dbService.restoreDatabaseSnapshot(dataMap);
    onProgress?.call(1.0);
    return true;
  }

  /// Uploads a local snapshot package to the user's partition in Supabase Storage.
  Future<String> uploadSnapshotToCloud(
    File snapshotFile, {
    String? userId,
    void Function(double progress)? onProgress,
  }) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      throw const AuthException(SupabaseConfig.errUserMustBeLoggedInToUpload);
    }

    onProgress?.call(0.2);
    final bytes = await snapshotFile.readAsBytes();
    final filename = p.basename(snapshotFile.path);
    final storagePath = '$uid/$filename';

    onProgress?.call(0.5);
    await _storage.uploadBinary(
      storagePath,
      bytes,
      contentType: SupabaseConfig.defaultBinaryContentType,
    );

    onProgress?.call(1.0);
    return storagePath;
  }

  /// Lists all cloud backups stored in Supabase Storage for the current user.
  Future<List<CloudBackupMetadata>> listCloudSnapshots({String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return [];

    try {
      final client = Supabase.instance.client;
      final fileObjects = await client.storage
          .from(SupabaseConfig.backupBucket)
          .list(path: uid);

      return fileObjects.map((item) {
        final createdAt = item.createdAt != null
            ? DateTime.tryParse(item.createdAt!)
            : null;
        final size = item.metadata?['size'] as int? ?? 0;
        return CloudBackupMetadata(
          name: item.name,
          path: '$uid/${item.name}',
          sizeBytes: size,
          createdAt: createdAt,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Downloads a cloud snapshot and restores local state from it.
  Future<bool> restoreFromCloudSnapshot(
    String cloudPath, {
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.1);
    final bytes = await _storage.download(cloudPath);
    onProgress?.call(0.4);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      p.join(tempDir.path, 'downloaded_${p.basename(cloudPath)}'),
    );
    await tempFile.writeAsBytes(bytes);

    return restoreFromSnapshot(tempFile, onProgress: onProgress);
  }

  /// Deletes a cloud snapshot from Supabase Storage.
  Future<void> deleteCloudSnapshot(String cloudPath) async {
    await _storage.remove([cloudPath]);
  }
}
