import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../config/app_config.dart';
import '../../config/supabase_config.dart';
import '../../models/exam_models.dart';
import '../../models/sync_payloads.dart';
import '../app_database.dart';
import 'database_context.dart';

class ExamDao {
  final DatabaseContext _context;

  ExamDao(this._context);

  AppDatabase get _db => _context.db;

  Future<void> saveExamCatalog(List<ExamPaperModel> exams) async {
    await _db.transaction(() async {
      for (final exam in exams) {
        await _db
            .into(_db.examPapers)
            .insertOnConflictUpdate(
              ExamPapersCompanion.insert(
                id: exam.id,
                title: exam.title,
                description: Value(exam.description),
                category: Value(exam.category.code),
                level: Value(exam.level),
                durationMinutes: Value(exam.durationMinutes),
                totalQuestions: Value(exam.totalQuestions),
                passingScore: Value(exam.passingScore),
                iconName: Value(exam.iconName),
                version: Value(exam.version),
                isPublished: Value(exam.isPublished),
                isDownloaded: Value(exam.isDownloaded),
                createdAt: Value(exam.createdAt),
                updatedAt: Value(exam.updatedAt),
              ),
            );
      }
    });
  }

  Future<List<ExamPaperModel>> getExamCatalog({
    ExamCategory? category,
    String? level,
  }) async {
    final query = _db.select(_db.examPapers)
      ..where((tbl) => tbl.isPublished.equals(true));
    if (category != null) {
      query.where((tbl) => tbl.category.equals(category.code));
    }
    if (level != null && level.isNotEmpty) {
      query.where((tbl) => tbl.level.equals(level));
    }
    query.orderBy([
      (tbl) => OrderingTerm.asc(tbl.category),
      (tbl) => OrderingTerm.asc(tbl.level),
    ]);
    final rows = await query.get();
    return rows
        .map(
          (r) => ExamPaperModel(
            id: r.id,
            title: r.title,
            description: r.description,
            category: ExamCategory.fromString(r.category),
            level: r.level,
            durationMinutes: r.durationMinutes,
            totalQuestions: r.totalQuestions,
            passingScore: r.passingScore,
            iconName: r.iconName,
            version: r.version,
            isPublished: r.isPublished,
            isDownloaded: r.isDownloaded,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<ExamPaperModel?> getExamPaperById(String examId) async {
    final row = await (_db.select(
      _db.examPapers,
    )..where((tbl) => tbl.id.equals(examId))).getSingleOrNull();
    if (row == null) return null;
    return ExamPaperModel(
      id: row.id,
      title: row.title,
      description: row.description,
      category: ExamCategory.fromString(row.category),
      level: row.level,
      durationMinutes: row.durationMinutes,
      totalQuestions: row.totalQuestions,
      passingScore: row.passingScore,
      iconName: row.iconName,
      version: row.version,
      isPublished: row.isPublished,
      isDownloaded: row.isDownloaded,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> saveExamPaperWithQuestions(
    ExamPaperModel paper,
    List<ExamSectionModel> sections,
    List<ExamQuestionModel> questions,
  ) async {
    await _db.transaction(() async {
      await _db
          .into(_db.examPapers)
          .insertOnConflictUpdate(
            ExamPapersCompanion.insert(
              id: paper.id,
              title: paper.title,
              description: Value(paper.description),
              category: Value(paper.category.code),
              level: Value(paper.level),
              durationMinutes: Value(paper.durationMinutes),
              totalQuestions: Value(paper.totalQuestions),
              passingScore: Value(paper.passingScore),
              iconName: Value(paper.iconName),
              version: Value(paper.version),
              isPublished: Value(paper.isPublished),
              isDownloaded: const Value(true),
              createdAt: Value(paper.createdAt),
              updatedAt: Value(paper.updatedAt),
            ),
          );

      for (final sec in sections) {
        await _db
            .into(_db.examSections)
            .insertOnConflictUpdate(
              ExamSectionsCompanion.insert(
                id: sec.id,
                examId: sec.examId,
                title: sec.title,
                sectionType: Value(sec.sectionType),
                orderIndex: Value(sec.orderIndex),
                instruction: Value(sec.instruction),
              ),
            );
      }

      for (final q in questions) {
        await _db
            .into(_db.examQuestions)
            .insertOnConflictUpdate(
              ExamQuestionsCompanion.insert(
                id: q.id,
                examId: q.examId,
                sectionId: q.sectionId,
                questionNumber: Value(q.questionNumber),
                questionText: q.questionText,
                contextPassage: Value(q.contextPassage),
                audioUrl: Value(q.audioUrl),
                optionsJson: Value(
                  jsonEncode(q.options.map((o) => o.toJson()).toList()),
                ),
                correctAnswer: q.correctAnswer,
                explanation: Value(q.explanation),
                points: Value(q.points),
              ),
            );
      }
    });
  }

  Future<List<ExamSectionModel>> getExamSections(String examId) async {
    final rows =
        await (_db.select(_db.examSections)
              ..where((tbl) => tbl.examId.equals(examId))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
            .get();
    return rows
        .map(
          (r) => ExamSectionModel(
            id: r.id,
            examId: r.examId,
            title: r.title,
            sectionType: r.sectionType,
            orderIndex: r.orderIndex,
            instruction: r.instruction,
          ),
        )
        .toList();
  }

  Future<List<ExamQuestionModel>> getExamQuestions(String examId) async {
    final rows =
        await (_db.select(_db.examQuestions)
              ..where((tbl) => tbl.examId.equals(examId))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.questionNumber)]))
            .get();
    return rows
        .map(
          (r) => ExamQuestionModel.fromJson({
            'id': r.id,
            'exam_id': r.examId,
            'section_id': r.sectionId,
            'question_number': r.questionNumber,
            'question_text': r.questionText,
            'context_passage': r.contextPassage,
            'audio_url': r.audioUrl,
            'options_json': r.optionsJson,
            'correct_answer': r.correctAnswer,
            'explanation': r.explanation,
            'points': r.points,
          }),
        )
        .toList();
  }

  Future<void> submitExamResult(
    ExamSubmissionModel submission,
    List<WrongQuestionModel> wrongQuestions, {
    bool markOutbox = true,
  }) async {
    final hlcStr = markOutbox ? _context.advanceHlc().pack() : '';

    await _db.transaction(() async {
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
              answersJson: Value(jsonEncode(submission.answers)),
              submittedAt: Value(submission.submittedAt),
              updatedAtHlc: Value(hlcStr),
              isDeleted: const Value(false),
            ),
          );

      if (markOutbox) {
        await _db
            .into(_db.syncOutbox)
            .insertOnConflictUpdate(
              SyncOutboxCompanion.insert(
                id: IdHelper.outboxId(
                  prefix: 'exam_sub',
                  entityId: submission.id,
                  hlc: hlcStr,
                ),
                entityType: SupabaseConfig.entityExamSubmission,
                entityId: submission.id,
                operation: SupabaseConfig.opUpsert,
                payloadJson: jsonEncode(submission.toJson()),
                hlc: hlcStr,
              ),
            );
      }

      for (final w in wrongQuestions) {
        final wHlcStr = markOutbox ? _context.advanceHlc().pack() : '';
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
                updatedAt: Value(DateTime.now().toUtc()),
                updatedAtHlc: Value(wHlcStr),
                isDeleted: const Value(false),
              ),
            );

        if (markOutbox) {
          await _db
              .into(_db.syncOutbox)
              .insertOnConflictUpdate(
                SyncOutboxCompanion.insert(
                  id: IdHelper.outboxId(
                    prefix: 'wrong_q',
                    entityId: w.id,
                    hlc: wHlcStr,
                  ),
                  entityType: SupabaseConfig.entityWrongQuestion,
                  entityId: w.id,
                  operation: SupabaseConfig.opUpsert,
                  payloadJson: jsonEncode(w.toJson()),
                  hlc: wHlcStr,
                ),
              );
        }
      }
    });

