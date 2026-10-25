import 'dart:math';

import '../srs/srs_scheduler.dart';
import 'models/fsrs_card.dart';
import 'models/fsrs_models.dart';
import 'models/fsrs_parameters.dart';
import 'models/record_log.dart';
import 'stability_curve_calculator.dart';

class FsrsEngine implements SrsScheduler {
  const FsrsEngine([this.parameters = const FsrsParameters(), this.rng]);

  final FsrsParameters parameters;
  final Random? rng;

  static const double factor = 19.0 / 81.0;

  double retrievability(double elapsedDays, double stability) =>
      StabilityCurveCalculator.retrievability(elapsedDays, stability);

  double initStability(Rating rating) {
    return parameters.w[rating.value - 1];
  }

  double initDifficulty(Rating rating) {
    final d = parameters.w[4] - (rating.value - 3) * parameters.w[5];
    return d.clamp(1.0, 10.0);
  }

  double nextDifficulty(double d, Rating rating) {
    final deltaD = -parameters.w[6] * (rating.value - 3);
    final dPrime = d + deltaD;
    final d0Good = initDifficulty(Rating.good);
    final nextD = parameters.w[7] * d0Good + (1.0 - parameters.w[7]) * dPrime;
    return nextD.clamp(1.0, 10.0);
  }

  double nextRecallStability(double d, double s, double r, Rating rating) {
    final hardPenalty = rating == Rating.hard ? parameters.w[15] : 1.0;
    final easyBonus = rating == Rating.easy ? parameters.w[16] : 1.0;
    final sPower = pow(s, -parameters.w[9]).toDouble();
    final rFactor = exp(parameters.w[10] * (1.0 - r)) - 1.0;
    final nextS =
        s *
        (1.0 +
            exp(parameters.w[8]) *
                (11.0 - d) *
                sPower *
                rFactor *
                hardPenalty *
                easyBonus);
    return max(0.1, nextS);
  }

  double nextLapseStability(double d, double s, double r) {
    final dPower = pow(d, -parameters.w[12]).toDouble();
    final sPower = pow(s + 1.0, parameters.w[13]).toDouble() - 1.0;
    final rFactor = exp(parameters.w[14] * (1.0 - r));
    final lapseS = parameters.w[11] * dPower * sPower * rFactor;
    return min(s, lapseS).clamp(0.1, double.infinity);
  }

  int nextInterval(double s) {
    final interval = (s / factor * (pow(parameters.requestRetention, -2) - 1.0))
        .round();
    return interval.clamp(1, parameters.maximumInterval);
  }

  int calculateFuzzOffset(int interval) {
    if (!parameters.enableFuzz || interval < 3) return 0;
    final r = rng ?? Random();
    final maxOffset = max(1, (interval * 0.05).round());
    return r.nextInt(maxOffset * 2 + 1) - maxOffset;
  }

  @override
  RecordLog schedule(
    FsrsCard card,
    Rating rating,
    DateTime reviewTime, {
    bool applyFuzz = true,
  }) {
    final reviewTimeUtc = reviewTime.toUtc();
    final int elapsedDays;
    final double r;

    if (card.lastReview == null) {
      elapsedDays = 0;
      r = 1.0;
    } else {
      final diff = reviewTimeUtc.difference(card.lastReview!.toUtc());
      elapsedDays = max(0, diff.inDays);
      final elapsedSeconds = max(0, diff.inSeconds);
      final t = elapsedSeconds / 86400.0;
      r = retrievability(t, card.stability);
    }

    final double newStability;
    final double newDifficulty;
    final CardState newState;
    final int newReps;
    final int newLapses;

    switch (card.state) {
      case CardState.newCard:
        newStability = initStability(rating);
        newDifficulty = initDifficulty(rating);
        if (rating == Rating.again) {
          newState = CardState.learning;
          newReps = card.reps;
          newLapses = card.lapses + 1;
        } else {
          newState = CardState.review;
          newReps = card.reps + 1;
          newLapses = card.lapses;
        }

      case CardState.learning:
      case CardState.relearning:
        newDifficulty = nextDifficulty(card.difficulty, rating);
        if (rating == Rating.again) {
          newStability = initStability(Rating.again);
          newState = card.state;
          newReps = card.reps;
          newLapses = card.lapses + 1;
        } else {
          newStability = nextRecallStability(
            card.difficulty,
            card.stability,
            r,
            rating,
          );
          newState = CardState.review;
          newReps = card.reps + 1;
          newLapses = card.lapses;
        }

      case CardState.review:
        newDifficulty = nextDifficulty(card.difficulty, rating);
        if (rating == Rating.again) {
          newStability = nextLapseStability(card.difficulty, card.stability, r);
          newState = CardState.relearning;
          newReps = card.reps;
          newLapses = card.lapses + 1;
        } else {
          newStability = nextRecallStability(
            card.difficulty,
            card.stability,
            r,
            rating,
          );
          newState = CardState.review;
          newReps = card.reps + 1;
          newLapses = card.lapses;
        }
    }

    final baseInterval = nextInterval(newStability);
    final fuzzOffset = applyFuzz ? calculateFuzzOffset(baseInterval) : 0;
    final scheduledDays = (baseInterval + fuzzOffset).clamp(
      1,
      parameters.maximumInterval,
    );
    final due = reviewTimeUtc.add(Duration(days: scheduledDays));

    final updatedCard = FsrsCard(
      state: newState,
      stability: newStability,
      difficulty: newDifficulty,
      due: due,
      lastReview: reviewTimeUtc,
      reps: newReps,
      lapses: newLapses,
    );

    final log = ReviewLogSnapshot(
      rating: rating,
      state: card.state,
      due: card.due,
      stability: newStability,
      difficulty: newDifficulty,
      elapsedDays: elapsedDays,
      lastElapsedDays: card.lastReview == null ? 0 : elapsedDays,
      scheduledDays: scheduledDays,
      reviewedAt: reviewTimeUtc,
    );

    return RecordLog(card: updatedCard, log: log);
  }

  @override
  Map<Rating, RecordLog> repeat(FsrsCard card, DateTime reviewTime) {
    return <Rating, RecordLog>{
      Rating.again: schedule(card, Rating.again, reviewTime, applyFuzz: false),
      Rating.hard: schedule(card, Rating.hard, reviewTime, applyFuzz: false),
      Rating.good: schedule(card, Rating.good, reviewTime, applyFuzz: false),
      Rating.easy: schedule(card, Rating.easy, reviewTime, applyFuzz: false),
    };
  }
}
