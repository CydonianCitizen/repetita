import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../../../core/database/app_database.dart';

/// Service responsible for exporting Repetita cards and decks into Anki (.apkg) format.
class AnkiExportService {
  const AnkiExportService(this.db);

  final AppDatabase db;

  /// Exports cards of a specific [deckId] (and optionally its subdecks) to .apkg bytes.
  Future<List<int>> exportDeckToApkg(
    int deckId, {
    bool includeRevlog = false,
    bool includeSubdecks = true,
  }) async {
    final deck = await (db.select(
      db.decks,
    )..where((d) => d.id.equals(deckId))).getSingleOrNull();
    if (deck == null) {
      throw ArgumentError('Deck with ID $deckId not found.');
    }

    final List<Deck> targetDecks;
    if (includeSubdecks) {
      final allDecks = await db.select(db.decks).get();
      targetDecks = allDecks.where((d) {
        return d.id == deck.id || d.name.startsWith('${deck.name}::');
      }).toList();
    } else {
      targetDecks = [deck];
    }

    return _buildApkgForDecks(targetDecks, includeRevlog: includeRevlog);
  }

  /// Exports all decks and cards to a single .apkg package.
  Future<List<int>> exportAllToApkg({bool includeRevlog = false}) async {
    final allDecks = await db.select(db.decks).get();
    if (allDecks.isEmpty) {
      throw StateError('No decks found to export.');
    }
    return _buildApkgForDecks(allDecks, includeRevlog: includeRevlog);
  }

  Future<List<int>> _buildApkgForDecks(
    List<Deck> targetDecks, {
    required bool includeRevlog,
  }) async {
    final targetDeckIds = targetDecks.map((d) => d.id).toSet();

    // Query cards
    final cards = await (db.select(
      db.cards,
    )..where((c) => c.deckId.isIn(targetDeckIds))).get();

    // Query tags per card
    final cardTagsQuery = (db.select(db.cardTags).join([
      innerJoin(db.tags, db.tags.id.equalsExp(db.cardTags.tagId)),
    ]))..where(db.cardTags.cardId.isIn(cards.map((c) => c.id).toSet()));

    final tagsByCard = <int, List<String>>{};
    for (final row in await cardTagsQuery.get()) {
      final cId = row.readTable(db.cardTags).cardId;
      final tName = row.readTable(db.tags).name;
      tagsByCard.putIfAbsent(cId, () => []).add(tName);
    }

    // Temporary working directory to create SQLite database
    final tempDir = Directory.systemTemp.createTempSync('repetita_export_');
    final tempDbFile = File(p.join(tempDir.path, 'collection.anki2'));

    try {
      final ankiDb = sqlite.sqlite3.open(tempDbFile.path);
      try {
        _createAnkiSchema(ankiDb);
        _populateColTable(ankiDb, targetDecks);
        _populateNotesAndCards(ankiDb, cards, targetDecks, tagsByCard);

        if (includeRevlog && cards.isNotEmpty) {
          await _populateRevlog(ankiDb, cards.map((c) => c.id).toSet());
        }
      } finally {
        ankiDb.close();
      }

      final collectionBytes = await tempDbFile.readAsBytes();

      // Package into ZIP
      final archive = Archive();
      archive.addFile(
        ArchiveFile(
          'collection.anki2',
          collectionBytes.length,
          collectionBytes,
        ),
      );
      archive.addFile(ArchiveFile.string('media', '{}'));

      final zipData = ZipEncoder().encode(archive);
      return zipData;
    } finally {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    }
  }

