/// Academic Examination Engine constants - eliminates magic numbers and raw literals
abstract final class ExamConstants {
  const ExamConstants._();

  // Academic scoring & passing thresholds
  static const int defaultPassingScorePercent = 60;
  static const int defaultQuestionPoints = 1;

  // Timing constants (seconds / minutes)
  static const int defaultDurationMinutes = 60;
  static const int secondsPerMinute = 60;
  static const int urgentTimerSeconds = 300; // 5 minutes remaining alert threshold

  // Structure & Default parameters
  static const int defaultTotalQuestions = 40;
  static const int defaultQuestionNumber = 1;
  static const int defaultExamVersion = 1;
  static const String defaultExamLevel = 'N3';
  static const String defaultExamIcon = 'file-text';
  static const String defaultSectionType = 'general';
  static const int defaultSectionOrder = 0;

  // Question option keys
  static const String optionIdA = 'A';
  static const String optionIdB = 'B';
  static const String optionIdC = 'C';
  static const String optionIdD = 'D';
  static const List<String> standardOptionIds = [
    optionIdA,
    optionIdB,
    optionIdC,
    optionIdD,
  ];
}
