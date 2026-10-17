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

class StatsData {
  const StatsData({
    required this.stateCounts,
    required this.retentionRate,
    required this.totalReviews,
    required this.forecast,
    this.dailyReviewCounts = const {},
    this.currentStreak = 0,
    this.leechCardsCount = 0,
  });

  final CardStateCounts stateCounts;
  final double retentionRate;
  final int totalReviews;
  final List<ForecastDay> forecast;
  final Map<DateTime, int> dailyReviewCounts;
  final int currentStreak;
  final int leechCardsCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsData &&
          runtimeType == other.runtimeType &&
          stateCounts == other.stateCounts &&
          retentionRate == other.retentionRate &&
          totalReviews == other.totalReviews &&
          currentStreak == other.currentStreak &&
          leechCardsCount == other.leechCardsCount;

  @override
  int get hashCode => Object.hash(
    stateCounts,
    retentionRate,
    totalReviews,
    forecast,
    dailyReviewCounts,
    currentStreak,
    leechCardsCount,
  );
}
