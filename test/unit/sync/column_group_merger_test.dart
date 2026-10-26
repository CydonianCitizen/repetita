import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/sync/column_group_merger.dart';
import 'package:repetita/src/core/sync/hlc.dart';
import 'package:repetita/src/core/sync/sync_event.dart';

void main() {
  group('ColumnGroupMerger Unit Tests', () {
    late AppDatabase db;
    late ColumnGroupMerger merger;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      merger = ColumnGroupMerger(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('creates deck and card from incoming events', () async {
      final hlc1 = const Hlc(millis: 1000, counter: 0, nodeId: 'nodeA').pack();

      await merger.mergeEvents([
        DeckSyncEvent(
          globalId: 'deck_1',
          name: 'Neuroscience',
          description: 'Brain anatomy',
          updatedHlc: hlc1,
        ),
        CardSyncEvent(
          globalId: 'card_1',
          deckGlobalId: 'deck_1',
          front: 'What is a neuron?',
          back: 'A nerve cell',
          contentHlc: hlc1,
          scheduleHlc: hlc1,
          state: 0,
          stability: 0.0,
          difficulty: 0.0,
          due: DateTime.utc(2026, 1, 1),
          reps: 0,
          lapses: 0,
          isSuspended: false,
          easinessFactor: 2.5,
          flag: 0,
        ),
      ]);

      final decks = await db.select(db.decks).get();
      expect(decks, hasLength(1));
      expect(decks.first.name, 'Neuroscience');

      final cards = await db.select(db.cards).get();
      expect(cards, hasLength(1));
      expect(cards.first.front, 'What is a neuron?');
      expect(cards.first.globalId, 'card_1');
    });

    test('dual HLC merges concurrent content edit and schedule update without loss', () async {
      final hlcInitial = const Hlc(
        millis: 1000,
        counter: 0,
        nodeId: 'nodeA',
      ).pack();

      // 1. Initial card creation
      await merger.mergeEvents([
        DeckSyncEvent(
          globalId: 'deck_1',
          name: 'Languages',
          updatedHlc: hlcInitial,
        ),
        CardSyncEvent(
          globalId: 'card_1',
          deckGlobalId: 'deck_1',
          front: 'Bonjour typo',
          back: 'Hello',
          contentHlc: hlcInitial,
          scheduleHlc: hlcInitial,
          state: 0,
          stability: 0.0,
          difficulty: 0.0,
          due: DateTime.utc(2026, 1, 1),
          reps: 0,
          lapses: 0,
          isSuspended: false,
          easinessFactor: 2.5,
          flag: 0,
        ),
      ]);

      // 2. Mobile reviews card offline (advances scheduleHlc to 2000, keeps contentHlc at 1000)
      final hlcMobileReview = const Hlc(
        millis: 2000,
        counter: 0,
        nodeId: 'mobile',
      ).pack();
      await merger.applyCard(
        CardSyncEvent(
          globalId: 'card_1',
          deckGlobalId: 'deck_1',
          front: 'Bonjour typo',
          back: 'Hello',
          contentHlc: hlcInitial,
          scheduleHlc: hlcMobileReview,
          state: 2,
          stability: 4.5,
          difficulty: 3.1,
          due: DateTime.utc(2026, 1, 10),
          reps: 1,
          lapses: 0,
          isSuspended: false,
          easinessFactor: 2.5,
          flag: 0,
        ),
      );

      // Verify local card has new schedule
      var card = await (db.select(
        db.cards,
      )..where((t) => t.globalId.equals('card_1'))).getSingle();
      expect(card.state, 2);
      expect(card.stability, 4.5);
      expect(card.front, 'Bonjour typo');

      // 3. Desktop edits typo offline (advances contentHlc to 3000, but has old scheduleHlc at 1000)
      final hlcDesktopEdit = const Hlc(
        millis: 3000,
        counter: 0,
        nodeId: 'desktop',
      ).pack();
      await merger.applyCard(
        CardSyncEvent(
          globalId: 'card_1',
          deckGlobalId: 'deck_1',
          front: 'Bonjour (fixed)',
          back: 'Hello / Good morning',
          contentHlc: hlcDesktopEdit,
          scheduleHlc: hlcInitial, // Desktop didn't know about mobile review!
          state: 0,
          stability: 0.0,
          difficulty: 0.0,
          due: DateTime.utc(2026, 1, 1),
          reps: 0,
          lapses: 0,
          isSuspended: false,
          easinessFactor: 2.5,
          flag: 0,
        ),
      );

      // 4. Verification: BOTH changes survived!
      card = await (db.select(
        db.cards,
      )..where((t) => t.globalId.equals('card_1'))).getSingle();
      // Content updated from desktop
      expect(card.front, 'Bonjour (fixed)');
      expect(card.back, 'Hello / Good morning');
      expect(card.contentHlc, hlcDesktopEdit);

      // Schedule preserved from mobile review! Not clobbered by desktop's stale state=0!
      expect(card.state, 2);
      expect(card.stability, 4.5);
      expect(card.due.toUtc(), DateTime.utc(2026, 1, 10));
      expect(card.scheduleHlc, hlcMobileReview);
    });

    test('tombstones purge local entity and prevent resurrection', () async {
      final hlc1 = const Hlc(millis: 1000, counter: 0, nodeId: 'nodeA').pack();
      final hlcDelete = const Hlc(
        millis: 2000,
        counter: 0,
        nodeId: 'nodeA',
      ).pack();
      final hlcStale = const Hlc(
        millis: 1500,
        counter: 0,
        nodeId: 'nodeB',
      ).pack();

      // Create card
      await merger.mergeEvents([
        DeckSyncEvent(globalId: 'deck_1', name: 'Deck', updatedHlc: hlc1),
        CardSyncEvent(
          globalId: 'card_doomed',
          deckGlobalId: 'deck_1',
          front: 'Delete me',
          back: 'Please',
          contentHlc: hlc1,
          scheduleHlc: hlc1,
          state: 0,
          stability: 0.0,
          difficulty: 0.0,
          due: DateTime.utc(2026, 1, 1),
          reps: 0,
          lapses: 0,
          isSuspended: false,
          easinessFactor: 2.5,
          flag: 0,
        ),
      ]);

      expect(await db.select(db.cards).get(), hasLength(1));

      // Apply tombstone delete
      await merger.applyTombstone(
        TombstoneSyncEvent(
          globalId: 'card_doomed',
          deletedHlc: hlcDelete,
          entityType: 0,
        ),
      );

      // Card must be deleted locally
      expect(await db.select(db.cards).get(), isEmpty);

      // Offline peer tries to resurrect with older update
      await merger.applyCard(
        CardSyncEvent(
          globalId: 'card_doomed',
          deckGlobalId: 'deck_1',
          front: 'I am back from the dead!',
          back: 'Muahaha',
          contentHlc: hlcStale, // 1500 < 2000
          scheduleHlc: hlcStale,
          state: 0,
          stability: 0.0,
          difficulty: 0.0,
          due: DateTime.utc(2026, 1, 1),
          reps: 0,
          lapses: 0,
          isSuspended: false,
          easinessFactor: 2.5,
          flag: 0,
        ),
      );

      // Zombie card must NOT be resurrected
      expect(await db.select(db.cards).get(), isEmpty);
    });

    test('review logs are idempotently unioned', () async {
      final hlc = const Hlc(millis: 1000, counter: 0, nodeId: 'nodeA').pack();
      await merger.mergeEvents([
        DeckSyncEvent(globalId: 'deck_1', name: 'Deck', updatedHlc: hlc),
        CardSyncEvent(
          globalId: 'card_1',
          deckGlobalId: 'deck_1',
          front: 'Q',
          back: 'A',
          contentHlc: hlc,
          scheduleHlc: hlc,
          state: 0,
          stability: 0.0,
          difficulty: 0.0,
          due: DateTime.utc(2026, 1, 1),
          reps: 0,
          lapses: 0,
          isSuspended: false,
          easinessFactor: 2.5,
          flag: 0,
        ),
        ReviewLogSyncEvent(
          globalId: 'revlog_1',
          cardGlobalId: 'card_1',
          rating: 3,
          state: 2,
          due: DateTime.utc(2026, 1, 5),
          stability: 3.0,
          difficulty: 4.0,
          elapsedDays: 1,
          lastElapsedDays: 0,
          scheduledDays: 4,
          reviewedAt: DateTime.utc(2026, 1, 1, 12, 0),
          easinessFactor: 2.5,
        ),
      ]);

      expect(await db.select(db.reviewLogs).get(), hasLength(1));

      // Same log imported a second time is ignored
      await merger.applyReviewLog(
        ReviewLogSyncEvent(
          globalId: 'revlog_1',
          cardGlobalId: 'card_1',
          rating: 3,
          state: 2,
          due: DateTime.utc(2026, 1, 5),
          stability: 3.0,
          difficulty: 4.0,
          elapsedDays: 1,
          lastElapsedDays: 0,
          scheduledDays: 4,
          reviewedAt: DateTime.utc(2026, 1, 1, 12, 0),
          easinessFactor: 2.5,
        ),
      );

      expect(await db.select(db.reviewLogs).get(), hasLength(1));
    });
  });
}
