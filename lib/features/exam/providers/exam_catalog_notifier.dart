import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exam_repository.dart';
import '../models/exam_models.dart';
import '../models/exam_catalog_state.dart';

export '../models/exam_catalog_state.dart';

final examCatalogProvider =
    NotifierProvider<ExamCatalogNotifier, ExamCatalogState>(
      ExamCatalogNotifier.new,
    );

class ExamCatalogNotifier extends Notifier<ExamCatalogState> {
  static const String errExamDownloadPrefix = 'ERR_EXAM_DOWNLOAD:';

  late final ExamRepository _repository;

  @override
  ExamCatalogState build() {
    _repository = ref.watch(examRepositoryProvider);
    Future.microtask(() => loadCatalog());
    return const ExamCatalogState();
  }

  Future<void> loadCatalog() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final papers = await _repository.getExamCatalog(
        category: state.selectedCategory,
        level: state.selectedLevel,
      );
      state = state.copyWith(isLoading: false, papers: papers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshFromCloud() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final papers = await _repository.refreshOnlineCatalog(
        category: state.selectedCategory,
        level: state.selectedLevel,
      );
      state = state.copyWith(isLoading: false, papers: papers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> downloadExam(String examId) async {
    try {
      final updated = await _repository.downloadExamOffline(examId);
      final updatedList = state.papers
          .map((p) => p.id == examId ? updated : p)
          .toList();
      state = state.copyWith(papers: updatedList);
    } catch (e) {
      state = state.copyWith(error: '$errExamDownloadPrefix$e');
    }
  }

  void filterCategory(ExamCategory? category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    loadCatalog();
  }

  void filterLevel(String? level) {
    if (state.selectedLevel == level) return;
    state = state.copyWith(selectedLevel: level);
    loadCatalog();
  }
}
