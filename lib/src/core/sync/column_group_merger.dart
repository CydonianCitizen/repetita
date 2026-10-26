import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'sync_event.dart';

/// Implements Column-Group Last-Write-Wins (LWW) conflict resolution
/// using dual Hybrid Logical Clocks (contentHlc vs scheduleHlc).
///
/// Ensures that concurrent content modifications (e.g. PC edits typo)
/// and FSRS review events (e.g. mobile completes study session)
/// merge seamlessly without clobbering each other.
class ColumnGroupMerger {
  const ColumnGroupMerger(this.db);

  final AppDatabase db;

  /// Applies a batch of sync events in a single atomic database transaction.
  Future<void> mergeEvents(List<SyncEvent> events) async {
    await db.transaction(() async {
      for (final event in events) {
        await applyEvent(event);
      }
    });
  }

  /// Dispatches and applies a single sync event based on its runtime type.
  Future<void> applyEvent(SyncEvent event) async {
    switch (event) {
      case EpochHeaderSyncEvent e:
        for (final t in e.tombstones) {
          await applyTombstone(t);
        }
        for (final d in e.decks) {
          await applyDeck(d);
        }
        for (final tag in e.tags) {
          await applyTag(tag);
        }
        for (final c in e.cards) {
          await applyCard(c);
        }
        for (final ct in e.cardTags) {
          await applyCardTag(ct);
        }
      case CardSyncEvent c:
        await applyCard(c);
      case DeckSyncEvent d:
        await applyDeck(d);
      case TagSyncEvent t:
        await applyTag(t);
      case CardTagSyncEvent ct:
        await applyCardTag(ct);
      case ReviewLogSyncEvent r:
        await applyReviewLog(r);
      case TombstoneSyncEvent t:
        await applyTombstone(t);
    }
  }

  /// Merges a tombstone record. If the entity exists locally, it is deleted.
  Future<void> applyTombstone(TombstoneSyncEvent event) async {
    final existing = await (db.select(
      db.syncTombstones,
    )..where((t) => t.globalId.equals(event.globalId))).getSingleOrNull();

    if (existing != null &&
        existing.deletedHlc.compareTo(event.deletedHlc) >= 0) {
      return; // Local tombstone is newer or equal
    }

    await db
        .into(db.syncTombstones)
        .insertOnConflictUpdate(
          SyncTombstonesCompanion(
            globalId: Value(event.globalId),
            deletedHlc: Value(event.deletedHlc),
            entityType: Value(event.entityType),
          ),
        );

    // Physical purge of tombstoned entity locally
    switch (event.entityType) {
      case 0: // Card
        await (db.delete(
          db.cards,
        )..where((t) => t.globalId.equals(event.globalId))).go();
      case 1: // Deck
        await (db.delete(
          db.decks,
        )..where((t) => t.globalId.equals(event.globalId))).go();
      case 2: // Tag
        await (db.delete(
          db.tags,
        )..where((t) => t.globalId.equals(event.globalId))).go();
    }
  }

