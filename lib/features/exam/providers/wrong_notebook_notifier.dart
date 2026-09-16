import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exam_repository.dart';
import '../models/exam_models.dart';
import '../models/wrong_notebook_state.dart';

export '../models/wrong_notebook_state.dart';

final wrongNotebookProvider =
    NotifierProvider<WrongNotebookNotifier, WrongNotebookState>(
      WrongNotebookNotifier.new,
    );

class WrongNotebookNotifier extends Notifier<WrongNotebookState> {
  static const String errWrongStatusUpdatePrefix = 'ERR_WRONG_STATUS_UPDATE:';

  late final ExamRepository _repository;

  @override
  WrongNotebookState build() {
    _repository = ref.watch(examRepositoryProvider);
    Future.microtask(() => loadNotebook());
    return const WrongNotebookState();
  }

  Future<void> loadNotebook() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getWrongQuestions(
        status: state.filterStatus,
      );
      state = state.copyWith(isLoading: false, questions: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void filterStatus(WrongQuestionStatus? status) {
    if (state.filterStatus == status) return;
    state = state.copyWith(filterStatus: status);
    loadNotebook();
  }

  Future<void> markStatus(String id, WrongQuestionStatus newStatus) async {
    try {
      await _repository.updateWrongQuestionStatus(id, newStatus);
      final updated = state.questions.map((q) {
        if (q.id == id) {
          return q.copyWith(status: newStatus);
        }
        return q;
      }).toList();
      state = state.copyWith(questions: updated);
    } catch (e) {
      state = state.copyWith(error: '$errWrongStatusUpdatePrefix$e');
    }
  }
}
