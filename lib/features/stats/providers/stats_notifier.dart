import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/card.dart';
import '../../../core/storage/database_service.dart';
import '../models/stats_state.dart';

export '../models/stats_state.dart';

part 'stats_notifier.g.dart';

@Riverpod(keepAlive: true, name: 'statsNotifierProvider')
class StatsNotifier extends _$StatsNotifier {
  int _trackedStudySecondsToday = 0;

  @override
  StatsData build() {
    return _computeStats();
  }

  void refresh() {
    state = _computeStats();
  }

  void recordStudyDuration(int seconds) {
    _trackedStudySecondsToday += seconds;
    refresh();
  }

  StatsData _computeStats() {
    final logs = DatabaseService.instance.getAllReviewLogs();
    if (logs.isEmpty) {
      return StatsData.initial();
    }

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    int reviewedToday = 0;
    int successfulReviews = 0;

    // Group reviews by Day (yyyy-mm-dd)
    final reviewsPerDay = <String, int>{};

    for (final log in logs) {
      // Retention: ratings Hard, Good, Easy are remembered; Again is lapse
      if (log.rating != ReviewRating.again) {
        successfulReviews++;
      }

      if (log.reviewTime.isAfter(todayStart)) {
        reviewedToday++;
      }

      final dayKey =
          '${log.reviewTime.year}-${log.reviewTime.month.toString().padLeft(2, '0')}-${log.reviewTime.day.toString().padLeft(2, '0')}';
      reviewsPerDay[dayKey] = (reviewsPerDay[dayKey] ?? 0) + 1;
    }

    final retention = logs.isNotEmpty ? (successfulReviews / logs.length) : 0.0;

    // Study time: prefer tracked real duration, or fallback to configured seconds per card
    final studyTimeMinutes = _trackedStudySecondsToday > 0
        ? (_trackedStudySecondsToday / 60).ceil()
        : (reviewedToday * AppConfig.fallbackSecondsPerCard / 60).round();

    // Calculate Streak
    int streak = 0;
    var checkDate = todayStart;

    // Check if reviewed today, if not check from yesterday
    final todayKey =
        '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
    if ((reviewsPerDay[todayKey] ?? 0) == 0) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (true) {
      final key =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if ((reviewsPerDay[key] ?? 0) > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Build heatmap matrix (totalWeeks x 7 days)
    // Last column is current week
    const int totalWeeks = AppConfig.heatmapTotalWeeks;
    final heatmap = List.generate(totalWeeks, (_) => List.filled(7, 0));
    final currentWeekday = now.weekday; // 1: Mon .. 7: Sun

    for (int w = totalWeeks - 1; w >= 0; w--) {
      for (int d = 6; d >= 0; d--) {
        final daysAgo = ((totalWeeks - 1 - w) * 7) + (currentWeekday - 1 - d);
        if (daysAgo >= 0) {
          final targetDay = todayStart.subtract(Duration(days: daysAgo));
          final key =
              '${targetDay.year}-${targetDay.month.toString().padLeft(2, '0')}-${targetDay.day.toString().padLeft(2, '0')}';
          final count = reviewsPerDay[key] ?? 0;

          int level = 0;
          if (count >= AppConfig.heatmapLevel3Threshold) {
            level = 3;
          } else if (count >= AppConfig.heatmapLevel2Threshold) {
            level = 2;
          } else if (count >= AppConfig.heatmapLevel1Threshold) {
            level = 1;
          }
          heatmap[w][d] = level;
        }
      }
    }

    return StatsData(
      retentionRate: retention,
      reviewedToday: reviewedToday,
      totalReviews: logs.length,
      studyTimeMinutes: studyTimeMinutes,
      streakDays: streak,
      heatmapLevels: heatmap,
    );
  }
}
