import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/cards/data/cards_dao.dart';

void main() {
  late AppDatabase db;
  late CardsDao cardsDao;
  late int deck1Id;
  late int deck2Id;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cardsDao = db.cardsDao;

    deck1Id = await db.decksDao.createDeck(name: 'Deck 1');
    deck2Id = await db.decksDao.createDeck(name: 'Deck 2');
  });

  tearDown(() async {
    await db.close();
  });

  group('CardsDao Unit Tests', () {
    test('createCard assigns correct initial FSRS default values', () async {
      final before = DateTime.now().toUtc();
      final cardId = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Question 1',
        back: 'Answer 1',
      );

      expect(cardId, greaterThan(0));

      final cards = await cardsDao.watchCardsByDeck(deck1Id).first;
      expect(cards, hasLength(1));

      final card = cards.first;
      expect(card.deckId, equals(deck1Id));
      expect(card.front, equals('Question 1'));
      expect(card.back, equals('Answer 1'));
      expect(card.state, equals(0)); // New
      expect(card.stability, equals(0.0));
      expect(card.difficulty, equals(0.0));
      expect(card.reps, equals(0));
      expect(card.lapses, equals(0));
      expect(card.lastReview, isNull);
      expect(card.due.difference(before).inSeconds.abs(), lessThanOrEqualTo(2));
    });

    test(
      'watchCardsByDeck filters by deck and orders by createdAt/id DESC',
      () async {
        final card1Id = await cardsDao.createCard(
          deckId: deck1Id,
          front: 'Card 1',
          back: 'Ans 1',
        );
        final card2Id = await cardsDao.createCard(
          deckId: deck1Id,
          front: 'Card 2',
          back: 'Ans 2',
        );
        await cardsDao.createCard(
          deckId: deck2Id,
          front: 'Deck 2 Card',
          back: 'Ans D2',
        );

        final deck1Cards = await cardsDao.watchCardsByDeck(deck1Id).first;
        expect(deck1Cards, hasLength(2));
        expect(deck1Cards[0].id, equals(card2Id)); // newest first
        expect(deck1Cards[1].id, equals(card1Id));

        final deck2Cards = await cardsDao.watchCardsByDeck(deck2Id).first;
        expect(deck2Cards, hasLength(1));
        expect(deck2Cards.first.front, equals('Deck 2 Card'));
      },
    );

    test('watchCardsByDeck emits updates when cards are inserted', () async {
      final stream = cardsDao.watchCardsByDeck(deck1Id);
      final expectation = expectLater(stream, emits(hasLength(1)));

      await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Stream Front',
        back: 'Stream Back',
      );

      await expectation;
    });

    test('StudySessionDao.fetchDueCards returns cards due before cutoff or in New state ordered by due ASC', () async {
      final now = DateTime.now().toUtc();

      // Card 1: Review card overdue (due 2 hours ago)
      final card1Id = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Overdue',
        back: 'Ans',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(card1Id))).write(
        CardsCompanion(
          state: const Value(2), // Review
          due: Value(now.subtract(const Duration(hours: 2))),
        ),
      );

      // Card 2: New card with future due date -> still due because state == 0
      final card2Id = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'New Card Future Due',
        back: 'Ans',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(card2Id))).write(
        CardsCompanion(
          state: const Value(0), // New
          due: Value(now.add(const Duration(days: 5))),
        ),
      );

      // Card 3: Review card due in 3 days -> NOT due
      final card3Id = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Future Review',
        back: 'Ans',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(card3Id))).write(
        CardsCompanion(
          state: const Value(2), // Review
          due: Value(now.add(const Duration(days: 3))),
        ),
      );

      final dueCards = await db.studySessionDao.fetchDueCards(
        deck1Id,
        cutoff: now,
      );
      expect(dueCards, hasLength(2));
      expect(dueCards[0].front, equals('Overdue'));
      expect(dueCards[1].front, equals('New Card Future Due'));
    });

    test('updateCardContent and deleteCard operate correctly', () async {
      final cardId = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Original Front',
        back: 'Original Back',
      );

      final updated = await cardsDao.updateCardContent(
        id: cardId,
        front: 'Modified Front',
        back: 'Modified Back',
      );
      expect(updated, isTrue);

      final cards = await cardsDao.watchCardsByDeck(deck1Id).first;
      expect(cards.first.front, equals('Modified Front'));
      expect(cards.first.back, equals('Modified Back'));

      final deleted = await cardsDao.deleteCard(cardId);
      expect(deleted, equals(1));

      final emptyCards = await cardsDao.watchCardsByDeck(deck1Id).first;
      expect(emptyCards, isEmpty);
    });

    test(
      'setCardSuspended updates isSuspended and filters out from due cards',
      () async {
        final now = DateTime.now().toUtc();
        final cardId = await cardsDao.createCard(
          deckId: deck1Id,
          front: 'Card to suspend',
          back: 'Answer',
        );

        var due = await db.studySessionDao.fetchDueCards(deck1Id, cutoff: now);
        expect(due, hasLength(1));

        await cardsDao.setCardSuspended(cardId, true);
        final cards = await cardsDao.watchCardsByDeck(deck1Id).first;
        expect(cards.first.isSuspended, isTrue);

        due = await db.studySessionDao.fetchDueCards(deck1Id, cutoff: now);
        expect(due, isEmpty);

        await cardsDao.setCardSuspended(cardId, false);
        due = await db.studySessionDao.fetchDueCards(deck1Id, cutoff: now);
        expect(due, hasLength(1));
      },
    );

    test(
      'buryCard sets buriedUntil and filters out from due cards until unburied',
      () async {
        final now = DateTime.now().toUtc();
        final cardId = await cardsDao.createCard(
          deckId: deck1Id,
          front: 'Card to bury',
          back: 'Answer',
        );

        final tomorrow = CardsDao.computeTomorrowMidnight(now);
        await cardsDao.buryCardUntilTomorrow(cardId, now);

        final cards = await cardsDao.watchCardsByDeck(deck1Id).first;
        expect(cards.first.buriedUntil, isNotNull);

        var due = await db.studySessionDao.fetchDueCards(deck1Id, cutoff: now);
        expect(due, isEmpty);

        // After tomorrow, it should be due again
        due = await db.studySessionDao.fetchDueCards(
          deck1Id,
          cutoff: tomorrow.add(const Duration(hours: 1)),
        );
        expect(due, hasLength(1));

        // Explicit unbury
        await cardsDao.unburyCard(cardId);
        due = await db.studySessionDao.fetchDueCards(deck1Id, cutoff: now);
        expect(due, hasLength(1));
      },
    );

    test(
      'buryCardUntilTomorrow calculates midnight tomorrow and buries card',
      () async {
        final now = DateTime.utc(2026, 10, 12, 14, 30);
        final cardId = await cardsDao.createCard(
          deckId: deck1Id,
          front: 'Card midnight',
          back: 'Answer',
        );

        await cardsDao.buryCardUntilTomorrow(cardId, now);

        final cards = await cardsDao.watchCardsByDeck(deck1Id).first;
        expect(
          cards.first.buriedUntil?.toUtc(),
          equals(DateTime.utc(2026, 10, 13, 0, 0)),
        );
      },
    );

    test('createReversedCards creates pair with shared noteId and swapped front/back', () async {
      final now = DateTime.utc(2026, 10, 18, 10, 0);
      final cardIds = await cardsDao.createReversedCards(
        deckId: deck1Id,
        front: 'Capital of France',
        back: 'Paris',
        now: now,
      );

      expect(cardIds, hasLength(2));
      final card1 = await cardsDao.getCardById(cardIds[0]);
      final card2 = await cardsDao.getCardById(cardIds[1]);

      expect(card1, isNotNull);
      expect(card2, isNotNull);
      expect(card1!.noteId, isNotNull);
      expect(card2!.noteId, equals(card1.noteId));
      expect(card1.front, equals('Capital of France'));
      expect(card1.back, equals('Paris'));
      expect(card2.front, equals('Paris'));
      expect(card2.back, equals('Capital of France'));
      expect(card1.deckId, equals(deck1Id));
      expect(card2.deckId, equals(deck1Id));
    });

    test('burySiblingCards buries siblings with same noteId except active card', () async {
      final now = DateTime.utc(2026, 10, 18, 10, 0);
      final cardIds = await cardsDao.createReversedCards(
        deckId: deck1Id,
        front: 'Question A',
        back: 'Answer A',
        now: now,
      );

      final card1 = await cardsDao.getCardById(cardIds[0]);
      final card2 = await cardsDao.getCardById(cardIds[1]);

      final count = await cardsDao.burySiblingCards(
        noteId: card1!.noteId!,
        excludeCardId: card1.id,
        now: now,
      );

      expect(count, equals(1));

      final c1 = await cardsDao.getCardById(card1.id);
      final c2 = await cardsDao.getCardById(card2!.id);

      expect(c1!.buriedUntil, isNull);
      expect(c2!.buriedUntil, isNotNull);
      expect(c2.buriedUntil!.toUtc(), equals(DateTime.utc(2026, 10, 19, 0, 0)));
    });

    test('unburyDeckCards clears buriedUntil for all cards in deck', () async {
      final now = DateTime.utc(2026, 10, 18, 10, 0);
      final cardIds = await cardsDao.createReversedCards(
        deckId: deck1Id,
        front: 'Question B',
        back: 'Answer B',
        now: now,
      );

      await cardsDao.buryCardUntilTomorrow(cardIds[0], now);
      await cardsDao.buryCardUntilTomorrow(cardIds[1], now);

      final count = await cardsDao.unburyDeckCards(deck1Id);
      expect(count, equals(2));

      final deckCards = await cardsDao.watchCardsByDeck(deck1Id).first;
      for (final card in deckCards) {
        expect(card.buriedUntil, isNull);
      }
    });
  });
}
