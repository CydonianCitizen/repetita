import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'column_group_merger.dart';
import 'sync_event.dart';
import 'sync_storage_adapter.dart';

class SyncSummary {
  const SyncSummary({
    required this.peersSynced,
    required this.eventsPulled,
    required this.success,
    this.errorMessage,
  });

  final int peersSynced;
  final int eventsPulled;
  final bool success;
  final String? errorMessage;
}

/// Orchestrates Single-Writer Multi-Reader (SWMR) Zero-Cloud File Sync.
class FileBasedSyncService {
  FileBasedSyncService({
    required this.db,
    required this.storage,
    required this.localDeviceId,
  }) : merger = ColumnGroupMerger(db);

  final AppDatabase db;
  final SyncStorageAdapter storage;
  final String localDeviceId;
  final ColumnGroupMerger merger;

  /// Compaction threshold in bytes (5 MB).
  static const int maxMailboxSizeBytes = 5 * 1024 * 1024;

  /// Executes a full synchronization cycle:
  /// 1. Ingests incremental events from all discovered peer mailboxes.
  /// 2. Ensures local mailbox exists and performs self-compaction if needed.
  Future<SyncSummary> sync() async {
    try {
      int peersCount = 0;
      int totalEventsPulled = 0;

      // 1. Ingest peer mailboxes
      final peerIds = await storage.listPeerNodeIds();
      for (final peerId in peerIds) {
        if (peerId == localDeviceId) continue;

        final pulled = await _ingestPeer(peerId);
        totalEventsPulled += pulled;
        peersCount++;
      }

      // 2. Ensure own mailbox exists & compact if needed
      await _ensureOwnMailbox();

      return SyncSummary(
        peersSynced: peersCount,
        eventsPulled: totalEventsPulled,
        success: true,
      );
    } catch (e) {
      return SyncSummary(
        peersSynced: 0,
        eventsPulled: 0,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<int> _ingestPeer(String peerId) async {
    final cursor = await (db.select(
      db.syncPeerCursors,
    )..where((t) => t.peerId.equals(peerId))).getSingleOrNull();

    final fileSize = await storage.getPeerFileSize(peerId);
    if (fileSize == 0) return 0;

    int fromOffset = cursor?.byteOffset ?? 0;
    // If remote file shrunk (compaction happened), restart from offset 0
    if (cursor != null && fileSize < cursor.byteOffset) {
      fromOffset = 0;
    }

    final readResult = await storage.readPeerEvents(
      peerId,
      fromByteOffset: fromOffset,
    );

    if (readResult.lines.isEmpty) return 0;

    int newGen = cursor?.gen ?? 0;
    final eventsToApply = <SyncEvent>[];

    for (int i = 0; i < readResult.lines.length; i++) {
      final line = readResult.lines[i];
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        final event = SyncEvent.fromJson(json);

        if (event is EpochHeaderSyncEvent) {
          newGen = event.gen;
          // If remote gen changed, we accept the full snapshot from the epoch
          eventsToApply.add(event);
        } else {
          eventsToApply.add(event);
        }
      } catch (_) {
        // Skip malformed individual event line
      }
    }

    if (eventsToApply.isNotEmpty) {
      await merger.mergeEvents(eventsToApply);
    }

    // Update cursor
    await db
        .into(db.syncPeerCursors)
        .insertOnConflictUpdate(
          SyncPeerCursorsCompanion(
            peerId: Value(peerId),
            gen: Value(newGen),
            byteOffset: Value(readResult.newByteOffset),
            lastSyncedAt: Value(DateTime.now().toUtc()),
          ),
        );

    return eventsToApply.length;
  }

  /// Appends a locally generated event to own mailbox.
  Future<void> emitLocalEvent(SyncEvent event) async {
    await storage.appendOwnEvent(jsonEncode(event.toJson()));
  }

  /// Emits a tombstone when a card, deck, or tag is deleted locally.
  Future<void> emitTombstone({
    required String globalId,
    required String deletedHlc,
    required int entityType,
  }) async {
    // Record in local tombstone table first
    await db
        .into(db.syncTombstones)
        .insertOnConflictUpdate(
          SyncTombstonesCompanion(
            globalId: Value(globalId),
            deletedHlc: Value(deletedHlc),
            entityType: Value(entityType),
          ),
        );

    final event = TombstoneSyncEvent(
      globalId: globalId,
      deletedHlc: deletedHlc,
      entityType: entityType,
    );
    await emitLocalEvent(event);
  }

  Future<void> _ensureOwnMailbox() async {
    final ownSize = await storage.getOwnFileSize();
    if (ownSize == 0 || ownSize > maxMailboxSizeBytes) {
      await compactOwnMailbox();
    }
  }

  /// Rewrites own `events.jsonl` with an Epoch header containing a full
  /// snapshot of all local active entities and tombstones.
  Future<void> compactOwnMailbox() async {
    final currentGenStr = await db.getSetting('sync_own_gen');
    final currentGen = int.tryParse(currentGenStr ?? '0') ?? 0;
    final nextGen = currentGen + 1;

    // Snapshot decks
    final allDecks = await db.select(db.decks).get();
    final deckEvents = allDecks
        .map(
          (d) => DeckSyncEvent(
            globalId: d.globalId,
            name: d.name,
            description: d.description,
            examDate: d.examDate,
            targetRetention: d.targetRetention,
            updatedHlc: d.updatedHlc,
          ),
        )
        .toList();

    // Snapshot cards
    final allCards = await db.select(db.cards).get();
    final cardEvents = allCards
        .map(
          (c) => CardSyncEvent(
            globalId: c.globalId,
            deckGlobalId: c.deckGlobalId,
            front: c.front,
            back: c.back,
            contentHlc: c.contentHlc,
            scheduleHlc: c.scheduleHlc,
            state: c.state,
            stability: c.stability,
            difficulty: c.difficulty,
            due: c.due,
            lastReview: c.lastReview,
            reps: c.reps,
            lapses: c.lapses,
            isSuspended: c.isSuspended,
            buriedUntil: c.buriedUntil,
            clozeIndex: c.clozeIndex,
            easinessFactor: c.easinessFactor,
            flag: c.flag,
            noteId: c.noteId,
          ),
        )
        .toList();

    // Snapshot tags
    final allTags = await db.select(db.tags).get();
    final tagEvents = allTags
        .map(
          (t) => TagSyncEvent(
            globalId: t.globalId,
            name: t.name,
            color: t.color,
            updatedHlc: t.updatedHlc,
          ),
        )
        .toList();

    // Snapshot card tags
    final allCardTags = await db.select(db.cardTags).get();
    final cardTagEvents = allCardTags
        .map(
          (ct) => CardTagSyncEvent(
            cardGlobalId: ct.cardGlobalId,
            tagGlobalId: ct.tagGlobalId,
            updatedHlc: ct.updatedHlc,
          ),
        )
        .toList();

    // Snapshot tombstones
    final allTombstones = await db.select(db.syncTombstones).get();
    final tombstoneEvents = allTombstones
        .map(
          (t) => TombstoneSyncEvent(
            globalId: t.globalId,
            deletedHlc: t.deletedHlc,
            entityType: t.entityType,
          ),
        )
        .toList();

    final epoch = EpochHeaderSyncEvent(
      gen: nextGen,
      deviceId: localDeviceId,
      createdAt: DateTime.now().toUtc(),
      decks: deckEvents,
      cards: cardEvents,
      tags: tagEvents,
      cardTags: cardTagEvents,
      tombstones: tombstoneEvents,
    );

    await storage.rewriteOwnFile(jsonEncode(epoch.toJson()));
    await db.setSetting('sync_own_gen', nextGen.toString());
  }
}
