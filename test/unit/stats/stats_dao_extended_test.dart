import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/stats/data/stats_dao.dart';

void main() {
  late AppDatabase db;
  late StatsDao statsDao;
  late int deck1Id;
  late int deck2Id;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    statsDao = db.statsDao;

    deck1Id = await db.decksDao.createDeck(name: 'Deck 1');
    deck2Id = await db.decksDao.createDeck(name: 'Deck 2');
  });

  tearDown(() async {
    await db.close();
  });

  group('StatsDao Extended Analytics Tests', () {
    test(
      'getTrueRetention calculates young vs mature retention rates correctly',
      () async {
        final now = DateTime.now().toUtc();
        final card1 = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'F1',
          back: 'B1',
        );
        final card2 = await db.cardsDao.createCard(
          deckId: deck2Id,
          front: 'F2',
          back: 'B2',
        );

        // Empty check
        final empty = await statsDao.getTrueRetention();
        expect(empty.youngTotal, equals(0));
        expect(empty.matureTotal, equals(0));
        expect(empty.overallRate, equals(0.0));

        // Insert for Deck 1:
        // Young pass (< 21 days, rating >= 2)
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: card1,
                rating: 3,
                state: 2,
                due: now,
                stability: 5.0,
                difficulty: 5.0,
                elapsedDays: 5,
                lastElapsedDays: 5,
                scheduledDays: 10,
                reviewedAt: now,
              ),
            );
        // Young fail (< 21 days, rating 1)
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: card1,
                rating: 1,
                state: 1,
                due: now,
                stability: 1.0,
                difficulty: 6.0,
                elapsedDays: 3,
                lastElapsedDays: 3,
                scheduledDays: 1,
                reviewedAt: now,
              ),
            );
        // Mature pass (>= 21 days, rating 4)
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: card1,
                rating: 4,
                state: 2,
                due: now,
                stability: 40.0,
                difficulty: 4.0,
                elapsedDays: 30,
                lastElapsedDays: 30,
                scheduledDays: 50,
                reviewedAt: now,
              ),
            );

        // Insert for Deck 2:
        // Mature fail (>= 21 days, rating 1)
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: card2,
                rating: 1,
                state: 3,
                due: now,
                stability: 5.0,
                difficulty: 7.0,
                elapsedDays: 25,
                lastElapsedDays: 25,
                scheduledDays: 1,
                reviewedAt: now,
              ),
            );

        // Global query
        final global = await statsDao.getTrueRetention();
        expect(global.youngPassed, equals(1));
        expect(global.youngTotal, equals(2));
        expect(global.youngRate, closeTo(0.5, 0.01));

        expect(global.maturePassed, equals(1));
        expect(global.matureTotal, equals(2));
        expect(global.matureRate, closeTo(0.5, 0.01));

        expect(global.totalPassed, equals(2));
        expect(global.totalReviews, equals(4));
        expect(global.overallRate, closeTo(0.5, 0.01));

        // Deck 1 filtered query
        final deck1Stats = await statsDao.getTrueRetention(deckId: deck1Id);
        expect(deck1Stats.youngTotal, equals(2));
        expect(deck1Stats.youngPassed, equals(1));
        expect(deck1Stats.matureTotal, equals(1));
        expect(deck1Stats.maturePassed, equals(1));
        expect(deck1Stats.matureRate, closeTo(1.0, 0.01));
      },
    );

    test(
      'getIntervalDistribution groups cards into correct interval buckets',
      () async {
        final now = DateTime.now().toUtc();

        // Card 1: 4 days interval (Bucket 1: 1-7d)
        final c1 = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'F1',
          back: 'B1',
        );
        await (db.update(db.cards)..where((t) => t.id.equals(c1))).write(
          CardsCompanion(
            state: const drift.Value(2),
            due: drift.Value(now.add(const Duration(days: 4))),
            lastReview: drift.Value(now),
          ),
        );

        // Card 2: 15 days interval (Bucket 2: 8-30d)
        final c2 = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'F2',
          back: 'B2',
        );
        await (db.update(db.cards)..where((t) => t.id.equals(c2))).write(
          CardsCompanion(
            state: const drift.Value(2),
            due: drift.Value(now.add(const Duration(days: 15))),
            lastReview: drift.Value(now),
          ),
        );

        // Card 3: 60 days interval (Bucket 3: 31-90d)
        final c3 = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'F3',
          back: 'B3',
        );
        await (db.update(db.cards)..where((t) => t.id.equals(c3))).write(
          CardsCompanion(
            state: const drift.Value(2),
            due: drift.Value(now.add(const Duration(days: 60))),
            lastReview: drift.Value(now),
          ),
        );

        // Card 4: 150 days interval in Deck 2 (Bucket 4: 91-365d)
        final c4 = await db.cardsDao.createCard(
          deckId: deck2Id,
          front: 'F4',
          back: 'B4',
        );
        await (db.update(db.cards)..where((t) => t.id.equals(c4))).write(
          CardsCompanion(
            state: const drift.Value(2),
            due: drift.Value(now.add(const Duration(days: 150))),
            lastReview: drift.Value(now),
          ),
        );

        final globalDist = await statsDao.getIntervalDistribution();
        expect(globalDist.totalCards, equals(4));
        expect(globalDist.buckets.length, equals(5));
        expect(globalDist.buckets[0].label, contains('1-7'));
        expect(globalDist.buckets[0].count, equals(1));
        expect(globalDist.buckets[1].count, equals(1));
        expect(globalDist.buckets[2].count, equals(1));
        expect(globalDist.buckets[3].count, equals(1));
        expect(globalDist.buckets[4].count, equals(0)); // 365+d

        // Filtered deck 1
        final deck1Dist = await statsDao.getIntervalDistribution(
          deckId: deck1Id,
        );
        expect(deck1Dist.totalCards, equals(3));
        expect(deck1Dist.buckets[3].count, equals(0));
      },
    );

    test('getRatingBreakdown returns count and proportions for Again, Hard, Good, Easy', () async {
      final now = DateTime.now().toUtc();
      final c1 = await db.cardsDao.createCard(
        deckId: deck1Id,
        front: 'F1',
        back: 'B1',
      );

      // Empty check
      final empty = await statsDao.getRatingBreakdown();
      expect(empty.total, equals(0));
      expect(empty.againRate, equals(0.0));

      // 1 Again, 2 Hard, 3 Good, 4 Easy = 10 total
      Future<void> addLog(int rating) async {
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: c1,
                rating: rating,
                state: 2,
                due: now,
                stability: 1.0,
                difficulty: 5.0,
                elapsedDays: 1,
                lastElapsedDays: 1,
                scheduledDays: 1,
                reviewedAt: now,
              ),
            );
      }

      await addLog(1);
      await addLog(2);
      await addLog(2);
      await addLog(3);
      await addLog(3);
      await addLog(3);
      await addLog(4);
      await addLog(4);
      await addLog(4);
      await addLog(4);

      final breakdown = await statsDao.getRatingBreakdown();
      expect(breakdown.total, equals(10));
      expect(breakdown.againCount, equals(1));
      expect(breakdown.hardCount, equals(2));
      expect(breakdown.goodCount, equals(3));
      expect(breakdown.easyCount, equals(4));

      expect(breakdown.againRate, closeTo(0.1, 0.01));
      expect(breakdown.hardRate, closeTo(0.2, 0.01));
      expect(breakdown.goodRate, closeTo(0.3, 0.01));
      expect(breakdown.easyRate, closeTo(0.4, 0.01));
    });
  });
}
