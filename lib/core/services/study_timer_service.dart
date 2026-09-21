import '../database/data_change_bus.dart';

/// In-memory service tracking active study session duration for the current day.
class StudyTimerService {
  static final StudyTimerService instance = StudyTimerService._();
  StudyTimerService._();

  int _trackedStudySecondsToday = 0;

  /// Returns total study seconds accumulated during the active app session today.
  int get trackedStudySecondsToday => _trackedStudySecondsToday;

  /// Records additional study seconds and notifies listeners via [DataChangeBus].
  void recordStudyDuration(int seconds) {
    _trackedStudySecondsToday += seconds;
    DataChangeBus.instance.notifyReviews();
  }

  /// Resets tracked study seconds (e.g. for testing).
  void reset() {
    _trackedStudySecondsToday = 0;
  }
}
