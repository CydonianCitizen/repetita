import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/backup_transfer/data/services/anki_package_service.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late AppDatabase db;
  late AnkiPackageService ankiService;
  late Directory tempTestDir;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    ankiService = AnkiPackageService(db);
    tempTestDir = Directory.systemTemp.createTempSync('repetita_anki_test_');
  });

  tearDown(() async {
    await db.close();
    try {
      if (tempTestDir.existsSync()) {
        tempTestDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  List<int> createSampleApkgBytes() {
    final dbFile = File(p.join(tempTestDir.path, 'sample_collection.anki2'));
    if (dbFile.existsSync()) dbFile.deleteSync();

    final sqliteDb = sqlite.sqlite3.open(dbFile.path);

    try {
      // 1. Create tables
      sqliteDb.execute('''
        CREATE TABLE col (
          id integer primary key,
          crt integer,
          mod integer,
          scm integer,
          ver integer,
          dty integer,
          usn integer,
          ls integer,
          conf text,
          models text,
          decks text,
          dconf text,
          tags text
        );
      ''');

      sqliteDb.execute('''
        CREATE TABLE notes (
          id integer primary key,
          guid text,
          mid integer,
          mod integer,
          usn integer,
          tags text,
          flds text,
          sfld text,
          csum integer,
          flags integer,
          data text
        );
      ''');

      sqliteDb.execute('''
        CREATE TABLE cards (
          id integer primary key,
          nid integer,
          did integer,
          ord integer,
          mod integer,
          usn integer,
          type integer,
          queue integer,
          due integer,
          ivl integer,
          factor integer,
          reps integer,
          lapses integer,
          left integer,
          odue integer,
          odid integer,
          flags integer,
          data text
        );
      ''');

      final modelsJson = jsonEncode({
        '1001': {
          'id': 1001,
          'name': 'Basic',
          'type': 0,
          'flds': [
            {'name': 'Front', 'ord': 0},
            {'name': 'Back', 'ord': 1},
          ],
          'tmpls': [
            {
              'name': 'Card 1',
              'ord': 0,
              'qfmt': '{{Front}}',
              'afmt': '{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}',
            },
          ],
        },
        '1002': {
          'id': 1002,
          'name': 'Cloze',
          'type': 1,
          'flds': [
            {'name': 'Text', 'ord': 0},
            {'name': 'Extra', 'ord': 1},
          ],
          'tmpls': [
            {
              'name': 'Cloze',
              'ord': 0,
              'qfmt': '{{cloze:Text}}',
              'afmt': '{{cloze:Text}}\n\n<hr id=answer>\n\n{{Extra}}',
            },
          ],
        },
      });

      final decksJson = jsonEncode({
        '1': {'id': 1, 'name': 'Default'},
        '2': {'id': 2, 'name': 'Computer Science'},
        '3': {'id': 3, 'name': 'Languages::Italian'},
      });

      sqliteDb.execute('INSERT INTO col (id, models, decks) VALUES (1, ?, ?)', [
        modelsJson,
        decksJson,
      ]);

      // Note 1: Basic
      sqliteDb.execute(
        'INSERT INTO notes (id, mid, tags, flds) VALUES (101, 1001, ?, ?)',
        [' programming flutter ', 'What is Flutter?\x1fUI framework by Google'],
      );

      // Note 2: Cloze
      sqliteDb.execute(
        'INSERT INTO notes (id, mid, tags, flds) VALUES (102, 1002, ?, ?)',
        [
          ' lang dart ',
          '{{c1::Dart}} is developed by {{c2::Google}}.\x1fLanguage note',
        ],
      );

      // Note 3: HTML with tags in Languages::Italian
      sqliteDb.execute(
        'INSERT INTO notes (id, mid, tags, flds) VALUES (103, 1001, ?, ?)',
        [
          ' vocab ',
          '<div><b>Ciao</b> means</div>\x1f<i>Hello</i> or <i>Goodbye</i>',
        ],
      );

      // Cards
      // Card 1: Note 1 in Computer Science
      sqliteDb.execute(
        'INSERT INTO cards (id, nid, did, ord) VALUES (201, 101, 2, 0)',
      );

      // Card 2: Note 2, Cloze c1 in Computer Science
      sqliteDb.execute(
        'INSERT INTO cards (id, nid, did, ord) VALUES (202, 102, 2, 0)',
      );

      // Card 3: Note 2, Cloze c2 in Computer Science
      sqliteDb.execute(
        'INSERT INTO cards (id, nid, did, ord) VALUES (203, 102, 2, 1)',
      );

      // Card 4: Note 3 in Languages::Italian
      sqliteDb.execute(
        'INSERT INTO cards (id, nid, did, ord) VALUES (204, 103, 3, 0)',
      );
    } finally {
      sqliteDb.close();
    }

    // Zip into .apkg
    final archive = Archive();
    final dbBytes = dbFile.readAsBytesSync();
    archive.addFile(ArchiveFile('collection.anki2', dbBytes.length, dbBytes));

    final zipBytes = ZipEncoder().encode(archive);
    return zipBytes;
  }

  group('AnkiPackageService Unit Tests', () {
    test(
      'successfully imports .apkg with Basic, Cloze, tags, and decks',
      () async {
        final apkgBytes = createSampleApkgBytes();

        final result = await ankiService.importApkgBytes(apkgBytes);

        expect(
          result.decksCreated,
          equals(2),
        ); // Computer Science and Languages - Italian
        expect(result.cardsImported, equals(4));
        expect(result.skippedCount, equals(0));
        expect(
          result.tagsCreated,
          greaterThanOrEqualTo(3),
        ); // programming, flutter, lang, dart, vocab

        // Verify decks in database
        final decks = await db.select(db.decks).get();
        expect(decks.any((d) => d.name == 'Computer Science'), isTrue);
        expect(decks.any((d) => d.name == 'Languages - Italian'), isTrue);

        // Verify cards in database
        final cards = await db.select(db.cards).get();
        expect(cards.length, equals(4));

        // Verify Basic card
        final basicCard = cards.firstWhere(
          (c) => c.front == 'What is Flutter?',
        );
        expect(basicCard.back, equals('UI framework by Google'));
        expect(basicCard.clozeIndex, isNull);
        expect(basicCard.noteId, equals(101));
        expect(basicCard.state, equals(0)); // New
        expect(basicCard.stability, equals(0.0));

        // Verify Cloze cards
        final cloze1 = cards.firstWhere((c) => c.clozeIndex == 1);
        expect(cloze1.front, contains('{{c1::Dart}}'));
        expect(cloze1.back, equals('Language note'));
        expect(cloze1.noteId, equals(102));

        final cloze2 = cards.firstWhere((c) => c.clozeIndex == 2);
        expect(cloze2.front, contains('{{c2::Google}}'));
        expect(cloze2.noteId, equals(102));

        // Verify HTML sanitized card
        final htmlCard = cards.firstWhere((c) => c.front.contains('**Ciao**'));
        expect(htmlCard.front, equals('**Ciao** means'));
        expect(htmlCard.back, equals('*Hello* or *Goodbye*'));
        expect(htmlCard.noteId, equals(103));

        // Verify tags
        final tags = await db.select(db.tags).get();
        expect(tags.any((t) => t.name == 'flutter'), isTrue);
        expect(tags.any((t) => t.name == 'vocab'), isTrue);

        // Verify card-tag relationships
        final cardTags = await db.select(db.cardTags).get();
        expect(cardTags.isNotEmpty, isTrue);
      },
    );

    test('imports all cards into specified targetDeckId', () async {
      final customDeckId = await db.decksDao.createDeck(name: 'My Target Deck');
      final apkgBytes = createSampleApkgBytes();

      final result = await ankiService.importApkgBytes(
        apkgBytes,
        targetDeckId: customDeckId,
      );

      expect(result.decksCreated, equals(0));
      expect(result.cardsImported, equals(4));

      final cards = await db.select(db.cards).get();
      for (final card in cards) {
        expect(card.deckId, equals(customDeckId));
      }
    });

    test('throws FormatException when archive is not a valid zip', () async {
      final invalidBytes = [1, 2, 3, 4, 5];
      expect(
        () => ankiService.importApkgBytes(invalidBytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('imports successfully from a File instance', () async {
      final apkgBytes = createSampleApkgBytes();
      final file = File(p.join(tempTestDir.path, 'test_deck.apkg'));
      await file.writeAsBytes(apkgBytes);

      final result = await ankiService.importApkgFile(file);
      expect(result.cardsImported, equals(4));
    });

    test(
      'throws FormatException when collection database is corrupted',
      () async {
        final archive = Archive();
        archive.addFile(
          ArchiveFile('collection.anki2', 10, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        );
        final corruptedZip = ZipEncoder().encode(archive);

        expect(
          () => ankiService.importApkgBytes(corruptedZip),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
