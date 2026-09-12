import '../models/grammar_models.dart';

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
