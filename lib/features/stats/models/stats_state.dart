import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_state.freezed.dart';

@freezed
abstract class StatsData with _$StatsData {
  const StatsData._();

  const factory StatsData({
    required double retentionRate,
    required int reviewedToday,
    required int totalReviews,
    required int studyTimeMinutes,
    required int streakDays,
    required List<List<int>> heatmapLevels,
  }) = _StatsData;

  factory StatsData.initial() {
    return const StatsData(
      retentionRate: 0.0,
      reviewedToday: 0,
      totalReviews: 0,
      studyTimeMinutes: 0,
      streakDays: 0,
      heatmapLevels: [],
    );
  }
}
