import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

/// Custom Drift serializer for backup JSON: ensures DateTimes are formatted as ISO 8601 strings
/// and supports parsing both ISO strings and millisecond epochs.
class BackupDateTimeSerializer extends ValueSerializer {
  const BackupDateTimeSerializer();

  @override
  T fromJson<T>(dynamic json) {
    if (json == null) {
      if (T == double) return 2.5 as T;
      if (T == int) return 0 as T;
      if (T == bool) return false as T;
      if (T == String) return '' as T;
      return null as T;
    }
    if (json is num && T == double) {
      return json.toDouble() as T;
    }
    if (json is num && T == int) {
      return json.toInt() as T;
    }
    if (T == DateTime || (json is String && DateTime.tryParse(json) != null)) {
      if (json is String) return DateTime.parse(json).toUtc() as T;
      if (json is int) {
        return DateTime.fromMillisecondsSinceEpoch(json, isUtc: true) as T;
      }
    }
    return driftRuntimeOptions.defaultSerializer.fromJson<T>(json);
  }

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    return driftRuntimeOptions.defaultSerializer.toJson<T>(value);
  }
}

class BackupPayload {
  const BackupPayload({
    required this.version,
    required this.exportedAt,
    required this.decks,
    required this.cards,
    required this.reviewLogs,
    this.tags = const [],
    this.cardTags = const [],
  });

  static const serializer = BackupDateTimeSerializer();

  final int version;
  final DateTime exportedAt;
  final List<Deck> decks;
  final List<Card> cards;
  final List<ReviewLog> reviewLogs;
  final List<Tag> tags;
  final List<CardTag> cardTags;

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'decks': decks.map((d) => d.toJson(serializer: serializer)).toList(),
    'cards': cards.map((c) => c.toJson(serializer: serializer)).toList(),
    'reviewLogs': reviewLogs
        .map((r) => r.toJson(serializer: serializer))
        .toList(),
    'tags': tags.map((t) => t.toJson(serializer: serializer)).toList(),
    'cardTags': cardTags
        .map((ct) => ct.toJson(serializer: serializer))
        .toList(),
  };

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('version')) {
      throw const FormatException('Missing version field in backup JSON');
    }
    if (!json.containsKey('decks') || json['decks'] is! List) {
      throw const FormatException(
        'Missing or invalid decks array in backup JSON',
      );
    }
    if (!json.containsKey('cards') || json['cards'] is! List) {
      throw const FormatException(
        'Missing or invalid cards array in backup JSON',
      );
    }
    if (!json.containsKey('reviewLogs') || json['reviewLogs'] is! List) {
      throw const FormatException(
        'Missing or invalid reviewLogs array in backup JSON',
      );
    }

    final version = json['version'] as int?;
    if (version == null || version < 1) {
      throw const FormatException('Invalid or missing version in backup JSON');
    }

    final decksList = (json['decks'] as List)
        .map(
          (d) =>
              Deck.fromJson(d as Map<String, dynamic>, serializer: serializer),
        )
        .toList();
    final cardsList = (json['cards'] as List)
        .map(
          (c) =>
              Card.fromJson(c as Map<String, dynamic>, serializer: serializer),
        )
        .toList();
    final reviewLogsList = (json['reviewLogs'] as List)
        .map(
          (r) => ReviewLog.fromJson(
            r as Map<String, dynamic>,
            serializer: serializer,
          ),
        )
        .toList();
    final tagsList =
        (json['tags'] as List?)
            ?.map(
              (t) => Tag.fromJson(
                t as Map<String, dynamic>,
                serializer: serializer,
              ),
            )
            .toList() ??
        const [];
    final cardTagsList =
        (json['cardTags'] as List?)
            ?.map(
              (ct) => CardTag.fromJson(
                ct as Map<String, dynamic>,
                serializer: serializer,
              ),
            )
            .toList() ??
        const [];

    return BackupPayload(
      version: version,
      exportedAt: DateTime.parse(json['exportedAt'] as String).toUtc(),
      decks: decksList,
      cards: cardsList,
      reviewLogs: reviewLogsList,
      tags: tagsList,
      cardTags: cardTagsList,
    );
  }
}

class CsvImportResult {
  const CsvImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  final int importedCount;
  final int skippedCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CsvImportResult &&
          runtimeType == other.runtimeType &&
          importedCount == other.importedCount &&
          skippedCount == other.skippedCount;

  @override
  int get hashCode => Object.hash(importedCount, skippedCount);
}
