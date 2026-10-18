import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/settings/domain/vacation_mode_service.dart';

void main() {
  late AppDatabase db;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'Vacation Deck');
  });

  tearDown(() async {
    await db.close();
  });

  group('Vacation Mode Tests', () {
    test('shiftDueDatesForVacation shifts review/learning cards and preserves new cards', () async {
      final now = DateTime.utc(2026, 6, 1, 10, 0, 0);

      // Card 1: New card (state = 0)
      final newCardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'New Front',
        back: 'New Back',
        now: now,
      );

      // Card 2: Review card (state = 2, due = now)
      final reviewCardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Review Front',
        back: 'Review Back',
        now: now,
      );
      await (db.update(db.cards)..where((tbl) => tbl.id.equals(reviewCardId)))
          .write(const CardsCompanion(state: Value(2)));

      // Card 3: Suspended review card (state = 2, isSuspended = true)
      final suspendedCardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Suspended Front',
        back: 'Suspended Back',
        now: now,
      );
      await (db.update(
        db.cards,
      )..where((tbl) => tbl.id.equals(suspendedCardId))).write(
        const CardsCompanion(state: Value(2), isSuspended: Value(true)),
      );

      // Card 4: Relearning card (state = 3, due = now)
      final relearningCardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Relearning Front',
        back: 'Relearning Back',
        now: now,
      );
      await (db.update(db.cards)
            ..where((tbl) => tbl.id.equals(relearningCardId)))
          .write(const CardsCompanion(state: Value(3)));

      // Shift by 7 days of vacation
      final shiftedCount = await db.cardsDao.shiftDueDatesForVacation(7);
      expect(
        shiftedCount,
        equals(2),
      ); // Both active review and relearning cards

      final newCard = await db.cardsDao.getCardById(newCardId);
      final reviewCard = await db.cardsDao.getCardById(reviewCardId);
      final suspendedCard = await db.cardsDao.getCardById(suspendedCardId);
      final relearningCard = await db.cardsDao.getCardById(relearningCardId);

      // New card due is UNCHANGED
      expect(newCard?.due.day, equals(now.day));

      // Review card due is shifted forward by 7 days
      expect(reviewCard?.due.day, equals(now.day + 7));

      // Relearning card due is shifted forward by 7 days
      expect(relearningCard?.due.day, equals(now.day + 7));

      // Suspended card due is UNCHANGED
      expect(suspendedCard?.due.day, equals(now.day));
    });

    test(
      'VacationModeService manages vacation activation and resumption',
      () async {
        final service = VacationModeService(db);

        expect(await service.isVacationActive(), isFalse);

        final startDate = DateTime.utc(2026, 7, 1);
        await service.startVacation(startDate);

        expect(await service.isVacationActive(), isTrue);

        // Resume 10 days later
        final endDate = DateTime.utc(2026, 7, 11);
        final shifted = await service.endVacation(resumeDate: endDate);

        expect(await service.isVacationActive(), isFalse);
        expect(shifted, greaterThanOrEqualTo(0));
      },
    );
  });
}
