import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/sync/hlc.dart';

void main() {
  group('Database Schema v10 & Migration', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('fresh schema v10 has sync tables and columns ready', () async {
      final deviceId = await db.getOrCreateDeviceId();
      expect(deviceId.isNotEmpty, isTrue);

      final secondDeviceId = await db.getOrCreateDeviceId();
      expect(secondDeviceId, equals(deviceId));

      // Test insertion into SyncTombstones
      final hlc = Hlc.initial(deviceId).pack();
      await db
          .into(db.syncTombstones)
          .insert(
            SyncTombstonesCompanion.insert(
              globalId: 'card_xyz',
              deletedHlc: hlc,
              entityType: 0,
            ),
          );

      final tombstones = await db.select(db.syncTombstones).get();
      expect(tombstones, hasLength(1));
      expect(tombstones.first.globalId, 'card_xyz');
      expect(tombstones.first.deletedHlc, hlc);

      // Test insertion into SyncPeerCursors
      await db
          .into(db.syncPeerCursors)
          .insert(
            SyncPeerCursorsCompanion.insert(
              peerId: 'peer_node_1',
              gen: const Value(1),
              byteOffset: const Value(1024),
              lastSyncedAt: DateTime.now().toUtc(),
            ),
          );

      final cursors = await db.select(db.syncPeerCursors).get();
      expect(cursors, hasLength(1));
      expect(cursors.first.peerId, 'peer_node_1');
      expect(cursors.first.gen, 1);
      expect(cursors.first.byteOffset, 1024);
    });

    test('creates deck and card with globalId and HLC fields', () async {
      final deviceId = await db.getOrCreateDeviceId();
      final now = DateTime.now().toUtc();
      final hlc = Hlc.initial(deviceId, now).pack();

      final deckId = await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              name: 'Anatomy',
              globalId: const Value('deck_uuid_1'),
              updatedHlc: Value(hlc),
            ),
          );

      final cardId = await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'What is the femur?',
              back: 'Thigh bone',
              due: now,
              globalId: const Value('card_uuid_1'),
              deckGlobalId: const Value('deck_uuid_1'),
              contentHlc: Value(hlc),
              scheduleHlc: Value(hlc),
            ),
          );

      final fetchedCard = await (db.select(
        db.cards,
      )..where((t) => t.id.equals(cardId))).getSingle();
      expect(fetchedCard.globalId, 'card_uuid_1');
      expect(fetchedCard.deckGlobalId, 'deck_uuid_1');
      expect(fetchedCard.contentHlc, hlc);
      expect(fetchedCard.scheduleHlc, hlc);
    });
  });
}
