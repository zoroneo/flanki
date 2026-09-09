/// Academic Grammar Engine constants - eliminates magic numbers and raw literals
abstract final class GrammarConstants {
  const GrammarConstants._();

  static const int totalUnits = 36;
  static const int exercisesPerUnit = 15;
  static const int totalExercises = totalUnits * exercisesPerUnit; // 540

  static const int level1UnitCount = 8;
  static const int level2UnitCount = 17;
  static const int level3UnitCount = 11;

  static const int choiceExercisesPerUnit = 5;
  static const int errorIdExercisesPerUnit = 5;
  static const int clozeExercisesPerUnit = 5;

  /// Stability in days representing 100% mastery under FSRS v4.5
  static const double masteryStabilityCapDays = 30.0;

  /// Relative path prefix for grammar asset json files
  static const String assetDir = 'assets/data/grammar';

  /// Standard 4-option markers for Error ID exercises
  static const List<String> errorIdOptionLabels = ['A', 'B', 'C', 'D'];

  /// Default FSRS target retention rate (90%)
  static const double defaultDesiredRetention = 0.9;

  /// Default unit identifier when doing cross-unit Ghost or Due reviews
  static const String globalReviewUnitId = 'grammar_review';

  /// Minimum accuracy percentage considered satisfactory / passed (80%)
  static const double passAccuracyThreshold = 80.0;
}
