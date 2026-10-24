class CardStateCounts {
  const CardStateCounts({
    this.newCount = 0,
    this.learningCount = 0,
    this.reviewCount = 0,
    this.relearningCount = 0,
  });

  final int newCount;
  final int learningCount;
  final int reviewCount;
  final int relearningCount;

  int get total => newCount + learningCount + reviewCount + relearningCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardStateCounts &&
          runtimeType == other.runtimeType &&
          newCount == other.newCount &&
          learningCount == other.learningCount &&
          reviewCount == other.reviewCount &&
          relearningCount == other.relearningCount;

  @override
  int get hashCode =>
      Object.hash(newCount, learningCount, reviewCount, relearningCount);
}

class ForecastDay {
  const ForecastDay({required this.date, required this.count});

  final DateTime date;
  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForecastDay &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          count == other.count;

  @override
  int get hashCode => Object.hash(date, count);
}

int calculateStreak(Set<DateTime> reviewDates, DateTime today) {
  if (reviewDates.isEmpty) return 0;
  final todayUtc = DateTime.utc(today.year, today.month, today.day);
  final yesterdayUtc = todayUtc.subtract(const Duration(days: 1));

  DateTime currentDay;
  if (reviewDates.contains(todayUtc)) {
    currentDay = todayUtc;
  } else if (reviewDates.contains(yesterdayUtc)) {
    currentDay = yesterdayUtc;
  } else {
    return 0;
  }

  int streak = 0;
  while (reviewDates.contains(currentDay)) {
    streak++;
    currentDay = currentDay.subtract(const Duration(days: 1));
  }
  return streak;
}

class TrueRetentionData {
  const TrueRetentionData({
    required this.youngPassed,
    required this.youngTotal,
    required this.maturePassed,
    required this.matureTotal,
  });

  final int youngPassed;
  final int youngTotal;
  final int maturePassed;
  final int matureTotal;

  double get youngRate => youngTotal > 0 ? (youngPassed / youngTotal) : 0.0;
  double get matureRate => matureTotal > 0 ? (maturePassed / matureTotal) : 0.0;
  int get totalPassed => youngPassed + maturePassed;
  int get totalReviews => youngTotal + matureTotal;
  double get overallRate =>
      totalReviews > 0 ? (totalPassed / totalReviews) : 0.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrueRetentionData &&
          runtimeType == other.runtimeType &&
          youngPassed == other.youngPassed &&
          youngTotal == other.youngTotal &&
          maturePassed == other.maturePassed &&
          matureTotal == other.matureTotal;

  @override
  int get hashCode =>
      Object.hash(youngPassed, youngTotal, maturePassed, matureTotal);
}

class IntervalBucket {
  const IntervalBucket({
    required this.label,
    required this.count,
    required this.percentage,
  });

  final String label;
  final int count;
  final double percentage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalBucket &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          count == other.count &&
          percentage == other.percentage;

  @override
  int get hashCode => Object.hash(label, count, percentage);
}

class IntervalDistributionData {
  const IntervalDistributionData({
    required this.buckets,
    required this.totalCards,
    required this.averageIntervalDays,
  });

  final List<IntervalBucket> buckets;
  final int totalCards;
  final double averageIntervalDays;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalDistributionData &&
          runtimeType == other.runtimeType &&
          totalCards == other.totalCards &&
          averageIntervalDays == other.averageIntervalDays;

  @override
  int get hashCode => Object.hash(totalCards, averageIntervalDays);
}

class RatingBreakdownData {
  const RatingBreakdownData({
    this.againCount = 0,
    this.hardCount = 0,
    this.goodCount = 0,
    this.easyCount = 0,
  });

  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;

  int get total => againCount + hardCount + goodCount + easyCount;
  double get againRate => total > 0 ? againCount / total : 0.0;
  double get hardRate => total > 0 ? hardCount / total : 0.0;
  double get goodRate => total > 0 ? goodCount / total : 0.0;
  double get easyRate => total > 0 ? easyCount / total : 0.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatingBreakdownData &&
          runtimeType == other.runtimeType &&
          againCount == other.againCount &&
          hardCount == other.hardCount &&
          goodCount == other.goodCount &&
          easyCount == other.easyCount;

  @override
  int get hashCode => Object.hash(againCount, hardCount, goodCount, easyCount);
}

class StatsData {
  const StatsData({
    required this.stateCounts,
    required this.retentionRate,
    required this.totalReviews,
    required this.forecast,
    this.dailyReviewCounts = const {},
    this.currentStreak = 0,
    this.leechCardsCount = 0,
    this.trueRetention = const TrueRetentionData(
      youngPassed: 0,
      youngTotal: 0,
      maturePassed: 0,
      matureTotal: 0,
    ),
    this.intervalDistribution = const IntervalDistributionData(
      buckets: [],
      totalCards: 0,
      averageIntervalDays: 0,
    ),
    this.ratingBreakdown = const RatingBreakdownData(),
  });

  final CardStateCounts stateCounts;
  final double retentionRate;
  final int totalReviews;
  final List<ForecastDay> forecast;
  final Map<DateTime, int> dailyReviewCounts;
  final int currentStreak;
  final int leechCardsCount;
  final TrueRetentionData trueRetention;
  final IntervalDistributionData intervalDistribution;
  final RatingBreakdownData ratingBreakdown;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsData &&
          runtimeType == other.runtimeType &&
          stateCounts == other.stateCounts &&
          retentionRate == other.retentionRate &&
          totalReviews == other.totalReviews &&
          currentStreak == other.currentStreak &&
          leechCardsCount == other.leechCardsCount &&
          trueRetention == other.trueRetention &&
          intervalDistribution == other.intervalDistribution &&
          ratingBreakdown == other.ratingBreakdown;

  @override
  int get hashCode => Object.hash(
    stateCounts,
    retentionRate,
    totalReviews,
    forecast,
    dailyReviewCounts,
    currentStreak,
    leechCardsCount,
    trueRetention,
    intervalDistribution,
    ratingBreakdown,
  );
}