    if (markOutbox) {
      _context.onMutationEnqueued?.call();
    }
  }

  Future<List<ExamSubmissionModel>> getExamSubmissions(String examId) async {
    final rows =
        await (_db.select(_db.examSubmissions)
              ..where(
                (tbl) =>
                    tbl.examId.equals(examId) & tbl.isDeleted.equals(false),
              )
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.submittedAt)]))
            .get();
    return rows
        .map(
          (r) => ExamSubmissionModel.fromJson({
            'id': r.id,
            'exam_id': r.examId,
            'score': r.score,
            'total_correct': r.totalCorrect,
            'total_questions': r.totalQuestions,
            'duration_seconds': r.durationSeconds,
            'answers_json': r.answersJson,
            'submitted_at': r.submittedAt.toIso8601String(),
            'updated_at_hlc': r.updatedAtHlc,
          }),
        )
        .toList();
  }

  Future<List<WrongQuestionModel>> getWrongQuestions({
    String? examId,
    WrongQuestionStatus? status,
  }) async {
    final query = _db.select(_db.wrongQuestionNotebook)
      ..where((tbl) => tbl.isDeleted.equals(false));
    if (examId != null) {
      query.where((tbl) => tbl.examId.equals(examId));
    }
    if (status != null) {
      query.where((tbl) => tbl.status.equals(status.code));
    }
    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    final rows = await query.get();
    return rows
        .map(
          (r) => WrongQuestionModel.fromJson({
            'id': r.id,
            'exam_id': r.examId,
            'question_id': r.questionId,
            'user_answer': r.userAnswer,
            'explanation': r.explanation,
            'notes': r.notes,
            'status': r.status,
            'created_at': r.createdAt.toIso8601String(),
            'updated_at': r.updatedAt.toIso8601String(),
            'updated_at_hlc': r.updatedAtHlc,
          }),
        )
        .toList();
  }

  Future<void> updateWrongQuestionStatus(
    String id,
    WrongQuestionStatus status, {
    bool markOutbox = true,
  }) async {
    final hlcStr = markOutbox ? _context.advanceHlc().pack() : '';
    await _db.transaction(() async {
      final existing = await (_db.select(
        _db.wrongQuestionNotebook,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      await (_db.update(
        _db.wrongQuestionNotebook,
      )..where((tbl) => tbl.id.equals(id))).write(
        WrongQuestionNotebookCompanion(
          status: Value(status.code),
          updatedAt: Value(DateTime.now().toUtc()),
          updatedAtHlc: Value(hlcStr),
        ),
      );

      if (markOutbox) {
        final payload = existing != null
            ? WrongQuestionModel(
                id: id,
                examId: existing.examId,
                questionId: existing.questionId,
                userAnswer: existing.userAnswer,
                explanation: existing.explanation,
                notes: existing.notes,
                status: status,
                createdAt: existing.createdAt,
                updatedAt: DateTime.now().toUtc(),
              ).toJson()
            : WrongQuestionStatusPayload(
                id: id,
                status: status.code,
                updatedAt: DateTime.now().toUtc().toIso8601String(),
              ).toJson();

        await _db
            .into(_db.syncOutbox)
            .insertOnConflictUpdate(
              SyncOutboxCompanion.insert(
                id: IdHelper.outboxId(
                  prefix: 'wrong_status',
                  entityId: id,
                  hlc: hlcStr,
                ),
                entityType: SupabaseConfig.entityWrongQuestion,
                entityId: id,
                operation: SupabaseConfig.opUpsert,
                payloadJson: jsonEncode(payload),
                hlc: hlcStr,
              ),
            );
      }
    });

    if (markOutbox) {
      _context.onMutationEnqueued?.call();
    }
  }
}
