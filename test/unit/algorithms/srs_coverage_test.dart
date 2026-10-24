import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/fsrs_engine.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_card.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_models.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_parameters.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/record_log.dart';
import 'package:repetita/src/core/algorithms/fsrs/optimizer/fsrs_optimizer_models.dart';
import 'package:repetita/src/core/algorithms/fsrs/stability_curve_calculator.dart';
import 'package:repetita/src/core/algorithms/sm2/sm2_engine.dart';
import 'package:repetita/src/features/settings/domain/srs_algorithm.dart';
import 'package:repetita/src/features/settings/presentation/controllers/fsrs_parameters_controller.dart';
import 'package:repetita/src/features/settings/presentation/controllers/srs_algorithm_controller.dart';
import 'package:repetita/src/features/study_session/presentation/controllers/srs_scheduler_provider.dart';

void main() {
  group('SRS Coverage & Boundary Tests', () {
    test('FsrsParameters weights encoding and decoding edge cases', () {
      final defaultJson = FsrsParameters.encodeWeights(
        FsrsParameters.defaultWeights,
      );
      expect(defaultJson, isNotEmpty);

      final decoded = FsrsParameters.decodeWeights(defaultJson);
      expect(decoded, isNotNull);
      expect(decoded!.length, equals(17));
      expect(decoded, equals(FsrsParameters.defaultWeights));

      // Malformed, null or empty inputs
      expect(FsrsParameters.decodeWeights(null), isNull);
      expect(FsrsParameters.decodeWeights(''), isNull);
      expect(FsrsParameters.decodeWeights('   '), isNull);
      expect(FsrsParameters.decodeWeights('not-a-json'), isNull);
      expect(FsrsParameters.decodeWeights('{"not": "a list"}'), isNull);
      expect(
        FsrsParameters.decodeWeights('[1.0, 2.0]'),
        isNull,
      ); // not 17 items

      // hasCustomWeights & copyWith
      const defaultParams = FsrsParameters();
      expect(defaultParams.hasCustomWeights, isFalse);

      final customWeights = List<double>.from(FsrsParameters.defaultWeights);
      customWeights[0] = 0.999;
      final customParams = defaultParams.copyWith(w: customWeights);
      expect(customParams.hasCustomWeights, isTrue);
      expect(customParams.w[0], equals(0.999));

      final retentionParams = defaultParams.copyWith(
        requestRetention: 0.85,
        maximumInterval: 100,
        enableFuzz: true,
      );
      expect(retentionParams.requestRetention, equals(0.85));
      expect(retentionParams.maximumInterval, equals(100));
      expect(retentionParams.enableFuzz, isTrue);
    });

    test('CurvePoint and StabilityCurveCalculator boundary tests', () {
      const p1 = CurvePoint(day: 5.0, retrievability: 0.9);
      const p2 = CurvePoint(day: 5.0, retrievability: 0.9);
      const p3 = CurvePoint(day: 6.0, retrievability: 0.9);
      const p4 = CurvePoint(day: 5.0, retrievability: 0.8);

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1 == p3, isFalse);
      expect(p1 == p4, isFalse);
      expect(p1 == Object(), isFalse);

      // StabilityCurveCalculator edge cases
      expect(StabilityCurveCalculator.retrievability(0.0, 10.0), equals(1.0));
      expect(StabilityCurveCalculator.retrievability(-5.0, 10.0), equals(1.0));
      expect(StabilityCurveCalculator.daysToRetention(1.0, 10.0), equals(0.0));
      expect(StabilityCurveCalculator.daysToRetention(0.0, 10.0), equals(0.0));
      expect(StabilityCurveCalculator.daysToRetention(0.9, 0.0), equals(0.0));
      expect(StabilityCurveCalculator.daysToRetention(0.9, -1.0), equals(0.0));
      expect(StabilityCurveCalculator.daysToHalfLife(10.0), greaterThan(0.0));

      final points = StabilityCurveCalculator.generateCurvePoints(
        stability: 10.0,
        pointCount: 6,
        maxDays: 10.0,
      );
      expect(points.length, equals(6));
      expect(points.first.retrievability, equals(1.0));

      // Boundary: stability <= 0.0
      final zeroPoints = StabilityCurveCalculator.generateCurvePoints(
        stability: 0.0,
        pointCount: 3,
      );
      expect(zeroPoints.length, equals(3));
      expect(zeroPoints.first.retrievability, equals(0.0));

      // Boundary: pointCount < 2 clamped
      final clampedPoints = StabilityCurveCalculator.generateCurvePoints(
        stability: 10.0,
        pointCount: 1,
      );
      expect(clampedPoints.length, equals(2));
    });

    test('Optimizer models serialization and progress calculations', () {
      const item = ReviewHistoryItem(rating: 3, elapsedDays: 2.5);
      final itemJson = item.toJson();
      expect(ReviewHistoryItem.fromJson(itemJson).rating, equals(3));
      expect(ReviewHistoryItem.fromJson(itemJson).elapsedDays, equals(2.5));

      const history = CardReviewHistory(cardId: 42, reviews: [item]);
      final historyJson = history.toJson();
      expect(CardReviewHistory.fromJson(historyJson).cardId, equals(42));
      expect(CardReviewHistory.fromJson(historyJson).reviews.length, equals(1));

      const progress = OptimizationProgress(
        iteration: 20,
        totalIterations: 40,
        currentLoss: 0.35,
        bestLoss: 0.30,
      );
      expect(progress.progressPercentage, equals(0.5));

      const zeroProgress = OptimizationProgress(
        iteration: 0,
        totalIterations: 0,
        currentLoss: 0.0,
        bestLoss: 0.0,
      );
      expect(zeroProgress.progressPercentage, equals(0.0));

      const result = OptimizationResult(
        weights: FsrsParameters.defaultWeights,
        initialLoss: 0.50,
        finalLoss: 0.40,
        improvementPercentage: 20.0,
        sampleCount: 500,
        iterationCount: 40,
      );
      final resultJson = result.toJson();
      final fromJson = OptimizationResult.fromJson(resultJson);
      expect(fromJson.sampleCount, equals(500));
      expect(fromJson.improvementPercentage, equals(20.0));
      expect(fromJson.iterationCount, equals(40));
    });

    test('FsrsCard and RecordLog value equality', () {
      final now = DateTime(2026, 1, 1);
      final card1 = FsrsCard(
        due: now,
        stability: 2.0,
        difficulty: 5.0,
        reps: 1,
        lapses: 0,
        state: CardState.review,
        lastReview: now,
      );
      final card2 = FsrsCard(
        due: now,
        stability: 2.0,
        difficulty: 5.0,
        reps: 1,
        lapses: 0,
        state: CardState.review,
        lastReview: now,
      );
      final card3 = card1.copyWith(reps: 2);

      expect(card1, equals(card2));
      expect(card1.hashCode, equals(card2.hashCode));
      expect(card1 == card3, isFalse);
      expect(card1 == Object(), isFalse);

      final snapshot1 = ReviewLogSnapshot(
        rating: Rating.good,
        state: CardState.review,
        due: now,
        stability: 2.0,
        difficulty: 5.0,
        elapsedDays: 1,
        lastElapsedDays: 0,
        scheduledDays: 1,
        reviewedAt: now,
      );
      final snapshot2 = ReviewLogSnapshot(
        rating: Rating.good,
        state: CardState.review,
        due: now,
        stability: 2.0,
        difficulty: 5.0,
        elapsedDays: 1,
        lastElapsedDays: 0,
        scheduledDays: 1,
        reviewedAt: now,
      );
      final snapshot3 = ReviewLogSnapshot(
        rating: Rating.easy,
        state: CardState.review,
        due: now,
        stability: 2.0,
        difficulty: 5.0,
        elapsedDays: 1,
        lastElapsedDays: 0,
        scheduledDays: 1,
        reviewedAt: now,
      );

      expect(snapshot1, equals(snapshot2));
      expect(snapshot1.hashCode, equals(snapshot2.hashCode));
      expect(snapshot1 == snapshot3, isFalse);
      expect(snapshot1 == Object(), isFalse);

      final recordLog1 = RecordLog(card: card1, log: snapshot1);
      final recordLog2 = RecordLog(card: card1, log: snapshot1);
      final recordLog3 = RecordLog(card: card1, log: snapshot3);

      expect(recordLog1, equals(recordLog2));
      expect(recordLog1.hashCode, equals(recordLog2.hashCode));
      expect(recordLog1 == recordLog3, isFalse);
      expect(recordLog1 == Object(), isFalse);
    });

    test('srsSchedulerProvider switches dynamically based on SrsAlgorithm', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final container = ProviderContainer(
        overrides: [
          srsAlgorithmControllerProvider.overrideWith(
            () => _MockAlgorithmNotifier(SrsAlgorithm.sm2),
          ),
          fsrsParametersControllerProvider.overrideWith(
            () => _MockFsrsParamsNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sm2Scheduler = container.read(srsSchedulerProvider);
      expect(sm2Scheduler, isA<Sm2Engine>());

      final fsrsContainer = ProviderContainer(
        overrides: [
          srsAlgorithmControllerProvider.overrideWith(
            () => _MockAlgorithmNotifier(SrsAlgorithm.fsrs),
          ),
          fsrsParametersControllerProvider.overrideWith(
            () => _MockFsrsParamsNotifier(),
          ),
        ],
      );
      addTearDown(fsrsContainer.dispose);

      final fsrsScheduler = fsrsContainer.read(srsSchedulerProvider);
      expect(fsrsScheduler, isA<FsrsEngine>());
    });
  });
}

class _MockAlgorithmNotifier extends SrsAlgorithmController {
  _MockAlgorithmNotifier(this.initialAlgorithm);
  final SrsAlgorithm initialAlgorithm;

  @override
  SrsAlgorithm build() => initialAlgorithm;
}

class _MockFsrsParamsNotifier extends FsrsParametersController {
  @override
  FsrsParameters build() => const FsrsParameters();
}
