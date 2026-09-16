import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_service.dart';
import '../../../core/sync/supabase_sync_engine.dart';
import '../models/exam_models.dart';

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ExamRepository(
    dbService: DatabaseService.instance,
    syncEngine: SupabaseSyncEngine(),
  );
});

class ExamRepository {
  final DatabaseService dbService;
  final SupabaseSyncEngine syncEngine;

  ExamRepository({required this.dbService, required this.syncEngine});

  /// Retrieves cached exam catalog from local SQLite, filtered by category and level.
  Future<List<ExamPaperModel>> getExamCatalog({
    ExamCategory? category,
    String? level,
  }) async {
    final list = await dbService.getExamCatalog(
      category: category,
      level: level,
    );
    if (list.isEmpty) {
      // Seed default sample exam if empty so offline experience works immediately
      await seedSampleExams();
      return dbService.getExamCatalog(category: category, level: level);
    }
    return list;
  }

  /// Refreshes exam catalog from cloud via Supabase.
  Future<List<ExamPaperModel>> refreshOnlineCatalog({
    ExamCategory? category,
    String? level,
  }) async {
    return syncEngine.fetchExamCatalogOnline(category: category, level: level);
  }

  /// Downloads full exam paper questions on-demand (Sparse Sync).
  Future<ExamPaperModel> downloadExamOffline(String examId) async {
    try {
      return await syncEngine.downloadExamPaperOffline(examId);
    } catch (_) {
      // If offline, check if already in local DB
      final local = await dbService.getExamPaperById(examId);
      if (local != null) return local;
      rethrow;
    }
  }

  Future<ExamPaperModel?> getExamPaper(String examId) async {
    return dbService.getExamPaperById(examId);
  }

  Future<List<ExamSectionModel>> getExamSections(String examId) async {
    return dbService.getExamSections(examId);
  }

  Future<List<ExamQuestionModel>> getExamQuestions(String examId) async {
    return dbService.getExamQuestions(examId);
  }

  Future<void> submitExam({
    required ExamSubmissionModel submission,
    required List<WrongQuestionModel> wrongQuestions,
  }) async {
    await dbService.submitExamResult(submission, wrongQuestions);
  }

  Future<List<ExamSubmissionModel>> getSubmissions(String examId) async {
    return dbService.getExamSubmissions(examId);
  }

  Future<List<WrongQuestionModel>> getWrongQuestions({
    String? examId,
    WrongQuestionStatus? status,
  }) async {
    return dbService.getWrongQuestions(examId: examId, status: status);
  }

  Future<void> updateWrongQuestionStatus(
    String id,
    WrongQuestionStatus status,
  ) async {
    await dbService.updateWrongQuestionStatus(id, status);
  }

  /// Pre-populates sample test papers for immediate offline usability and verification.
  Future<void> seedSampleExams({AssetBundle? bundle}) async {
    final targetBundle = bundle ?? rootBundle;
    try {
      final jsonStr = await targetBundle.loadString(
        'assets/data/exams/jlpt_n3_mock_01.json',
      );
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final paper = ExamPaperModel.fromJson(
        Map<String, dynamic>.from(data['paper'] as Map),
      );
      final sections = (data['sections'] as List<dynamic>)
          .map(
            (s) =>
                ExamSectionModel.fromJson(Map<String, dynamic>.from(s as Map)),
          )
          .toList();
      final questions = (data['questions'] as List<dynamic>)
          .map(
            (q) =>
                ExamQuestionModel.fromJson(Map<String, dynamic>.from(q as Map)),
          )
          .toList();

      await dbService.saveExamPaperWithQuestions(paper, sections, questions);
    } catch (_) {
      // In headless test environments where rootBundle is unavailable, load from file system directly
      try {
        final file = File('assets/data/exams/jlpt_n3_mock_01.json');
        if (file.existsSync()) {
          final jsonStr = await file.readAsString();
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          final paper = ExamPaperModel.fromJson(
            Map<String, dynamic>.from(data['paper'] as Map),
          );
          final sections = (data['sections'] as List<dynamic>)
              .map(
                (s) => ExamSectionModel.fromJson(
                  Map<String, dynamic>.from(s as Map),
                ),
              )
              .toList();
          final questions = (data['questions'] as List<dynamic>)
              .map(
                (q) => ExamQuestionModel.fromJson(
                  Map<String, dynamic>.from(q as Map),
                ),
              )
              .toList();

          await dbService.saveExamPaperWithQuestions(
            paper,
            sections,
            questions,
          );
        }
      } catch (_) {}
    }
  }
}
