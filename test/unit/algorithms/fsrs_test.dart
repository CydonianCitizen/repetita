import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/fsrs_engine.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_card.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_models.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_parameters.dart';

void main() {
  const engine = FsrsEngine();
  final baseTime = DateTime.utc(2026, 1, 1, 12, 0, 0);

  group('FsrsEngine - Initial Scheduling (New Card)', () {
    final newCard = FsrsCard(due: baseTime);

    test('Rating.again transitions to learning with initial parameters', () {
      final record = engine.schedule(newCard, Rating.again, baseTime);
      final card = record.card;

      expect(card.state, equals(CardState.learning));
      expect(card.stability, equals(engine.parameters.w[0])); // 0.4
      expect(card.difficulty, closeTo(6.81, 0.01));
      expect(card.reps, equals(0));
      expect(card.lapses, equals(1));
      expect(card.lastReview, equals(baseTime));
      expect(card.due, equals(baseTime.add(const Duration(days: 1))));
      expect(record.log.rating, equals(Rating.again));
      expect(record.log.state, equals(CardState.newCard));
    });

    test('Rating.hard transitions to review', () {
      final record = engine.schedule(newCard, Rating.hard, baseTime);
      final card = record.card;

      expect(card.state, equals(CardState.review));
      expect(card.stability, equals(engine.parameters.w[1])); // 0.6
      expect(card.difficulty, closeTo(5.87, 0.01));
      expect(card.reps, equals(1));
      expect(card.lapses, equals(0));
      expect(card.lastReview, equals(baseTime));
    });

    test('Rating.good transitions to review', () {
      final record = engine.schedule(newCard, Rating.good, baseTime);
      final card = record.card;

      expect(card.state, equals(CardState.review));
      expect(card.stability, equals(engine.parameters.w[2])); // 2.4
      expect(card.difficulty, closeTo(4.93, 0.01));
      expect(card.reps, equals(1));
      expect(card.lapses, equals(0));
    });

    test('Rating.easy transitions to review', () {
      final record = engine.schedule(newCard, Rating.easy, baseTime);
      final card = record.card;

      expect(card.state, equals(CardState.review));
      expect(card.stability, equals(engine.parameters.w[3])); // 5.8
      expect(card.difficulty, closeTo(3.99, 0.01));
      expect(card.reps, equals(1));
      expect(card.lapses, equals(0));
    });

    test('Initial difficulty stays bounded in [1.0, 10.0]', () {
      const customParamsLow = FsrsParameters(
        w: <double>[
          0.4,
          0.6,
          2.4,
          5.8,
          -5.0,
          0.94,
          0.86,
          0.01,
          1.49,
          0.14,
          0.94,
          2.18,
          0.05,
          0.34,
          1.26,
          0.29,
          2.61,
        ],
      );
      const engineLow = FsrsEngine(customParamsLow);
      expect(engineLow.initDifficulty(Rating.easy), equals(1.0));

      const customParamsHigh = FsrsParameters(
        w: <double>[
          0.4,
          0.6,
          2.4,
          5.8,
          20.0,
          0.94,
          0.86,
          0.01,
          1.49,
          0.14,
          0.94,
          2.18,
          0.05,
          0.34,
          1.26,
          0.29,
          2.61,
        ],
      );
      const engineHigh = FsrsEngine(customParamsHigh);
      expect(engineHigh.initDifficulty(Rating.again), equals(10.0));
    });
  });

  group('FsrsEngine - Learning and Relearning Transitions', () {
    final learningCard = FsrsCard(
      state: CardState.learning,
      stability: 0.4,
      difficulty: 6.81,
      due: baseTime.add(const Duration(days: 1)),
      lastReview: baseTime,
      reps: 0,
      lapses: 1,
    );

    test('Learning card with Again stays learning and increments lapses', () {
      final reviewTime = baseTime.add(const Duration(days: 1));
      final record = engine.schedule(learningCard, Rating.again, reviewTime);

      expect(record.card.state, equals(CardState.learning));
      expect(record.card.lapses, equals(2));
      expect(record.card.reps, equals(0));
      expect(record.card.stability, equals(engine.parameters.w[0]));
    });

    test('Learning card with Good graduates to review', () {
      final reviewTime = baseTime.add(const Duration(days: 1));
      final record = engine.schedule(learningCard, Rating.good, reviewTime);

      expect(record.card.state, equals(CardState.review));
      expect(record.card.reps, equals(1));
      expect(record.card.lapses, equals(1));
      expect(record.card.stability, greaterThan(learningCard.stability));
    });

    final relearningCard = FsrsCard(
      state: CardState.relearning,
      stability: 1.5,
      difficulty: 7.0,
      due: baseTime.add(const Duration(days: 1)),
      lastReview: baseTime,
      reps: 3,
      lapses: 2,
    );

    test(
      'Relearning card with Again stays relearning and increments lapses',
      () {
        final reviewTime = baseTime.add(const Duration(days: 1));
        final record = engine.schedule(
          relearningCard,
          Rating.again,
          reviewTime,
        );

        expect(record.card.state, equals(CardState.relearning));
        expect(record.card.lapses, equals(3));
        expect(record.card.reps, equals(3));
      },
    );

    test('Relearning card with Good graduates to review', () {
      final reviewTime = baseTime.add(const Duration(days: 1));
      final record = engine.schedule(relearningCard, Rating.good, reviewTime);

      expect(record.card.state, equals(CardState.review));
      expect(record.card.reps, equals(4));
      expect(record.card.lapses, equals(2));
    });
  });

  group('FsrsEngine - Review State Transitions', () {
    final reviewCard = FsrsCard(
      state: CardState.review,
      stability: 5.0,
      difficulty: 5.0,
      due: baseTime.add(const Duration(days: 5)),
      lastReview: baseTime,
      reps: 2,
      lapses: 0,
    );

    final reviewTime = baseTime.add(const Duration(days: 5));

    test('Rating.again causes lapse and transitions to relearning', () {
      final record = engine.schedule(reviewCard, Rating.again, reviewTime);
      final card = record.card;

      expect(card.state, equals(CardState.relearning));
      expect(card.lapses, equals(1));
      expect(card.reps, equals(2)); // reps count successful reviews only
      expect(card.stability, lessThanOrEqualTo(reviewCard.stability));
      expect(card.difficulty, greaterThan(reviewCard.difficulty));
    });

    test('Rating.good recalls card and remains in review', () {
      final record = engine.schedule(reviewCard, Rating.good, reviewTime);
      final card = record.card;

      expect(card.state, equals(CardState.review));
      expect(card.lapses, equals(0));
      expect(card.reps, equals(3));
      expect(card.stability, greaterThan(reviewCard.stability));
    });

    test(
      'Rating.hard recalls card with hard penalty and remains in review',
      () {
        final recordHard = engine.schedule(reviewCard, Rating.hard, reviewTime);
        final recordGood = engine.schedule(reviewCard, Rating.good, reviewTime);

        expect(recordHard.card.state, equals(CardState.review));
        expect(recordHard.card.reps, equals(3));
        expect(recordHard.card.lapses, equals(0));
        expect(recordHard.card.stability, lessThan(recordGood.card.stability));
      },
    );

    test('Rating.easy recalls card with easy bonus and remains in review', () {
      final recordGood = engine.schedule(reviewCard, Rating.good, reviewTime);
      final recordEasy = engine.schedule(reviewCard, Rating.easy, reviewTime);

      expect(recordEasy.card.state, equals(CardState.review));
      expect(recordEasy.card.reps, equals(3));
      expect(recordEasy.card.lapses, equals(0));
      expect(recordEasy.card.stability, greaterThan(recordGood.card.stability));
    });
  });

  group('FsrsEngine - Retrievability & Intervals', () {
    test('Retrievability decays monotonically over elapsed time', () {
      const stability = 10.0;
      final r0 = engine.retrievability(0.0, stability);
      final r5 = engine.retrievability(5.0, stability);
      final r10 = engine.retrievability(10.0, stability);
      final r30 = engine.retrievability(30.0, stability);

      expect(r0, equals(1.0));
      expect(r10, closeTo(0.9, 0.0001)); // at t = S, R is exactly 90%
      expect(r5, greaterThan(r10));
      expect(r10, greaterThan(r30));
    });

    test('Retrievability handles boundary zero/negative values gracefully', () {
      expect(engine.retrievability(0.0, 0.0), equals(0.0));
      expect(engine.retrievability(-1.0, 5.0), equals(1.0));
      expect(engine.retrievability(5.0, -1.0), equals(0.0));
    });

    test('Interval clamping strictly enforces bounds [1, maximumInterval]', () {
      const customParams = FsrsParameters(maximumInterval: 30);
      const boundedEngine = FsrsEngine(customParams);

      expect(boundedEngine.nextInterval(0.001), equals(1));
      expect(boundedEngine.nextInterval(1000.0), equals(30));
      expect(engine.nextInterval(1000000.0), equals(36500));
    });
  });

  group('FsrsEngine - Determinism & Repeat Previews', () {
    test('Identical inputs produce exact identical output timestamps', () {
      final card = FsrsCard(
        state: CardState.review,
        stability: 12.5,
        difficulty: 4.8,
        due: baseTime,
        lastReview: baseTime.subtract(const Duration(days: 12)),
        reps: 4,
        lapses: 1,
      );

      final reviewTime = DateTime.utc(2026, 3, 15, 14, 30, 45);

      final result1 = engine.schedule(card, Rating.good, reviewTime);
      final result2 = engine.schedule(card, Rating.good, reviewTime);

      expect(result1, equals(result2));
      expect(result1.card.due, equals(result2.card.due));
      expect(result1.card.lastReview, equals(result2.card.lastReview));
      expect(result1.card.stability, equals(result2.card.stability));
      expect(result1.card.difficulty, equals(result2.card.difficulty));
    });

    test('repeat returns previews for all 4 ratings', () {
      final card = FsrsCard(due: baseTime);
      final previews = engine.repeat(card, baseTime);

      expect(previews.keys, containsAll(Rating.values));
      expect(previews[Rating.again]!.card.state, equals(CardState.learning));
      expect(previews[Rating.hard]!.card.state, equals(CardState.review));
      expect(previews[Rating.good]!.card.state, equals(CardState.review));
      expect(previews[Rating.easy]!.card.state, equals(CardState.review));
    });
  });

  group('Fsrs Models - copyWith, hashCode, and value checks', () {
    test('FsrsCard properties and equality work accurately', () {
      final card = FsrsCard(due: baseTime);
      final custom = FsrsCard(
        state: CardState.review,
        stability: 3.5,
        difficulty: 4.2,
        due: baseTime.add(const Duration(days: 3)),
        lastReview: baseTime,
        reps: 1,
        lapses: 0,
      );

      expect(custom.state, equals(CardState.review));
      expect(custom.stability, equals(3.5));
      expect(custom.difficulty, equals(4.2));
      expect(custom.reps, equals(1));
      expect(custom.lapses, equals(0));
      expect(custom == card, isFalse);
      expect(card.hashCode, isA<int>());
      expect(custom.hashCode, isA<int>());
    });

    test(
      'FsrsCard copyWith accurately duplicates or overrides every field',
      () {
        final card = FsrsCard(due: baseTime);
        final updated = card.copyWith(
          state: CardState.relearning,
          stability: 12.5,
          difficulty: 8.1,
          due: baseTime.add(const Duration(days: 10)),
          lastReview: baseTime,
          reps: 5,
          lapses: 2,
          easinessFactor: 2.1,
        );

        expect(updated.state, equals(CardState.relearning));
        expect(updated.stability, equals(12.5));
        expect(updated.difficulty, equals(8.1));
        expect(updated.due, equals(baseTime.add(const Duration(days: 10))));
        expect(updated.lastReview, equals(baseTime));
        expect(updated.reps, equals(5));
        expect(updated.lapses, equals(2));
        expect(updated.easinessFactor, equals(2.1));

        // No-arg copyWith returns identical fields
        final identicalCopy = updated.copyWith();
        expect(identicalCopy, equals(updated));
      },
    );

    test('ReviewLogSnapshot and RecordLog hashCode and equality work', () {
      final record = engine.schedule(
        FsrsCard(due: baseTime),
        Rating.good,
        baseTime,
      );
      expect(record.hashCode, isA<int>());
      expect(record.log.hashCode, isA<int>());
      expect(record.log == record.log, isTrue);
      expect(record == record, isTrue);
    });

    test('CardState and Rating enum values are correct', () {
      expect(CardState.newCard.value, equals(0));
      expect(CardState.learning.value, equals(1));
      expect(CardState.review.value, equals(2));
      expect(CardState.relearning.value, equals(3));

      expect(Rating.again.value, equals(1));
      expect(Rating.hard.value, equals(2));
      expect(Rating.good.value, equals(3));
      expect(Rating.easy.value, equals(4));
    });
  });

  group('FsrsEngine - Study-Ahead and Clamping Tests', () {
    test('retrievability clamps zero and negative elapsed days to 1.0', () {
      expect(engine.retrievability(0.0, 5.0), equals(1.0));
      expect(engine.retrievability(-1.0, 5.0), equals(1.0));
      expect(engine.retrievability(-100.0, 5.0), equals(1.0));
      expect(engine.retrievability(0.0, -1.0), equals(0.0));
    });

    test('schedule clamps negative review times to zero elapsed days and 1.0 retrievability', () {
      final card = FsrsCard(
        state: CardState.review,
        stability: 10.0,
        difficulty: 5.0,
        due: baseTime.add(const Duration(days: 10)),
        lastReview: baseTime,
        reps: 2,
        lapses: 0,
      );

      final sameTimeRecord = engine.schedule(card, Rating.good, baseTime);
      expect(sameTimeRecord.log.elapsedDays, equals(0));

      final pastTime = baseTime.subtract(const Duration(days: 2));
      final pastRecord = engine.schedule(card, Rating.good, pastTime);
      expect(pastRecord.log.elapsedDays, equals(0));
      expect(pastRecord.card.stability, greaterThan(0.0));
      expect(pastRecord.card.due.isAfter(pastTime), isTrue);
    });

    test('Study-ahead review calculates adjusted retrievability and schedules correctly', () {
      final reviewCard = FsrsCard(
        state: CardState.review,
        stability: 10.0,
        difficulty: 5.0,
        due: baseTime.add(const Duration(days: 10)),
        lastReview: baseTime,
        reps: 2,
        lapses: 0,
      );

      final earlyReviewTime = baseTime.add(const Duration(days: 2));
      final repeats = engine.repeat(reviewCard, earlyReviewTime);

      expect(
        repeats.keys,
        containsAll([Rating.again, Rating.hard, Rating.good, Rating.easy]),
      );

      final againRecord = repeats[Rating.again]!;
      expect(againRecord.card.state, equals(CardState.relearning));
      expect(againRecord.log.elapsedDays, equals(2));
      expect(againRecord.card.lapses, equals(1));

      final goodRecord = repeats[Rating.good]!;
      expect(goodRecord.card.state, equals(CardState.review));
      expect(goodRecord.log.elapsedDays, equals(2));
      expect(goodRecord.card.reps, equals(3));
      expect(goodRecord.card.stability, greaterThan(0.0));
      expect(goodRecord.card.due.isAfter(earlyReviewTime), isTrue);

      final rEarly = engine.retrievability(2.0, 10.0);
      expect(rEarly, greaterThan(0.90));
      expect(rEarly, closeTo(0.977, 0.01));
    });
  });
}
