
import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:flanki/core/fsrs/fsrs_optimizer_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/review_log.dart';

void main() {
  group('FsrsOptimizerService Tests', () {
    test('canOptimize enforces 200 reviews minimum', () {
      expect(FsrsOptimizerService.canOptimize(0), isFalse);
      expect(FsrsOptimizerService.canOptimize(199), isFalse);
      expect(FsrsOptimizerService.canOptimize(200), isTrue);
      expect(FsrsOptimizerService.canOptimize(500), isTrue);
    });

    test('groupLogsByCard chronologically groups and ignores single reviews', () {
      final now = DateTime.utc(2026, 1, 1);
      final logs = [
        ReviewLogModel(
          id: 1,
          cardId: 'card_1',
          rating: ReviewRating.good,
          reviewTime: now.add(const Duration(days: 4)),
        ),
        ReviewLogModel(
          id: 2,
          cardId: 'card_1',
          rating: ReviewRating.good,
          reviewTime: now,
        ),
        ReviewLogModel(
          id: 3,
          cardId: 'card_single',
          rating: ReviewRating.good,
          reviewTime: now,
        ),
      ];

      final sequences = FsrsOptimizerService.extractSequences(logs);
      expect(sequences.length, 1);
      expect(sequences.first.cardId, 'card_1');
      expect(sequences.first.reviews.length, 2);
      expect(sequences.first.reviews[0].reviewTime, now);
      expect(sequences.first.reviews[1].reviewTime, now.add(const Duration(days: 4)));
    });

    test('evaluateMetrics returns non-zero baseline log-loss and rmse on valid data', () {
      final now = DateTime.utc(2026, 1, 1);
      final logs = <ReviewLogModel>[];

      // Generate 25 cards each with 8 sequential reviews
      for (int c = 0; c < 25; c++) {
        final cardId = 'card_$c';
        var t = now;
        logs.add(ReviewLogModel(
          id: logs.length + 1,
          cardId: cardId,
          rating: ReviewRating.good,
          reviewTime: t,
        ));
        for (int step = 1; step < 8; step++) {
          t = t.add(Duration(days: step * 3));
          logs.add(ReviewLogModel(
            id: logs.length + 1,
            cardId: cardId,
            rating: (step % 5 == 0) ? ReviewRating.again : ReviewRating.good,
            reviewTime: t,
          ));
        }
      }

      final sequences = FsrsOptimizerService.extractSequences(logs);
      final metrics = FsrsOptimizerService.evaluateMetrics(
        sequences: sequences,
        parameters: fsrs.defaultParameters,
      );

      expect(metrics.sampleCount, greaterThan(100));
      expect(metrics.logLoss, greaterThan(0.0));
      expect(metrics.rmse, greaterThan(0.0));
      expect(metrics.logLoss.isFinite, isTrue);
      expect(metrics.rmse.isFinite, isTrue);
    });

    test('optimize reduces Log-Loss & RMSE and keeps all 21 parameters within bounds', () {
      final now = DateTime.utc(2026, 1, 1);
      final logs = <ReviewLogModel>[];

      // Generate 40 cards with 6 reviews each (240 reviews >= 200 min)
      // Emulating a fast-learning user who remembers easily (longer intervals)
      for (int c = 0; c < 40; c++) {
        final cardId = 'user_card_$c';
        var t = now;
        logs.add(ReviewLogModel(
          id: logs.length + 1,
          cardId: cardId,
          rating: ReviewRating.easy,
          reviewTime: t,
        ));
        for (int step = 1; step < 6; step++) {
          t = t.add(Duration(days: step * 5));
          logs.add(ReviewLogModel(
            id: logs.length + 1,
            cardId: cardId,
            rating: ReviewRating.easy,
            reviewTime: t,
          ));
        }
      }

      final result = FsrsOptimizerService.optimizeSync(logs);

      expect(result.totalReviews, 240);
      expect(result.totalSamples, greaterThan(150));
      expect(result.optimizedParameters.length, fsrs.defaultParameters.length);
      expect(result.optimizedParameters.length, 21);

      // Verify all parameters are within strict FSRS bounds
      for (int i = 0; i < 21; i++) {
        expect(
          result.optimizedParameters[i],
          greaterThanOrEqualTo(fsrs.lowerBoundsParameters[i]),
          reason: 'Param $i below lower bound',
        );
        expect(
          result.optimizedParameters[i],
          lessThanOrEqualTo(fsrs.upperBoundsParameters[i]),
          reason: 'Param $i exceeds upper bound',
        );
      }

      // Verify optimization improved or kept stable loss
      expect(result.optimizedLogLoss, lessThanOrEqualTo(result.baselineLogLoss + 1e-4));
      expect(result.optimizedRmse, lessThanOrEqualTo(result.baselineRmse + 1e-4));
    });

    test('optimize throws StateError when reviews < 200', () {
      final logs = List.generate(
        150,
        (i) => ReviewLogModel(
          id: i,
          cardId: 'c_$i',
          rating: ReviewRating.good,
          reviewTime: DateTime.now(),
        ),
      );

      expect(
        () => FsrsOptimizerService.optimizeSync(logs),
        throwsA(isA<StateError>()),
      );
    });
  });
}
