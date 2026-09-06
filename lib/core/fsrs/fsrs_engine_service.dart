import 'dart:math' as math;
import 'package:fsrs/fsrs.dart' as fsrs;
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

    final cardId = int.tryParse(card.id.replaceAll(RegExp(r'\D'), '')) ??
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
  Map<int, String> previewIntervals(CardModel card) {
    final now = DateTime.now().toUtc();
    final fsrsCard = toFsrsCard(card);

    final results = <int, String>{};
    for (final rating in [
      fsrs.Rating.again,
      fsrs.Rating.hard,
      fsrs.Rating.good,
      fsrs.Rating.easy,
    ]) {
      try {
        final outcome = scheduler.reviewCard(
          fsrsCard,
          rating,
          reviewDateTime: now,
        );
        final diff = outcome.card.due.difference(now);
        results[rating.value] = formatInterval(diff);
      } catch (_) {
        results[rating.value] = _fallbackInterval(rating.value);
      }
    }
    return results;
  }

  /// Applies user review rating (1: Again, 2: Hard, 3: Good, 4: Easy)
  /// and returns an updated CardModel with calculated FSRS stability, difficulty, due date.
  CardModel scheduleReview(CardModel card, int ratingValue) {
    final now = DateTime.now().toUtc();
    final fsrsCard = toFsrsCard(card);
    final rating = fsrs.Rating.fromValue(ratingValue);

    final outcome = scheduler.reviewCard(
      fsrsCard,
      rating,
      reviewDateTime: now,
    );

    final newCard = outcome.card;
    final intervalDuration = newCard.due.difference(now);
    final intervalDays = math.max(1, intervalDuration.inDays);

    final isAgain = ratingValue == 1;

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

  /// Formats a duration into Anki-style interval strings: < 10m, 1d, 4d, 1.2m, etc.
  static String formatInterval(Duration duration) {
    if (duration.inMinutes < 60) {
      final mins = duration.inMinutes <= 1 ? 1 : duration.inMinutes;
      return '$mins phút';
    } else if (duration.inHours < 24) {
      final hours = duration.inHours;
      return '$hours giờ';
    } else if (duration.inDays < 30) {
      final days = duration.inDays;
      return '$days ngày';
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).toStringAsFixed(1);
      final clean = months.endsWith('.0')
          ? months.substring(0, months.length - 2)
          : months;
      return '$clean tháng';
    } else {
      final years = (duration.inDays / 365).toStringAsFixed(1);
      final clean =
          years.endsWith('.0') ? years.substring(0, years.length - 2) : years;
      return '$clean năm';
    }
  }

  static String _fallbackInterval(int rating) {
    switch (rating) {
      case 1:
        return '< 10 phút';
      case 2:
        return '1 ngày';
      case 3:
        return '4 ngày';
      case 4:
        return '12 ngày';
      default:
        return '1 ngày';
    }
  }
}
