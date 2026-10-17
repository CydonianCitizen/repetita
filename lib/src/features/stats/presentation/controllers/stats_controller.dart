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

    final results = await (
      dao.getCardStateCounts(deckId: deckId),
      dao.getRetentionRate(deckId: deckId),
      dao.getTotalReviewsCount(deckId: deckId),
      dao.getDueForecast(deckId: deckId, days: 7, fromDate: now),
      dao.getDailyReviewCounts(deckId: deckId, days: 105, toDate: now),
      dao.getCurrentStreak(deckId: deckId, today: now),
      dao.getLeechCardsCount(deckId: deckId),
    ).wait;

    return StatsData(
      stateCounts: results.$1,
      retentionRate: results.$2,
      totalReviews: results.$3,
      forecast: results.$4,
      dailyReviewCounts: results.$5,
      currentStreak: results.$6,
      leechCardsCount: results.$7,
    );
  }
}
