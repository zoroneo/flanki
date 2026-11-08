import 'dart:isolate';
import 'dart:math' as math;

import 'package:fsrs/fsrs.dart' as fsrs;

import '../config/app_config.dart';
import '../models/review_log.dart';

/// Grouped sequence of historical reviews for a specific card.
class FsrsTrainingSequence {
  final String cardId;
  final List<ReviewLogModel> reviews;

  const FsrsTrainingSequence({
    required this.cardId,
    required this.reviews,
  });
}

/// Evaluation metrics (Binary Cross-Entropy Log-Loss and RMSE).
class FsrsOptimizationMetrics {
  final double logLoss;
  final double rmse;
  final int sampleCount;

  const FsrsOptimizationMetrics({
    required this.logLoss,
    required this.rmse,
    required this.sampleCount,
  });

  @override
  String toString() =>
      'FsrsOptimizationMetrics(logLoss: ${logLoss.toStringAsFixed(4)}, rmse: ${rmse.toStringAsFixed(4)}, samples: $sampleCount)';
}

/// Comprehensive result comparing baseline (default) vs optimized parameters.
class FsrsOptimizationResult {
  final List<double> optimizedParameters;
  final List<double> baselineParameters;
  final FsrsOptimizationMetrics baselineMetrics;
  final FsrsOptimizationMetrics optimizedMetrics;
  final int totalReviews;
  final DateTime optimizedAt;

  const FsrsOptimizationResult({
    required this.optimizedParameters,
    required this.baselineParameters,
    required this.baselineMetrics,
    required this.optimizedMetrics,
    required this.totalReviews,
    required this.optimizedAt,
  });

  double get baselineLogLoss => baselineMetrics.logLoss;
  double get optimizedLogLoss => optimizedMetrics.logLoss;
  double get baselineRmse => baselineMetrics.rmse;
  double get optimizedRmse => optimizedMetrics.rmse;
  int get totalSamples => optimizedMetrics.sampleCount;

  /// Percentage improvement in Log-Loss (positive means loss decreased / improved)
  double get logLossImprovementPercent {
    if (baselineLogLoss <= 1e-6) return 0.0;
    return ((baselineLogLoss - optimizedLogLoss) / baselineLogLoss) * 100.0;
  }

  /// Percentage improvement in RMSE (positive means RMSE decreased / improved)
  double get rmseImprovementPercent {
    if (baselineRmse <= 1e-6) return 0.0;
    return ((baselineRmse - optimizedRmse) / baselineRmse) * 100.0;
  }
}

/// Pure Dart service to calibrate and optimize FSRS v5 parameters from ReviewLogs.
class FsrsOptimizerService {
  static const int minRequiredReviews =
      AppConfig.minReviewLogsForFsrsOptimization;

  static const double _eps = 1e-4;
  static const double _l2Lambda = 0.005;

  /// Checks whether dataset contains enough review logs for statistical reliability.
  static bool canOptimize(int totalReviews) =>
      totalReviews >= minRequiredReviews;

  /// Organizes review logs chronologically by card ID, filtering cards with < 2 reviews.
  static List<FsrsTrainingSequence> extractSequences(
      List<ReviewLogModel> logs) {
    if (logs.isEmpty) return const [];

    final map = <String, List<ReviewLogModel>>{};
    for (final log in logs) {
      map.putIfAbsent(log.cardId, () => []).add(log);
    }

    final sequences = <FsrsTrainingSequence>[];
    for (final entry in map.entries) {
      final reviews = entry.value;
      if (reviews.length >= 2) {
        reviews.sort((a, b) => a.reviewTime.compareTo(b.reviewTime));
        sequences.add(FsrsTrainingSequence(
          cardId: entry.key,
          reviews: reviews,
        ));
      }
    }

    return sequences;
  }

