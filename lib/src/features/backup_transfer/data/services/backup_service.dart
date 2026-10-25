import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show compute;

import '../../../../core/database/app_database.dart';
import '../../domain/models/backup_payload.dart';

String _encodeJsonPayload(Map<String, dynamic> json) =>
    const JsonEncoder.withIndent('  ').convert(json);

BackupPayload _decodeJsonPayload(String jsonString) {
  final Map<String, dynamic> decoded;
  try {
    decoded = jsonDecode(jsonString) as Map<String, dynamic>;
  } catch (e) {
    throw FormatException('Invalid JSON format: $e');
  }
  return BackupPayload.fromJson(decoded);
}

String _encodeCsvRows(List<List<dynamic>> rows) => csv.encode(rows);

List<List<dynamic>> _decodeCsvRows(String csvString) => csv.decode(csvString);

/// Under this size, encode/decode stays on the main isolate: the cost of
/// spawning a worker isolate outweighs the parsing cost.
const int _offloadThresholdChars = 256 * 1024;
const int _offloadThresholdRows = 2000;

class BackupService {
  const BackupService(this.db);

  final AppDatabase db;

  Future<String> exportJsonPayload({DateTime? now}) async {
    final results = await Future.wait([
      db.select(db.decks).get(),
      db.select(db.cards).get(),
      db.select(db.reviewLogs).get(),
      db.select(db.tags).get(),
      db.select(db.cardTags).get(),
    ]);

    final decksList = results[0] as List<Deck>;
    final cardsList = results[1] as List<Card>;
    final reviewLogsList = results[2] as List<ReviewLog>;
    final tagsList = results[3] as List<Tag>;
    final cardTagsList = results[4] as List<CardTag>;

    final payload = BackupPayload(
      version: 1,
      exportedAt: (now ?? DateTime.now()).toUtc(),
      decks: decksList,
      cards: cardsList,
      reviewLogs: reviewLogsList,
      tags: tagsList,
      cardTags: cardTagsList,
    );

    final json = payload.toJson();
    final totalRows =
        payload.decks.length +
        payload.cards.length +
        payload.reviewLogs.length +
        payload.tags.length +
        payload.cardTags.length;
    if (totalRows < _offloadThresholdRows) {
      return _encodeJsonPayload(json);
    }
    return compute(_encodeJsonPayload, json);
  }

