import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/sync/directory_sync_storage_adapter.dart';
import 'package:repetita/src/core/sync/file_based_sync_service.dart';
import 'package:repetita/src/core/sync/hlc.dart';
import 'package:repetita/src/core/sync/sync_event.dart';

void main() {
  group('FileBasedSyncService Full 2-Node Sync Test', () {
    late Directory sharedSyncDir;
    late AppDatabase dbA;
    late AppDatabase dbB;
    late DirectorySyncStorageAdapter storageA;
    late DirectorySyncStorageAdapter storageB;
    late FileBasedSyncService syncA;
    late FileBasedSyncService syncB;

    setUp(() {
      sharedSyncDir = Directory.systemTemp.createTempSync(
        'repetita_sync_test_',
      );

      dbA = AppDatabase.forTesting(NativeDatabase.memory());
      dbB = AppDatabase.forTesting(NativeDatabase.memory());

      storageA = DirectorySyncStorageAdapter(
        rootDir: sharedSyncDir,
        ownDeviceId: 'node_A',
      );
      storageB = DirectorySyncStorageAdapter(
        rootDir: sharedSyncDir,
        ownDeviceId: 'node_B',
      );

      syncA = FileBasedSyncService(
        db: dbA,
        storage: storageA,
        localDeviceId: 'node_A',
      );
      syncB = FileBasedSyncService(
        db: dbB,
        storage: storageB,
        localDeviceId: 'node_B',
      );
    });

    tearDown(() async {
      await dbA.close();
      await dbB.close();
      if (sharedSyncDir.existsSync()) {
        sharedSyncDir.deleteSync(recursive: true);
      }
    });

    test(
      'Node A creates deck & card, Node B pulls and incorporates them',
      () async {
        final hlc1 = const Hlc(
          millis: 1000,
          counter: 0,
          nodeId: 'node_A',
        ).pack();

        // Node A creates deck and card in its database
        await dbA
            .into(dbA.decks)
            .insert(
              DecksCompanion.insert(
                name: 'Computer Science',
                globalId: const Value('deck_cs_1'),
                updatedHlc: Value(hlc1),
              ),
            );

        final deck = await (dbA.select(
          dbA.decks,
        )..where((t) => t.globalId.equals('deck_cs_1'))).getSingle();

        await dbA
            .into(dbA.cards)
            .insert(
              CardsCompanion.insert(
                deckId: deck.id,
                deckGlobalId: const Value('deck_cs_1'),
                front: 'What is a binary tree?',
                back: 'A tree where each node has at most two children',
                due: DateTime.utc(2026, 1, 1),
                globalId: const Value('card_bt_1'),
                contentHlc: Value(hlc1),
                scheduleHlc: Value(hlc1),
              ),
            );

        // Node A runs sync (creates its snapshot epoch mailbox)
        final resA = await syncA.sync();
        expect(resA.success, isTrue);

        // Node B starts completely empty
        expect(await dbB.select(dbB.decks).get(), isEmpty);
        expect(await dbB.select(dbB.cards).get(), isEmpty);

        // Node B runs sync
        final resB = await syncB.sync();
        expect(resB.success, isTrue);
        expect(resB.peersSynced, 1);
        expect(resB.eventsPulled, greaterThan(0));

        // Node B now has the deck and card!
        final bDecks = await dbB.select(dbB.decks).get();
        expect(bDecks, hasLength(1));
        expect(bDecks.first.name, 'Computer Science');
        expect(bDecks.first.globalId, 'deck_cs_1');

        final bCards = await dbB.select(dbB.cards).get();
        expect(bCards, hasLength(1));
        expect(bCards.first.front, 'What is a binary tree?');
        expect(bCards.first.globalId, 'card_bt_1');
      },
    );

    test('Incremental sync: Node B reviews card, Node A pulls incremental review via byte offset', () async {
      final hlc1 = const Hlc(millis: 1000, counter: 0, nodeId: 'node_A').pack();

      // Initial card creation on A
      await dbA
          .into(dbA.decks)
          .insert(
            DecksCompanion.insert(
              name: 'Math',
              globalId: const Value('deck_math'),
              updatedHlc: Value(hlc1),
            ),
          );
      final deckA = await dbA.select(dbA.decks).getSingle();
      await dbA
          .into(dbA.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckA.id,
              deckGlobalId: const Value('deck_math'),
              front: '2 + 2?',
              back: '4',
              due: DateTime.utc(2026, 1, 1),
              globalId: const Value('card_math_1'),
              contentHlc: Value(hlc1),
              scheduleHlc: Value(hlc1),
            ),
          );

      // A syncs -> B syncs
      await syncA.sync();
      await syncB.sync();

      // Node B reviews card offline
      final hlcReview = const Hlc(
        millis: 2000,
        counter: 0,
        nodeId: 'node_B',
      ).pack();
      final cardB = await (dbB.select(
        dbB.cards,
      )..where((t) => t.globalId.equals('card_math_1'))).getSingle();

      // Emit incremental review log and card schedule update on B
      await syncB.emitLocalEvent(
        ReviewLogSyncEvent(
          globalId: 'revlog_b_1',
          cardGlobalId: 'card_math_1',
          rating: 4,
          state: 2,
          due: DateTime.utc(2026, 1, 15),
          stability: 6.0,
          difficulty: 2.5,
          elapsedDays: 1,
          lastElapsedDays: 0,
          scheduledDays: 14,
          reviewedAt: DateTime.utc(2026, 1, 1, 15, 0),
          easinessFactor: 2.5,
        ),
      );
      await syncB.emitLocalEvent(
        CardSyncEvent(
          globalId: cardB.globalId,
          deckGlobalId: cardB.deckGlobalId,
          front: cardB.front,
          back: cardB.back,
          contentHlc: cardB.contentHlc,
          scheduleHlc: hlcReview,
          state: 2,
          stability: 6.0,
          difficulty: 2.5,
          due: DateTime.utc(2026, 1, 15),
          reps: 1,
          lapses: 0,
          isSuspended: false,
          easinessFactor: 2.5,
          flag: 0,
        ),
      );

      // Node A performs sync (pulls B's epoch snapshot + 2 incremental events = 3)
      final syncRes = await syncA.sync();
      expect(syncRes.success, isTrue);
      expect(syncRes.eventsPulled, 3);

      // A second sync from A pulls 0 new events because offset is up to date!
      final syncRes2 = await syncA.sync();
      expect(syncRes2.success, isTrue);
      expect(syncRes2.eventsPulled, 0);

      // Node A has the review log and updated schedule!
      final aLogs = await dbA.select(dbA.reviewLogs).get();
      expect(aLogs, hasLength(1));
      expect(aLogs.first.globalId, 'revlog_b_1');
      expect(aLogs.first.rating, 4);

      final aCard = await (dbA.select(
        dbA.cards,
      )..where((t) => t.globalId.equals('card_math_1'))).getSingle();
      expect(aCard.state, 2);
      expect(aCard.stability, 6.0);
      expect(aCard.due.toUtc(), DateTime.utc(2026, 1, 15));
      expect(aCard.scheduleHlc, hlcReview);
    });

    test('Tombstone sync: Node A deletes card, Node B syncs and deletes it without resurrecting', () async {
      final hlc1 = const Hlc(millis: 1000, counter: 0, nodeId: 'node_A').pack();

      // Create on A
      await dbA
          .into(dbA.decks)
          .insert(
            DecksCompanion.insert(
              name: 'Deck',
              globalId: const Value('deck_del'),
              updatedHlc: Value(hlc1),
            ),
          );
      final deck = await dbA.select(dbA.decks).getSingle();
      await dbA
          .into(dbA.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deck.id,
              deckGlobalId: const Value('deck_del'),
              front: 'Will be deleted',
              back: 'Soon',
              due: DateTime.utc(2026, 1, 1),
              globalId: const Value('card_del_1'),
              contentHlc: Value(hlc1),
              scheduleHlc: Value(hlc1),
            ),
          );

      await syncA.sync();
      await syncB.sync();
      expect(await dbB.select(dbB.cards).get(), hasLength(1));

      // Node A deletes card and emits tombstone
      final hlcDel = const Hlc(
        millis: 3000,
        counter: 0,
        nodeId: 'node_A',
      ).pack();
      await (dbA.delete(
        dbA.cards,
      )..where((t) => t.globalId.equals('card_del_1'))).go();
      await syncA.emitTombstone(
        globalId: 'card_del_1',
        deletedHlc: hlcDel,
        entityType: 0,
      );

      // Node B syncs
      await syncB.sync();

      // Node B card is gone!
      expect(await dbB.select(dbB.cards).get(), isEmpty);
      // Tombstone is recorded on Node B
      final bTombstones = await dbB.select(dbB.syncTombstones).get();
      expect(bTombstones, hasLength(1));
      expect(bTombstones.first.globalId, 'card_del_1');
    });

    test('Epoch self-compaction resets cursor cleanly', () async {
      final hlc1 = const Hlc(millis: 1000, counter: 0, nodeId: 'node_A').pack();
      await dbA
          .into(dbA.decks)
          .insert(
            DecksCompanion.insert(
              name: 'History',
              globalId: const Value('deck_hist'),
              updatedHlc: Value(hlc1),
            ),
          );

      await syncA.sync();
      await syncB.sync();

      // Node A forces self-compaction (simulating reaching max size)
      await syncA.compactOwnMailbox();

      // Node B syncs again: detects new gen and ingests seamlessly
      final resB = await syncB.sync();
      expect(resB.success, isTrue);

      final bDecks = await dbB.select(dbB.decks).get();
      expect(bDecks, hasLength(1));
      expect(bDecks.first.name, 'History');
    });
  });
}
