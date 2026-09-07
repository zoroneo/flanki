import 'dart:math' as math;
import '../../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import 'fsrs_engine_service.dart';

/// Service implementing the classic SuperMemo 2 (SM-2) algorithm used by standard Anki.
/// Activated when FSRS v5 is toggled off in settings.
class Sm2EngineService {
  const Sm2EngineService();

  /// Maps unified card difficulty back to SM-2 ease factor.
  static double difficultyToFactor(double difficulty) {
    if (difficulty > 0) {
      final ease = 3.0 - ((difficulty - 1.0) / 9.0 * 1.7);
      return ease.clamp(1.3, 3.0);
    }
    return 2.5;
  }

  /// Maps SM-2 ease factor into unified card difficulty.
  static double factorToDifficulty(double factor) {
    return ((3.0 - factor) / 1.7 * 9.0 + 1.0).clamp(1.0, 10.0);
  }

  /// Estimates the current ease factor from card stability & difficulty, defaulting to 2.5.
  double getEaseFactor(CardModel card) => difficultyToFactor(card.difficulty);

  /// Calculates next interval labels for all 4 ratings (Again, Hard, Good, Easy) under SM-2.
  Map<ReviewRating, String> previewIntervals(CardModel card, {AppLocalizations? l10n, DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final results = <ReviewRating, String>{};
    for (final rating in ReviewRating.values) {
      final scheduled = scheduleReview(card, rating, now: effectiveNow);
      final duration = scheduled.due != null
          ? scheduled.due!.difference(effectiveNow)
          : Duration(days: scheduled.intervalDays);
      results[rating] = FsrsEngineService.formatInterval(duration, l10n: l10n);
    }
    return results;
  }

  /// Applies user review rating under SM-2 and returns updated CardModel.
  CardModel scheduleReview(CardModel card, ReviewRating rating, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    double factor = getEaseFactor(card);
    int newInterval;
    int newReps = card.reps;
    int newLapses = card.lapses;

    switch (rating) {
      case ReviewRating.again:
        newLapses += 1;
        newReps = card.reps + 1;
        newInterval = 0;
        factor = math.max(1.3, factor - 0.2);
        break;

      case ReviewRating.hard:
        newReps = card.reps + 1;
        if (newReps <= 1) {
          newInterval = 1;
        } else {
          newInterval = math.max(1, (card.intervalDays * 1.2).round());
        }
        factor = math.max(1.3, factor - 0.15);
        break;

      case ReviewRating.good:
        newReps = card.reps + 1;
        if (newReps <= 1) {
          newInterval = 1;
        } else if (newReps == 2) {
          newInterval = 6;
        } else {
          newInterval = math.max(1, (card.intervalDays * factor).round());
        }
        break;

      case ReviewRating.easy:
        newReps = card.reps + 1;
        if (newReps <= 1) {
          newInterval = 4;
        } else {
          newInterval = math.max(1, (card.intervalDays * factor * 1.3).round());
        }
        factor = factor + 0.15;
        break;
    }

    // Inverse map ease factor back into difficulty for unified storage
    final updatedDifficulty = ((3.0 - factor) / 1.7 * 9.0 + 1.0).clamp(1.0, 10.0);
    final due = rating == ReviewRating.again
        ? effectiveNow.add(const Duration(minutes: 10))
        : effectiveNow.add(Duration(days: newInterval));

    return card.copyWith(
      intervalDays: newInterval,
      stability: newInterval.toDouble(),
      difficulty: updatedDifficulty,
      reps: newReps,
      lapses: newLapses,
      due: due,
      lastStudied: effectiveNow,
    );
  }
}
