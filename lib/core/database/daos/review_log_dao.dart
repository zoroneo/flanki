import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../config/app_config.dart';
import '../../config/supabase_config.dart';
import '../../models/card.dart';
import '../../models/review_log.dart';
import '../app_database.dart';
import 'database_context.dart';

class ReviewLogDao {
  final DatabaseContext _context;

  ReviewLogDao(this._context);

  AppDatabase get _db => _context.db;

  List<ReviewLogModel> getAllReviewLogs() =>
      List.unmodifiable(_context.cachedReviewLogs);

  Future<void> insertReviewLog({
    required String cardId,
    required ReviewRating rating,
    required DateTime reviewTime,
    required int scheduledDays,
    required int elapsedDays,
  }) async {
    final clientLogId = 'log_${cardId}_${reviewTime.millisecondsSinceEpoch}';
    final log = ReviewLogModel(
      id: DateTime.now().microsecondsSinceEpoch,
      cardId: cardId,
      rating: rating,
      reviewTime: reviewTime,
      scheduledDays: scheduledDays,
      elapsedDays: elapsedDays,
      clientLogId: clientLogId,
    );
    _context.cachedReviewLogs.insert(0, log);

    final hlcStr = _context.advanceHlc().pack();

    await _db.transaction(() async {
      await _db
          .into(_db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: cardId,
              rating: rating.value,
              reviewTime: reviewTime,
              scheduledDays: Value(scheduledDays),
              elapsedDays: Value(elapsedDays),
              clientLogId: Value(clientLogId),
            ),
          );

      await _db
          .into(_db.syncOutbox)
          .insertOnConflictUpdate(
            SyncOutboxCompanion.insert(
              id: IdHelper.outboxId(
                prefix: 'revlog',
                entityId: clientLogId,
                hlc: hlcStr,
              ),
              entityType: SupabaseConfig.entityReviewLog,
              entityId: clientLogId,
              operation: SupabaseConfig.opInsert,
              payloadJson: jsonEncode(log.toJson()),
              hlc: hlcStr,
            ),
          );
    });
    await _context.reloadCache();
    _context.onMutationEnqueued?.call();
  }

  Future<void> saveReviewLogs(List<ReviewLogModel> logs) async {
    if (logs.isEmpty) return;

    final existingSet = _context.cachedReviewLogs
        .map((l) => '${l.cardId}_${l.reviewTime.millisecondsSinceEpoch}')
        .toSet();

    final cardIdSet = _context.cachedCards.map((c) => c.id).toSet();

    final newLogs = logs.where((l) {
      final key = '${l.cardId}_${l.reviewTime.millisecondsSinceEpoch}';
      return !existingSet.contains(key) && cardIdSet.contains(l.cardId);
    }).toList();

    if (newLogs.isEmpty) return;

    await _db.batch((batch) {
      for (final log in newLogs) {
        batch.insert(
          _db.reviewLogs,
          ReviewLogsCompanion.insert(
            cardId: log.cardId,
            rating: log.rating.value,
            reviewTime: log.reviewTime,
            scheduledDays: Value(log.scheduledDays),
            elapsedDays: Value(log.elapsedDays),
          ),
        );
      }
    });

    await _context.reloadCache();
  }

  /// Checks if any cards or review logs have been added or updated after [lastSyncTime].
  bool hasLocalChangesSince(DateTime? lastSyncTime) {
    if (lastSyncTime == null) {
      return _context.cachedCards.isNotEmpty ||
          _context.cachedReviewLogs.isNotEmpty;
    }
    final hasReviewedCard = _context.cachedCards.any(
      (c) =>
          (c.lastStudied != null && c.lastStudied!.isAfter(lastSyncTime)) ||
          (c.createdAt != null && c.createdAt!.isAfter(lastSyncTime)),
    );
    if (hasReviewedCard) return true;

    return _context.cachedReviewLogs.any(
      (l) => l.reviewTime.isAfter(lastSyncTime),
    );
  }

  /// Persists downloaded SQLite bytes from AnkiWeb as the sync template.
  Future<void> saveSyncTemplateBytes(Uint8List bytes) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final file = File('${supportDir.path}/sync_template.anki2');
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {}
  }

  /// Persists sync template from an existing file using OS-level copy.
  Future<void> saveSyncTemplateFile(File sourceFile) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final file = File('${supportDir.path}/sync_template.anki2');
      if (file.existsSync()) {
        file.deleteSync();
      }
      await sourceFile.copy(file.path);
    } catch (_) {}
  }

  /// Exports local collection and review logs to a valid SQLite collection.anki2 binary.
  Future<Uint8List> exportToAnki2Db() async {
    final supportDir = await getApplicationSupportDirectory();
    final templateFile = File(
      '${supportDir.path}/${AppConfig.ankiSyncTemplateFileName}',
    );
    final tempDir = Directory.systemTemp.createTempSync(
      AppConfig.tempExportPrefix,
    );
    final targetDbFile = File('${tempDir.path}/${AppConfig.anki2DbFileName}');

    try {
      if (templateFile.existsSync()) {
        templateFile.copySync(targetDbFile.path);
      }

      final db = sqlite3.open(targetDbFile.path);
      try {
        db.execute('''
          CREATE TABLE IF NOT EXISTS col (
            id integer primary key,
            crt integer,
            mod integer,
            scm integer,
            ver integer,
            dty integer,
            usn integer,
            ls integer,
            conf text,
            models text,
            decks text,
            dconf text,
            tags text
          );
          CREATE TABLE IF NOT EXISTS notes (
            id integer primary key,
            guid text,
            mid integer,
            mod integer,
            usn integer,
            tags text,
            flds text,
            sfld integer,
            csum integer,
            flags integer,
            data text
          );
          CREATE TABLE IF NOT EXISTS cards (
            id integer primary key,
            nid integer,
            did integer,
            ord integer,
            mod integer,
            usn integer,
            type integer,
            queue integer,
            due integer,
            ivl integer,
            factor integer,
            reps integer,
            lapses integer,
            left integer,
            odue integer,
            odid integer,
            flags integer,
            data text
          );
          CREATE TABLE IF NOT EXISTS revlog (
            id integer primary key,
            cid integer,
            usn integer,
            ease integer,
            ivl integer,
            lastIvl integer,
            factor integer,
            time integer,
            type integer
          );
          CREATE TABLE IF NOT EXISTS graves (
            usn integer not null,
            oid integer not null,
            type integer not null
          );
        ''');

        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // Update or insert col row
        final colCount =
            db.select('SELECT count(*) as cnt FROM col').first['cnt'] as int;
        if (colCount == 0) {
          db.execute(
            '''
            INSERT INTO col (id, crt, mod, scm, ver, dty, usn, ls, conf, models, decks, dconf, tags)
            VALUES (1, ?, ?, ?, ${AppConfig.ankiColSchemaVersion}, 0, 0, 0, '{}', '{}', '{}', '{}', '{}')
          ''',
            [nowSec, nowSec, nowSec],
          );
        } else {
          db.execute('UPDATE col SET mod = ?, usn = usn + 1', [nowSec]);
        }

        final colRow = db.select('SELECT crt FROM col LIMIT 1');
        final colCrtSec = colRow.isNotEmpty
            ? (colRow.first['crt'] as int? ?? nowSec)
            : nowSec;
        final colCrtDate = DateTime.fromMillisecondsSinceEpoch(
          colCrtSec * 1000,
        );

        // Update cards scheduling state
        for (final card in _context.cachedCards) {
          final cid =
              int.tryParse(card.id.replaceAll(RegExp(r'\D'), '')) ??
              card.id.hashCode.abs();
          if (cid == 0) continue;

          final factor = (card.difficulty > 0)
              ? ((3.0 - (card.difficulty - 1.0) / 9.0 * 1.7) * 1000)
                    .toInt()
                    .clamp(AppConfig.minAnkiFactor, AppConfig.maxAnkiFactor)
              : AppConfig.defaultAnkiFactor;

          final cardModSec =
              (card.lastStudied ?? card.createdAt ?? DateTime.now())
                  .millisecondsSinceEpoch ~/
              1000;
          final dueDays = card.due != null
              ? (card.reps > 0 ? card.due!.difference(colCrtDate).inDays : 0)
              : card.intervalDays;

          db.execute(
            '''
            UPDATE cards SET
              ivl = ?,
              factor = ?,
              reps = ?,
              lapses = ?,
              due = ?,
              mod = ?,
              usn = ?
            WHERE id = ?
          ''',
            [
              card.intervalDays,
              factor,
              card.reps,
              card.lapses,
              dueDays,
              cardModSec,
              AppConfig.ankiSyncUsnModified,
              cid,
            ],
          );
        }

        // Insert review logs
        for (final log in _context.cachedReviewLogs) {
          final cid =
              int.tryParse(log.cardId.replaceAll(RegExp(r'\D'), '')) ??
              log.cardId.hashCode.abs();
          if (cid == 0) continue;

          final logId = log.reviewTime.millisecondsSinceEpoch;
          final ease = log.rating.value;
          final ivl = log.scheduledDays;
          final lastIvl = log.elapsedDays;

          db.execute(
            '''
            INSERT OR IGNORE INTO revlog (id, cid, usn, ease, ivl, lastIvl, factor, time, type)
            VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?)
          ''',
            [
              logId,
              cid,
              AppConfig.ankiSyncUsnModified,
              ease,
              ivl,
              lastIvl,
              AppConfig.defaultAnkiFactor,
              AppConfig.ankiRevlogTypeReview,
            ],
          );
        }

        db.execute('PRAGMA integrity_check;');
      } finally {
        db.close();
      }

      return targetDbFile.readAsBytesSync();
    } finally {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  }
}
