import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../data/exam_repository.dart';
import '../models/exam_models.dart';
import '../models/exam_session_state.dart';

export '../models/exam_session_state.dart';

final examSessionProvider =
    NotifierProvider.autoDispose<ExamSessionNotifier, ExamSessionState>(
      ExamSessionNotifier.new,
    );

class ExamSessionNotifier extends Notifier<ExamSessionState> {
  static const String errExamNotFound = 'ERR_EXAM_NOT_FOUND';
  static const String errExamLoadPrefix = 'ERR_EXAM_LOAD:';
  static const String errExamSubmitPrefix = 'ERR_EXAM_SUBMIT:';

  late final ExamRepository _repository;
  Timer? _timer;

  @override
  ExamSessionState build() {
    _repository = ref.watch(examRepositoryProvider);
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const ExamSessionState();
  }

  Future<void> initSession(String examId) async {
    _timer?.cancel();
    state = state.copyWith(isLoading: true, error: null);

    try {
      final paper = await _repository.getExamPaper(examId);
      if (paper == null) {
        state = state.copyWith(isLoading: false, error: errExamNotFound);
        return;
      }

      var sections = await _repository.getExamSections(examId);
      var questions = await _repository.getExamQuestions(examId);

      // If paper is not downloaded locally yet, perform sparse download
      if (questions.isEmpty) {
        await _repository.downloadExamOffline(examId);
        sections = await _repository.getExamSections(examId);
        questions = await _repository.getExamQuestions(examId);
      }

      final durationSec =
          paper.durationMinutes * ExamConstants.secondsPerMinute;

      state = state.copyWith(
        isLoading: false,
        paper: paper,
        sections: sections,
        questions: questions,
        currentIndex: 0,
        selectedAnswers: {},
        flaggedQuestionIds: {},
        remainingSeconds: durationSec,
        totalDurationSeconds: durationSec,
        isFinished: false,
        isSubmitting: false,
        submission: null,
        wrongQuestions: [],
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$errExamLoadPrefix$e');
    }
  }

  Future<void> reloadQuestions() async {
    if (state.paper == null) return;
    final examId = state.paper!.id;
    await _repository.seedSampleExams();
    final questions = await _repository.getExamQuestions(examId);
    state = state.copyWith(questions: questions);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConfig.examTimerTickInterval, (timer) {
      if (state.remainingSeconds <= 1) {
        timer.cancel();
        submitExam();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void selectAnswer(String questionId, String optionId) {
    if (state.isFinished) return;
    final updated = Map<String, String>.from(state.selectedAnswers);
    updated[questionId] = optionId;
    state = state.copyWith(selectedAnswers: updated);
  }

  void toggleFlag(String questionId) {
    final updated = Set<String>.from(state.flaggedQuestionIds);
    if (updated.contains(questionId)) {
      updated.remove(questionId);
    } else {
      updated.add(questionId);
    }
    state = state.copyWith(flaggedQuestionIds: updated);
  }

  void jumpTo(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void prevQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  Future<void> submitExam() async {
    if (state.isFinished || state.isSubmitting) return;
    _timer?.cancel();
    state = state.copyWith(isSubmitting: true);

    try {
      final now = DateTime.now().toUtc();
      final elapsedSec = state.totalDurationSeconds - state.remainingSeconds;

      int score = 0;
      int totalCorrect = 0;
      final wrongList = <WrongQuestionModel>[];

      for (final q in state.questions) {
        final userAnswer = state.selectedAnswers[q.id];
        final isCorrect =
            userAnswer != null &&
            userAnswer.trim().toUpperCase() ==
                q.correctAnswer.trim().toUpperCase();

        if (isCorrect) {
          score += q.points;
          totalCorrect++;
        } else {
          wrongList.add(
            WrongQuestionModel(
              id: IdHelper.wrongQuestionId(
                q.examId,
                q.id,
                now.millisecondsSinceEpoch,
              ),
              examId: q.examId,
              questionId: q.id,
              userAnswer: userAnswer ?? '',
              explanation: q.explanation,
              status: WrongQuestionStatus.newQuestion,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }

      final submission = ExamSubmissionModel(
        id: IdHelper.examSubmissionId(
          state.paper!.id,
          now.millisecondsSinceEpoch,
        ),
        examId: state.paper!.id,
        score: score,
        totalCorrect: totalCorrect,
        totalQuestions: state.questions.length,
        durationSeconds: elapsedSec,
        answers: state.selectedAnswers,
        submittedAt: now,
      );

      await _repository.submitExam(
        submission: submission,
        wrongQuestions: wrongList,
      );

      state = state.copyWith(
        isFinished: true,
        isSubmitting: false,
        submission: submission,
        wrongQuestions: wrongList,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: '$errExamSubmitPrefix$e',
      );
    }
  }
}
