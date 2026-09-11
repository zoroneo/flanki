import 'dart:math' as math;

import 'package:fsrs/fsrs.dart' as fsrs;

import '../../l10n/generated/app_localizations.dart';
import '../config/app_config.dart';
import '../models/card.dart';

/// Service wrapping package:fsrs to manage spaced repetition scheduling.
class FsrsEngineService {
  final fsrs.Scheduler scheduler;

  FsrsEngineService({
    double desiredRetention = 0.9,
    bool enableFuzzing = false, // deterministic intervals for UI preview
  }) : scheduler = fsrs.Scheduler(
         desiredRetention: desiredRetention,
         enableFuzzing: enableFuzzing,
       );

  /// Convert Flanki's CardModel to fsrs.Card
  fsrs.Card toFsrsCard(CardModel card) {
    fsrs.State state;
    if (card.reps == 0 && card.stability == 0.0) {
      state = fsrs.State.learning;
    } else if (card.lapses > 0 && card.intervalDays <= 1) {
      state = fsrs.State.learning;
    } else {
      state = fsrs.State.review;
    }

    final cardId =
        int.tryParse(card.id.replaceAll(RegExp(r'\D'), '')) ??
        card.id.hashCode.abs();

    return fsrs.Card(
      cardId: cardId,
      state: state,
      stability: card.stability > 0 ? card.stability : null,
      difficulty: card.difficulty > 0 ? card.difficulty : null,
      due: (card.due ?? DateTime.now()).toUtc(),
      lastReview: card.lastStudied?.toUtc(),
    );
  }

  /// Calculates next interval labels for all 4 ratings (Again, Hard, Good, Easy)
  Map<ReviewRating, String> previewIntervals(
    CardModel card, {
    AppLocalizations? l10n,
  }) {
    final now = DateTime.now().toUtc();
    final fsrsCard = toFsrsCard(card);

    final results = <ReviewRating, String>{};
    for (final rating in [
      fsrs.Rating.again,
      fsrs.Rating.hard,
      fsrs.Rating.good,
      fsrs.Rating.easy,
    ]) {
      final reviewRating = ReviewRating.fromValue(rating.value);
      try {
        final outcome = scheduler.reviewCard(
          fsrsCard,
          rating,
          reviewDateTime: now,
        );
        final diff = outcome.card.due.difference(now);
        results[reviewRating] = formatInterval(diff, l10n: l10n);
      } catch (_) {
        results[reviewRating] = _fallbackInterval(reviewRating, l10n: l10n);
      }
    }
    return results;
  }

  /// Applies user review rating (Again, Hard, Good, Easy)
  /// and returns an updated CardModel with calculated FSRS stability, difficulty, due date.
  CardModel scheduleReview(CardModel card, ReviewRating ratingEnum) {
    final now = DateTime.now().toUtc();
    final fsrsCard = toFsrsCard(card);
    final rating = fsrs.Rating.fromValue(ratingEnum.value);

    final outcome = scheduler.reviewCard(fsrsCard, rating, reviewDateTime: now);

    final newCard = outcome.card;
    final intervalDuration = newCard.due.difference(now);
    final intervalDays = math.max(1, intervalDuration.inDays);

    final isAgain = ratingEnum == ReviewRating.again;

    return card.copyWith(
      stability: newCard.stability ?? card.stability,
      difficulty: newCard.difficulty ?? card.difficulty,
      intervalDays: intervalDays,
      due: newCard.due.toLocal(),
      lastStudied: DateTime.now(),
      reps: card.reps + 1,
      lapses: isAgain ? card.lapses + 1 : card.lapses,
    );
  }

  static AppLocalizations _defaultL10n() => AppConfig.getL10n();

  /// Formats a duration into Anki-style interval strings: < 10m, 1d, 4d, 1.2m, etc.
  static String formatInterval(Duration duration, {AppLocalizations? l10n}) {
    final resL10n = l10n ?? _defaultL10n();
    if (duration.inMinutes < 60) {
      final mins = duration.inMinutes <= 1 ? 1 : duration.inMinutes;
      return resL10n.intervalMinutes(mins);
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      return resL10n.intervalHours(hours);
    } else if (duration.inDays < 30) {
      final days = duration.inDays;
      return resL10n.intervalDays(days);
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).toStringAsFixed(1);
      final clean = months.endsWith('.0')
          ? months.substring(0, months.length - 2)
          : months;
      return resL10n.intervalMonths(clean);
    } else {
      final years = (duration.inDays / 365).toStringAsFixed(1);
      final clean = years.endsWith('.0')
          ? years.substring(0, years.length - 2)
          : years;
      return resL10n.intervalYears(clean);
    }
  }

  static String _fallbackInterval(
    ReviewRating rating, {
    AppLocalizations? l10n,
  }) {
    final resL10n = l10n ?? _defaultL10n();
    switch (rating) {
      case ReviewRating.again:
        return '< ${resL10n.intervalMinutes(10)}';
      case ReviewRating.hard:
        return resL10n.intervalDays(1);
      case ReviewRating.good:
        return resL10n.intervalDays(4);
      case ReviewRating.easy:
        return resL10n.intervalDays(12);
    }
  }
}
