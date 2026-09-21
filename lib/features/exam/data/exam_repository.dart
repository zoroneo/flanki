import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
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
    final list = await dbService.getExamQuestions(examId);
    if (list.isNotEmpty && list.any((q) => q.options.isEmpty)) {
      // Re-seed to repair questions that were seeded with old json structure
      await seedSampleExams();
      return dbService.getExamQuestions(examId);
    }
    return list;
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
        AppConfig.sampleMockExamAssetPath,
      );
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final details = ExamPaperDetailsDto.fromJson(data);

      await dbService.saveExamPaperWithQuestions(
        details.paper,
        details.sections,
        details.questions,
      );
    } catch (_) {
      // In headless test environments where rootBundle is unavailable, load from file system directly
      try {
        final file = File(AppConfig.sampleMockExamAssetPath);
        if (file.existsSync()) {
          final jsonStr = await file.readAsString();
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          final details = ExamPaperDetailsDto.fromJson(data);

          await dbService.saveExamPaperWithQuestions(
            details.paper,
            details.sections,
            details.questions,
          );
        }
      } catch (_) {}
    }
  }
}
