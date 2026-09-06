import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';
import '../storage/database_service.dart';

class StatsData {
  final double retentionRate;
  final int reviewedToday;
  final int totalReviews;
  final int studyTimeMinutes;
  final int streakDays;
  final List<List<int>> heatmapLevels; // 5 weeks x 7 days (0..3)

  const StatsData({
    required this.retentionRate,
    required this.reviewedToday,
    required this.totalReviews,
    required this.studyTimeMinutes,
    required this.streakDays,
    required this.heatmapLevels,
  });

  factory StatsData.initial() {
    return const StatsData(
      retentionRate: 0.0,
      reviewedToday: 0,
      totalReviews: 0,
      studyTimeMinutes: 0,
      streakDays: 0,
      heatmapLevels: [
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
    );
  }
}

final statsNotifierProvider =
    NotifierProvider<StatsNotifier, StatsData>(StatsNotifier.new);

class StatsNotifier extends Notifier<StatsData> {
  @override
  StatsData build() {
    return _computeStats();
  }

  void refresh() {
    state = _computeStats();
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

    // Estimated study time: ~15 seconds per card
    final studyTimeMinutes = (reviewedToday * 15 / 60).round();

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

    // Build 5-week x 7-day heatmap matrix
    // Index 4 is the current week, index 0 is 4 weeks ago
    final heatmap = List.generate(5, (_) => List.filled(7, 0));
    final currentWeekday = now.weekday; // 1: Mon .. 7: Sun

    for (int w = 4; w >= 0; w--) {
      for (int d = 6; d >= 0; d--) {
        final daysAgo = ((4 - w) * 7) + (currentWeekday - 1 - d);
        if (daysAgo >= 0) {
          final targetDay = todayStart.subtract(Duration(days: daysAgo));
          final key =
              '${targetDay.year}-${targetDay.month.toString().padLeft(2, '0')}-${targetDay.day.toString().padLeft(2, '0')}';
          final count = reviewsPerDay[key] ?? 0;

          int level = 0;
          if (count >= 10) {
            level = 3;
          } else if (count >= 4) {
            level = 2;
          } else if (count >= 1) {
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
