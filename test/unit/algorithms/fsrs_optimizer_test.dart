import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_parameters.dart';
import 'package:repetita/src/core/algorithms/fsrs/optimizer/fsrs_optimizer.dart';
import 'package:repetita/src/core/algorithms/fsrs/optimizer/fsrs_optimizer_isolate.dart';
import 'package:repetita/src/core/algorithms/fsrs/optimizer/fsrs_optimizer_models.dart';

void main() {
  group('FsrsOptimizer Unit Tests', () {
    late List<CardReviewHistory> sampleHistories;

    setUp(() {
      // Create synthetic review histories representing varied retention patterns:
      // Card 1: Easy learning, retained consistently across multiple intervals
      // Card 2: Lapsed on interval 2, then recovered
      // Card 3: Difficult card, short intervals, recalled
      sampleHistories = [
        const CardReviewHistory(
          cardId: 1,
          reviews: [
            ReviewHistoryItem(rating: 3, elapsedDays: 0),
            ReviewHistoryItem(rating: 3, elapsedDays: 3),
            ReviewHistoryItem(rating: 4, elapsedDays: 8),
            ReviewHistoryItem(rating: 3, elapsedDays: 21),
          ],
        ),
        const CardReviewHistory(
          cardId: 2,
          reviews: [
            ReviewHistoryItem(rating: 3, elapsedDays: 0),
            ReviewHistoryItem(rating: 1, elapsedDays: 5), // lapsed
            ReviewHistoryItem(rating: 2, elapsedDays: 1),
            ReviewHistoryItem(rating: 3, elapsedDays: 4),
          ],
        ),
        const CardReviewHistory(
          cardId: 3,
          reviews: [
            ReviewHistoryItem(rating: 2, elapsedDays: 0),
            ReviewHistoryItem(rating: 2, elapsedDays: 2),
            ReviewHistoryItem(rating: 3, elapsedDays: 5),
          ],
        ),
      ];
    });

    test('calculateLoss computes positive binary cross-entropy loss', () {
      const optimizer = FsrsOptimizer();
      final loss = optimizer.calculateLoss(
        sampleHistories,
        FsrsParameters.defaultWeights,
      );

      expect(loss.isFinite, isTrue);
      expect(loss, greaterThan(0.0));
      expect(loss, lessThan(2.0));
    });

    test('clampWeights enforces physiologically valid bounds and monotonicity', () {
      const optimizer = FsrsOptimizer();
      final invalidWeights = List<double>.filled(17, -5.0);

      final clamped = optimizer.clampWeights(invalidWeights);

      expect(clamped.length, 17);
      // Monotonicity of initial stabilities
      expect(clamped[0], greaterThanOrEqualTo(0.1));
      expect(clamped[1], greaterThanOrEqualTo(clamped[0]));
      expect(clamped[2], greaterThanOrEqualTo(clamped[1]));
      expect(clamped[3], greaterThanOrEqualTo(clamped[2]));

      // Check bounds
      for (var i = 0; i < 17; i++) {
        final (minB, maxB) = FsrsOptimizer.bounds[i];
        expect(clamped[i], greaterThanOrEqualTo(minB));
        expect(clamped[i], lessThanOrEqualTo(maxB));
      }
    });

    test('optimize reduces or maintains binary cross-entropy loss', () {
      const optimizer = FsrsOptimizer(
        maxIterations: 15,
        learningRate: 0.04,
      );

      final result = optimizer.optimize(
        sampleHistories,
        initialWeights: FsrsParameters.defaultWeights,
      );

      expect(result.weights.length, 17);
      expect(result.sampleCount, 8); // (4-1) + (4-1) + (3-1) = 8 evaluable review transitions
      expect(result.finalLoss, lessThanOrEqualTo(result.initialLoss + 1e-6));
      expect(result.improvementPercentage, greaterThanOrEqualTo(0.0));
    });

    test('optimizeInIsolate executes optimization in background isolate and reports progress', () async {
      final progressUpdates = <OptimizationProgress>[];

      final result = await optimizeInIsolate(
        sampleHistories,
        initialWeights: FsrsParameters.defaultWeights,
        maxIterations: 10,
        learningRate: 0.04,
        onProgress: progressUpdates.add,
      );

      expect(result.weights.length, 17);
      expect(result.sampleCount, 8);
      expect(result.finalLoss.isFinite, isTrue);
      expect(progressUpdates, isNotEmpty);
      expect(progressUpdates.last.iteration, 10);
      expect(progressUpdates.last.progressPercentage, 1.0);
    });
  });
}
