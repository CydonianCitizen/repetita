class DeckPayload {
  const DeckPayload({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.examDate,
    this.targetRetention,
  });

  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? examDate;
  final double? targetRetention;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    if (examDate != null) 'examDate': examDate!.toUtc().toIso8601String(),
    if (targetRetention != null) 'targetRetention': targetRetention,
  };

  factory DeckPayload.fromJson(Map<String, dynamic> json) => DeckPayload(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
    examDate: json['examDate'] != null
        ? DateTime.parse(json['examDate'] as String).toUtc()
        : null,
    targetRetention: (json['targetRetention'] as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          examDate == other.examDate &&
          targetRetention == other.targetRetention;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    createdAt,
    updatedAt,
    examDate,
    targetRetention,
  );
}

class CardPayload {
  const CardPayload({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.state,
    required this.stability,
    required this.difficulty,
    this.easinessFactor = 2.5,
    required this.due,
    this.lastReview,
    required this.reps,
    required this.lapses,
    required this.createdAt,
    this.isSuspended = false,
    this.buriedUntil,
    this.clozeIndex,
    this.flag = 0,
    this.noteId,
  });

  final int id;
  final int deckId;
  final String front;
  final String back;
  final int state;
  final double stability;
  final double difficulty;
  final double easinessFactor;
  final DateTime due;
  final DateTime? lastReview;
  final int reps;
  final int lapses;
  final DateTime createdAt;
  final bool isSuspended;
  final DateTime? buriedUntil;
  final int? clozeIndex;
  final int flag;
  final int? noteId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'deckId': deckId,
    'front': front,
    'back': back,
    'state': state,
    'stability': stability,
    'difficulty': difficulty,
    'easinessFactor': easinessFactor,
    'due': due.toUtc().toIso8601String(),
    'lastReview': lastReview?.toUtc().toIso8601String(),
    'reps': reps,
    'lapses': lapses,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'isSuspended': isSuspended,
    'buriedUntil': buriedUntil?.toUtc().toIso8601String(),
    if (clozeIndex != null) 'clozeIndex': clozeIndex,
    if (flag != 0) 'flag': flag,
    if (noteId != null) 'noteId': noteId,
  };

  factory CardPayload.fromJson(Map<String, dynamic> json) => CardPayload(
    id: json['id'] as int,
    deckId: json['deckId'] as int,
    front: json['front'] as String,
    back: json['back'] as String,
    state: json['state'] as int,
    stability: (json['stability'] as num).toDouble(),
    difficulty: (json['difficulty'] as num).toDouble(),
    easinessFactor: (json['easinessFactor'] as num?)?.toDouble() ?? 2.5,
    due: DateTime.parse(json['due'] as String).toUtc(),
    lastReview: json['lastReview'] != null
        ? DateTime.parse(json['lastReview'] as String).toUtc()
        : null,
    reps: json['reps'] as int,
    lapses: json['lapses'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    isSuspended: (json['isSuspended'] as bool?) ?? false,
    buriedUntil: json['buriedUntil'] != null
        ? DateTime.parse(json['buriedUntil'] as String).toUtc()
        : null,
    clozeIndex: json['clozeIndex'] as int?,
    flag: (json['flag'] as int?) ?? 0,
    noteId: json['noteId'] as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deckId == other.deckId &&
          front == other.front &&
          back == other.back &&
          state == other.state &&
          stability == other.stability &&
          difficulty == other.difficulty &&
          easinessFactor == other.easinessFactor &&
          due == other.due &&
          lastReview == other.lastReview &&
          reps == other.reps &&
          lapses == other.lapses &&
          createdAt == other.createdAt &&
          isSuspended == other.isSuspended &&
          buriedUntil == other.buriedUntil &&
          clozeIndex == other.clozeIndex &&
          flag == other.flag &&
          noteId == other.noteId;

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    front,
    back,
    state,
    stability,
    difficulty,
    easinessFactor,
    due,
    lastReview,
    reps,
    lapses,
    createdAt,
    isSuspended,
    buriedUntil,
    clozeIndex,
    flag,
    noteId,
  );
}

class ReviewLogPayload {
  const ReviewLogPayload({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    this.easinessFactor = 2.5,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.reviewedAt,
  });