  /// Evaluates Log-Loss and RMSE across all sequences using provided FSRS parameters.
  static FsrsOptimizationMetrics evaluateMetrics({
    required List<FsrsTrainingSequence> sequences,
    required List<double> parameters,
  }) {
    if (sequences.isEmpty) {
      return const FsrsOptimizationMetrics(
        logLoss: 0.0,
        rmse: 0.0,
        sampleCount: 0,
      );
    }

    final decay = -parameters[20];
    final factor = math.pow(0.9, 1.0 / decay) - 1.0;

    double totalLogLoss = 0.0;
    double totalSquaredError = 0.0;
    int evaluatedSamples = 0;

    for (final seq in sequences) {
      final reviews = seq.reviews;
      if (reviews.length < 2) continue;

      // 1. Initial review
      final first = reviews[0];
      final firstRatingVal = first.rating.value;
      double stability = math.max(
        parameters[firstRatingVal - 1],
        fsrs.stabilityMin,
      );
      double difficulty = (parameters[4] -
              math.exp(parameters[5] * (firstRatingVal - 1)) +
              1.0)
          .clamp(fsrs.minDifficulty, fsrs.maxDifficulty);
      DateTime lastReviewTime = first.reviewTime;

      // 2. Sequential transitions
      for (int i = 1; i < reviews.length; i++) {
        final current = reviews[i];
        final currentRating = current.rating;
        final ratingVal = currentRating.value;

        final elapsedDays = math.max(
          0,
          current.reviewTime.difference(lastReviewTime).inDays,
        );

        // Retrievability prediction
        double retrievability = math
            .pow(1.0 + factor * (elapsedDays / stability), decay)
            .toDouble();
        retrievability = retrievability.clamp(_eps, 1.0 - _eps);

        // Ground truth: Recall (Hard, Good, Easy) = 1.0, Lapse (Again) = 0.0
        final outcome = ratingVal > 1 ? 1.0 : 0.0;

        // Evaluate prediction only for inter-day reviews (elapsedDays >= 1)
        if (elapsedDays >= 1) {
          final sampleLoss = -(outcome * math.log(retrievability) +
              (1.0 - outcome) * math.log(1.0 - retrievability));
          final se = math.pow(outcome - retrievability, 2).toDouble();

          totalLogLoss += sampleLoss;
          totalSquaredError += se;
          evaluatedSamples++;
        }

        // State update for next step
        // Next difficulty
        final deltaDifficulty = -(parameters[6] * (ratingVal - 3));
        final dampedDifficulty =
            difficulty + (10.0 - difficulty) * deltaDifficulty / 9.0;
        final initEasyDiff = (parameters[4] -
                math.exp(parameters[5] * (fsrs.Rating.easy.value - 1)) +
                1.0)
            .clamp(fsrs.minDifficulty, fsrs.maxDifficulty);
        final nextDifficulty = (parameters[7] * initEasyDiff +
                (1.0 - parameters[7]) * dampedDifficulty)
            .clamp(fsrs.minDifficulty, fsrs.maxDifficulty);

        // Next stability
        double nextStability;
        if (elapsedDays < 1) {
          // Short-term stability
          var shortTermIncrease = math.exp(
                  parameters[17] * (ratingVal - 3 + parameters[18])) *
              math.pow(stability, -parameters[19]);
          if (ratingVal >= 3) {
            shortTermIncrease = math.max(shortTermIncrease, 1.0);
          }
          nextStability = stability * shortTermIncrease;
        } else if (ratingVal == 1) {
          // Forget stability
          final longTerm = parameters[11] *
              math.pow(nextDifficulty, -parameters[12]) *
              (math.pow(stability + 1.0, parameters[13]) - 1.0) *
              math.exp((1.0 - retrievability) * parameters[14]);
          final shortTerm =
              stability / math.exp(parameters[17] * parameters[18]);
          nextStability = math.min(longTerm, shortTerm);
        } else {
          // Recall stability
          final hardPenalty = ratingVal == 2 ? parameters[15] : 1.0;
          final easyBonus = ratingVal == 4 ? parameters[16] : 1.0;
          nextStability = stability *
              (1.0 +
                  math.exp(parameters[8]) *
                      (11.0 - nextDifficulty) *
                      math.pow(stability, -parameters[9]) *
                      (math.exp((1.0 - retrievability) * parameters[10]) -
                          1.0) *
                      hardPenalty *
                      easyBonus);
        }

        stability = math.max(nextStability, fsrs.stabilityMin);
        difficulty = nextDifficulty;
        lastReviewTime = current.reviewTime;
      }
    }

    if (evaluatedSamples == 0) {
      return const FsrsOptimizationMetrics(
        logLoss: 0.0,
        rmse: 0.0,
        sampleCount: 0,
      );
    }

    return FsrsOptimizationMetrics(
      logLoss: totalLogLoss / evaluatedSamples,
      rmse: math.sqrt(totalSquaredError / evaluatedSamples),
      sampleCount: evaluatedSamples,
    );
  }

