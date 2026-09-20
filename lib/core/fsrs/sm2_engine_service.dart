import 'dart:math' as math;

import '../../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';
import '../models/card.dart';
import 'fsrs_engine_service.dart';

/// Service implementing the classic SuperMemo 2 (SM-2) algorithm used by standard Anki.
/// Activated when FSRS v5 is toggled off in settings.
class Sm2EngineService {
  const Sm2EngineService();

  /// Core SM-2 ease factor boundary constants
  static const double minEaseFactor = 1.3;
  static const double maxEaseFactor = 3.0;
  static const double defaultEaseFactor = 2.5;

  /// Unified difficulty scale boundaries (1.0 to 10.0)
  static const double minDifficulty = 1.0;
  static const double maxDifficulty = 10.0;
  static const double easeSpan = maxEaseFactor - minEaseFactor; // 1.7
  static const double difficultySpan = maxDifficulty - minDifficulty; // 9.0

  /// SM-2 rating adjustment factors
  static const double againFactorPenalty = 0.2;
  static const double hardFactorPenalty = 0.15;
  static const double hardIntervalMultiplier = 1.2;
  static const double easyFactorBonus = 0.15;
  static const double easyIntervalMultiplier = 1.3;

  /// Initial review interval steps (in days)
  static const int initialRep1IntervalDays = 1;
  static const int initialRep2IntervalDays = 6;
  static const int initialEasyIntervalDays = 4;
  static const int minIntervalDays = 1;

  /// Maps unified card difficulty back to SM-2 ease factor.
  static double difficultyToFactor(double difficulty) {
    if (difficulty > 0) {
      final ease =
          maxEaseFactor -
          ((difficulty - minDifficulty) / difficultySpan * easeSpan);
      return ease.clamp(minEaseFactor, maxEaseFactor);
    }
    return defaultEaseFactor;
  }

  /// Maps SM-2 ease factor into unified card difficulty.
  static double factorToDifficulty(double factor) {
    return ((maxEaseFactor - factor) / easeSpan * difficultySpan +
            minDifficulty)
        .clamp(minDifficulty, maxDifficulty);
  }

  /// Estimates the current ease factor from card stability & difficulty, defaulting to 2.5.
  double getEaseFactor(CardModel card) => difficultyToFactor(card.difficulty);

  /// Calculates next interval labels for all 4 ratings (Again, Hard, Good, Easy) under SM-2.
  Map<ReviewRating, String> previewIntervals(
    CardModel card, {
    AppLocalizations? l10n,
    DateTime? now,
  }) {
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
  CardModel scheduleReview(
    CardModel card,
    ReviewRating rating, {
    DateTime? now,
  }) {
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
        factor = math.max(minEaseFactor, factor - againFactorPenalty);
        break;

      case ReviewRating.hard:
        newReps = card.reps + 1;
        if (newReps <= 1) {
          newInterval = initialRep1IntervalDays;
        } else {
          newInterval = math.max(
            minIntervalDays,
            (card.intervalDays * hardIntervalMultiplier).round(),
          );
        }
        factor = math.max(minEaseFactor, factor - hardFactorPenalty);
        break;

      case ReviewRating.good:
        newReps = card.reps + 1;
        if (newReps <= 1) {
          newInterval = initialRep1IntervalDays;
        } else if (newReps == 2) {
          newInterval = initialRep2IntervalDays;
        } else {
          newInterval = math.max(
            minIntervalDays,
            (card.intervalDays * factor).round(),
          );
        }
        break;

      case ReviewRating.easy:
        newReps = card.reps + 1;
        if (newReps <= 1) {
          newInterval = initialEasyIntervalDays;
        } else {
          newInterval = math.max(
            minIntervalDays,
            (card.intervalDays * factor * easyIntervalMultiplier).round(),
          );
        }
        factor = factor + easyFactorBonus;
        break;
    }

    // Inverse map ease factor back into difficulty for unified storage
    final updatedDifficulty = factorToDifficulty(factor);
    final due = rating == ReviewRating.again
        ? effectiveNow.add(AppConfig.defaultRelearnStep)
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
