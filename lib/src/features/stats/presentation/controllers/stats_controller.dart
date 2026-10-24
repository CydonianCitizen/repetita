import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/stats_models.dart';

part 'stats_controller.g.dart';

@riverpod
class StatsController extends _$StatsController {
  @override
  FutureOr<StatsData> build({int? deckId}) async {
    final dao = ref.watch(statsDaoProvider);
    final now = DateTime.now().toUtc();

    final (
      stateCounts,
      retentionRate,
      totalReviews,
      forecast,
      dailyReviewCounts,
    ) = await (
      dao.getCardStateCounts(deckId: deckId),
      dao.getRetentionRate(deckId: deckId),
      dao.getTotalReviewsCount(deckId: deckId),
      dao.getDueForecast(deckId: deckId, days: 7, fromDate: now),
      dao.getDailyReviewCounts(deckId: deckId, days: 105, toDate: now),
    ).wait;

    final (
      currentStreak,
      leechCardsCount,
      trueRetention,
      intervalDistribution,
      ratingBreakdown,
    ) = await (
      dao.getCurrentStreak(deckId: deckId, today: now),
      dao.getLeechCardsCount(deckId: deckId),
      dao.getTrueRetention(deckId: deckId),
      dao.getIntervalDistribution(deckId: deckId),
      dao.getRatingBreakdown(deckId: deckId),
    ).wait;

    return StatsData(
      stateCounts: stateCounts,
      retentionRate: retentionRate,
      totalReviews: totalReviews,
      forecast: forecast,
      dailyReviewCounts: dailyReviewCounts,
      currentStreak: currentStreak,
      leechCardsCount: leechCardsCount,
      trueRetention: trueRetention,
      intervalDistribution: intervalDistribution,
      ratingBreakdown: ratingBreakdown,
    );
  }
}
