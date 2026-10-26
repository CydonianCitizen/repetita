import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/cards/data/cards_dao.dart';
import '../../features/decks/data/decks_dao.dart';
import '../../features/media/data/media_dao.dart';
import '../../features/stats/data/stats_dao.dart';
import '../../features/study_session/data/study_session_dao.dart';
import '../../features/tags/data/tags_dao.dart';
import '../sync/hlc.dart';
import '../sync/sync_ids.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Decks,
    Cards,
    ReviewLogs,
    Tags,
    CardTags,
    AppSettings,
    Media,
    SyncTombstones,
    SyncPeerCursors,
  ],
  daos: [DecksDao, CardsDao, StudySessionDao, StatsDao, TagsDao, MediaDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        await customStatement('PRAGMA journal_mode = WAL;');
        await customStatement('PRAGMA synchronous = NORMAL;');
        await customStatement('PRAGMA temp_store = MEMORY;');
        await customStatement('PRAGMA cache_size = -64000;');
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(cards, cards.isSuspended);
          await m.addColumn(cards, cards.buriedUntil);
        }
        if (from < 3) {
          await m.addColumn(cards, cards.clozeIndex);
          await m.createTable(tags);
          await m.createTable(cardTags);
        }
        if (from < 4) {
          await m.createTable(appSettings);
        }
        if (from < 5) {
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_cards_deck_id ON cards (deck_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_cards_due ON cards (due)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_review_logs_card_id ON review_logs (card_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_review_logs_reviewed_at ON review_logs (reviewed_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_card_tags_tag_id ON card_tags (tag_id)',
          );
        }
        if (from < 6) {
          await m.addColumn(cards, cards.easinessFactor);
          await m.addColumn(reviewLogs, reviewLogs.easinessFactor);
        }
        if (from < 7) {
          await m.addColumn(cards, cards.flag);
          await m.addColumn(decks, decks.examDate);
          await m.addColumn(decks, decks.targetRetention);
        }
        if (from < 8) {
          await m.addColumn(cards, cards.noteId);
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_cards_note_id ON cards (note_id)',
          );
        }
        if (from < 9) {
          await m.createTable(media);
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_media_checksum ON media (checksum)',
          );
        }
        if (from < 10) {
          Future<bool> hasColumn(String table, String column) async {
            final rows = await customSelect("PRAGMA table_info('$table');")
                .get();
            return rows.any((r) => r.read<String>('name') == column);
          }

          Future<void> addCol(
            GeneratedColumn<Object> col,
            TableInfo<Table, Object?> table,
          ) async {
            if (!await hasColumn(table.actualTableName, col.name)) {
              await m.addColumn(table, col);
            }
          }

          await addCol(decks.globalId, decks);
          await addCol(decks.updatedHlc, decks);
          await addCol(cards.globalId, cards);
          await addCol(cards.deckGlobalId, cards);
          await addCol(cards.contentHlc, cards);
          await addCol(cards.scheduleHlc, cards);
          await addCol(reviewLogs.globalId, reviewLogs);
          await addCol(reviewLogs.cardGlobalId, reviewLogs);
          await addCol(tags.globalId, tags);
          await addCol(tags.updatedHlc, tags);
          await addCol(cardTags.cardGlobalId, cardTags);
          await addCol(cardTags.tagGlobalId, cardTags);
          await addCol(cardTags.updatedHlc, cardTags);
          await customStatement(
            'CREATE TABLE IF NOT EXISTS sync_tombstones (global_id TEXT NOT NULL PRIMARY KEY, deleted_hlc TEXT NOT NULL, entity_type INTEGER NOT NULL);',
          );
          await customStatement(
            'CREATE TABLE IF NOT EXISTS sync_peer_cursors (peer_id TEXT NOT NULL PRIMARY KEY, gen INTEGER NOT NULL DEFAULT 0, byte_offset INTEGER NOT NULL DEFAULT 0, last_synced_at INTEGER NOT NULL);',
          );

          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_decks_global_id ON decks (global_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_cards_global_id ON cards (global_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_review_logs_global_id ON review_logs (global_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_tags_global_id ON tags (global_id)',
          );

          await _backfillSyncData();
        }
      },
    );
  }

  Future<void> _backfillSyncData() async {
    final deviceId = await getOrCreateDeviceId();

    // 1. Decks
    final allDecks = await select(decks).get();
    for (final d in allDecks) {
      final gId = SyncIds.uuidV5(deviceId, 'deck_${d.id}');
      final hlc = Hlc.initial(deviceId, d.updatedAt).pack();
      await (update(decks)..where((t) => t.id.equals(d.id))).write(
        DecksCompanion(globalId: Value(gId), updatedHlc: Value(hlc)),
      );
    }

    // 2. Cards
    final allCards = await select(cards).get();
    for (final c in allCards) {
      final gId = SyncIds.uuidV5(deviceId, 'card_${c.id}');
      final cHlc = Hlc.initial(deviceId, c.createdAt).pack();
      final sHlc = Hlc.initial(deviceId, c.lastReview ?? c.createdAt).pack();
      await (update(cards)..where((t) => t.id.equals(c.id))).write(
        CardsCompanion(
          globalId: Value(gId),
          contentHlc: Value(cHlc),
          scheduleHlc: Value(sHlc),
        ),
      );
    }
    await customStatement(
      "UPDATE cards SET deck_global_id = coalesce((SELECT global_id FROM decks WHERE decks.id = cards.deck_id), '')",
    );

    // 3. ReviewLogs
    final allLogs = await select(reviewLogs).get();
    for (final log in allLogs) {
      final gId = SyncIds.uuidV5(deviceId, 'revlog_${log.id}');
      await (update(reviewLogs)..where((t) => t.id.equals(log.id))).write(
        ReviewLogsCompanion(globalId: Value(gId)),
      );
    }
    await customStatement(
      "UPDATE review_logs SET card_global_id = coalesce((SELECT global_id FROM cards WHERE cards.id = review_logs.card_id), '')",
    );

    // 4. Tags
    final allTags = await select(tags).get();
    for (final tag in allTags) {
      final gId = SyncIds.uuidV5(deviceId, 'tag_${tag.id}');
      final hlc = Hlc.initial(deviceId, tag.createdAt).pack();
      await (update(tags)..where((t) => t.id.equals(tag.id))).write(
        TagsCompanion(globalId: Value(gId), updatedHlc: Value(hlc)),
      );
    }

    // 5. CardTags
    await customStatement(
      "UPDATE card_tags SET card_global_id = coalesce((SELECT global_id FROM cards WHERE cards.id = card_tags.card_id), '')",
    );
    await customStatement(
      "UPDATE card_tags SET tag_global_id = coalesce((SELECT global_id FROM tags WHERE tags.id = card_tags.tag_id), '')",
    );
    await customStatement(
      "UPDATE card_tags SET updated_hlc = coalesce((SELECT updated_hlc FROM tags WHERE tags.id = card_tags.tag_id), '')",
    );
  }

  Future<String> getOrCreateDeviceId() async {
    final existing = await getSetting('sync_device_id');
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final newId = SyncIds.uuidV7();
    await setSetting('sync_device_id', newId);
    return newId;
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'repetita.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