  Future<void> importJsonPayload(
    String jsonString, {
    bool replaceExisting = true,
  }) async {
    final payload = jsonString.length < _offloadThresholdChars
        ? _decodeJsonPayload(jsonString)
        : await compute(_decodeJsonPayload, jsonString);

    await db.transaction(() async {
      if (replaceExisting) {
        await db.delete(db.cardTags).go();
        await db.delete(db.tags).go();
        await db.delete(db.reviewLogs).go();
        await db.delete(db.cards).go();
        await db.delete(db.decks).go();

        final validDeckIds = payload.decks.map((d) => d.id).toSet();
        final deckCompanions = [
          for (final d in payload.decks) d.toCompanion(false),
        ];

        final validCards = payload.cards
            .where((c) => validDeckIds.contains(c.deckId))
            .toList();
        final validCardIds = validCards.map((c) => c.id).toSet();
        final cardCompanions = [
          for (final c in validCards) c.toCompanion(false),
        ];

        final validLogs = payload.reviewLogs
            .where((l) => validCardIds.contains(l.cardId))
            .toList();
        final logCompanions = [for (final l in validLogs) l.toCompanion(false)];

        final validTagIds = payload.tags.map((t) => t.id).toSet();
        final tagCompanions = [
          for (final t in payload.tags) t.toCompanion(false),
        ];

        final cardTagCompanions = [
          for (final ct in payload.cardTags)
            if (validCardIds.contains(ct.cardId) &&
                validTagIds.contains(ct.tagId))
              ct.toCompanion(false),
        ];

        await db.batch((batch) {
          if (deckCompanions.isNotEmpty) {
            batch.insertAll(db.decks, deckCompanions);
          }
          if (cardCompanions.isNotEmpty) {
            batch.insertAll(db.cards, cardCompanions);
          }
          if (logCompanions.isNotEmpty) {
            batch.insertAll(db.reviewLogs, logCompanions);
          }
          if (tagCompanions.isNotEmpty) {
            batch.insertAll(db.tags, tagCompanions);
          }
          if (cardTagCompanions.isNotEmpty) {
            batch.insertAll(
              db.cardTags,
              cardTagCompanions,
              mode: InsertMode.insertOrIgnore,
            );
          }
        });
        return;
      }

      // Merge mode: match existing rows for idempotency and batch inserts
      final existingDecks = await db.select(db.decks).get();
      final existingCards = await db.select(db.cards).get();
      final existingLogs = await db.select(db.reviewLogs).get();
      final existingTags = await db.select(db.tags).get();
      final existingCardTags = await db.select(db.cardTags).get();

      final existingDecksById = {for (final d in existingDecks) d.id: d};
      final existingDecksByName = {for (final d in existingDecks) d.name: d};
      int nextDeckId =
          existingDecks.fold(0, (max, d) => d.id > max ? d.id : max) + 1;

      final deckIdMap = <int, int>{};
      final newDeckCompanions = <DecksCompanion>[];

      for (final deck in payload.decks) {
        if (existingDecksById.containsKey(deck.id) &&
            existingDecksById[deck.id]!.name == deck.name) {
          deckIdMap[deck.id] = deck.id;
        } else if (existingDecksByName.containsKey(deck.name)) {
          deckIdMap[deck.id] = existingDecksByName[deck.name]!.id;
        } else {
          final int assignedId;
          if (!existingDecksById.containsKey(deck.id)) {
            assignedId = deck.id;
            if (assignedId >= nextDeckId) nextDeckId = assignedId + 1;
          } else {
            assignedId = nextDeckId++;
          }
          deckIdMap[deck.id] = assignedId;
          final assignedDeck = deck.copyWith(id: assignedId);
          newDeckCompanions.add(assignedDeck.toCompanion(false));
          existingDecksById[assignedId] = assignedDeck;
        }
      }

      final existingCardsById = {for (final c in existingCards) c.id: c};
      final existingCardsByContent = {
        for (final c in existingCards)
          '${c.deckId}__${c.front}__${c.back}__${c.clozeIndex}': c,
      };
      int nextCardId =
          existingCards.fold(0, (max, c) => c.id > max ? c.id : max) + 1;

      final cardIdMap = <int, int>{};
      final newCardCompanions = <CardsCompanion>[];

      for (final card in payload.cards) {
        final targetDeckId = deckIdMap[card.deckId];
        if (targetDeckId == null) {
          // Reject cards referencing unknown deckIds: never attach by raw numeric id!
          continue;
        }

        final contentKey =
            '${targetDeckId}__${card.front}__${card.back}__${card.clozeIndex}';
        Card? existingCard;
        if (existingCardsById.containsKey(card.id) &&
            existingCardsById[card.id]!.deckId == targetDeckId) {
          existingCard = existingCardsById[card.id];
        } else if (existingCardsByContent.containsKey(contentKey)) {
          existingCard = existingCardsByContent[contentKey];
        }

        if (existingCard != null) {
          cardIdMap[card.id] = existingCard.id;
        } else {
          final int assignedId;
          if (!existingCardsById.containsKey(card.id)) {
            assignedId = card.id;
            if (assignedId >= nextCardId) nextCardId = assignedId + 1;
          } else {
            assignedId = nextCardId++;
          }
          cardIdMap[card.id] = assignedId;
          final assignedCard = card.copyWith(
            id: assignedId,
            deckId: targetDeckId,
          );
          newCardCompanions.add(assignedCard.toCompanion(false));
          existingCardsById[assignedId] = assignedCard;
          existingCardsByContent[contentKey] = assignedCard;
        }
      }

      final existingLogsByKey = {
        for (final l in existingLogs)
          '${l.cardId}__${l.reviewedAt.toUtc().millisecondsSinceEpoch}': l,
      };
      int nextLogId =
          existingLogs.fold(0, (max, l) => l.id > max ? l.id : max) + 1;
      final newLogCompanions = <ReviewLogsCompanion>[];

      for (final log in payload.reviewLogs) {
        final targetCardId = cardIdMap[log.cardId];
        if (targetCardId == null) {
          continue;
        }

        final logKey =
            '${targetCardId}__${log.reviewedAt.toUtc().millisecondsSinceEpoch}';
        if (existingLogsByKey.containsKey(logKey)) {
          continue;
        }

        final int assignedId;
        if (nextLogId <= log.id) nextLogId = log.id + 1;
        assignedId = nextLogId++;

        final assignedLog = log.copyWith(id: assignedId, cardId: targetCardId);
        newLogCompanions.add(assignedLog.toCompanion(false));
        existingLogsByKey[logKey] = assignedLog;
      }

      final existingTagsByName = {for (final t in existingTags) t.name: t};
      final existingTagsById = {for (final t in existingTags) t.id: t};
      int nextTagId =
          existingTags.fold(0, (max, t) => t.id > max ? t.id : max) + 1;
      final tagIdMap = <int, int>{};
      final newTagCompanions = <TagsCompanion>[];

      for (final tag in payload.tags) {
        if (existingTagsByName.containsKey(tag.name)) {
          tagIdMap[tag.id] = existingTagsByName[tag.name]!.id;
        } else {
          final int assignedId;
          if (!existingTagsById.containsKey(tag.id)) {
            assignedId = tag.id;
            if (assignedId >= nextTagId) nextTagId = assignedId + 1;
          } else {
            assignedId = nextTagId++;
          }
          tagIdMap[tag.id] = assignedId;
          final assignedTag = tag.copyWith(id: assignedId);
          newTagCompanions.add(assignedTag.toCompanion(false));
          existingTagsByName[tag.name] = assignedTag;
          existingTagsById[assignedId] = assignedTag;
        }
      }

      final existingCardTagKeys = {
        for (final ct in existingCardTags) '${ct.cardId}__${ct.tagId}',
      };
      final newCardTagCompanions = <CardTagsCompanion>[];

      for (final ct in payload.cardTags) {
        final targetCardId = cardIdMap[ct.cardId];
        final targetTagId = tagIdMap[ct.tagId];
        if (targetCardId != null && targetTagId != null) {
          final key = '${targetCardId}__$targetTagId';
          if (!existingCardTagKeys.contains(key)) {
            existingCardTagKeys.add(key);
            newCardTagCompanions.add(
              CardTagsCompanion.insert(
                cardId: targetCardId,
                tagId: targetTagId,
              ),
            );
          }
        }
      }

      await db.batch((batch) {
        if (newDeckCompanions.isNotEmpty) {
          batch.insertAll(db.decks, newDeckCompanions);
        }
        if (newCardCompanions.isNotEmpty) {
          batch.insertAll(db.cards, newCardCompanions);
        }
        if (newLogCompanions.isNotEmpty) {
          batch.insertAll(db.reviewLogs, newLogCompanions);
        }
        if (newTagCompanions.isNotEmpty) {
          batch.insertAll(db.tags, newTagCompanions);
        }
        if (newCardTagCompanions.isNotEmpty) {
          batch.insertAll(
            db.cardTags,
            newCardTagCompanions,
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
    });
  }

  Future<String> exportCardsToCsv({int? deckId}) async {
    final query = db.select(db.cards).join([
      innerJoin(db.decks, db.decks.id.equalsExp(db.cards.deckId)),
    ]);

    if (deckId != null) {
      query.where(db.cards.deckId.equals(deckId));
    }

    final rows = await query.get();
    final csvData = <List<dynamic>>[
      ['Front', 'Back', 'DeckName'],
      for (final row in rows)
        [
          row.readTable(db.cards).front,
          row.readTable(db.cards).back,
          row.readTable(db.decks).name,
        ],
    ];

    if (csvData.length < _offloadThresholdRows) {
      return _encodeCsvRows(csvData);
    }
    return compute(_encodeCsvRows, csvData);
  }

  Future<CsvImportResult> importCardsFromCsv(
    String csvString, {
    required int targetDeckId,
    DateTime? now,
  }) async {
    final parsedRows = csvString.length < _offloadThresholdChars
        ? _decodeCsvRows(csvString)
        : await compute(_decodeCsvRows, csvString);

    if (parsedRows.isEmpty) {
      return const CsvImportResult(importedCount: 0, skippedCount: 0);
    }

    int importedCount = 0;
    int skippedCount = 0;

    int startIndex = 0;
    final firstRow = parsedRows.first;
    if (firstRow.isNotEmpty &&
        firstRow[0].toString().trim().toLowerCase() == 'front') {
      startIndex = 1;
    }

    final effectiveNow = (now ?? DateTime.now()).toUtc();

    final companions = <CardsCompanion>[];
    for (int i = startIndex; i < parsedRows.length; i++) {
      final row = parsedRows[i];
      if (row.length < 2) {
        skippedCount++;
        continue;
      }

      final front = row[0].toString().trim();
      final back = row[1].toString().trim();

      if (front.isEmpty || back.isEmpty) {
        skippedCount++;
        continue;
      }

      companions.add(
        CardsCompanion.insert(
          deckId: targetDeckId,
          front: front,
          back: back,
          state: const Value(0),
          stability: const Value(0.0),
          difficulty: const Value(0.0),
          easinessFactor: const Value(2.5),
          due: effectiveNow,
          reps: const Value(0),
          lapses: const Value(0),
          createdAt: Value(effectiveNow),
        ),
      );
      importedCount++;
    }

    if (companions.isNotEmpty) {
      await db.batch((batch) {
        batch.insertAll(db.cards, companions);
      });
    }

    return CsvImportResult(
      importedCount: importedCount,
      skippedCount: skippedCount,
    );
  }
}
