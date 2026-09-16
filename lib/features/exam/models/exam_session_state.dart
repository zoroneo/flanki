import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'exam_models.dart';

part 'exam_session_state.freezed.dart';

@freezed
abstract class ExamSessionState with _$ExamSessionState {
  const ExamSessionState._();

  const factory ExamSessionState({
    @Default(false) bool isLoading,
    ExamPaperModel? paper,
    @Default([]) List<ExamSectionModel> sections,
    @Default([]) List<ExamQuestionModel> questions,
    @Default(0) int currentIndex,
    @Default({}) Map<String, String> selectedAnswers,
    @Default({}) Set<String> flaggedQuestionIds,
    @Default(0) int remainingSeconds,
    @Default(0) int totalDurationSeconds,
    @Default(false) bool isFinished,
    @Default(false) bool isSubmitting,
    ExamSubmissionModel? submission,
    @Default([]) List<WrongQuestionModel> wrongQuestions,
    String? error,
  }) = _ExamSessionState;

  ExamQuestionModel? get currentQuestion =>
      questions.isNotEmpty &&
          currentIndex >= 0 &&
          currentIndex < questions.length
      ? questions[currentIndex]
      : null;

  int get answeredCount => selectedAnswers.length;

  double get progressRatio =>
      questions.isNotEmpty ? answeredCount / questions.length : 0.0;

  String? getLocalizedError(AppLocalizations l10n) {
    final err = error;
    if (err == null) return null;
    return switch (err) {
      'ERR_EXAM_NOT_FOUND' => l10n.examNotFound,
      _ when err.startsWith('ERR_EXAM_LOAD:') => l10n.examLoadFailed(
        err.substring('ERR_EXAM_LOAD:'.length),
      ),
      _ when err.startsWith('ERR_EXAM_SUBMIT:') => l10n.examSubmitFailed(
        err.substring('ERR_EXAM_SUBMIT:'.length),
      ),
      _ => err,
    };
  }
}
