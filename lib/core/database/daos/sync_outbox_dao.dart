import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/card.dart';
import '../../models/deck.dart';
import '../../models/exam_models.dart';
import '../../models/grammar_progress.dart';
import '../../models/review_log.dart';
import '../app_database.dart';
import 'database_context.dart';

class SyncOutboxDao {
  final DatabaseContext _context;

  SyncOutboxDao(this._context);

  AppDatabase get _db => _context.db;

  Future<List<SyncOutboxData>> getPendingOutboxBatch({int limit = 100}) async {
    return (_db.select(_db.syncOutbox)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> acknowledgeOutboxBatch(List<String> ids) async {
    if (ids.isEmpty) return;
    await (_db.delete(_db.syncOutbox)..where((tbl) => tbl.id.isIn(ids))).go();
  }

  Future<int> getPendingOutboxCount() async {
    final countExpr = _db.syncOutbox.id.count();
    final query = _db.selectOnly(_db.syncOutbox)..addColumns([countExpr]);
    final result = await query.map((row) => row.read(countExpr)).getSingle();
    return result ?? 0;
  }

  Future<String?> getSyncCursor(String entityType) async {
    final row = await (_db.select(
      _db.syncCursors,
    )..where((t) => t.entityType.equals(entityType))).getSingleOrNull();
    return row?.lastServerHlc;
  }

  Future<void> setSyncCursor(String entityType, String lastServerHlc) async {
    await _db
        .into(_db.syncCursors)
        .insertOnConflictUpdate(
          SyncCursorsCompanion.insert(
            entityType: entityType,
            lastServerHlc: Value(lastServerHlc),
            lastSyncedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> enqueueOutbox({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    String? hlc,
  }) async {
    final hlcStr = hlc ?? _context.advanceHlc().pack();
    final outboxId = 'outbox_${entityType}_${entityId}_$hlcStr';
    await _db
        .into(_db.syncOutbox)
        .insertOnConflictUpdate(
          SyncOutboxCompanion.insert(
            id: outboxId,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: jsonEncode(payload),
            hlc: hlcStr,
          ),
        );
    _context.onMutationEnqueued?.call();
  }

  /// Applies a batch of remote deltas pulled from the cloud directly into SQLite
  /// and updates in-memory caches WITHOUT enqueuing mutations into [syncOutbox].
  Future<void> applyRemoteDeltasBatch({
    List<Map<String, dynamic>> decks = const [],
    List<Map<String, dynamic>> cards = const [],
    List<Map<String, dynamic>> reviewLogs = const [],
    List<Map<String, dynamic>> grammarProgress = const [],
    List<Map<String, dynamic>> examSubmissions = const [],
    List<Map<String, dynamic>> wrongQuestions = const [],
    List<Map<String, dynamic>> userMedia = const [],
  }) async {
    if (decks.isEmpty &&
        cards.isEmpty &&
        reviewLogs.isEmpty &&
        grammarProgress.isEmpty &&
        examSubmissions.isEmpty &&
        wrongQuestions.isEmpty &&
        userMedia.isEmpty) {
      return;
    }

    await _db.transaction(() async {
      // 1. Apply Decks
      for (final raw in decks) {
        final deck = DeckModel.fromJson(raw);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        await _db
            .into(_db.decks)
            .insertOnConflictUpdate(
              DecksCompanion.insert(
                id: deck.id,
                title: deck.title,
                description: deck.description,
                dueCount: Value(deck.dueCount),
                newCount: Value(deck.newCount),
                totalCount: Value(deck.totalCount),
                lastStudied: Value(deck.lastStudied),
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
                isSyncEnabled: Value(deck.isSyncEnabled),
              ),
            );
      }

      // 2. Apply Cards
      for (final raw in cards) {
        final card = CardModel.fromJson(raw);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        await _db
            .into(_db.cards)
            .insertOnConflictUpdate(
              CardsCompanion.insert(
                id: card.id,
                deckId: card.deckId,
                front: card.front,
                back: card.back,
                hint: Value(card.hint),
                noteType: Value(card.noteType.value),
                flag: Value(card.flag.value),
                isSuspended: Value(card.isSuspended),
                isBuried: Value(card.isBuried),
                tags: Value(card.tags.join(',')),
                intervalDays: Value(card.intervalDays),
                stability: Value(card.stability),
                difficulty: Value(card.difficulty),
                reps: Value(card.reps),
                lapses: Value(card.lapses),
                due: Value(card.due),
                lastStudied: Value(card.lastStudied),
                createdAt: Value(card.createdAt ?? DateTime.now()),
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }

      // 3. Apply Review Logs
      for (final raw in reviewLogs) {
        final log = ReviewLogModel.fromJson(raw);
        final clientLogId = log.clientLogId.isNotEmpty
            ? log.clientLogId
            : (raw['client_log_id'] as String? ??
                  'log_${log.cardId}_${log.reviewTime.millisecondsSinceEpoch}');

        final existing =
            await (_db.select(_db.reviewLogs)
                  ..where((tbl) => tbl.clientLogId.equals(clientLogId)))
                .getSingleOrNull();

        if (existing == null) {
          await _db
              .into(_db.reviewLogs)
              .insert(
                ReviewLogsCompanion.insert(
                  cardId: log.cardId,
                  rating: log.rating.value,
                  reviewTime: log.reviewTime,
                  scheduledDays: Value(log.scheduledDays),
                  elapsedDays: Value(log.elapsedDays),
                  clientLogId: Value(clientLogId),
                ),
              );
        }
      }

      // 4. Apply Grammar Progress
      for (final raw in grammarProgress) {
        final model = GrammarProgressModel.fromJson(raw);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        await _db
            .into(_db.grammarProgressEntries)
            .insertOnConflictUpdate(
              GrammarProgressEntriesCompanion.insert(
                unitId: model.unitId,
                exerciseId: model.exerciseId,
                stability: Value(model.stability),
                difficulty: Value(model.difficulty),
                due: Value(model.due),
                lastStudied: Value(model.lastStudied),
                reps: Value(model.reps),
                lapses: Value(model.lapses),
                state: Value(model.state),
                isGhost: Value(model.isGhost),
                isCompleted: Value(model.isCompleted),
                lastUserAnswer: Value(model.lastUserAnswer),
                updatedAt: Value(model.updatedAt),
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }

      // 5. Apply Exam Submissions
      for (final raw in examSubmissions) {
        final submission = ExamSubmissionModel.fromJson(raw);
        final answersJson = raw['answers_json'] is String
            ? raw['answers_json'] as String
            : jsonEncode(submission.answers);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        await _db
            .into(_db.examSubmissions)
            .insertOnConflictUpdate(
              ExamSubmissionsCompanion.insert(
                id: submission.id,
                examId: submission.examId,
                score: Value(submission.score),
                totalCorrect: Value(submission.totalCorrect),
                totalQuestions: Value(submission.totalQuestions),
                durationSeconds: Value(submission.durationSeconds),
                answersJson: Value(answersJson),
                submittedAt: Value(submission.submittedAt),
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }

      // 6. Apply Wrong Questions Notebook
      for (final raw in wrongQuestions) {
        final w = WrongQuestionModel.fromJson(raw);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        await _db
            .into(_db.wrongQuestionNotebook)
            .insertOnConflictUpdate(
              WrongQuestionNotebookCompanion.insert(
                id: w.id,
                examId: w.examId,
                questionId: w.questionId,
                userAnswer: w.userAnswer,
                explanation: Value(w.explanation),
                notes: Value(w.notes),
                status: Value(w.status.code),
                createdAt: Value(w.createdAt),
                updatedAt: Value(w.updatedAt),
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }

      // 7. Apply User Media
      for (final raw in userMedia) {
        final filename = raw['filename'] as String? ?? '';
        if (filename.isEmpty) continue;
        final hash = raw['hash_sha256'] as String? ?? '';
        final size = (raw['size_bytes'] as num?)?.toInt() ?? 0;
        final mime = raw['mime_type'] as String? ?? 'application/octet-stream';
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        final existing = await (_db.select(
          _db.userMedia,
        )..where((tbl) => tbl.filename.equals(filename))).getSingleOrNull();

        if (existing == null || hlc.compareTo(existing.updatedAtHlc) > 0) {
          await _db
              .into(_db.userMedia)
              .insertOnConflictUpdate(
                UserMediaCompanion.insert(
                  filename: filename,
                  hashSha256: Value(hash),
                  sizeBytes: Value(size),
                  mimeType: Value(mime),
                  isUploaded: const Value(true),
                  updatedAtHlc: Value(hlc),
                  isDeleted: Value(isDeleted),
                  updatedAt: Value(DateTime.now()),
                ),
              );
        }
      }
    });

    // Reload cache to reflect remote changes immediately
    await _context.reloadCache();
  }

  /// Exports all database tables into a JSON-serializable Map for snapshot packaging.
  Future<Map<String, dynamic>> exportDatabaseSnapshot() async {
    final decks = _context.cachedDecks.map((d) => d.toJson()).toList();
    final cards = _context.cachedCards.map((c) => c.toJson()).toList();
    final reviewLogs = _context.cachedReviewLogs
        .map((r) => r.toJson())
        .toList();

    List<Map<String, dynamic>> grammar = [];
    List<Map<String, dynamic>> exams = [];
    List<Map<String, dynamic>> wrongs = [];
    List<Map<String, dynamic>> media = [];

    final grammarRows = await (_db.select(
      _db.grammarProgressEntries,
    )..where((t) => t.isDeleted.equals(false))).get();
    grammar = grammarRows
        .map(
          (g) => {
            'unit_id': g.unitId,
            'exercise_id': g.exerciseId,
            'stability': g.stability,
            'difficulty': g.difficulty,
            'due': g.due?.toIso8601String(),
            'last_studied': g.lastStudied?.toIso8601String(),
            'reps': g.reps,
            'lapses': g.lapses,
            'state': g.state.index,
            'is_ghost': g.isGhost,
            'is_completed': g.isCompleted,
            'last_user_answer': g.lastUserAnswer,
            'updated_at': g.updatedAt.toIso8601String(),
            'updated_at_hlc': g.updatedAtHlc,
          },
        )
        .toList();

    final examRows = await (_db.select(
      _db.examSubmissions,
    )..where((t) => t.isDeleted.equals(false))).get();
    exams = examRows
        .map(
          (e) => {
            'id': e.id,
            'exam_id': e.examId,
            'score': e.score,
            'total_correct': e.totalCorrect,
            'total_questions': e.totalQuestions,
            'duration_seconds': e.durationSeconds,
            'submitted_at': e.submittedAt.toIso8601String(),
            'answers_json': e.answersJson,
            'updated_at_hlc': e.updatedAtHlc,
          },
        )
        .toList();

    final wrongRows = await (_db.select(
      _db.wrongQuestionNotebook,
    )..where((t) => t.isDeleted.equals(false))).get();
    wrongs = wrongRows
        .map(
          (w) => {
            'id': w.id,
            'question_id': w.questionId,
            'exam_id': w.examId,
            'user_answer': w.userAnswer,
            'explanation': w.explanation,
            'notes': w.notes,
            'status': w.status,
            'updated_at_hlc': w.updatedAtHlc,
          },
        )
        .toList();

    final mediaRows = await (_db.select(
      _db.userMedia,
    )..where((t) => t.isDeleted.equals(false))).get();
    media = mediaRows
        .map(
          (m) => {
            'filename': m.filename,
            'hash_sha256': m.hashSha256,
            'size_bytes': m.sizeBytes,
            'mime_type': m.mimeType,
            'updated_at_hlc': m.updatedAtHlc,
          },
        )
        .toList();

    return {
      'decks': decks,
      'cards': cards,
      'review_logs': reviewLogs,
      'grammar_progress': grammar,
      'exam_submissions': exams,
      'wrong_questions': wrongs,
      'user_media': media,
    };
  }

  /// Restores database state from a snapshot Map directly into SQLite and memory caches.
  Future<void> restoreDatabaseSnapshot(Map<String, dynamic> data) async {
    final decks = (data['decks'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final cards = (data['cards'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final reviewLogs = (data['review_logs'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final grammar = (data['grammar_progress'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final exams = (data['exam_submissions'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final wrongs = (data['wrong_questions'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final media = (data['user_media'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    await applyRemoteDeltasBatch(
      decks: decks,
      cards: cards,
      reviewLogs: reviewLogs,
      grammarProgress: grammar,
      examSubmissions: exams,
      wrongQuestions: wrongs,
      userMedia: media,
    );
  }
}