  /// Objective function: Cross-Entropy Log-Loss + L2 prior regularization towards defaults.
  static double _computeObjective({
    required List<FsrsTrainingSequence> sequences,
    required List<double> candidate,
    required List<double> baseline,
  }) {
    final metrics = evaluateMetrics(
      sequences: sequences,
      parameters: candidate,
    );

    double reg = 0.0;
    for (int j = 0; j < 21; j++) {
      final scale = math.max(0.1, 0.5 * baseline[j].abs());
      final diff = (candidate[j] - baseline[j]) / scale;
      reg += diff * diff;
    }

    return metrics.logLoss + _l2Lambda * reg;
  }

  /// Synchronously optimizes FSRS v5 weights on extracted review logs.
  static FsrsOptimizationResult optimizeSync(
    List<ReviewLogModel> logs, {
    List<double>? currentWeights,
    int epochs = 35,
  }) {
    if (!canOptimize(logs.length)) {
      throw StateError(
        'Requires at least $minRequiredReviews review logs to optimize (Found: ${logs.length})',
      );
    }

    final sequences = extractSequences(logs);
    if (sequences.isEmpty) {
      throw StateError('No multi-review card sequences available for training.');
    }

    final baseline = List<double>.from(fsrs.defaultParameters);
    final baselineMetrics = evaluateMetrics(
      sequences: sequences,
      parameters: baseline,
    );

    var w = List<double>.from(currentWeights ?? baseline);
    var bestW = List<double>.from(w);
    var bestLoss = _computeObjective(
      sequences: sequences,
      candidate: w,
      baseline: baseline,
    );

    // Adam optimizer moments
    final m = List<double>.filled(21, 0.0);
    final v = List<double>.filled(21, 0.0);
    const alpha = 0.015;
    const beta1 = 0.9;
    const beta2 = 0.999;
    const adamEps = 1e-8;

    for (int t = 1; t <= epochs; t++) {
      for (int j = 0; j < 21; j++) {
        final stepH = 1e-4 * math.max(0.1, w[j].abs());

        final wPlus = List<double>.from(w);
        wPlus[j] = (w[j] + stepH)
            .clamp(fsrs.lowerBoundsParameters[j], fsrs.upperBoundsParameters[j]);

        final wMinus = List<double>.from(w);
        wMinus[j] = (w[j] - stepH)
            .clamp(fsrs.lowerBoundsParameters[j], fsrs.upperBoundsParameters[j]);

        final fPlus = _computeObjective(
          sequences: sequences,
          candidate: wPlus,
          baseline: baseline,
        );
        final fMinus = _computeObjective(
          sequences: sequences,
          candidate: wMinus,
          baseline: baseline,
        );

        final delta = wPlus[j] - wMinus[j];
        final grad = delta.abs() > 1e-9 ? (fPlus - fMinus) / delta : 0.0;

        // Adam update
        m[j] = beta1 * m[j] + (1.0 - beta1) * grad;
        v[j] = beta2 * v[j] + (1.0 - beta2) * grad * grad;

        final mHat = m[j] / (1.0 - math.pow(beta1, t));
        final vHat = v[j] / (1.0 - math.pow(beta2, t));

        w[j] = (w[j] - alpha * (mHat / (math.sqrt(vHat) + adamEps)))
            .clamp(fsrs.lowerBoundsParameters[j], fsrs.upperBoundsParameters[j]);
      }

      final epochLoss = _computeObjective(
        sequences: sequences,
        candidate: w,
        baseline: baseline,
      );

      if (epochLoss < bestLoss) {
        bestLoss = epochLoss;
        bestW = List<double>.from(w);
      }
    }

    final optimizedMetrics = evaluateMetrics(
      sequences: sequences,
      parameters: bestW,
    );

    return FsrsOptimizationResult(
      optimizedParameters: bestW,
      baselineParameters: baseline,
      baselineMetrics: baselineMetrics,
      optimizedMetrics: optimizedMetrics,
      totalReviews: logs.length,
      optimizedAt: DateTime.now(),
    );
  }

  /// Spawns background isolate to run optimization without dropping any UI frames.
  static Future<FsrsOptimizationResult> optimizeAsync(
    List<ReviewLogModel> logs, {
    List<double>? currentWeights,
    int epochs = 35,
  }) async {
    return await Isolate.run(
      () => optimizeSync(
        logs,
        currentWeights: currentWeights,
        epochs: epochs,
      ),
    );
  }
}
