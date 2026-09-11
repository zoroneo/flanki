import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart' as fsrs;

import '../models/card.dart';
import '../models/grammar/grammar_models.dart';
import '../storage/grammar_repository.dart';

/// Evaluates and normalizes user answers for Choice, Error ID, and Cloze questions
class GrammarAnswerEvaluator {
  /// Normalize text for robust cloze evaluation
  static String normalizeCloze(String text) {
    var cleaned = text.trim().toLowerCase();
    // Normalize typographic curly quotes to straight single quote
    cleaned = cleaned.replaceAll('’', "'").replaceAll('‘', "'");
    // Replace multiple consecutive whitespaces with a single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    // Strip trailing punctuation (. , ! ?)
    cleaned = cleaned.replaceAll(RegExp(r'[.,!?]+$'), '');
    return cleaned.trim();
  }

  /// Check whether user's answer matches the correct answer
  static bool isCorrect(GrammarExercise exercise, String userAnswer) {
    if (userAnswer.isEmpty) return false;

    switch (exercise.type) {
      case GrammarExerciseType.choice:
        return userAnswer.trim() == exercise.correctAnswer.trim();

      case GrammarExerciseType.errorId:
        return userAnswer.trim().toUpperCase() ==
            exercise.correctAnswer.trim().toUpperCase();

      case GrammarExerciseType.cloze:
        final normUser = normalizeCloze(userAnswer);
        final normCorrect = normalizeCloze(exercise.correctAnswer);
        if (normUser == normCorrect) return true;

        // Check for alternative answers if slash separated (e.g. "will go / goes")
        if (exercise.correctAnswer.contains('/')) {
          final parts = exercise.correctAnswer
              .split('/')
              .map((p) => normalizeCloze(p))
              .toList();
          return parts.contains(normUser);
        }
        return false;
    }
  }
}

/// State of an active grammar practice or review session
class GrammarSessionState {
  final GrammarUnit? unit;
  final List<GrammarExercise> exercises;
  final int currentIndex;
  final String? selectedAnswer;
  final Map<String, String> userAnswers;
  final Map<String, bool> results;
  final bool isSubmitted;
  final bool? isCurrentCorrect;
  final List<GrammarExercise> ghostChallengeQueue;
  final bool isGhostChallenge;
  final bool isFinished;
  final DateTime startTime;
  final DateTime questionStartTime;

  GrammarSessionState({
    this.unit,
    this.exercises = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.userAnswers = const {},
    this.results = const {},
    this.isSubmitted = false,
    this.isCurrentCorrect,
    this.ghostChallengeQueue = const [],
    this.isGhostChallenge = false,
    this.isFinished = false,
    DateTime? startTime,
    DateTime? questionStartTime,
  })  : startTime = startTime ?? DateTime.now(),
        questionStartTime = questionStartTime ?? DateTime.now();

  GrammarExercise? get currentExercise {
    if (currentIndex >= 0 && currentIndex < exercises.length) {
      return exercises[currentIndex];
    }
    return null;
  }

  bool get isLastQuestion =>
      exercises.isNotEmpty && currentIndex == exercises.length - 1;

  int get totalQuestions => exercises.length;

  double get progressFraction {
    if (exercises.isEmpty) return 0.0;
    final completed = currentIndex + (isSubmitted ? 1 : 0);
    return (completed / exercises.length).clamp(0.0, 1.0);
  }

  int get correctCount => results.values.where((r) => r).length;

  double get accuracyPercentage {
    if (results.isEmpty) return 0.0;
    return (correctCount / results.length) * 100.0;
  }

  GrammarSessionState copyWith({
    GrammarUnit? unit,
    List<GrammarExercise>? exercises,
    int? currentIndex,
    String? selectedAnswer,
    bool clearSelectedAnswer = false,
    Map<String, String>? userAnswers,
    Map<String, bool>? results,
    bool? isSubmitted,
    bool? isCurrentCorrect,
    bool clearCurrentCorrect = false,
    List<GrammarExercise>? ghostChallengeQueue,
    bool? isGhostChallenge,
    bool? isFinished,
    DateTime? startTime,
    DateTime? questionStartTime,
  }) {
    return GrammarSessionState(
      unit: unit ?? this.unit,
      exercises: exercises ?? this.exercises,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer:
          clearSelectedAnswer ? null : (selectedAnswer ?? this.selectedAnswer),
      userAnswers: userAnswers ?? this.userAnswers,
      results: results ?? this.results,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isCurrentCorrect: clearCurrentCorrect
          ? null
          : (isCurrentCorrect ?? this.isCurrentCorrect),
      ghostChallengeQueue: ghostChallengeQueue ?? this.ghostChallengeQueue,
      isGhostChallenge: isGhostChallenge ?? this.isGhostChallenge,
      isFinished: isFinished ?? this.isFinished,
      startTime: startTime ?? this.startTime,
      questionStartTime: questionStartTime ?? this.questionStartTime,
    );
  }
}

final grammarSessionNotifierProvider =
    NotifierProvider<GrammarSessionNotifier, GrammarSessionState>(
  GrammarSessionNotifier.new,
);

class GrammarSessionNotifier extends Notifier<GrammarSessionState> {
  final GrammarRepository? _repoOverride;
  final fsrs.Scheduler? _schedOverride;

  GrammarSessionNotifier({
    GrammarRepository? repository,
    fsrs.Scheduler? scheduler,
  })  : _repoOverride = repository,
        _schedOverride = scheduler;

  GrammarRepository get _repository =>
      _repoOverride ?? ref.read(grammarRepositoryProvider);

  fsrs.Scheduler get _scheduler =>
      _schedOverride ??
      fsrs.Scheduler(
          desiredRetention: GrammarConstants.defaultDesiredRetention);

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
  void startGhostSession(List<GrammarExercise> ghostExercises,
      {GrammarUnit? unit}) {
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

    final updatedGhostQueue =
        List<GrammarExercise>.from(state.ghostChallengeQueue);
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
        clearSelectedAnswer: true,
        clearCurrentCorrect: true,
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
    final existing = _repository.getProgress(unitId, exerciseId) ??
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
