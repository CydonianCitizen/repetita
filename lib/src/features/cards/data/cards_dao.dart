import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../domain/card_entity.dart';

part 'cards_dao.g.dart';

extension CardToEntity on Card {
  CardEntity toEntity() => CardEntity(
    id: id,
    deckId: deckId,
    front: front,
    back: back,
    state: state,
    stability: stability,
    difficulty: difficulty,
    due: due.toUtc(),
    lastReview: lastReview?.toUtc(),
    reps: reps,
    lapses: lapses,
    createdAt: createdAt.toUtc(),
    isSuspended: isSuspended,
    buriedUntil: buriedUntil?.toUtc(),
    clozeIndex: clozeIndex,
    easinessFactor: easinessFactor,
    flag: flag,
    noteId: noteId,
  );
}

@DriftAccessor(tables: [Cards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  Stream<List<Card>> watchCardsByDeck(int deckId, {int? limit, int? offset}) {
    final query = select(cards)
      ..where((t) => t.deckId.equals(deckId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.watch();
  }

  Future<List<Card>> getCardsByDeck(int deckId, {int? limit, int? offset}) {
    final query = select(cards)
      ..where((t) => t.deckId.equals(deckId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  static DateTime computeTomorrowMidnight([DateTime? now]) {
    final effective = now ?? DateTime.now();
    if (effective.isUtc) {
      final base = effective.add(const Duration(days: 1));
      return DateTime.utc(base.year, base.month, base.day);
    }
    final local = effective.toLocal();
    final tomorrowLocal = DateTime(local.year, local.month, local.day + 1);
    return tomorrowLocal.toUtc();
  }

  Future<int> createCard({
    required int deckId,
    required String front,
    required String back,
    int? clozeIndex,
    int? noteId,
    DateTime? now,
  }) {
    final effectiveNow = (now ?? DateTime.now()).toUtc();
    return into(cards).insert(
      CardsCompanion.insert(
        deckId: deckId,
        front: front.trim(),
        back: back.trim(),
        state: const Value(0),
        stability: const Value(0.0),
        difficulty: const Value(0.0),
        due: effectiveNow,
        reps: const Value(0),
        lapses: const Value(0),
        createdAt: Value(effectiveNow),
        isSuspended: const Value(false),
        clozeIndex: Value(clozeIndex),
        noteId: Value(noteId),
      ),
    );
  }

  Future<List<int>> createReversedCards({
    required int deckId,
    required String front,
    required String back,
    DateTime? now,
  }) {
    final effectiveNow = (now ?? DateTime.now()).toUtc();
    return transaction(() async {
      final noteId = effectiveNow.microsecondsSinceEpoch;
      final card1 = await createCard(
        deckId: deckId,
        front: front,
        back: back,
        noteId: noteId,
        now: effectiveNow,
      );
      final card2 = await createCard(
        deckId: deckId,
        front: back,
        back: front,
        noteId: noteId,
        now: effectiveNow,
      );
      return [card1, card2];
    });
  }

  Future<int> unburyDeckCards(int deckId) {
    return (update(cards)
          ..where((t) => t.deckId.equals(deckId) & t.buriedUntil.isNotNull()))
        .write(const CardsCompanion(buriedUntil: Value(null)));
  }

  Future<int> burySiblingCards({
    required int noteId,
    required int excludeCardId,
    DateTime? now,
  }) {
    final tomorrow = computeTomorrowMidnight(now);
    return (update(cards)
          ..where(
            (t) =>
                t.noteId.equals(noteId) &
                t.id.equals(excludeCardId).not() &
                t.isSuspended.equals(false),
          ))
        .write(CardsCompanion(buriedUntil: Value(tomorrow)));
  }

  Future<bool> updateCardContent({
    required int id,
    required String front,
    required String back,
  }) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(
          CardsCompanion(front: Value(front.trim()), back: Value(back.trim())),
        )
        .then((rows) => rows > 0);
  }

  Future<bool> setCardSuspended(int id, bool isSuspended) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(CardsCompanion(isSuspended: Value(isSuspended)))
        .then((rows) => rows > 0);
  }

  Future<bool> _buryCard(int id, DateTime until) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(CardsCompanion(buriedUntil: Value(until.toUtc())))
        .then((rows) => rows > 0);
  }

  Future<bool> buryCardUntilTomorrow(int id, [DateTime? now]) {
    return _buryCard(id, computeTomorrowMidnight(now));
  }

  Future<bool> unburyCard(int id) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(const CardsCompanion(buriedUntil: Value(null)))
        .then((rows) => rows > 0);
  }

  Future<Card?> getCardById(int id) {
    return (select(cards)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> setCardFlag(int id, int flag) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(CardsCompanion(flag: Value(flag)))
        .then((rows) => rows > 0);
  }

  Future<bool> setCardDueDate(int id, DateTime due) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(CardsCompanion(due: Value(due.toUtc())))
        .then((rows) => rows > 0);
  }

  Future<bool> resetCardProgress(int id) {
    final now = DateTime.now().toUtc();
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(
          CardsCompanion(
            state: const Value(0),
            reps: const Value(0),
            lapses: const Value(0),
            stability: const Value(0.0),
            difficulty: const Value(0.0),
            easinessFactor: const Value(2.5),
            due: Value(now),
            lastReview: const Value(null),
          ),
        )
        .then((rows) => rows > 0);
  }

  Future<int> duplicateCard(int id) async {
    final card = await getCardById(id);
    if (card == null) {
      throw ArgumentError('Card $id not found');
    }
    return createCard(
      deckId: card.deckId,
      front: card.front,
      back: card.back,
      clozeIndex: card.clozeIndex,
    );
  }

  Future<int> shiftDueDatesForVacation(int days) async {
    if (days <= 0) return 0;
    final seconds = days * 86400;
    return customUpdate(
      'UPDATE cards SET due = due + ? WHERE state IN (1, 2, 3) AND is_suspended = 0',
      variables: [Variable.withInt(seconds)],
      updates: {cards},
    );
  }

  Future<int> deleteCard(int id) {
    return (delete(cards)..where((t) => t.id.equals(id))).go();
  }
}
