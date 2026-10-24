import 'package:drift/drift.dart';

import '../../../core/algorithms/fsrs/optimizer/fsrs_optimizer_models.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../domain/stats_models.dart';

part 'stats_dao.g.dart';

@DriftAccessor(tables: [Cards, ReviewLogs])
class StatsDao extends DatabaseAccessor<AppDatabase> with _$StatsDaoMixin {
  StatsDao(super.db);

  Future<CardStateCounts> getCardStateCounts({int? deckId}) async {
    final countCol = cards.id.count();
    final query = selectOnly(cards)
      ..addColumns([cards.state, countCol])
      ..groupBy([cards.state]);
    if (deckId != null) {
      query.where(cards.deckId.equals(deckId));
    }

    final rows = await query.get();
    int newCount = 0;
    int learningCount = 0;
    int reviewCount = 0;
    int relearningCount = 0;

    for (final row in rows) {
      final state = row.read(cards.state);
      final count = row.read(countCol) ?? 0;
      switch (state) {
        case 0:
          newCount = count;
        case 1:
          learningCount = count;
        case 2:
          reviewCount = count;
        case 3:
          relearningCount = count;
      }
    }

    return CardStateCounts(
      newCount: newCount,
      learningCount: learningCount,
      reviewCount: reviewCount,
      relearningCount: relearningCount,
    );
  }