  void _createAnkiSchema(sqlite.Database ankiDb) {
    ankiDb.execute('''
      CREATE TABLE col (
        id integer primary key,
        crt integer not null,
        mod integer not null,
        scm integer not null,
        ver integer not null,
        dty integer not null,
        usn integer not null,
        ls integer not null,
        conf text not null,
        models text not null,
        decks text not null,
        dconf text not null,
        tags text not null
      );
      CREATE TABLE notes (
        id integer primary key,
        guid text not null,
        mid integer not null,
        mod integer not null,
        usn integer not null,
        tags text not null,
        flds text not null,
        sfld text not null,
        csum integer not null,
        flags integer not null,
        data text not null
      );
      CREATE TABLE cards (
        id integer primary key,
        nid integer not null,
        did integer not null,
        ord integer not null,
        mod integer not null,
        usn integer not null,
        type integer not null,
        queue integer not null,
        due integer not null,
        ivl integer not null,
        factor integer not null,
        reps integer not null,
        lapses integer not null,
        left integer not null,
        odue integer not null,
        odid integer not null,
        flags integer not null,
        data text not null
      );
      CREATE TABLE revlog (
        id integer primary key,
        cid integer not null,
        usn integer not null,
        ease integer not null,
        ivl integer not null,
        lastIvl integer not null,
        factor integer not null,
        time integer not null,
        type integer not null
      );
      CREATE INDEX ix_notes_usn on notes (usn);
      CREATE INDEX ix_cards_usn on cards (usn);
      CREATE INDEX ix_cards_nid on cards (nid);
      CREATE INDEX ix_cards_sched on cards (did, queue, due);
      CREATE INDEX ix_revlog_usn on revlog (usn);
      CREATE INDEX ix_revlog_cid on revlog (cid);
    ''');
  }

