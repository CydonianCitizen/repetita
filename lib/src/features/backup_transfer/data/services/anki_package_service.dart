import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../../../../core/database/app_database.dart';
import '../../domain/models/anki_models.dart';
import '../../domain/services/anki_html_sanitizer.dart';

/// Service responsible for importing Anki packages (.apkg) into Repetita.
class AnkiPackageService {
  const AnkiPackageService(this.db);

  final AppDatabase db;

  /// Imports an Anki package (.apkg) from raw bytes.
  /// If [targetDeckId] is provided, all imported cards are assigned to that deck.
  /// Otherwise, decks are automatically resolved or created from the Anki collection.
  Future<AnkiImportResult> importApkgBytes(
    List<int> bytes, {
    int? targetDeckId,
    DateTime? now,
  }) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes, verify: false);
    } catch (e) {
      throw FormatException('Failed to decompress .apkg archive: $e');
    }

    ArchiveFile? sqliteEntry;
    for (final file in archive) {
      if (file.name == 'collection.anki2') {
        sqliteEntry = file;
        break;
      } else if (file.name == 'collection.anki21') {
        sqliteEntry = file;
      }
    }

    if (sqliteEntry == null) {
      throw const FormatException(
        'Invalid Anki package: collection.anki2 SQLite database not found.',
      );
    }

    final tempDir = Directory.systemTemp.createTempSync('repetita_anki_');
    final tempDbFile = File(p.join(tempDir.path, 'collection.anki2'));

    try {
      final content = sqliteEntry.content;
      await tempDbFile.writeAsBytes(content);

      return await _processAnkiDatabase(
        tempDbFile.path,
        targetDeckId: targetDeckId,
        now: now,
      );
    } finally {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    }
  }

  /// Imports an Anki package (.apkg) from a file.
  Future<AnkiImportResult> importApkgFile(
    File file, {
    int? targetDeckId,
    DateTime? now,
  }) async {
    final bytes = await file.readAsBytes();
    return importApkgBytes(bytes, targetDeckId: targetDeckId, now: now);
  }

  Future<AnkiImportResult> _processAnkiDatabase(
    String dbPath, {
    int? targetDeckId,
    DateTime? now,
  }) async {
    final sqlite.Database ankiDb;
    try {
      ankiDb = sqlite.sqlite3.open(dbPath);
    } catch (e) {
      throw FormatException('Failed to open Anki collection database: $e');
    }

    try {
      // 1. Read 'col' table
      final colRows = ankiDb.select('SELECT models, decks FROM col LIMIT 1');
      if (colRows.isEmpty) {
        throw const FormatException('Anki database col table is empty.');
      }

      final colRow = colRows.first;
      final modelsJsonStr = colRow['models'] as String? ?? '{}';
      final decksJsonStr = colRow['decks'] as String? ?? '{}';

      final Map<int, String> ankiDecks = _parseDecks(decksJsonStr);
      final Map<int, AnkiRawModel> ankiModels = _parseModels(modelsJsonStr);

      // 2. Read 'notes' table
      final noteRows = ankiDb.select('SELECT id, mid, tags, flds FROM notes');
      final notesMap = <int, AnkiRawNote>{};
      for (final row in noteRows) {
        final id = row['id'] as int;
        final mid = row['mid'] as int;
        final tagsStr = row['tags'] as String? ?? '';
        final fldsStr = row['flds'] as String? ?? '';

        final fields = fldsStr.split('\x1f');
        final tags = tagsStr
            .trim()
            .split(RegExp(r'\s+'))
            .where((t) => t.isNotEmpty)
            .toList();

        notesMap[id] = AnkiRawNote(
          id: id,
          modelId: mid,
          fields: fields,
          tags: tags,
        );
      }

      // 3. Read 'cards' table
      final cardRows = ankiDb.select(
        'SELECT id, nid, did, ord, factor FROM cards',
      );
      final parsedCards = <AnkiParsedCard>[];
      int skipped = 0;

      if (cardRows.isNotEmpty) {
        for (final row in cardRows) {
          final nid = row['nid'] as int;
          final did = row['did'] as int;
          final ord = row['ord'] as int;
          final factor = (row['factor'] as num?)?.toInt() ?? 2500;
          final ef = factor > 0 ? (factor / 1000.0) : 2.5;

          final note = notesMap[nid];
          if (note == null) {
            skipped++;
            continue;
          }

          final model = ankiModels[note.modelId];
          final synthesized = _synthesizeCard(
            note: note,
            model: model,
            ord: ord,
            did: did,
            decks: ankiDecks,
            easinessFactor: ef,
          );

          if (synthesized != null) {
            parsedCards.add(synthesized);
          } else {
            skipped++;
          }
        }
      } else {
        // Fallback for collections with notes only
        for (final note in notesMap.values) {
          final model = ankiModels[note.modelId];
          final synthesized = _synthesizeCard(
            note: note,
            model: model,
            ord: 0,
            did: 1,
            decks: ankiDecks,
          );
          if (synthesized != null) {
            parsedCards.add(synthesized);
          } else {
            skipped++;
          }
        }
      }

      if (parsedCards.isEmpty) {
        return AnkiImportResult(
          decksCreated: 0,
          cardsImported: 0,
          tagsCreated: 0,
          skippedCount: skipped,
          deckNames: const [],
        );
      }

      // 4. Save into Drift DB in an atomic transaction
      return await _persistParsedCards(
        parsedCards,
        targetDeckId: targetDeckId,
        skippedCount: skipped,
        now: now,
      );
    } on sqlite.SqliteException catch (e) {
      throw FormatException('Corrupted Anki collection database: ${e.message}');
    } finally {
      ankiDb.close();
    }
  }

  Map<int, String> _parseDecks(String decksJsonStr) {
    final decks = <int, String>{};
    try {
      final decoded = jsonDecode(decksJsonStr) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final val = entry.value as Map<String, dynamic>;
        final id = (val['id'] as num?)?.toInt() ?? int.tryParse(entry.key) ?? 1;
        final name = (val['name'] as String?)?.trim() ?? 'Anki Deck';
        decks[id] = name;
      }
    } catch (_) {}
    return decks;
  }

  Map<int, AnkiRawModel> _parseModels(String modelsJsonStr) {
    final models = <int, AnkiRawModel>{};
    try {
      final decoded = jsonDecode(modelsJsonStr) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final val = entry.value as Map<String, dynamic>;
        final id = (val['id'] as num?)?.toInt() ?? int.tryParse(entry.key) ?? 0;
        final name = (val['name'] as String?) ?? 'Basic';
        final type = (val['type'] as num?)?.toInt() ?? 0;

        final rawFlds = val['flds'] as List<dynamic>? ?? [];
        final fieldNames = rawFlds
            .map((f) => (f['name'] as String?) ?? '')
            .toList();

        final rawTmpls = val['tmpls'] as List<dynamic>? ?? [];
        final templates = rawTmpls
            .map(
              (t) => AnkiRawTemplate(
                name: (t['name'] as String?) ?? '',
                ord: (t['ord'] as num?)?.toInt() ?? 0,
                qfmt: (t['qfmt'] as String?) ?? '',
                afmt: (t['afmt'] as String?) ?? '',
              ),
            )
            .toList();

        models[id] = AnkiRawModel(
          id: id,
          name: name,
          type: type,
          fieldNames: fieldNames,
          templates: templates,
        );
      }
    } catch (_) {}
    return models;
  }

  AnkiParsedCard? _synthesizeCard({
    required AnkiRawNote note,
    required AnkiRawModel? model,
    required int ord,
    required int did,
    required Map<int, String> decks,
    double easinessFactor = 2.5,
  }) {
    String rawFront = '';
    String rawBack = '';
    int? clozeIndex;

    if (model != null && model.isCloze) {
      rawFront = note.fields.isNotEmpty ? note.fields[0] : '';
      rawBack = note.fields.length > 1 ? note.fields[1] : '';
      clozeIndex = ord + 1;
    } else {
      AnkiRawTemplate? tmpl;
      if (model != null && model.templates.isNotEmpty) {
        tmpl = model.templates.firstWhere(
          (t) => t.ord == ord,
          orElse: () => model.templates.first,
        );
      }

      final isReversed =
          tmpl != null &&
          (tmpl.name.toLowerCase().contains('reverse') ||
              tmpl.qfmt.toLowerCase().contains('{{back}}'));

      if (isReversed && note.fields.length > 1) {
        rawFront = note.fields[1];
        rawBack = note.fields[0];
      } else {
        rawFront = note.fields.isNotEmpty ? note.fields[0] : '';
        rawBack = note.fields.length > 1 ? note.fields[1] : '';
      }
    }

    final cleanFront = AnkiHtmlSanitizer.sanitize(rawFront);
    final cleanBack = AnkiHtmlSanitizer.sanitize(rawBack);

    if (cleanFront.isEmpty && cleanBack.isEmpty) {
      return null;
    }

    // Resolve clean deck name
    String deckName = decks[did] ?? 'Anki Deck';
    if (deckName == 'Default' && decks.length > 1) {
      deckName = decks.values.firstWhere(
        (n) => n != 'Default',
        orElse: () => 'Default',
      );
    }
    // Replace Anki's hierarchy separator :: with -
    deckName = deckName.replaceAll('::', ' - ').trim();
    if (deckName.isEmpty) deckName = 'Anki Deck';

    return AnkiParsedCard(
      front: cleanFront.isNotEmpty ? cleanFront : cleanBack,
      back: cleanBack,
      clozeIndex: clozeIndex,
      tags: note.tags,
      deckName: deckName,
      easinessFactor: easinessFactor,
      noteId: note.id,
    );
  }

  Future<AnkiImportResult> _persistParsedCards(
    List<AnkiParsedCard> cards, {
    int? targetDeckId,
    required int skippedCount,
    DateTime? now,
  }) async {
    final effectiveNow = (now ?? DateTime.now()).toUtc();

    return await db.transaction(() async {
      final deckIdMap = <String, int>{};
      int decksCreated = 0;
      final usedDeckNames = <String>{};

      if (targetDeckId != null) {
        final targetDeck = await (db.select(
          db.decks,
        )..where((d) => d.id.equals(targetDeckId))).getSingleOrNull();

        if (targetDeck == null) {
          throw ArgumentError('Target deck with ID $targetDeckId not found.');
        }

        for (final card in cards) {
          deckIdMap[card.deckName] = targetDeckId;
        }
        usedDeckNames.add(targetDeck.name);
      } else {
        final existingDecks = await db.select(db.decks).get();
        final deckNameMap = {for (final d in existingDecks) d.name: d.id};

        final uniqueNames = cards.map((c) => c.deckName).toSet();
        for (final name in uniqueNames) {
          if (deckNameMap.containsKey(name)) {
            deckIdMap[name] = deckNameMap[name]!;
          } else {
            final newId = await db.decksDao.createDeck(
              name: name,
              description: 'Imported from Anki',
            );
            deckIdMap[name] = newId;
            deckNameMap[name] = newId;
            decksCreated++;
          }
          usedDeckNames.add(name);
        }
      }

      // 2. Resolve / create Tags
      final distinctTags = cards.expand((c) => c.tags).toSet();
      final tagIdMap = <String, int>{};
      int tagsCreated = 0;

      for (final rawTag in distinctTags) {
        final cleanTag = rawTag.trim();
        if (cleanTag.isEmpty) continue;
        final cappedTag = cleanTag.length > 50
            ? cleanTag.substring(0, 50)
            : cleanTag;

        final existing = await (db.select(
          db.tags,
        )..where((t) => t.name.equals(cappedTag))).getSingleOrNull();

        if (existing != null) {
          tagIdMap[rawTag] = existing.id;
        } else {
          final tagId = await db.tagsDao.getOrCreateTag(cappedTag);
          tagIdMap[rawTag] = tagId;
          tagsCreated++;
        }
      }

      // 3. Insert cards and link tags
      int cardsImported = 0;
      for (final card in cards) {
        final deckId = deckIdMap[card.deckName]!;
        final cardId = await db
            .into(db.cards)
            .insert(
              CardsCompanion.insert(
                deckId: deckId,
                front: card.front,
                back: card.back,
                due: effectiveNow,
                state: const Value(0),
                stability: const Value(0.0),
                difficulty: const Value(0.0),
                reps: const Value(0),
                lapses: const Value(0),
                createdAt: Value(effectiveNow),
                isSuspended: const Value(false),
                clozeIndex: Value(card.clozeIndex),
                easinessFactor: Value(card.easinessFactor),
                noteId: Value(card.noteId),
              ),
            );
        cardsImported++;

        for (final tag in card.tags) {
          final tagId = tagIdMap[tag];
          if (tagId != null) {
            await db
                .into(db.cardTags)
                .insert(
                  CardTagsCompanion.insert(cardId: cardId, tagId: tagId),
                  mode: InsertMode.insertOrIgnore,
                );
          }
        }
      }

      return AnkiImportResult(
        decksCreated: decksCreated,
        cardsImported: cardsImported,
        tagsCreated: tagsCreated,
        skippedCount: skippedCount,
        deckNames: usedDeckNames.toList()..sort(),
      );
    });
  }
}
