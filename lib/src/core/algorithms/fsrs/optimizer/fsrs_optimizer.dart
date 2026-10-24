import 'dart:math';

import '../models/fsrs_parameters.dart';
import 'fsrs_optimizer_models.dart';

/// Pure Dart On-Device FSRS Parameter Optimizer using Binary Cross-Entropy loss
/// and Adam optimization with central difference numerical gradients.
class FsrsOptimizer {
  const FsrsOptimizer({
    this.maxIterations = 40,
    this.learningRate = 0.04,
    this.beta1 = 0.9,
    this.beta2 = 0.999,
    this.epsilon = 1e-8,
    this.gradientStep = 1e-4,
  });

  final int maxIterations;
  final double learningRate;
  final double beta1;
  final double beta2;
  final double epsilon;
  final double gradientStep;

  /// Parameter bounds for the 17 FSRS weights.
  static const List<(double, double)> bounds = [
    (0.1, 10.0), // w0: S_0(Again)
    (0.1, 10.0), // w1: S_0(Hard)
    (0.5, 20.0), // w2: S_0(Good)
    (1.0, 50.0), // w3: S_0(Easy)
    (1.0, 10.0), // w4: Initial base difficulty
    (0.05, 4.0), // w5: Initial difficulty rating delta
    (0.01, 3.0), // w6: Difficulty update delta
    (0.001, 0.5), // w7: Mean reversion weight
    (0.01, 3.0), // w8: Recall stability base exponent
    (0.01, 0.8), // w9: Recall stability S exponent
    (0.01, 2.5), // w10: Recall stability R factor
    (0.01, 5.0), // w11: Lapse stability multiplier
    (0.01, 1.0), // w12: Lapse stability D exponent
    (0.01, 1.0), // w13: Lapse stability S exponent
    (0.01, 3.0), // w14: Lapse stability R factor
    (0.1, 1.0), // w15: Hard penalty
    (1.0, 6.0), // w16: Easy bonus
  ];

  /// Enforces valid parameter bounds and monotonicity of initial stabilities.
  List<double> clampWeights(List<double> w) {
    assert(w.length == 17, 'FSRS requires exactly 17 parameter weights');
    final clamped = List<double>.filled(17, 0.0);

    for (var i = 0; i < 17; i++) {
      final (minB, maxB) = bounds[i];
      clamped[i] = w[i].clamp(minB, maxB);
    }

    // Monotonicity for initial stabilities: S_0(1) <= S_0(2) <= S_0(3) <= S_0(4)
    clamped[0] = clamped[0].clamp(0.1, 10.0);
    clamped[1] = max(clamped[0], clamped[1]);
    clamped[2] = max(clamped[1], clamped[2]);
    clamped[3] = max(clamped[2], clamped[3]);

    return clamped;
  }

  /// Counts the total number of evaluable review transitions across histories.
  int countEvaluableSamples(List<CardReviewHistory> histories) {
    var count = 0;
    for (final h in histories) {
      if (h.reviews.length > 1) {
        count += h.reviews.length - 1;
      }
    }
    return count;
  }

  /// Calculates the Binary Cross-Entropy loss across all card review histories:
  /// L = - (1/N) * sum [ y_i * ln(R_i) + (1 - y_i) * ln(1 - R_i) ]
  double calculateLoss(List<CardReviewHistory> histories, List<double> w) {
    const factor = 19.0 / 81.0;
    var totalLoss = 0.0;
    var count = 0;

    for (final history in histories) {
      if (history.reviews.length < 2) continue;

      final first = history.reviews[0];
      final firstRating = first.rating.clamp(1, 4);

      var s = w[firstRating - 1];
      var d = (w[4] - (firstRating - 3) * w[5]).clamp(1.0, 10.0);

      for (var i = 1; i < history.reviews.length; i++) {
        final review = history.reviews[i];
        final t = max(0.0, review.elapsedDays);

        // Retrievability: R(t, S) = (1 + factor * t / S)^(-0.5)
        var r = pow(1.0 + factor * (t / s), -0.5).toDouble();
        r = r.clamp(1e-6, 1.0 - 1e-6);

        final y = review.rating > 1 ? 1.0 : 0.0;
        final bce = -(y * log(r) + (1.0 - y) * log(1.0 - r));
        totalLoss += bce;
        count++;

        // Update difficulty
        final rating = review.rating.clamp(1, 4);
        final deltaD = -w[6] * (rating - 3);
        final dPrime = d + deltaD;
        final d0Good = (w[4] - (3 - 3) * w[5]).clamp(1.0, 10.0);
        d = (w[7] * d0Good + (1.0 - w[7]) * dPrime).clamp(1.0, 10.0);

        // Update stability
        if (rating == 1) {
          final dPower = pow(d, -w[12]).toDouble();
          final sPower = pow(s + 1.0, w[13]).toDouble() - 1.0;
          final rFactor = exp(w[14] * (1.0 - r));
          final lapseS = w[11] * dPower * sPower * rFactor;
          s = min(s, lapseS).clamp(0.1, 36500.0);
        } else {
          final hardPenalty = rating == 2 ? w[15] : 1.0;
          final easyBonus = rating == 4 ? w[16] : 1.0;
          final sPower = pow(s, -w[9]).toDouble();
          final rFactor = exp(w[10] * (1.0 - r)) - 1.0;
          final nextS = s *
              (1.0 +
                  exp(w[8]) *
                      (11.0 - d) *
                      sPower *
                      rFactor *
                      hardPenalty *
                      easyBonus);
          s = max(0.1, nextS).clamp(0.1, 36500.0);
        }
      }
    }

    if (count == 0) return 0.0;
    return totalLoss / count;
  }