  final int id;
  final int cardId;
  final int rating;
  final int state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final double easinessFactor;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final DateTime reviewedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardId': cardId,
    'rating': rating,
    'state': state,
    'due': due.toUtc().toIso8601String(),
    'stability': stability,
    'difficulty': difficulty,
    'easinessFactor': easinessFactor,
    'elapsedDays': elapsedDays,
    'lastElapsedDays': lastElapsedDays,
    'scheduledDays': scheduledDays,
    'reviewedAt': reviewedAt.toUtc().toIso8601String(),
  };

  factory ReviewLogPayload.fromJson(Map<String, dynamic> json) =>
      ReviewLogPayload(
        id: json['id'] as int,
        cardId: json['cardId'] as int,
        rating: json['rating'] as int,
        state: json['state'] as int,
        due: DateTime.parse(json['due'] as String).toUtc(),
        stability: (json['stability'] as num).toDouble(),
        difficulty: (json['difficulty'] as num).toDouble(),
        easinessFactor: (json['easinessFactor'] as num?)?.toDouble() ?? 2.5,
        elapsedDays: json['elapsedDays'] as int,
        lastElapsedDays: json['lastElapsedDays'] as int,
        scheduledDays: json['scheduledDays'] as int,
        reviewedAt: DateTime.parse(json['reviewedAt'] as String).toUtc(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewLogPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cardId == other.cardId &&
          rating == other.rating &&
          state == other.state &&
          due == other.due &&
          stability == other.stability &&
          difficulty == other.difficulty &&
          easinessFactor == other.easinessFactor &&
          elapsedDays == other.elapsedDays &&
          lastElapsedDays == other.lastElapsedDays &&
          scheduledDays == other.scheduledDays &&
          reviewedAt == other.reviewedAt;

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    rating,
    state,
    due,
    stability,
    difficulty,
    easinessFactor,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    reviewedAt,
  );
}

class TagPayload {
  const TagPayload({
    required this.id,
    required this.name,
    this.color = 0,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int color;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory TagPayload.fromJson(Map<String, dynamic> json) => TagPayload(
    id: json['id'] as int,
    name: json['name'] as String,
    color: (json['color'] as int?) ?? 0,
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, name, color, createdAt);
}

class CardTagPayload {
  const CardTagPayload({required this.cardId, required this.tagId});

  final int cardId;
  final int tagId;

  Map<String, dynamic> toJson() => {'cardId': cardId, 'tagId': tagId};

  factory CardTagPayload.fromJson(Map<String, dynamic> json) => CardTagPayload(
    cardId: json['cardId'] as int,
    tagId: json['tagId'] as int,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardTagPayload &&
          runtimeType == other.runtimeType &&
          cardId == other.cardId &&
          tagId == other.tagId;

  @override
  int get hashCode => Object.hash(cardId, tagId);
}

class BackupPayload {
  const BackupPayload({
    this.version = 1,
    required this.exportedAt,
    required this.decks,
    required this.cards,
    required this.reviewLogs,
    this.tags = const [],
    this.cardTags = const [],
  });

  final int version;
  final DateTime exportedAt;
  final List<DeckPayload> decks;
  final List<CardPayload> cards;
  final List<ReviewLogPayload> reviewLogs;
  final List<TagPayload> tags;
  final List<CardTagPayload> cardTags;

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'decks': decks.map((d) => d.toJson()).toList(),
    'cards': cards.map((c) => c.toJson()).toList(),
    'reviewLogs': reviewLogs.map((r) => r.toJson()).toList(),
    'tags': tags.map((t) => t.toJson()).toList(),
    'cardTags': cardTags.map((ct) => ct.toJson()).toList(),
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

    final decksList = (json['decks'] as List)
        .map((d) => DeckPayload.fromJson(d as Map<String, dynamic>))
        .toList();
    final cardsList = (json['cards'] as List)
        .map((c) => CardPayload.fromJson(c as Map<String, dynamic>))
        .toList();
    final reviewLogsList = (json['reviewLogs'] as List)
        .map((r) => ReviewLogPayload.fromJson(r as Map<String, dynamic>))
        .toList();
    final tagsList =
        (json['tags'] as List?)
            ?.map((t) => TagPayload.fromJson(t as Map<String, dynamic>))
            .toList() ??
        const [];
    final cardTagsList =
        (json['cardTags'] as List?)
            ?.map((ct) => CardTagPayload.fromJson(ct as Map<String, dynamic>))
            .toList() ??
        const [];

    final version = json['version'] as int?;
    if (version == null || version < 1) {
      throw const FormatException('Invalid or missing version in backup JSON');
    }

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
