/// Result summary of an Anki package import operation.
class AnkiImportResult {
  const AnkiImportResult({
    required this.decksCreated,
    required this.cardsImported,
    required this.tagsCreated,
    required this.skippedCount,
    required this.deckNames,
  });

  final int decksCreated;
  final int cardsImported;
  final int tagsCreated;
  final int skippedCount;
  final List<String> deckNames;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnkiImportResult &&
          runtimeType == other.runtimeType &&
          decksCreated == other.decksCreated &&
          cardsImported == other.cardsImported &&
          tagsCreated == other.tagsCreated &&
          skippedCount == other.skippedCount;

  @override
  int get hashCode =>
      Object.hash(decksCreated, cardsImported, tagsCreated, skippedCount);

  @override
  String toString() =>
      'AnkiImportResult(decks: $decksCreated, cards: $cardsImported, tags: $tagsCreated, skipped: $skippedCount)';
}

/// Raw template definition extracted from Anki note model.
class AnkiRawTemplate {
  const AnkiRawTemplate({
    required this.name,
    required this.ord,
    required this.qfmt,
    required this.afmt,
  });

  final String name;
  final int ord;
  final String qfmt;
  final String afmt;
}

/// Raw note model (Note Type) extracted from Anki collection database.
class AnkiRawModel {
  const AnkiRawModel({
    required this.id,
    required this.name,
    required this.type,
    required this.fieldNames,
    required this.templates,
  });

  final int id;
  final String name;
  final int type; // 0 = standard, 1 = cloze
  final List<String> fieldNames;
  final List<AnkiRawTemplate> templates;

  bool get isCloze => type == 1;
}

/// Raw note record extracted from Anki collection database.
class AnkiRawNote {
  const AnkiRawNote({
    required this.id,
    required this.modelId,
    required this.fields,
    required this.tags,
  });

  final int id;
  final int modelId;
  final List<String> fields;
  final List<String> tags;
}

/// Raw card record extracted from Anki collection database.
class AnkiRawCard {
  const AnkiRawCard({
    required this.id,
    required this.noteId,
    required this.deckId,
    required this.ord,
    this.factor = 2500,
  });

  final int id;
  final int noteId;
  final int deckId;
  final int ord;
  final int factor;
}

/// Synthesized card ready for insertion into Repetita database.
class AnkiParsedCard {
  const AnkiParsedCard({
    required this.front,
    required this.back,
    this.clozeIndex,
    required this.tags,
    required this.deckName,
    this.easinessFactor = 2.5,
    this.noteId,
  });

  final String front;
  final String back;
  final int? clozeIndex;
  final List<String> tags;
  final String deckName;
  final double easinessFactor;
  final int? noteId;
}
