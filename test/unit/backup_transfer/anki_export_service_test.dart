import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/backup_transfer/data/services/anki_export_service.dart';
import 'package:repetita/src/features/backup_transfer/data/services/anki_package_service.dart';

void main() {
  late AppDatabase db;
  late AnkiExportService exportService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    exportService = AnkiExportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AnkiExportService', () {
    test(
      'exports deck to .apkg and re-imports successfully with exact contents',
      () async {
        // 1. Create decks and cards
        final deckId = await db.decksDao.createDeck(
          name: 'Science::Physics',
          description: 'Physics concepts',
        );

        final card1Id = await db.cardsDao.createCard(
          deckId: deckId,
          front: 'What is force?',
          back: 'Mass times acceleration',
        );

        final card2Id = await db.cardsDao.createCard(
          deckId: deckId,
          front: 'Energy is {{c1::conserved}} in closed systems.',
          back: 'First law of thermodynamics',
          clozeIndex: 1,
        );

        final tagPhysics = await db.tagsDao.getOrCreateTag('Physics');
        await db.tagsDao.setCardTags(card1Id, [tagPhysics]);
        await db.tagsDao.setCardTags(card2Id, [tagPhysics]);

        // 2. Export deck to .apkg bytes
        final apkgBytes = await exportService.exportDeckToApkg(deckId);

        expect(apkgBytes, isNotEmpty);
        expect(apkgBytes.length, greaterThan(100));

        // 3. Clear database or import into second database
        final destDb = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final destImportService = AnkiPackageService(destDb);
          final result = await destImportService.importApkgBytes(apkgBytes);

          expect(result.cardsImported, equals(2));
          expect(result.decksCreated, greaterThanOrEqualTo(1));

          final importedDecks = await destDb.select(destDb.decks).get();
          expect(importedDecks, isNotEmpty);
          final importedCards = await destDb.cardsDao.getCardsByDeck(
            importedDecks.first.id,
          );
          expect(importedCards.length, equals(2));
          expect(
            importedCards.any((c) => c.front.contains('What is force?')),
            isTrue,
          );
          expect(
            importedCards.any((c) => c.front.contains('{{c1::conserved}}')),
            isTrue,
          );
        } finally {
          await destDb.close();
        }
      },
    );

    test('exports all decks when requested', () async {
      final deck1 = await db.decksDao.createDeck(name: 'Deck A');
      final deck2 = await db.decksDao.createDeck(name: 'Deck B');

      await db.cardsDao.createCard(deckId: deck1, front: 'A', back: 'B');
      await db.cardsDao.createCard(deckId: deck2, front: 'C', back: 'D');

      final apkgBytes = await exportService.exportAllToApkg();
      expect(apkgBytes, isNotEmpty);

      final destDb = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        final destImportService = AnkiPackageService(destDb);
        final result = await destImportService.importApkgBytes(apkgBytes);
        expect(result.cardsImported, equals(2));
        expect(result.decksCreated, equals(2));
      } finally {
        await destDb.close();
      }
    });

    test('exports deck with review cards and simultaneous revlogs', () async {
      final deckId = await db.decksDao.createDeck(name: 'Review Deck');
      final cardId = await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Q',
        back: 'A',
      );

      final now = DateTime.now();
      // Update card to review state (state = 2)
      await (db.update(db.cards)..where((c) => c.id.equals(cardId))).write(
        CardsCompanion(
          state: const Value(2),
          due: Value(now.add(const Duration(days: 4))),
        ),
      );

      // Insert two review logs with exact same timestamp
      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: cardId,
              rating: 3,
              state: 2,
              due: now.add(const Duration(days: 4)),
              stability: 2.0,
              difficulty: 5.0,
              elapsedDays: 1,
              lastElapsedDays: 0,
              scheduledDays: 4,
              reviewedAt: now,
            ),
          );
      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: cardId,
              rating: 4,
              state: 2,
              due: now.add(const Duration(days: 8)),
              stability: 4.0,
              difficulty: 4.5,
              elapsedDays: 4,
              lastElapsedDays: 4,
              scheduledDays: 8,
              reviewedAt: now,
            ),
          );

      final bytes = await exportService.exportDeckToApkg(
        deckId,
        includeRevlog: true,
      );
      expect(bytes, isNotEmpty);
    });
  });
}
