import 'package:drift/drift.dart';

import '../../../core/algorithms/fsrs/models/fsrs_card.dart';
import '../../../core/algorithms/fsrs/models/record_log.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../domain/models/custom_study_config.dart';

part 'study_session_dao.g.dart';

@DriftAccessor(tables: [Cards, ReviewLogs, CardTags])
class StudySessionDao extends DatabaseAccessor<AppDatabase>
    with _$StudySessionDaoMixin {
  StudySessionDao(super.db);

  Future<List<Card>> fetchDueCards(
    int deckId, {
    required DateTime cutoff,
    int limit = 200,
  }) => fetchDueCardsForDecks([deckId], cutoff: cutoff, limit: limit);

  Future<List<Card>> fetchDueCardsForDecks(
    List<int> deckIds, {
    required DateTime cutoff,
    int limit = 200,
  }) {
    final cutoffUtc = cutoff.toUtc();
    return (select(cards)
          ..where(
            (t) =>
                t.deckId.isIn(deckIds) &
                t.isSuspended.equals(false) &
                (t.buriedUntil.isNull() |
                    t.buriedUntil.isSmallerOrEqualValue(cutoffUtc)) &
                (t.due.isSmallerOrEqualValue(cutoffUtc) | t.state.equals(0)),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.due),
            (t) => OrderingTerm.asc(t.id),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<Card>> fetchCustomStudyCards({
    required int deckId,
    required DateTime now,
    required CustomStudyScope scope,
    int? tagId,
    int daysAhead = 1,
    int limit = 200,
  }) async {
    final nowUtc = now.toUtc();
    final baseCondition =
        cards.deckId.equals(deckId) &
        cards.isSuspended.equals(false) &
        (cards.buriedUntil.isNull() |
            cards.buriedUntil.isSmallerOrEqualValue(nowUtc));

    switch (scope) {
      case CustomStudyScope.allCards:
        return (select(cards)
              ..where((t) => baseCondition)
              ..orderBy([
                (t) => OrderingTerm.asc(t.due),
                (t) => OrderingTerm.asc(t.id),
              ])
              ..limit(limit))
            .get();

      case CustomStudyScope.reviewAhead:
        final aheadCutoff = nowUtc.add(Duration(days: daysAhead));
        return (select(cards)
              ..where(
                (t) =>
                    baseCondition &
                    (t.due.isSmallerOrEqualValue(aheadCutoff) |
                        t.state.equals(0)),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.due),
                (t) => OrderingTerm.asc(t.id),
              ])
              ..limit(limit))
            .get();

      case CustomStudyScope.byTag:
        if (tagId == null) {
          return (select(cards)
                ..where((t) => baseCondition)
                ..orderBy([
                  (t) => OrderingTerm.asc(t.due),
                  (t) => OrderingTerm.asc(t.id),
                ])
                ..limit(limit))
              .get();
        }
        final query =
            select(
                cards,
                distinct: true,
              ).join([innerJoin(cardTags, cardTags.cardId.equalsExp(cards.id))])
              ..where(baseCondition & cardTags.tagId.equals(tagId))
              ..orderBy([
                OrderingTerm.asc(cards.due),
                OrderingTerm.asc(cards.id),
              ])
              ..limit(limit);
        final rows = await query.get();
        return rows.map((r) => r.readTable(cards)).toList();
    }
  }

  Future<int> recordReview({
    required int cardId,
    required FsrsCard updatedCard,
    required ReviewLogSnapshot logSnapshot,
  }) {
    return transaction(() async {
      await (update(cards)..where((t) => t.id.equals(cardId))).write(
        CardsCompanion(
          state: Value(updatedCard.state.value),
          stability: Value(updatedCard.stability),
          difficulty: Value(updatedCard.difficulty),
          due: Value(updatedCard.due),
          lastReview: Value(updatedCard.lastReview),
          reps: Value(updatedCard.reps),
          lapses: Value(updatedCard.lapses),
          easinessFactor: Value(updatedCard.easinessFactor),
        ),
      );

      final logId = await into(reviewLogs).insert(
        ReviewLogsCompanion.insert(
          cardId: cardId,
          rating: logSnapshot.rating.value,
          state: logSnapshot.state.value,
          due: logSnapshot.due,
          stability: logSnapshot.stability,
          difficulty: logSnapshot.difficulty,
          elapsedDays: logSnapshot.elapsedDays,
          lastElapsedDays: logSnapshot.lastElapsedDays,
          scheduledDays: logSnapshot.scheduledDays,
          reviewedAt: logSnapshot.reviewedAt,
          easinessFactor: Value(logSnapshot.easinessFactor),
        ),
      );

      return logId;
    });
  }

  Future<void> undoReview({
    required int cardId,
    required FsrsCard previousCard,
    required int reviewLogId,
  }) {
    return transaction(() async {
      await (update(cards)..where((t) => t.id.equals(cardId))).write(
        CardsCompanion(
          state: Value(previousCard.state.value),
          stability: Value(previousCard.stability),
          difficulty: Value(previousCard.difficulty),
          due: Value(previousCard.due),
          lastReview: Value(previousCard.lastReview),
          reps: Value(previousCard.reps),
          lapses: Value(previousCard.lapses),
          easinessFactor: Value(previousCard.easinessFactor),
        ),
      );

      await (delete(reviewLogs)..where((t) => t.id.equals(reviewLogId))).go();
    });
  }
}
