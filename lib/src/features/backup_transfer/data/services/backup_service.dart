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
      decks: decksList
          .map(
            (d) => DeckPayload(
              id: d.id,
              name: d.name,
              description: d.description,
              createdAt: d.createdAt,
              updatedAt: d.updatedAt,
              examDate: d.examDate,
              targetRetention: d.targetRetention,
            ),
          )
          .toList(),
      cards: cardsList
          .map(
            (c) => CardPayload(
              id: c.id,
              deckId: c.deckId,
              front: c.front,
              back: c.back,
              state: c.state,
              stability: c.stability,
              difficulty: c.difficulty,
              easinessFactor: c.easinessFactor,
              due: c.due,
              lastReview: c.lastReview,
              reps: c.reps,
              lapses: c.lapses,
              createdAt: c.createdAt,
              isSuspended: c.isSuspended,
              buriedUntil: c.buriedUntil,
              clozeIndex: c.clozeIndex,
              flag: c.flag,
              noteId: c.noteId,
            ),
          )
          .toList(),
      reviewLogs: reviewLogsList
          .map(
            (r) => ReviewLogPayload(
              id: r.id,
              cardId: r.cardId,
              rating: r.rating,
              state: r.state,
              due: r.due,
              stability: r.stability,
              difficulty: r.difficulty,
              easinessFactor: r.easinessFactor,
              elapsedDays: r.elapsedDays,
              lastElapsedDays: r.lastElapsedDays,
              scheduledDays: r.scheduledDays,
              reviewedAt: r.reviewedAt,
            ),
          )
          .toList(),
      tags: tagsList
          .map(
            (t) => TagPayload(
              id: t.id,
              name: t.name,
              color: t.color,
              createdAt: t.createdAt,
            ),
          )
          .toList(),
      cardTags: cardTagsList
          .map((ct) => CardTagPayload(cardId: ct.cardId, tagId: ct.tagId))
          .toList(),
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
        final deckCompanions = <DecksCompanion>[
          for (final d in payload.decks)
            DecksCompanion.insert(
              id: Value(d.id),
              name: d.name,
              description: Value(d.description),
              createdAt: Value(d.createdAt),
              updatedAt: Value(d.updatedAt),
              examDate: Value(d.examDate),
              targetRetention: Value(d.targetRetention),
            ),
        ];

        final validCards = payload.cards
            .where((c) => validDeckIds.contains(c.deckId))
            .toList();
        final validCardIds = validCards.map((c) => c.id).toSet();
        final cardCompanions = <CardsCompanion>[
          for (final c in validCards)
            CardsCompanion.insert(
              id: Value(c.id),
              deckId: c.deckId,
              front: c.front,
              back: c.back,
              state: Value(c.state),
              stability: Value(c.stability),
              difficulty: Value(c.difficulty),
              due: c.due,
              lastReview: Value(c.lastReview),
              reps: Value(c.reps),
              lapses: Value(c.lapses),
              createdAt: Value(c.createdAt),
              isSuspended: Value(c.isSuspended),
              buriedUntil: Value(c.buriedUntil),
              clozeIndex: Value(c.clozeIndex),
              flag: Value(c.flag),
              noteId: Value(c.noteId),
            ),
        ];

        final validLogs = payload.reviewLogs
            .where((l) => validCardIds.contains(l.cardId))
            .toList();
        final logCompanions = <ReviewLogsCompanion>[
          for (final l in validLogs)
            ReviewLogsCompanion.insert(
              id: Value(l.id),
              cardId: l.cardId,
              rating: l.rating,
              state: l.state,
              due: l.due,
              stability: l.stability,
              difficulty: l.difficulty,
              elapsedDays: l.elapsedDays,
              lastElapsedDays: l.lastElapsedDays,
              scheduledDays: l.scheduledDays,
              reviewedAt: l.reviewedAt,
            ),
        ];

        final validTagIds = payload.tags.map((t) => t.id).toSet();
        final tagCompanions = <TagsCompanion>[
          for (final t in payload.tags)
            TagsCompanion.insert(
              id: Value(t.id),
              name: t.name,
              color: Value(t.color),
              createdAt: Value(t.createdAt),
            ),
        ];

        final cardTagCompanions = <CardTagsCompanion>[
          for (final ct in payload.cardTags)
            if (validCardIds.contains(ct.cardId) &&
                validTagIds.contains(ct.tagId))
              CardTagsCompanion.insert(cardId: ct.cardId, tagId: ct.tagId),
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
          newDeckCompanions.add(
            DecksCompanion.insert(
              id: Value(assignedId),
              name: deck.name,
              description: Value(deck.description),
              createdAt: Value(deck.createdAt),
              updatedAt: Value(deck.updatedAt),
              examDate: Value(deck.examDate),
              targetRetention: Value(deck.targetRetention),
            ),
          );
          existingDecksById[assignedId] = Deck(
            id: assignedId,
            name: deck.name,
            description: deck.description,
            createdAt: deck.createdAt,
            updatedAt: deck.updatedAt,
            examDate: deck.examDate,
            targetRetention: deck.targetRetention,
          );
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
          newCardCompanions.add(
            CardsCompanion.insert(
              id: Value(assignedId),
              deckId: targetDeckId,
              front: card.front,
              back: card.back,
              state: Value(card.state),
              stability: Value(card.stability),
              difficulty: Value(card.difficulty),
              easinessFactor: Value(card.easinessFactor),
              due: card.due,
              lastReview: Value(card.lastReview),
              reps: Value(card.reps),
              lapses: Value(card.lapses),
              createdAt: Value(card.createdAt),
              isSuspended: Value(card.isSuspended),
              buriedUntil: Value(card.buriedUntil),
              clozeIndex: Value(card.clozeIndex),
              flag: Value(card.flag),
              noteId: Value(card.noteId),
            ),
          );
          final addedCard = Card(
            id: assignedId,
            deckId: targetDeckId,
            front: card.front,
            back: card.back,
            state: card.state,
            stability: card.stability,
            difficulty: card.difficulty,
            easinessFactor: card.easinessFactor,
            due: card.due,
            lastReview: card.lastReview,
            reps: card.reps,
            lapses: card.lapses,
            createdAt: card.createdAt,
            isSuspended: card.isSuspended,
            buriedUntil: card.buriedUntil,
            clozeIndex: card.clozeIndex,
            flag: card.flag,
          );
          existingCardsById[assignedId] = addedCard;
          existingCardsByContent[contentKey] = addedCard;
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

        newLogCompanions.add(
          ReviewLogsCompanion.insert(
            id: Value(assignedId),
            cardId: targetCardId,
            rating: log.rating,
            state: log.state,
            due: log.due,
            stability: log.stability,
            difficulty: log.difficulty,
            easinessFactor: Value(log.easinessFactor),
            elapsedDays: log.elapsedDays,
            lastElapsedDays: log.lastElapsedDays,
            scheduledDays: log.scheduledDays,
            reviewedAt: log.reviewedAt,
          ),
        );
        existingLogsByKey[logKey] = ReviewLog(
          id: assignedId,
          cardId: targetCardId,
          rating: log.rating,
          state: log.state,
          due: log.due,
          stability: log.stability,
          difficulty: log.difficulty,
          easinessFactor: log.easinessFactor,
          elapsedDays: log.elapsedDays,
          lastElapsedDays: log.lastElapsedDays,
          scheduledDays: log.scheduledDays,
          reviewedAt: log.reviewedAt,
        );
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
          newTagCompanions.add(
            TagsCompanion.insert(
              id: Value(assignedId),
              name: tag.name,
              color: Value(tag.color),
              createdAt: Value(tag.createdAt),
            ),
          );
          final addedTag = Tag(
            id: assignedId,
            name: tag.name,
            color: tag.color,
            createdAt: tag.createdAt,
          );
          existingTagsByName[tag.name] = addedTag;
          existingTagsById[assignedId] = addedTag;
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
