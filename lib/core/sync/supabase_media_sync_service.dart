import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../database/database_service.dart';
import '../database/media_storage_service.dart';

/// Abstraction over Supabase Storage for mockability in tests.
abstract class SupabaseStorageBridge {
  Future<Uint8List> download(String path);
  Future<void> uploadBinary(String path, Uint8List data, {String? contentType});
  Future<void> remove(List<String> paths);
}

class DefaultSupabaseStorageBridge implements SupabaseStorageBridge {
  final SupabaseClient _client;
  final String _bucket;

  DefaultSupabaseStorageBridge(this._client, {String? bucket})
    : _bucket = bucket ?? SupabaseConfig.mediaBucket;

  StorageFileApi get _storage => _client.storage.from(_bucket);

  @override
  Future<Uint8List> download(String path) {
    return _storage.download(path);
  }

  @override
  Future<void> uploadBinary(
    String path,
    Uint8List data, {
    String? contentType,
  }) async {
    await _storage.uploadBinary(
      path,
      data,
      fileOptions: FileOptions(
        upsert: true,
        contentType: contentType ?? SupabaseConfig.defaultBinaryContentType,
      ),
    );
  }

  @override
  Future<void> remove(List<String> paths) async {
    await _storage.remove(paths);
  }
}

/// Result of a binary media sync execution.
class MediaTransferSummary {
  final int uploadedCount;
  final int downloadedCount;
  final int failedCount;

  const MediaTransferSummary({
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.failedCount = 0,
  });

  bool get hasActivity => uploadedCount > 0 || downloadedCount > 0;
}

/// Service managing binary upload and download of flashcard media assets (images, audio)
/// with Supabase Storage bucket (`flanki_media`).
class SupabaseMediaSyncService {
  final SupabaseStorageBridge _storage;
  final DatabaseService _dbService;
  final MediaStorageService _mediaStorage;
  final String? Function()? _userIdProvider;
  final int maxConcurrent;

  static const String _logTag = '[MediaSync]';

  SupabaseMediaSyncService({
    SupabaseStorageBridge? storageBridge,
    SupabaseClient? client,
    DatabaseService? dbService,
    MediaStorageService? mediaStorage,
    String? Function()? userIdProvider,
    int? maxConcurrent,
  }) : _storage =
           storageBridge ??
           DefaultSupabaseStorageBridge(client ?? _getSupabaseClientSafe()),
       _dbService = dbService ?? DatabaseService.instance,
       _mediaStorage = mediaStorage ?? MediaStorageService.instance,
       _userIdProvider =
           userIdProvider ??
           (() {
             try {
               return Supabase.instance.client.auth.currentUser?.id;
             } catch (_) {
               return null;
             }
           }),
       maxConcurrent = maxConcurrent ?? AppConfig.syncMediaMaxConcurrent;

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

  /// Uploads all pending local media files to Supabase Storage in user-partitioned path.
  Future<int> uploadPendingMedia({
    String? userId,
    void Function(int done, int total)? onProgress,
  }) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return 0;

    final pending = await _dbService.getPendingUploadMedia();
    if (pending.isEmpty) return 0;

    int uploaded = 0;
    int processed = 0;

    for (int i = 0; i < pending.length; i += maxConcurrent) {
      final chunk = pending.skip(i).take(maxConcurrent).toList();
      final results = await Future.wait(
        chunk.map((item) async {
          final file = _mediaStorage.resolveMediaFile(item.filename);

          if (file != null && file.existsSync()) {
            try {
              final bytes = await file.readAsBytes();
              final storagePath = '$uid/${item.filename}';

              await _storage.uploadBinary(
                storagePath,
                bytes,
                contentType: item.mimeType.isNotEmpty
                    ? item.mimeType
                    : SupabaseConfig.defaultBinaryContentType,
              );
              await _dbService.markMediaUploaded(item.filename);
              return true;
            } catch (e) {
              debugPrint('$_logTag Failed to upload ${item.filename}: $e');
            }
          }
          return false;
        }),
      );

      for (final success in results) {
        if (success) uploaded++;
        processed++;
        onProgress?.call(processed, pending.length);
      }
    }

    return uploaded;
  }

  /// Downloads media files that exist in the remote registry but are missing locally.
  Future<int> downloadMissingMedia({
    String? userId,
    void Function(int done, int total)? onProgress,
  }) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return 0;

    final allMedia = await _dbService.getAllUserMedia();
    final missing = allMedia.where((item) {
      final file = _mediaStorage.resolveMediaFile(item.filename);
      return file == null || !file.existsSync() || file.lengthSync() == 0;
    }).toList();

    if (missing.isEmpty) return 0;

    int downloaded = 0;
    int processed = 0;

    for (int i = 0; i < missing.length; i += maxConcurrent) {
      final chunk = missing.skip(i).take(maxConcurrent).toList();
      final results = await Future.wait(
        chunk.map((item) async {
          final storagePath = '$uid/${item.filename}';

          try {
            final bytes = await _storage.download(storagePath);
            if (bytes.isNotEmpty) {
              await _mediaStorage.saveMediaFile(item.filename, bytes);
              return true;
            }
          } catch (e) {
            debugPrint('$_logTag Failed to download ${item.filename}: $e');
          }
          return false;
        }),
      );

      for (final success in results) {
        if (success) downloaded++;
        processed++;
        onProgress?.call(processed, missing.length);
      }
    }

    return downloaded;
  }

  /// Executes a full two-way binary media sync: Uploads pending -> Downloads missing.
  Future<MediaTransferSummary> syncMedia({
    String? userId,
    void Function(int completed, int total)? onProgress,
  }) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      return const MediaTransferSummary();
    }

    final uploaded = await uploadPendingMedia(userId: uid);
    final downloaded = await downloadMissingMedia(userId: uid);

    return MediaTransferSummary(
      uploadedCount: uploaded,
      downloadedCount: downloaded,
    );
  }
}