  /// Computes numerical gradients using central differences:
  /// g_j = (L(w + h * e_j) - L(w - h * e_j)) / (2 * h)
  List<double> computeGradients(
    List<CardReviewHistory> histories,
    List<double> w,
  ) {
    final gradients = List<double>.filled(17, 0.0);
    final wTemp = List<double>.from(w);

    for (var j = 0; j < 17; j++) {
      final orig = wTemp[j];

      wTemp[j] = orig + gradientStep;
      final lossPlus = calculateLoss(histories, clampWeights(wTemp));

      wTemp[j] = orig - gradientStep;
      final lossMinus = calculateLoss(histories, clampWeights(wTemp));

      wTemp[j] = orig;

      gradients[j] = (lossPlus - lossMinus) / (2.0 * gradientStep);
      if (gradients[j].isNaN || gradients[j].isInfinite) {
        gradients[j] = 0.0;
      }
    }

    return gradients;
  }

  /// Runs the optimization process with Adam optimizer.
  OptimizationResult optimize(
    List<CardReviewHistory> histories, {
    List<double> initialWeights = FsrsParameters.defaultWeights,
    void Function(OptimizationProgress)? onProgress,
  }) {
    final sampleCount = countEvaluableSamples(histories);
    if (sampleCount == 0) {
      return OptimizationResult(
        weights: List<double>.from(initialWeights),
        initialLoss: 0.0,
        finalLoss: 0.0,
        improvementPercentage: 0.0,
        sampleCount: 0,
        iterationCount: 0,
      );
    }

    var currentWeights = clampWeights(initialWeights);
    final initialLoss = calculateLoss(histories, currentWeights);

    var bestLoss = initialLoss;
    var bestWeights = List<double>.from(currentWeights);

    final m = List<double>.filled(17, 0.0);
    final v = List<double>.filled(17, 0.0);

    for (var iter = 1; iter <= maxIterations; iter++) {
      final gradients = computeGradients(histories, currentWeights);

      // Adam parameter update step
      for (var j = 0; j < 17; j++) {
        m[j] = beta1 * m[j] + (1.0 - beta1) * gradients[j];
        v[j] = beta2 * v[j] + (1.0 - beta2) * gradients[j] * gradients[j];

        final mHat = m[j] / (1.0 - pow(beta1, iter));
        final vHat = v[j] / (1.0 - pow(beta2, iter));

        currentWeights[j] -= learningRate * mHat / (sqrt(vHat) + epsilon);
      }

      currentWeights = clampWeights(currentWeights);
      final currentLoss = calculateLoss(histories, currentWeights);

      if (currentLoss < bestLoss) {
        bestLoss = currentLoss;
        bestWeights = List<double>.from(currentWeights);
      }

      onProgress?.call(
        OptimizationProgress(
          iteration: iter,
          totalIterations: maxIterations,
          currentLoss: currentLoss,
          bestLoss: bestLoss,
        ),
      );
    }

    final improvement = initialLoss > 0.0
        ? ((initialLoss - bestLoss) / initialLoss * 100.0).clamp(0.0, 100.0)
        : 0.0;

    return OptimizationResult(
      weights: bestWeights,
      initialLoss: initialLoss,
      finalLoss: bestLoss,
      improvementPercentage: improvement,
      sampleCount: sampleCount,
      iterationCount: maxIterations,
    );
  }
}