  /// Merges a Deck with HLC comparison.
  Future<void> applyDeck(DeckSyncEvent event) async {
    final tombstone = await (db.select(
      db.syncTombstones,
    )..where((t) => t.globalId.equals(event.globalId))).getSingleOrNull();
    if (tombstone != null &&
        tombstone.deletedHlc.compareTo(event.updatedHlc) >= 0) {
      return; // Deck was deleted
    }

    final existing = await (db.select(
      db.decks,
    )..where((t) => t.globalId.equals(event.globalId))).getSingleOrNull();

    if (existing == null) {
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              name: event.name,
              description: Value(event.description),
              examDate: Value(event.examDate),
              targetRetention: Value(event.targetRetention),
              globalId: Value(event.globalId),
              updatedHlc: Value(event.updatedHlc),
            ),
          );
    } else if (event.updatedHlc.compareTo(existing.updatedHlc) > 0) {
      await (db.update(db.decks)..where((t) => t.id.equals(existing.id))).write(
        DecksCompanion(
          name: Value(event.name),
          description: Value(event.description),
          examDate: Value(event.examDate),
          targetRetention: Value(event.targetRetention),
          updatedHlc: Value(event.updatedHlc),
        ),
      );
    }
  }

  /// Merges a Card using dual HLC Column-Group LWW.
  Future<void> applyCard(CardSyncEvent event) async {
    final tombstone = await (db.select(
      db.syncTombstones,
    )..where((t) => t.globalId.equals(event.globalId))).getSingleOrNull();
    if (tombstone != null &&
        tombstone.deletedHlc.compareTo(event.contentHlc) >= 0) {
      return; // Card was deleted
    }

    final existing = await (db.select(
      db.cards,
    )..where((t) => t.globalId.equals(event.globalId))).getSingleOrNull();

    if (existing == null) {
      // Resolve deck foreign key
      var localDeck = await (db.select(
        db.decks,
      )..where((t) => t.globalId.equals(event.deckGlobalId))).getSingleOrNull();

      if (localDeck == null) {
        // Fallback to first available deck if peer deck has not arrived
        final allDecks = await db.select(db.decks).get();
        if (allDecks.isNotEmpty) {
          localDeck = allDecks.first;
        } else {
          final id = await db
              .into(db.decks)
              .insert(
                DecksCompanion.insert(
                  name: 'Default',
                  globalId: Value(event.deckGlobalId),
                  updatedHlc: Value(event.contentHlc),
                ),
              );
          localDeck = await (db.select(
            db.decks,
          )..where((t) => t.id.equals(id))).getSingle();
        }
      }

      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: localDeck.id,
              deckGlobalId: Value(event.deckGlobalId),
              front: event.front,
              back: event.back,
              state: Value(event.state),
              stability: Value(event.stability),
              difficulty: Value(event.difficulty),
              due: event.due,
              lastReview: Value(event.lastReview),
              reps: Value(event.reps),
              lapses: Value(event.lapses),
              isSuspended: Value(event.isSuspended),
              buriedUntil: Value(event.buriedUntil),
              clozeIndex: Value(event.clozeIndex),
              easinessFactor: Value(event.easinessFactor),
              flag: Value(event.flag),
              noteId: Value(event.noteId),
              globalId: Value(event.globalId),
              contentHlc: Value(event.contentHlc),
              scheduleHlc: Value(event.scheduleHlc),
            ),
          );
      return;
    }

    // Existing card: resolve column groups independently
    final shouldUpdateContent =
        event.contentHlc.compareTo(existing.contentHlc) > 0;
    final shouldUpdateSchedule =
        event.scheduleHlc.compareTo(existing.scheduleHlc) > 0;

    if (!shouldUpdateContent && !shouldUpdateSchedule) {
      return; // Local state is strictly newer on both dimensions
    }

    CardsCompanion companion = const CardsCompanion();

    if (shouldUpdateContent) {
      var newDeckId = existing.deckId;
      if (event.deckGlobalId != existing.deckGlobalId &&
          event.deckGlobalId.isNotEmpty) {
        final targetDeck =
            await (db.select(db.decks)
                  ..where((t) => t.globalId.equals(event.deckGlobalId)))
                .getSingleOrNull();
        if (targetDeck != null) {
          newDeckId = targetDeck.id;
        }
      }

      companion = companion.copyWith(
        deckId: Value(newDeckId),
        deckGlobalId: Value(event.deckGlobalId),
        front: Value(event.front),
        back: Value(event.back),
        clozeIndex: Value(event.clozeIndex),
        noteId: Value(event.noteId),
        contentHlc: Value(event.contentHlc),
      );
    }

    if (shouldUpdateSchedule) {
      companion = companion.copyWith(
        state: Value(event.state),
        stability: Value(event.stability),
        difficulty: Value(event.difficulty),
        due: Value(event.due),
        lastReview: Value(event.lastReview),
        reps: Value(event.reps),
        lapses: Value(event.lapses),
        isSuspended: Value(event.isSuspended),
        buriedUntil: Value(event.buriedUntil),
        easinessFactor: Value(event.easinessFactor),
        flag: Value(event.flag),
        scheduleHlc: Value(event.scheduleHlc),
      );
    }

    await (db.update(
      db.cards,
    )..where((t) => t.id.equals(existing.id))).write(companion);
  }

  /// Merges a Tag record with HLC comparison.
  Future<void> applyTag(TagSyncEvent event) async {
    final tombstone = await (db.select(
      db.syncTombstones,
    )..where((t) => t.globalId.equals(event.globalId))).getSingleOrNull();
    if (tombstone != null &&
        tombstone.deletedHlc.compareTo(event.updatedHlc) >= 0) {
      return;
    }

    final existing = await (db.select(
      db.tags,
    )..where((t) => t.globalId.equals(event.globalId))).getSingleOrNull();

    if (existing == null) {
      await db
          .into(db.tags)
          .insert(
            TagsCompanion.insert(
              name: event.name,
              color: Value(event.color),
              globalId: Value(event.globalId),
              updatedHlc: Value(event.updatedHlc),
            ),
          );
    } else if (event.updatedHlc.compareTo(existing.updatedHlc) > 0) {
      await (db.update(db.tags)..where((t) => t.id.equals(existing.id))).write(
        TagsCompanion(
          name: Value(event.name),
          color: Value(event.color),
          updatedHlc: Value(event.updatedHlc),
        ),
      );
    }
  }

  /// Merges a CardTag association.
  Future<void> applyCardTag(CardTagSyncEvent event) async {
    final card = await (db.select(
      db.cards,
    )..where((t) => t.globalId.equals(event.cardGlobalId))).getSingleOrNull();
    final tag = await (db.select(
      db.tags,
    )..where((t) => t.globalId.equals(event.tagGlobalId))).getSingleOrNull();

    if (card != null && tag != null) {
      await db
          .into(db.cardTags)
          .insert(
            CardTagsCompanion.insert(
              cardId: card.id,
              tagId: tag.id,
              cardGlobalId: Value(event.cardGlobalId),
              tagGlobalId: Value(event.tagGlobalId),
              updatedHlc: Value(event.updatedHlc),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  /// Merges an immutable ReviewLog event (pure set union).
  Future<void> applyReviewLog(ReviewLogSyncEvent event) async {
    // Check if log already imported
    final existing = await (db.select(
      db.reviewLogs,
    )..where((t) => t.globalId.equals(event.globalId))).getSingleOrNull();
    if (existing != null) return;

    final card = await (db.select(
      db.cards,
    )..where((t) => t.globalId.equals(event.cardGlobalId))).getSingleOrNull();
    if (card == null) return; // Cannot attach to missing card

    await db
        .into(db.reviewLogs)
        .insert(
          ReviewLogsCompanion.insert(
            cardId: card.id,
            rating: event.rating,
            state: event.state,
            due: event.due,
            stability: event.stability,
            difficulty: event.difficulty,
            elapsedDays: event.elapsedDays,
            lastElapsedDays: event.lastElapsedDays,
            scheduledDays: event.scheduledDays,
            reviewedAt: event.reviewedAt,
            easinessFactor: Value(event.easinessFactor),
            globalId: Value(event.globalId),
            cardGlobalId: Value(event.cardGlobalId),
          ),
        );
  }
}