  Future<double> getRetentionRate({int? deckId}) async {
    final total = await getTotalReviewsCount(deckId: deckId);
    if (total == 0) return 0.0;

    final countExp = reviewLogs.id.count();
    final successfulQuery = selectOnly(reviewLogs);
    if (deckId != null) {
      successfulQuery.join([
        innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId)),
      ]);
      successfulQuery.where(
        cards.deckId.equals(deckId) & reviewLogs.rating.isBiggerOrEqualValue(2),
      );
    } else {
      successfulQuery.where(reviewLogs.rating.isBiggerOrEqualValue(2));
    }
    successfulQuery.addColumns([countExp]);
    final successful =
        await successfulQuery.map((r) => r.read(countExp)).getSingle() ?? 0;
    return successful / total;
  }

  Future<int> getTotalReviewsCount({int? deckId}) async {
    if (deckId == null) {
      final countExp = reviewLogs.id.count();
      final query = selectOnly(reviewLogs)..addColumns([countExp]);
      final count = await query.map((r) => r.read(countExp)).getSingle();
      return count ?? 0;
    } else {
      final countExp = reviewLogs.id.count();
      final query =
          selectOnly(reviewLogs)
              .join([innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId))])
            ..where(cards.deckId.equals(deckId))
            ..addColumns([countExp]);
      final count = await query.map((r) => r.read(countExp)).getSingle();
      return count ?? 0;
    }
  }

  Future<List<ForecastDay>> getDueForecast({
    int? deckId,
    int days = 7,
    required DateTime fromDate,
  }) async {
    final fromUtc = fromDate.toUtc();
    final todayStart = DateTime.utc(fromUtc.year, fromUtc.month, fromUtc.day);
    final forecastEnd = todayStart.add(Duration(days: days));

    final countExpressions = <Expression<int>>[];
    for (int i = 0; i < days; i++) {
      final dayStart = todayStart.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayCondition = i == 0
          ? (cards.state.equals(0) | cards.due.isSmallerThanValue(dayEnd))
          : (cards.state.equals(0).not() &
                cards.due.isBiggerOrEqualValue(dayStart) &
                cards.due.isSmallerThanValue(dayEnd));

      countExpressions.add(cards.id.count(filter: dayCondition));
    }

    final overallCondition =
        cards.state.equals(0) | cards.due.isSmallerThanValue(forecastEnd);
    final query = selectOnly(cards)
      ..addColumns(countExpressions)
      ..where(
        deckId != null
            ? cards.deckId.equals(deckId) & overallCondition
            : overallCondition,
      );

    final row = await query.getSingle();

    return List.generate(days, (i) {
      final dayStart = todayStart.add(Duration(days: i));
      final count = row.read(countExpressions[i]) ?? 0;
      return ForecastDay(date: dayStart, count: count);
    });
  }

  Future<Map<DateTime, int>> getDailyReviewCounts({
    int? deckId,
    int days = 105,
    required DateTime toDate,
  }) async {
    final toUtc = toDate.toUtc();
    final endOfDay = DateTime.utc(
      toUtc.year,
      toUtc.month,
      toUtc.day,
      23,
      59,
      59,
      999,
    );
    final startDay = DateTime.utc(
      toUtc.year,
      toUtc.month,
      toUtc.day,
    ).subtract(Duration(days: days - 1));

    final query = selectOnly(reviewLogs);
    if (deckId != null) {
      query.join([innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId))]);
      query.where(
        cards.deckId.equals(deckId) &
            reviewLogs.reviewedAt.isBiggerOrEqualValue(startDay) &
            reviewLogs.reviewedAt.isSmallerOrEqualValue(endOfDay),
      );
    } else {
      query.where(
        reviewLogs.reviewedAt.isBiggerOrEqualValue(startDay) &
            reviewLogs.reviewedAt.isSmallerOrEqualValue(endOfDay),
      );
    }
    query.addColumns([reviewLogs.reviewedAt]);

    final rows = await query.get();
    final map = <DateTime, int>{};
    for (final row in rows) {
      final dt = row.read(reviewLogs.reviewedAt);
      if (dt != null) {
        final utc = dt.toUtc();
        final dayKey = DateTime.utc(utc.year, utc.month, utc.day);
        map[dayKey] = (map[dayKey] ?? 0) + 1;
      }
    }
    return map;
  }

  Future<int> getCurrentStreak({int? deckId, required DateTime today}) async {
    final todayUtc = DateTime.utc(today.year, today.month, today.day);
    // Streak cannot exceed 366 days; limit lookback to avoid full-table scan.
    final lookbackStart = todayUtc.subtract(const Duration(days: 366));

    final query = selectOnly(reviewLogs);
    if (deckId != null) {
      query.join([innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId))]);
      query.where(
        cards.deckId.equals(deckId) &
            reviewLogs.reviewedAt.isBiggerOrEqualValue(lookbackStart),
      );
    } else {
      query.where(reviewLogs.reviewedAt.isBiggerOrEqualValue(lookbackStart));
    }
    query.addColumns([reviewLogs.reviewedAt]);

    final rows = await query.get();
    final uniqueDays = <DateTime>{};
    for (final row in rows) {
      final dt = row.read(reviewLogs.reviewedAt);
      if (dt != null) {
        final utc = dt.toUtc();
        uniqueDays.add(DateTime.utc(utc.year, utc.month, utc.day));
      }
    }

    return calculateStreak(uniqueDays, today);
  }

  Future<int> getLeechCardsCount({int? deckId, int threshold = 8}) async {
    final countCol = cards.id.count();
    final query = selectOnly(cards)..addColumns([countCol]);
    final conditions = <Expression<bool>>[
      cards.lapses.isBiggerOrEqualValue(threshold),
    ];
    if (deckId != null) {
      conditions.add(cards.deckId.equals(deckId));
    }
    query.where(conditions.reduce((a, b) => a & b));
    final row = await query.getSingleOrNull();
    return row?.read(countCol) ?? 0;
  }

  Future<TrueRetentionData> getTrueRetention({int? deckId}) async {
    final youngPassedExp = reviewLogs.id.count(
      filter:
          reviewLogs.lastElapsedDays.isSmallerThanValue(21) &
          reviewLogs.rating.isBiggerOrEqualValue(2),
    );
    final youngTotalExp = reviewLogs.id.count(
      filter: reviewLogs.lastElapsedDays.isSmallerThanValue(21),
    );
    final maturePassedExp = reviewLogs.id.count(
      filter:
          reviewLogs.lastElapsedDays.isBiggerOrEqualValue(21) &
          reviewLogs.rating.isBiggerOrEqualValue(2),
    );
    final matureTotalExp = reviewLogs.id.count(
      filter: reviewLogs.lastElapsedDays.isBiggerOrEqualValue(21),
    );

    final query = selectOnly(reviewLogs)
      ..addColumns([
        youngPassedExp,
        youngTotalExp,
        maturePassedExp,
        matureTotalExp,
      ]);

    if (deckId != null) {
      query.join([innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId))]);
      query.where(cards.deckId.equals(deckId));
    }

    final row = await query.getSingleOrNull();
    if (row == null) {
      return const TrueRetentionData(
        youngPassed: 0,
        youngTotal: 0,
        maturePassed: 0,
        matureTotal: 0,
      );
    }

    return TrueRetentionData(
      youngPassed: row.read(youngPassedExp) ?? 0,
      youngTotal: row.read(youngTotalExp) ?? 0,
      maturePassed: row.read(maturePassedExp) ?? 0,
      matureTotal: row.read(matureTotalExp) ?? 0,
    );
  }

  Future<IntervalDistributionData> getIntervalDistribution({
    int? deckId,
  }) async {
    final query = select(cards)..where((c) => c.state.equals(2));
    if (deckId != null) {
      query.where((c) => c.deckId.equals(deckId));
    }
    final reviewCards = await query.get();
    if (reviewCards.isEmpty) {
      return const IntervalDistributionData(
        buckets: [
          IntervalBucket(label: '1-7 d', count: 0, percentage: 0),
          IntervalBucket(label: '8-30 d', count: 0, percentage: 0),
          IntervalBucket(label: '31-90 d', count: 0, percentage: 0),
          IntervalBucket(label: '91-365 d', count: 0, percentage: 0),
          IntervalBucket(label: '365+ d', count: 0, percentage: 0),
        ],
        totalCards: 0,
        averageIntervalDays: 0,
      );
    }

    int b1 = 0; // 1-7d
    int b2 = 0; // 8-30d
    int b3 = 0; // 31-90d
    int b4 = 0; // 91-365d
    int b5 = 0; // 365+d
    int totalIntervalDays = 0;

    for (final card in reviewCards) {
      int intervalDays = 1;
      if (card.lastReview != null) {
        intervalDays = card.due.difference(card.lastReview!).inDays;
        if (intervalDays < 1) intervalDays = 1;
      }
      totalIntervalDays += intervalDays;

      if (intervalDays <= 7) {
        b1++;
      } else if (intervalDays <= 30) {
        b2++;
      } else if (intervalDays <= 90) {
        b3++;
      } else if (intervalDays <= 365) {
        b4++;
      } else {
        b5++;
      }
    }

    final total = reviewCards.length;
    final avg = total > 0 ? (totalIntervalDays / total) : 0.0;

    return IntervalDistributionData(
      buckets: [
        IntervalBucket(
          label: '1-7 d',
          count: b1,
          percentage: total > 0 ? b1 / total : 0,
        ),
        IntervalBucket(
          label: '8-30 d',
          count: b2,
          percentage: total > 0 ? b2 / total : 0,
        ),
        IntervalBucket(
          label: '31-90 d',
          count: b3,
          percentage: total > 0 ? b3 / total : 0,
        ),
        IntervalBucket(
          label: '91-365 d',
          count: b4,
          percentage: total > 0 ? b4 / total : 0,
        ),
        IntervalBucket(
          label: '365+ d',
          count: b5,
          percentage: total > 0 ? b5 / total : 0,
        ),
      ],
      totalCards: total,
      averageIntervalDays: avg,
    );
  }

  Future<RatingBreakdownData> getRatingBreakdown({int? deckId}) async {
    final againExp = reviewLogs.id.count(filter: reviewLogs.rating.equals(1));
    final hardExp = reviewLogs.id.count(filter: reviewLogs.rating.equals(2));
    final goodExp = reviewLogs.id.count(filter: reviewLogs.rating.equals(3));
    final easyExp = reviewLogs.id.count(filter: reviewLogs.rating.equals(4));

    final query = selectOnly(reviewLogs)
      ..addColumns([againExp, hardExp, goodExp, easyExp]);

    if (deckId != null) {
      query.join([innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId))]);
      query.where(cards.deckId.equals(deckId));
    }

    final row = await query.getSingleOrNull();
    if (row == null) {
      return const RatingBreakdownData();
    }

    return RatingBreakdownData(
      againCount: row.read(againExp) ?? 0,
      hardCount: row.read(hardExp) ?? 0,
      goodCount: row.read(goodExp) ?? 0,
      easyCount: row.read(easyExp) ?? 0,
    );
  }

  Future<List<CardReviewHistory>> getCardReviewHistories() async {
    final rows = await (select(reviewLogs)
          ..orderBy([
            (t) => OrderingTerm.asc(t.cardId),
            (t) => OrderingTerm.asc(t.reviewedAt),
          ]))
        .get();

    final grouped = <int, List<ReviewHistoryItem>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.cardId, () => []).add(
            ReviewHistoryItem(
              rating: row.rating,
              elapsedDays: row.elapsedDays.toDouble(),
            ),
          );
    }

    return grouped.entries
        .map((e) => CardReviewHistory(cardId: e.key, reviews: e.value))
        .toList();
  }
}
