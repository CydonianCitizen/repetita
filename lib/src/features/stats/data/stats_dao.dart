import 'package:drift/drift.dart';

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
}