  void _populateColTable(sqlite.Database ankiDb, List<Deck> targetDecks) {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Define standard models (Basic and Cloze)
    final models = {
      '1600000000000': {
        'id': 1600000000000,
        'name': 'Basic',
        'type': 0,
        'mod': nowSeconds,
        'usn': -1,
        'sortf': 0,
        'did': targetDecks.first.id,
        'tmpls': [
          {
            'name': 'Card 1',
            'ord': 0,
            'qfmt': '{{Front}}',
            'afmt': '{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}',
            'bqfmt': '',
            'bafmt': '',
            'did': null,
          },
        ],
        'flds': [
          {
            'name': 'Front',
            'ord': 0,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20,
          },
          {
            'name': 'Back',
            'ord': 1,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20,
          },
        ],
        'css': '.card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }',
      },
      '1600000000001': {
        'id': 1600000000001,
        'name': 'Cloze',
        'type': 1,
        'mod': nowSeconds,
        'usn': -1,
        'sortf': 0,
        'did': targetDecks.first.id,
        'tmpls': [
          {
            'name': 'Cloze',
            'ord': 0,
            'qfmt': '{{cloze:Text}}',
            'afmt': '{{cloze:Text}}\n\n<hr id=answer>\n\n{{Extra}}',
            'bqfmt': '',
            'bafmt': '',
            'did': null,
          },
        ],
        'flds': [
          {
            'name': 'Text',
            'ord': 0,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20,
          },
          {
            'name': 'Extra',
            'ord': 1,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20,
          },
        ],
        'css': '.cloze { font-weight: bold; color: blue; }',
      },
    };

    final decks = <String, dynamic>{};
    for (final d in targetDecks) {
      decks[d.id.toString()] = {
        'id': d.id,
        'name': d.name,
        'desc': d.description ?? '',
        'mod': nowSeconds,
        'usn': -1,
        'collapsed': false,
      };
    }

    final dconf = {
      '1': {
        'id': 1,
        'mod': nowSeconds,
        'name': 'Default',
        'usn': 0,
        'maxTaken': 60,
        'autoplay': true,
        'timer': 0,
        'replayq': true,
        'new': {
          'bury': false,
          'delays': [1.0, 10.0],
          'initialFactor': 2500,
          'ints': [1, 4, 0],
          'order': 1,
          'perDay': 20,
        },
        'rev': {
          'bury': false,
          'ease4': 1.3,
          'ivlFctr': 1.0,
          'maxIvl': 36500,
          'perDay': 200,
        },
        'lapse': {
          'delays': [10.0],
          'leechAction': 0,
          'leechFails': 8,
          'minInt': 1,
          'mult': 0.0,
        },
      },
    };

    final conf = {
      'nextPos': 1,
      'estTimes': true,
      'activeDecks': [targetDecks.first.id],
      'sortType': 'noteFld',
      'timeLim': 0,
      'sortBackwards': false,
      'addToCur': true,
      'curDeck': targetDecks.first.id,
      'curModel': 1600000000000,
    };

    ankiDb.execute(
      'INSERT INTO col VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        1,
        nowSeconds,
        nowSeconds,
        nowSeconds,
        11,
        0,
        0,
        0,
        jsonEncode(conf),
        jsonEncode(models),
        jsonEncode(decks),
        jsonEncode(dconf),
        '{}',
      ],
    );
  }

  void _populateNotesAndCards(
    sqlite.Database ankiDb,
    List<Card> cards,
    List<Deck> targetDecks,
    Map<int, List<String>> tagsByCard,
  ) {
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final noteStmt = ankiDb.prepare(
      'INSERT INTO notes VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    );
    final cardStmt = ankiDb.prepare(
      'INSERT INTO cards VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    );

    try {
      final noteIdToAnkiNoteId = <int, int>{};
      int autoNoteCounter = nowMs;

      for (int i = 0; i < cards.length; i++) {
        final card = cards[i];
        final tags = tagsByCard[card.id] ?? [];
        final tagsStr = tags.isNotEmpty ? ' ${tags.join(' ')} ' : '';

        final isCloze = card.clozeIndex != null && card.front.contains('{{c');
        final modelId = isCloze ? 1600000000001 : 1600000000000;

        int ankiNoteId;
        if (card.noteId != null &&
            noteIdToAnkiNoteId.containsKey(card.noteId)) {
          ankiNoteId = noteIdToAnkiNoteId[card.noteId]!;
        } else {
          autoNoteCounter++;
          ankiNoteId = autoNoteCounter;
          if (card.noteId != null) {
            noteIdToAnkiNoteId[card.noteId!] = ankiNoteId;
          }

          final flds = '${card.front}\x1f${card.back}';
          final sfld = card.front.length > 50
              ? card.front.substring(0, 50)
              : card.front;
          final csum = _checksum(sfld);
          final guid = _generateGuid(card.id, ankiNoteId);

          noteStmt.execute([
            ankiNoteId,
            guid,
            modelId,
            nowSeconds,
            -1,
            tagsStr,
            flds,
            sfld,
            csum,
            0,
            '',
          ]);
        }

        final factor = (card.easinessFactor * 1000).round();
        final dueDays = card.due
            .difference(DateTime.fromMillisecondsSinceEpoch(0))
            .inDays;
        final ord = card.clozeIndex != null ? (card.clozeIndex! - 1) : 0;
        final cardAnkiId = autoNoteCounter * 10 + i;

        cardStmt.execute([
          cardAnkiId,
          ankiNoteId,
          card.deckId,
          ord < 0 ? 0 : ord,
          nowSeconds,
          -1,
          card.state, // type
          card.isSuspended
              ? -1
              : (card.state == 0
                    ? 0
                    : 2), // queue: -1 suspended, 0 new, 2 review
          card.state == 0 ? (i + 1) : dueDays, // due
          0, // ivl
          factor,
          card.reps,
          card.lapses,
          0, // left
          0, // odue
          0, // odid
          card.flag, // flags
          '',
        ]);
      }
    } finally {
      noteStmt.close();
      cardStmt.close();
    }
  }

  Future<void> _populateRevlog(sqlite.Database ankiDb, Set<int> cardIds) async {
    final logs = await (db.select(
      db.reviewLogs,
    )..where((l) => l.cardId.isIn(cardIds))).get();

    final stmt = ankiDb.prepare(
      'INSERT INTO revlog VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    );
    try {
      for (final log in logs) {
        final id = log.reviewedAt.millisecondsSinceEpoch;
        final factor = ((log.easinessFactor) * 1000).round();
        stmt.execute([
          id,
          log.cardId,
          -1,
          log.rating,
          log.scheduledDays, // ivl
          log.lastElapsedDays, // lastIvl
          factor,
          10000, // time in ms
          log.state, // type
        ]);
      }
    } finally {
      stmt.close();
    }
  }

  int _checksum(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = (31 * hash + text.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  String _generateGuid(int cardId, int noteId) {
    final raw = '$cardId:$noteId:${DateTime.now().microsecondsSinceEpoch}';
    return base64Url
        .encode(utf8.encode(raw))
        .replaceAll('=', '')
        .substring(0, 10);
  }
}
