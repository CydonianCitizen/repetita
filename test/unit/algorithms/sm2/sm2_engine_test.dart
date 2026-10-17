import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_card.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_models.dart';
import 'package:repetita/src/core/algorithms/sm2/sm2_engine.dart';

void main() {
  group('Sm2Engine Unit Tests', () {
    const engine = Sm2Engine();
    final now = DateTime.utc(2026, 10, 14, 12, 0);

    test(
      'new card rated Good schedules 1 day review and maintains default EF',
      () {
        final card = FsrsCard(due: now);
        final result = engine.schedule(card, Rating.good, now);

        expect(result.card.state, CardState.review);
        expect(result.card.reps, 1);
        expect(result.card.lapses, 0);
        expect(result.card.easinessFactor, 2.5);
        expect(result.card.due, now.add(const Duration(days: 1)));
        expect(result.log.scheduledDays, 1);
        expect(result.log.rating, Rating.good);
      },
    );

    test(
      'new card rated Easy schedules 4 days review and increases EF by 0.1',
      () {
        final card = FsrsCard(due: now);
        final result = engine.schedule(card, Rating.easy, now);

        expect(result.card.state, CardState.review);
        expect(result.card.reps, 1);
        expect(result.card.lapses, 0);
        expect(result.card.easinessFactor, closeTo(2.6, 0.001));
        expect(result.card.due, now.add(const Duration(days: 4)));
        expect(result.log.scheduledDays, 4);
      },
    );

    test(
      'new card rated Hard schedules 1 day review and decreases EF by 0.14',
      () {
        final card = FsrsCard(due: now);
        final result = engine.schedule(card, Rating.hard, now);

        expect(result.card.state, CardState.review);
        expect(result.card.reps, 1);
        expect(result.card.lapses, 0);
        expect(result.card.easinessFactor, closeTo(2.36, 0.001));
        expect(result.card.due, now.add(const Duration(days: 1)));
        expect(result.log.scheduledDays, 1);
      },
    );

    test(
      'new card rated Again transitions to learning with 1 day interval',
      () {
        final card = FsrsCard(due: now);
        final result = engine.schedule(card, Rating.again, now);

        expect(result.card.state, CardState.learning);
        expect(result.card.reps, 0);
        expect(result.card.lapses, 1);
        expect(result.card.due, now.add(const Duration(days: 1)));
        expect(result.log.scheduledDays, 1);
      },
    );

    test(
      'second repetition schedules 6 days for Good, 4 for Hard, 8 for Easy',
      () {
        final card = FsrsCard(
          state: CardState.review,
          reps: 1,
          due: now,
          lastReview: now.subtract(const Duration(days: 1)),
          easinessFactor: 2.5,
        );

        final goodResult = engine.schedule(card, Rating.good, now);
        expect(goodResult.card.reps, 2);
        expect(goodResult.card.due, now.add(const Duration(days: 6)));
        expect(goodResult.log.scheduledDays, 6);

        final hardResult = engine.schedule(card, Rating.hard, now);
        expect(hardResult.card.reps, 2);
        expect(hardResult.card.due, now.add(const Duration(days: 4)));
        expect(hardResult.log.scheduledDays, 4);

        final easyResult = engine.schedule(card, Rating.easy, now);
        expect(easyResult.card.reps, 2);
        expect(easyResult.card.due, now.add(const Duration(days: 8)));
        expect(easyResult.log.scheduledDays, 8);
      },
    );

    test('third repetition scales previous interval by EF', () {
      final card = FsrsCard(
        state: CardState.review,
        reps: 2,
        due: now,
        lastReview: now.subtract(const Duration(days: 6)),
        easinessFactor: 2.5,
      );

      final result = engine.schedule(card, Rating.good, now);
      // 6 * 2.5 = 15 days
      expect(result.card.reps, 3);
      expect(result.card.due, now.add(const Duration(days: 15)));
      expect(result.log.scheduledDays, 15);
      expect(result.card.easinessFactor, 2.5);
    });

    test('third repetition Easy applies easy bonus multiplier', () {
      final card = FsrsCard(
        state: CardState.review,
        reps: 2,
        due: now,
        lastReview: now.subtract(const Duration(days: 6)),
        easinessFactor: 2.5,
      );

      final result = engine.schedule(card, Rating.easy, now);
      // EF' = 2.6
      // 6 * 2.6 * 1.3 = 20.28 -> 20 days
      expect(result.card.reps, 3);
      expect(result.card.due, now.add(const Duration(days: 20)));
      expect(result.log.scheduledDays, 20);
    });

    test('third repetition Hard applies 1.2x conservative scaling', () {
      final card = FsrsCard(
        state: CardState.review,
        reps: 2,
        due: now,
        lastReview: now.subtract(const Duration(days: 6)),
        easinessFactor: 2.5,
      );

      final result = engine.schedule(card, Rating.hard, now);
      // 6 * 1.2 = 7.2 -> 7 days
      expect(result.card.reps, 3);
      expect(result.card.due, now.add(const Duration(days: 7)));
      expect(result.log.scheduledDays, 7);
      expect(result.card.easinessFactor, closeTo(2.36, 0.001));
    });

    test('review card rated Again resets reps and enters relearning', () {
      final card = FsrsCard(
        state: CardState.review,
        reps: 4,
        lapses: 1,
        due: now,
        lastReview: now.subtract(const Duration(days: 20)),
        easinessFactor: 2.5,
      );

      final result = engine.schedule(card, Rating.again, now);

      expect(result.card.state, CardState.relearning);
      expect(result.card.reps, 0);
      expect(result.card.lapses, 2);
      expect(result.card.due, now.add(const Duration(days: 1)));
      expect(result.log.scheduledDays, 1);
      expect(result.card.lastReview, now);
    });

    test('EF never drops below minEasinessFactor (1.3)', () {
      var card = FsrsCard(due: now, easinessFactor: 1.4);

      // Multiple Hard / Again ratings that would push EF < 1.3
      for (var i = 0; i < 5; i++) {
        final res = engine.schedule(card, Rating.again, now);
        card = res.card;
      }

      expect(card.easinessFactor, 1.3);
    });

    test(
      'transition rule derives initial EF from FSRS difficulty if EF is unset',
      () {
        // D = 1.0 (easiest in FSRS) -> EF = 2.5
        final easyFsrs = FsrsCard(
          due: now,
          difficulty: 1.0,
          easinessFactor: 0.0,
        );
        final easyRes = engine.schedule(easyFsrs, Rating.good, now);
        expect(easyRes.card.easinessFactor, closeTo(2.5, 0.01));

        // D = 10.0 (hardest in FSRS) -> EF = 1.3
        final hardFsrs = FsrsCard(
          due: now,
          difficulty: 10.0,
          easinessFactor: 0.0,
        );
        final hardRes = engine.schedule(hardFsrs, Rating.good, now);
        expect(hardRes.card.easinessFactor, closeTo(1.3, 0.01));
      },
    );

    test('repeat returns a complete map of all ratings', () {
      final card = FsrsCard(due: now, state: CardState.review, reps: 2);
      final repeats = engine.repeat(card, now);

      expect(
        repeats.keys,
        containsAll([Rating.again, Rating.hard, Rating.good, Rating.easy]),
      );
      expect(repeats[Rating.again]!.card.state, CardState.relearning);
      expect(repeats[Rating.good]!.card.state, CardState.review);
    });

    test(
      'falls back to initialEasinessFactor when difficulty and EF are both 0.0',
      () {
        final blankCard = FsrsCard(
          due: now,
          difficulty: 0.0,
          easinessFactor: 0.0,
        );
        final res = engine.schedule(blankCard, Rating.good, now);
        expect(res.card.easinessFactor, equals(2.5));
      },
    );

    test(
      'handles reps >= 3 when lastReview is null or in the future gracefully',
      () {
        final cardWithoutLastReview = FsrsCard(
          due: now,
          state: CardState.review,
          reps: 3,
          lastReview: null,
          easinessFactor: 2.5,
        );
        final resNull = engine.schedule(
          cardWithoutLastReview,
          Rating.good,
          now,
        );
        // baseInterval falls back to 6 -> 6 * 2.5 = 15
        expect(resNull.card.due, equals(now.add(const Duration(days: 15))));

        final cardWithFutureLastReview = FsrsCard(
          due: now,
          state: CardState.review,
          reps: 3,
          lastReview: now.add(const Duration(days: 2)), // elapsed < 0
          easinessFactor: 2.5,
        );
        final resFuture = engine.schedule(
          cardWithFutureLastReview,
          Rating.good,
          now,
        );
        // baseInterval falls back to 6 -> 6 * 2.5 = 15
        expect(resFuture.card.due, equals(now.add(const Duration(days: 15))));
      },
    );

    test('custom Sm2Engine parameters configure initial and minimum EF', () {
      const customEngine = Sm2Engine(
        initialEasinessFactor: 2.8,
        minEasinessFactor: 1.5,
      );
      expect(customEngine.initialEasinessFactor, 2.8);
      expect(customEngine.minEasinessFactor, 1.5);

      final blankCard = FsrsCard(
        due: now,
        difficulty: 0.0,
        easinessFactor: 0.0,
      );
      final res = customEngine.schedule(blankCard, Rating.good, now);
      expect(res.card.easinessFactor, 2.8);

      var droppingCard = FsrsCard(due: now, easinessFactor: 1.6);
      for (var i = 0; i < 5; i++) {
        droppingCard = customEngine
            .schedule(droppingCard, Rating.again, now)
            .card;
      }
      expect(droppingCard.easinessFactor, equals(1.5));
    });
  });
}
