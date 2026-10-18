import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:repetita/src/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late Directory tempDir;
  var dbCounter = 0;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('drift_migration_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  File getNextDbFile() {
    dbCounter++;
    return File(p.join(tempDir.path, 'migration_test_$dbCounter.sqlite'));
  }

  void setupV1Schema(sqlite.Database raw) {
    raw.execute('''
      CREATE TABLE decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      );

      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER NOT NULL REFERENCES decks (id) ON DELETE CASCADE,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        state INTEGER NOT NULL DEFAULT 0,
        stability REAL NOT NULL DEFAULT 0.0,
        difficulty REAL NOT NULL DEFAULT 0.0,
        due INTEGER NOT NULL,
        last_review INTEGER,
        reps INTEGER NOT NULL DEFAULT 0,
        lapses INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      );

      CREATE TABLE review_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id INTEGER NOT NULL REFERENCES cards (id) ON DELETE CASCADE,
        rating INTEGER NOT NULL,
        state INTEGER NOT NULL,
        due INTEGER NOT NULL,
        stability REAL NOT NULL,
        difficulty REAL NOT NULL,
        elapsed_days INTEGER NOT NULL,
        last_elapsed_days INTEGER NOT NULL,
        scheduled_days INTEGER NOT NULL,
        reviewed_at INTEGER NOT NULL
      );

      PRAGMA user_version = 1;
    ''');
  }

  group('Drift Schema Migration Tests (v1 -> v8)', () {
    test(
      'upgrades from v1 directly to v8 preserving all data and column defaults',
      () async {
        final dbFile = getNextDbFile();
        final raw = sqlite.sqlite3.open(dbFile.path);
        setupV1Schema(raw);

        // Seed v1 sample data
        raw.execute('''
        INSERT INTO decks (id, name, description, created_at, updated_at)
        VALUES (1, 'V1 Biology', 'Cellular biology fundamentals', 1700000000, 1700000000);

        INSERT INTO cards (id, deck_id, front, back, state, stability, difficulty, due, reps, lapses, created_at)
        VALUES (1, 1, 'Mitochondria', 'Powerhouse of the cell', 2, 5.0, 3.2, 1700100000, 3, 0, 1700000000);

        INSERT INTO review_logs (id, card_id, rating, state, due, stability, difficulty, elapsed_days, last_elapsed_days, scheduled_days, reviewed_at)
        VALUES (1, 1, 3, 2, 1700100000, 5.0, 3.2, 2, 0, 5, 1700000000);
      ''');
        raw.close();

        // Open database with Drift at current schemaVersion (8)
        final appDb = AppDatabase.forTesting(NativeDatabase(dbFile));

        // Trigger schema upgrade via query
        final decks = await appDb.select(appDb.decks).get();
        expect(decks, hasLength(1));
        final deck = decks.first;
        expect(deck.id, 1);
        expect(deck.name, 'V1 Biology');
        expect(deck.description, 'Cellular biology fundamentals');
        expect(deck.examDate, isNull);
        expect(deck.targetRetention, isNull);

        // Verify Card row with default values on new v2, v3, v6, v7, v8 columns
        final cards = await appDb.select(appDb.cards).get();
        expect(cards, hasLength(1));
        final card = cards.first;
        expect(card.id, 1);
        expect(card.front, 'Mitochondria');
        expect(card.back, 'Powerhouse of the cell');
        expect(card.isSuspended, isFalse); // v2 added
        expect(card.buriedUntil, isNull); // v2 added
        expect(card.clozeIndex, isNull); // v3 added
        expect(card.easinessFactor, 2.5); // v6 added
        expect(card.flag, 0); // v7 added
        expect(card.noteId, isNull); // v8 added

        // Verify ReviewLog row with default value on new v6 easinessFactor
        final logs = await appDb.select(appDb.reviewLogs).get();
        expect(logs, hasLength(1));
        final log = logs.first;
        expect(log.id, 1);
        expect(log.rating, 3);
        expect(log.easinessFactor, 2.5); // v6 added

        // Verify newly created tables exist and accept CRUD
        // 1. Tags & CardTags (v3)
        final tagId = await appDb
            .into(appDb.tags)
            .insert(
              TagsCompanion.insert(
                name: 'science',
                color: const drift.Value(1),
              ),
            );
        expect(tagId, greaterThan(0));
        await appDb
            .into(appDb.cardTags)
            .insert(CardTagsCompanion.insert(cardId: card.id, tagId: tagId));
        final tagEntries = await appDb.select(appDb.tags).get();
        expect(tagEntries, hasLength(1));

        // 2. AppSettings (v4)
        await appDb.setSetting('app_theme', 'pure_black');
        expect(await appDb.getSetting('app_theme'), 'pure_black');

        // Verify PRAGMA user_version is 8
        final versionResult = await appDb
            .customSelect('PRAGMA user_version;')
            .getSingle();
        expect(versionResult.read<int>('user_version'), 8);

        await appDb.close();
      },
    );

    test('creates all expected performance indexes during migration', () async {
      final dbFile = getNextDbFile();
      final raw = sqlite.sqlite3.open(dbFile.path);
      setupV1Schema(raw);
      raw.close();

      final appDb = AppDatabase.forTesting(NativeDatabase(dbFile));
      await appDb.select(appDb.decks).get(); // Trigger migration

      final indexRows = await appDb
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index';")
          .get();
      final indexNames = indexRows.map((r) => r.read<String>('name')).toSet();

      expect(indexNames, contains('idx_cards_deck_id'));
      expect(indexNames, contains('idx_cards_due'));
      expect(indexNames, contains('idx_cards_note_id'));
      expect(indexNames, contains('idx_review_logs_card_id'));
      expect(indexNames, contains('idx_review_logs_reviewed_at'));
      expect(indexNames, contains('idx_card_tags_tag_id'));

      await appDb.close();
    });

    test('preserves foreign key cascading after migration', () async {
      final dbFile = getNextDbFile();
      final raw = sqlite.sqlite3.open(dbFile.path);
      setupV1Schema(raw);
      raw.execute('''
        INSERT INTO decks (id, name) VALUES (10, 'Cascade Deck');
        INSERT INTO cards (id, deck_id, front, back, due) VALUES (20, 10, 'Front', 'Back', 1700000000);
        INSERT INTO review_logs (id, card_id, rating, state, due, stability, difficulty, elapsed_days, last_elapsed_days, scheduled_days, reviewed_at)
        VALUES (30, 20, 3, 0, 1700000000, 1.0, 5.0, 0, 0, 1, 1700000000);
      ''');
      raw.close();

      final appDb = AppDatabase.forTesting(NativeDatabase(dbFile));

      // Verify records are present
      expect(await appDb.select(appDb.decks).get(), hasLength(1));
      expect(await appDb.select(appDb.cards).get(), hasLength(1));
      expect(await appDb.select(appDb.reviewLogs).get(), hasLength(1));

      // Add a card tag to test multi-level cascade
      final tagId = await appDb
          .into(appDb.tags)
          .insert(TagsCompanion.insert(name: 'biology'));
      await appDb
          .into(appDb.cardTags)
          .insert(CardTagsCompanion.insert(cardId: 20, tagId: tagId));
      expect(await appDb.select(appDb.cardTags).get(), hasLength(1));

      // Delete deck
      await (appDb.delete(appDb.decks)..where((t) => t.id.equals(10))).go();

      // Everything cascading should be deleted
      expect(await appDb.select(appDb.decks).get(), isEmpty);
      expect(await appDb.select(appDb.cards).get(), isEmpty);
      expect(await appDb.select(appDb.reviewLogs).get(), isEmpty);
      expect(await appDb.select(appDb.cardTags).get(), isEmpty);
      // Independent tag should still exist
      expect(await appDb.select(appDb.tags).get(), hasLength(1));

      await appDb.close();
    });

    test('upgrades from schema v5 to v7 seamlessly', () async {
      final dbFile = getNextDbFile();
      final raw = sqlite.sqlite3.open(dbFile.path);
      setupV1Schema(raw);

      // Apply v2 to v5 migrations manually on raw sqlite
      raw.execute('''
        ALTER TABLE cards ADD COLUMN is_suspended INTEGER NOT NULL DEFAULT 0;
        ALTER TABLE cards ADD COLUMN buried_until INTEGER;
        ALTER TABLE cards ADD COLUMN cloze_index INTEGER;
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
        CREATE TABLE card_tags (
          card_id INTEGER NOT NULL REFERENCES cards (id) ON DELETE CASCADE,
          tag_id INTEGER NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
          PRIMARY KEY (card_id, tag_id)
        );
        CREATE TABLE app_settings (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
        CREATE INDEX idx_cards_deck_id ON cards (deck_id);
        CREATE INDEX idx_cards_due ON cards (due);
        CREATE INDEX idx_review_logs_card_id ON review_logs (card_id);
        CREATE INDEX idx_review_logs_reviewed_at ON review_logs (reviewed_at);
        CREATE INDEX idx_card_tags_tag_id ON card_tags (tag_id);

        PRAGMA user_version = 5;

        INSERT INTO decks (id, name) VALUES (1, 'V5 Deck');
        INSERT INTO cards (id, deck_id, front, back, due) VALUES (1, 1, 'Q', 'A', 1700000000);
      ''');
      raw.close();

      final appDb = AppDatabase.forTesting(NativeDatabase(dbFile));
      final cards = await appDb.select(appDb.cards).get();
      expect(cards.first.easinessFactor, 2.5);
      expect(cards.first.flag, 0);

      // Verify write to new v7 fields works
      final now = DateTime.now().toUtc();
      await (appDb.update(appDb.decks)..where((t) => t.id.equals(1))).write(
        DecksCompanion(
          examDate: drift.Value(now.add(const Duration(days: 30))),
          targetRetention: const drift.Value(0.85),
        ),
      );

      final updatedDeck = await (appDb.select(
        appDb.decks,
      )..where((t) => t.id.equals(1))).getSingle();
      expect(updatedDeck.targetRetention, 0.85);
      expect(updatedDeck.examDate, isNotNull);

      await appDb.close();
    });

    test('upgrades from schema v6 to v7 seamlessly', () async {
      final dbFile = getNextDbFile();
      final raw = sqlite.sqlite3.open(dbFile.path);
      setupV1Schema(raw);

      // Apply up to v6
      raw.execute('''
        ALTER TABLE cards ADD COLUMN is_suspended INTEGER NOT NULL DEFAULT 0;
        ALTER TABLE cards ADD COLUMN buried_until INTEGER;
        ALTER TABLE cards ADD COLUMN cloze_index INTEGER;
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
        CREATE TABLE card_tags (
          card_id INTEGER NOT NULL REFERENCES cards (id) ON DELETE CASCADE,
          tag_id INTEGER NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
          PRIMARY KEY (card_id, tag_id)
        );
        CREATE TABLE app_settings (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
        CREATE INDEX idx_cards_deck_id ON cards (deck_id);
        CREATE INDEX idx_cards_due ON cards (due);
        CREATE INDEX idx_review_logs_card_id ON review_logs (card_id);
        CREATE INDEX idx_review_logs_reviewed_at ON review_logs (reviewed_at);
        CREATE INDEX idx_card_tags_tag_id ON card_tags (tag_id);
        ALTER TABLE cards ADD COLUMN easiness_factor REAL NOT NULL DEFAULT 2.5;
        ALTER TABLE review_logs ADD COLUMN easiness_factor REAL NOT NULL DEFAULT 2.5;

        PRAGMA user_version = 6;

        INSERT INTO decks (id, name) VALUES (1, 'V6 Deck');
        INSERT INTO cards (id, deck_id, front, back, due, easiness_factor) VALUES (1, 1, 'Q', 'A', 1700000000, 2.3);
      ''');
      raw.close();

      final appDb = AppDatabase.forTesting(NativeDatabase(dbFile));
      final cards = await appDb.select(appDb.cards).get();
      expect(cards.first.easinessFactor, 2.3);
      expect(cards.first.flag, 0);

      final versionResult = await appDb
          .customSelect('PRAGMA user_version;')
          .getSingle();
      expect(versionResult.read<int>('user_version'), 8);

      await appDb.close();
    });

    test('upgrades from schema v7 to v8 seamlessly', () async {
      final dbFile = getNextDbFile();
      final raw = sqlite.sqlite3.open(dbFile.path);
      setupV1Schema(raw);

      // Apply up to v7
      raw.execute('''
        ALTER TABLE cards ADD COLUMN is_suspended INTEGER NOT NULL DEFAULT 0;
        ALTER TABLE cards ADD COLUMN buried_until INTEGER;
        ALTER TABLE cards ADD COLUMN cloze_index INTEGER;
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
        CREATE TABLE card_tags (
          card_id INTEGER NOT NULL REFERENCES cards (id) ON DELETE CASCADE,
          tag_id INTEGER NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
          PRIMARY KEY (card_id, tag_id)
        );
        CREATE TABLE app_settings (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
        CREATE INDEX idx_cards_deck_id ON cards (deck_id);
        CREATE INDEX idx_cards_due ON cards (due);
        CREATE INDEX idx_review_logs_card_id ON review_logs (card_id);
        CREATE INDEX idx_review_logs_reviewed_at ON review_logs (reviewed_at);
        CREATE INDEX idx_card_tags_tag_id ON card_tags (tag_id);
        ALTER TABLE cards ADD COLUMN easiness_factor REAL NOT NULL DEFAULT 2.5;
        ALTER TABLE review_logs ADD COLUMN easiness_factor REAL NOT NULL DEFAULT 2.5;
        ALTER TABLE cards ADD COLUMN flag INTEGER NOT NULL DEFAULT 0;
        ALTER TABLE decks ADD COLUMN exam_date INTEGER;
        ALTER TABLE decks ADD COLUMN target_retention REAL;

        PRAGMA user_version = 7;

        INSERT INTO decks (id, name) VALUES (1, 'V7 Deck');
        INSERT INTO cards (id, deck_id, front, back, due, flag) VALUES (1, 1, 'Q', 'A', 1700000000, 2);
      ''');
      raw.close();

      final appDb = AppDatabase.forTesting(NativeDatabase(dbFile));
      final cards = await appDb.select(appDb.cards).get();
      expect(cards.first.flag, 2);
      expect(cards.first.noteId, isNull);

      final versionResult = await appDb
          .customSelect('PRAGMA user_version;')
          .getSingle();
      expect(versionResult.read<int>('user_version'), 8);

      // Verify creating card with noteId on v8 works
      final newCardId = await appDb.cardsDao.createCard(
        deckId: 1,
        front: 'Front',
        back: 'Back',
        noteId: 999,
      );
      final newCard = await appDb.cardsDao.getCardById(newCardId);
      expect(newCard?.noteId, equals(999));

      await appDb.close();
    });

    test(
      'reopening an already migrated v8 database is idempotent and safe',
      () async {
        final dbFile = getNextDbFile();
        final raw = sqlite.sqlite3.open(dbFile.path);
        setupV1Schema(raw);
        raw.execute(
          "INSERT INTO decks (id, name) VALUES (1, 'Idempotent Deck');",
        );
        raw.close();

        // First open -> triggers migration from 1 to 8
        var appDb = AppDatabase.forTesting(NativeDatabase(dbFile));
        expect(await appDb.select(appDb.decks).get(), hasLength(1));
        await appDb.close();

        // Second open -> should be a no-op migration
        appDb = AppDatabase.forTesting(NativeDatabase(dbFile));
        final decks = await appDb.select(appDb.decks).get();
        expect(decks, hasLength(1));
        expect(decks.first.name, 'Idempotent Deck');

        final versionResult = await appDb
            .customSelect('PRAGMA user_version;')
            .getSingle();
        expect(versionResult.read<int>('user_version'), 8);
        await appDb.close();
      },
    );
  });
}
