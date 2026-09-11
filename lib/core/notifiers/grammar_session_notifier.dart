import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/card.dart';
import '../models/grammar/grammar_models.dart';
import '../services/grammar_answer_evaluator.dart';
import '../states/grammar_session_state.dart';
import '../storage/grammar_repository.dart';

export '../services/grammar_answer_evaluator.dart';
export '../states/grammar_session_state.dart';

part 'grammar_session_notifier.g.dart';

@Riverpod(keepAlive: true, name: 'grammarSessionNotifierProvider')
class GrammarSessionNotifier extends _$GrammarSessionNotifier {
  final GrammarRepository? _repoOverride;
  final fsrs.Scheduler? _schedOverride;

  GrammarSessionNotifier({
    GrammarRepository? repository,
    fsrs.Scheduler? scheduler,
  }) : _repoOverride = repository,
       _schedOverride = scheduler;

  GrammarRepository get _repository =>
      _repoOverride ?? ref.read(grammarRepositoryProvider);

  fsrs.Scheduler get _scheduler =>
      _schedOverride ??
      fsrs.Scheduler(
        desiredRetention: GrammarConstants.defaultDesiredRetention,
      );

  @override
  GrammarSessionState build() {
    return GrammarSessionState();
  }

  /// Start practice session for a specific GrammarUnit
  void startUnitSession(GrammarUnit unit) {
    state = GrammarSessionState(
      unit: unit,
      exercises: unit.exercises,
      currentIndex: 0,
      startTime: DateTime.now(),
      questionStartTime: DateTime.now(),
    );
  }

  /// Start review session for Ghost questions
  void startGhostSession(
    List<GrammarExercise> ghostExercises, {
    GrammarUnit? unit,
  }) {
    state = GrammarSessionState(
      unit: unit,
      exercises: ghostExercises,
      currentIndex: 0,
      isGhostChallenge: true,
      startTime: DateTime.now(),
      questionStartTime: DateTime.now(),
    );
  }

  /// User selects or inputs an answer
  void selectAnswer(String answer) {
    if (state.isSubmitted || state.isFinished) return;
    state = state.copyWith(selectedAnswer: answer);
  }

  /// Submit current answer, score it and schedule with FSRS
  Future<bool> submitAnswer() async {
    final current = state.currentExercise;
    if (current == null || state.isSubmitted || state.isFinished) {
      return false;
    }

    final answer = state.selectedAnswer ?? '';
    final isRight = GrammarAnswerEvaluator.isCorrect(current, answer);

    // Track user answers and results
    final updatedAnswers = Map<String, String>.from(state.userAnswers)
      ..[current.id] = answer;
    final updatedResults = Map<String, bool>.from(state.results)
      ..[current.id] = isRight;

    final updatedGhostQueue = List<GrammarExercise>.from(
      state.ghostChallengeQueue,
    );
    if (!isRight && !updatedGhostQueue.any((e) => e.id == current.id)) {
      updatedGhostQueue.add(current);
    }

    // Schedule review via FSRS
    final unitId = state.unit?.unitId ?? GrammarConstants.globalReviewUnitId;
    await _applyFsrsUpdate(unitId, current.id, isRight, answer);

    state = state.copyWith(
      userAnswers: updatedAnswers,
      results: updatedResults,
      ghostChallengeQueue: updatedGhostQueue,
      isSubmitted: true,
      isCurrentCorrect: isRight,
    );

    return isRight;
  }

  /// Move to the next question in queue or complete session
  void nextQuestion() {
    if (!state.isSubmitted) return;

    if (state.isLastQuestion) {
      state = state.copyWith(isFinished: true);
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        selectedAnswer: null,
        isCurrentCorrect: null,
        isSubmitted: false,
        questionStartTime: DateTime.now(),
      );
    }
  }

  /// Start post-session remediation for questions failed during this session
  void startGhostChallenge() {
    if (state.ghostChallengeQueue.isEmpty) return;

    state = GrammarSessionState(
      unit: state.unit,
      exercises: List.from(state.ghostChallengeQueue),
      currentIndex: 0,
      isGhostChallenge: true,
      startTime: DateTime.now(),
      questionStartTime: DateTime.now(),
    );
  }

  /// Restart current session from beginning
  void restartSession() {
    if (state.unit != null) {
      startUnitSession(state.unit!);
    } else if (state.exercises.isNotEmpty) {
      startGhostSession(state.exercises);
    }
  }

  Future<void> _applyFsrsUpdate(
    String unitId,
    String exerciseId,
    bool isCorrect,
    String userAnswer,
  ) async {
    final now = DateTime.now().toUtc();
    final existing =
        _repository.getProgress(unitId, exerciseId) ??
        GrammarProgressModel(
          unitId: unitId,
          exerciseId: exerciseId,
          updatedAt: now,
        );

    final rating = isCorrect ? ReviewRating.good : ReviewRating.again;

    fsrs.State stateType;
    if (existing.reps == 0 && existing.stability == 0.0) {
      stateType = fsrs.State.learning;
    } else if (existing.lapses > 0 && existing.stability < 1.0) {
      stateType = fsrs.State.learning;
    } else {
      stateType = fsrs.State.review;
    }

    final cardId = (unitId + exerciseId).hashCode.abs();
    final fsrsCard = fsrs.Card(
      cardId: cardId,
      state: stateType,
      stability: existing.stability > 0 ? existing.stability : null,
      difficulty: existing.difficulty > 0 ? existing.difficulty : null,
      due: (existing.due ?? now).toUtc(),
      lastReview: existing.lastStudied?.toUtc(),
    );

    final outcome = _scheduler.reviewCard(
      fsrsCard,
      fsrs.Rating.fromValue(rating.value),
      reviewDateTime: now,
    );
    final newCard = outcome.card;

    final updated = existing.copyWith(
      stability: newCard.stability ?? existing.stability,
      difficulty: newCard.difficulty ?? existing.difficulty,
      due: newCard.due.toUtc(),
      lastStudied: now,
      reps: existing.reps + 1,
      lapses: !isCorrect ? existing.lapses + 1 : existing.lapses,
      state: CardState.fromValue(newCard.state.index),
      isGhost: !isCorrect,
      isCompleted: true,
      lastUserAnswer: userAnswer,
      updatedAt: now,
    );

    await _repository.saveProgress(updated);
  }
}
