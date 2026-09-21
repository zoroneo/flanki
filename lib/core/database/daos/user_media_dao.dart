import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../../config/supabase_config.dart';
import '../app_database.dart';
import 'database_context.dart';

class UserMediaDao {
  final DatabaseContext _context;

  UserMediaDao(this._context);

  AppDatabase get _db => _context.db;

  static String lookupMimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/m4a';
      case 'ogg':
        return 'audio/ogg';
      case 'wav':
        return 'audio/wav';
      default:
        return 'application/octet-stream';
    }
  }

  /// Registers a local media file into the database and enqueues it into syncOutbox.
  Future<UserMediaData> registerLocalMedia({
    required String filename,
    required List<int> bytes,
    String? mimeType,
  }) async {
    final sanitized = filename.trim();
    final hash = sha256.convert(bytes).toString();
    final size = bytes.length;
    final mime = mimeType ?? lookupMimeType(sanitized);
    final hlc = _context.advanceHlc().pack();

    await _db
        .into(_db.userMedia)
        .insertOnConflictUpdate(
          UserMediaCompanion.insert(
            filename: sanitized,
            hashSha256: Value(hash),
            sizeBytes: Value(size),
            mimeType: Value(mime),
            isUploaded: const Value(false),
            updatedAtHlc: Value(hlc),
            isDeleted: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );

    await _context.enqueueOutbox(
      entityType: SupabaseConfig.entityUserMedia,
      entityId: sanitized,
      operation: SupabaseConfig.opUpsert,
      payload: {
        'filename': sanitized,
        'hash_sha256': hash,
        'size_bytes': size,
        'mime_type': mime,
      },
      hlc: hlc,
    );

    return (await (_db.select(
      _db.userMedia,
    )..where((tbl) => tbl.filename.equals(sanitized))).getSingle());
  }

  /// Returns media records that need to be uploaded to Supabase Storage.
  Future<List<UserMediaData>> getPendingUploadMedia({int limit = 50}) async {
    return (_db.select(_db.userMedia)
          ..where(
            (tbl) => tbl.isUploaded.equals(false) & tbl.isDeleted.equals(false),
          )
          ..limit(limit))
        .get();
  }

  /// Marks a media record as uploaded.
  Future<void> markMediaUploaded(String filename) async {
    await (_db.update(_db.userMedia)
          ..where((tbl) => tbl.filename.equals(filename)))
        .write(const UserMediaCompanion(isUploaded: Value(true)));
  }

  /// Retrieves all active media records from the registry.
  Future<List<UserMediaData>> getAllUserMedia() async {
    return (_db.select(
      _db.userMedia,
    )..where((tbl) => tbl.isDeleted.equals(false))).get();
  }

  /// Retrieves a specific media record by filename.
  Future<UserMediaData?> getUserMedia(String filename) async {
    return (_db.select(
      _db.userMedia,
    )..where((tbl) => tbl.filename.equals(filename))).getSingleOrNull();
  }

  /// Soft-deletes a local media file and enqueues a tombstone mutation.
  Future<void> deleteMediaLocal(String filename) async {
    final hlc = _context.advanceHlc().pack();
    await (_db.update(
      _db.userMedia,
    )..where((tbl) => tbl.filename.equals(filename))).write(
      UserMediaCompanion(
        isDeleted: const Value(true),
        updatedAtHlc: Value(hlc),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await _context.enqueueOutbox(
      entityType: SupabaseConfig.entityUserMedia,
      entityId: filename,
      operation: SupabaseConfig.opDelete,
      payload: {'filename': filename},
      hlc: hlc,
    );
  }
}
