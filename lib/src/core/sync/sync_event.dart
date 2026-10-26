sealed class SyncEvent {
  const SyncEvent();

  Map<String, dynamic> toJson();

  static SyncEvent fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'epoch' => EpochHeaderSyncEvent.fromJson(json),
      'card' => CardSyncEvent.fromJson(json),
      'deck' => DeckSyncEvent.fromJson(json),
      'tag' => TagSyncEvent.fromJson(json),
      'card_tag' => CardTagSyncEvent.fromJson(json),
      'review_log' => ReviewLogSyncEvent.fromJson(json),
      'tombstone' => TombstoneSyncEvent.fromJson(json),
      _ => throw FormatException('Unknown SyncEvent type: $type'),
    };
  }
}

class EpochHeaderSyncEvent extends SyncEvent {
  const EpochHeaderSyncEvent({
    required this.gen,
    required this.deviceId,
    required this.createdAt,
    this.cards = const [],
    this.decks = const [],
    this.tags = const [],
    this.cardTags = const [],
    this.tombstones = const [],
  });

  final int gen;
  final String deviceId;
  final DateTime createdAt;
  final List<CardSyncEvent> cards;
  final List<DeckSyncEvent> decks;
  final List<TagSyncEvent> tags;
  final List<CardTagSyncEvent> cardTags;
  final List<TombstoneSyncEvent> tombstones;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'epoch',
    'gen': gen,
    'device_id': deviceId,
    'created_at': createdAt.toUtc().toIso8601String(),
    'cards': cards.map((c) => c.toJson()).toList(),
    'decks': decks.map((d) => d.toJson()).toList(),
    'tags': tags.map((t) => t.toJson()).toList(),
    'card_tags': cardTags.map((ct) => ct.toJson()).toList(),
    'tombstones': tombstones.map((t) => t.toJson()).toList(),
  };

  factory EpochHeaderSyncEvent.fromJson(
    Map<String, dynamic> json,
  ) => EpochHeaderSyncEvent(
    gen: json['gen'] as int? ?? 0,
    deviceId: json['device_id'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    cards:
        (json['cards'] as List<dynamic>?)
            ?.map((c) => CardSyncEvent.fromJson(c as Map<String, dynamic>))
            .toList() ??
        const [],
    decks:
        (json['decks'] as List<dynamic>?)
            ?.map((d) => DeckSyncEvent.fromJson(d as Map<String, dynamic>))
            .toList() ??
        const [],
    tags:
        (json['tags'] as List<dynamic>?)
            ?.map((t) => TagSyncEvent.fromJson(t as Map<String, dynamic>))
            .toList() ??
        const [],
    cardTags:
        (json['card_tags'] as List<dynamic>?)
            ?.map((ct) => CardTagSyncEvent.fromJson(ct as Map<String, dynamic>))
            .toList() ??
        const [],
    tombstones:
        (json['tombstones'] as List<dynamic>?)
            ?.map((t) => TombstoneSyncEvent.fromJson(t as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

class CardSyncEvent extends SyncEvent {
  const CardSyncEvent({
    required this.globalId,
    required this.deckGlobalId,
    required this.front,
    required this.back,
    required this.contentHlc,
    required this.scheduleHlc,
    required this.state,
    required this.stability,
    required this.difficulty,
    required this.due,
    this.lastReview,
    required this.reps,
    required this.lapses,
    required this.isSuspended,
    this.buriedUntil,
    this.clozeIndex,
    required this.easinessFactor,
    required this.flag,
    this.noteId,
  });

  final String globalId;
  final String deckGlobalId;
  final String front;
  final String back;
  final String contentHlc;
  final String scheduleHlc;
  final int state;
  final double stability;
  final double difficulty;
  final DateTime due;
  final DateTime? lastReview;
  final int reps;
  final int lapses;
  final bool isSuspended;
  final DateTime? buriedUntil;
  final int? clozeIndex;
  final double easinessFactor;
  final int flag;
  final int? noteId;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'card',
    'global_id': globalId,
    'deck_global_id': deckGlobalId,
    'front': front,
    'back': back,
    'content_hlc': contentHlc,
    'schedule_hlc': scheduleHlc,
    'state': state,
    'stability': stability,
    'difficulty': difficulty,
    'due': due.toUtc().toIso8601String(),
    'last_review': lastReview?.toUtc().toIso8601String(),
    'reps': reps,
    'lapses': lapses,
    'is_suspended': isSuspended,
    'buried_until': buriedUntil?.toUtc().toIso8601String(),
    'cloze_index': clozeIndex,
    'easiness_factor': easinessFactor,
    'flag': flag,
    'note_id': noteId,
  };

  factory CardSyncEvent.fromJson(Map<String, dynamic> json) => CardSyncEvent(
    globalId: json['global_id'] as String,
    deckGlobalId: json['deck_global_id'] as String? ?? '',
    front: json['front'] as String,
    back: json['back'] as String,
    contentHlc: json['content_hlc'] as String? ?? '',
    scheduleHlc: json['schedule_hlc'] as String? ?? '',
    state: json['state'] as int? ?? 0,
    stability: (json['stability'] as num?)?.toDouble() ?? 0.0,
    difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.0,
    due: DateTime.parse(json['due'] as String).toUtc(),
    lastReview: json['last_review'] != null
        ? DateTime.parse(json['last_review'] as String).toUtc()
        : null,
    reps: json['reps'] as int? ?? 0,
    lapses: json['lapses'] as int? ?? 0,
    isSuspended: json['is_suspended'] as bool? ?? false,
    buriedUntil: json['buried_until'] != null
        ? DateTime.parse(json['buried_until'] as String).toUtc()
        : null,
    clozeIndex: json['cloze_index'] as int?,
    easinessFactor: (json['easiness_factor'] as num?)?.toDouble() ?? 2.5,
    flag: json['flag'] as int? ?? 0,
    noteId: json['note_id'] as int?,
  );
}

class DeckSyncEvent extends SyncEvent {
  const DeckSyncEvent({
    required this.globalId,
    required this.name,
    this.description,
    this.examDate,
    this.targetRetention,
    required this.updatedHlc,
  });

  final String globalId;
  final String name;
  final String? description;
  final DateTime? examDate;
  final double? targetRetention;
  final String updatedHlc;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'deck',
    'global_id': globalId,
    'name': name,
    'description': description,
    'exam_date': examDate?.toUtc().toIso8601String(),
    'target_retention': targetRetention,
    'updated_hlc': updatedHlc,
  };

  factory DeckSyncEvent.fromJson(Map<String, dynamic> json) => DeckSyncEvent(
    globalId: json['global_id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    examDate: json['exam_date'] != null
        ? DateTime.parse(json['exam_date'] as String).toUtc()
        : null,
    targetRetention: (json['target_retention'] as num?)?.toDouble(),
    updatedHlc: json['updated_hlc'] as String? ?? '',
  );
}

class TagSyncEvent extends SyncEvent {
  const TagSyncEvent({
    required this.globalId,
    required this.name,
    required this.color,
    required this.updatedHlc,
  });

  final String globalId;
  final String name;
  final int color;
  final String updatedHlc;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tag',
    'global_id': globalId,
    'name': name,
    'color': color,
    'updated_hlc': updatedHlc,
  };

  factory TagSyncEvent.fromJson(Map<String, dynamic> json) => TagSyncEvent(
    globalId: json['global_id'] as String,
    name: json['name'] as String,
    color: json['color'] as int? ?? 0,
    updatedHlc: json['updated_hlc'] as String? ?? '',
  );
}

class CardTagSyncEvent extends SyncEvent {
  const CardTagSyncEvent({
    required this.cardGlobalId,
    required this.tagGlobalId,
    required this.updatedHlc,
  });

  final String cardGlobalId;
  final String tagGlobalId;
  final String updatedHlc;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'card_tag',
    'card_global_id': cardGlobalId,
    'tag_global_id': tagGlobalId,
    'updated_hlc': updatedHlc,
  };

  factory CardTagSyncEvent.fromJson(Map<String, dynamic> json) =>
      CardTagSyncEvent(
        cardGlobalId: json['card_global_id'] as String,
        tagGlobalId: json['tag_global_id'] as String,
        updatedHlc: json['updated_hlc'] as String? ?? '',
      );
}

class ReviewLogSyncEvent extends SyncEvent {
  const ReviewLogSyncEvent({
    required this.globalId,
    required this.cardGlobalId,
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.reviewedAt,
    required this.easinessFactor,
  });

  final String globalId;
  final String cardGlobalId;
  final int rating;
  final int state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final DateTime reviewedAt;
  final double easinessFactor;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'review_log',
    'global_id': globalId,
    'card_global_id': cardGlobalId,
    'rating': rating,
    'state': state,
    'due': due.toUtc().toIso8601String(),
    'stability': stability,
    'difficulty': difficulty,
    'elapsed_days': elapsedDays,
    'last_elapsed_days': lastElapsedDays,
    'scheduled_days': scheduledDays,
    'reviewed_at': reviewedAt.toUtc().toIso8601String(),
    'easiness_factor': easinessFactor,
  };

  factory ReviewLogSyncEvent.fromJson(Map<String, dynamic> json) =>
      ReviewLogSyncEvent(
        globalId: json['global_id'] as String,
        cardGlobalId: json['card_global_id'] as String,
        rating: json['rating'] as int,
        state: json['state'] as int,
        due: DateTime.parse(json['due'] as String).toUtc(),
        stability: (json['stability'] as num).toDouble(),
        difficulty: (json['difficulty'] as num).toDouble(),
        elapsedDays: json['elapsed_days'] as int? ?? 0,
        lastElapsedDays: json['last_elapsed_days'] as int? ?? 0,
        scheduledDays: json['scheduled_days'] as int? ?? 0,
        reviewedAt: DateTime.parse(json['reviewed_at'] as String).toUtc(),
        easinessFactor: (json['easiness_factor'] as num?)?.toDouble() ?? 2.5,
      );
}

class TombstoneSyncEvent extends SyncEvent {
  const TombstoneSyncEvent({
    required this.globalId,
    required this.deletedHlc,
    required this.entityType,
  });

  final String globalId;
  final String deletedHlc;
  final int entityType; // 0: Card, 1: Deck, 2: Tag

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tombstone',
    'global_id': globalId,
    'deleted_hlc': deletedHlc,
    'entity_type': entityType,
  };

  factory TombstoneSyncEvent.fromJson(Map<String, dynamic> json) =>
      TombstoneSyncEvent(
        globalId: json['global_id'] as String,
        deletedHlc: json['deleted_hlc'] as String,
        entityType: json['entity_type'] as int,
      );
}
