import 'package:freezed_annotation/freezed_annotation.dart';

import 'grammar_models.dart';

part 'grammar_session_state.freezed.dart';

/// State of an active grammar practice or review session
@freezed
abstract class GrammarSessionState with _$GrammarSessionState {
  const GrammarSessionState._();

  const factory GrammarSessionState({
    GrammarUnit? unit,
    @Default([]) List<GrammarExercise> exercises,
    @Default(0) int currentIndex,
    String? selectedAnswer,
    @Default({}) Map<String, String> userAnswers,
    @Default({}) Map<String, bool> results,
    @Default(false) bool isSubmitted,
    bool? isCurrentCorrect,
    @Default([]) List<GrammarExercise> ghostChallengeQueue,
    @Default(false) bool isGhostChallenge,
    @Default(false) bool isFinished,
    DateTime? startTime,
    DateTime? questionStartTime,
  }) = _GrammarSessionState;

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
}
