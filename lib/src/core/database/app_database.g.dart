// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DecksTable extends Decks with TableInfo<$DecksTable, Deck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _globalIdMeta = const VerificationMeta(
    'globalId',
  );
  @override
  late final GeneratedColumn<String> globalId = GeneratedColumn<String>(
    'global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _examDateMeta = const VerificationMeta(
    'examDate',
  );
  @override
  late final GeneratedColumn<DateTime> examDate = GeneratedColumn<DateTime>(
    'exam_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRetentionMeta = const VerificationMeta(
    'targetRetention',
  );
  @override
  late final GeneratedColumn<double> targetRetention = GeneratedColumn<double>(
    'target_retention',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedHlcMeta = const VerificationMeta(
    'updatedHlc',
  );
  @override
  late final GeneratedColumn<String> updatedHlc = GeneratedColumn<String>(
    'updated_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    globalId,
    name,
    description,
    createdAt,
    updatedAt,
    examDate,
    targetRetention,
    updatedHlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('global_id')) {
      context.handle(
        _globalIdMeta,
        globalId.isAcceptableOrUnknown(data['global_id']!, _globalIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('exam_date')) {
      context.handle(
        _examDateMeta,
        examDate.isAcceptableOrUnknown(data['exam_date']!, _examDateMeta),
      );
    }
    if (data.containsKey('target_retention')) {
      context.handle(
        _targetRetentionMeta,
        targetRetention.isAcceptableOrUnknown(
          data['target_retention']!,
          _targetRetentionMeta,
        ),
      );
    }
    if (data.containsKey('updated_hlc')) {
      context.handle(
        _updatedHlcMeta,
        updatedHlc.isAcceptableOrUnknown(data['updated_hlc']!, _updatedHlcMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      globalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}global_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      examDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exam_date'],
      ),
      targetRetention: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_retention'],
      ),
      updatedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_hlc'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class Deck extends DataClass implements Insertable<Deck> {
  final int id;
  final String globalId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? examDate;
  final double? targetRetention;
  final String updatedHlc;
  const Deck({
    required this.id,
    required this.globalId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.examDate,
    this.targetRetention,
    required this.updatedHlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['global_id'] = Variable<String>(globalId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || examDate != null) {
      map['exam_date'] = Variable<DateTime>(examDate);
    }
    if (!nullToAbsent || targetRetention != null) {
      map['target_retention'] = Variable<double>(targetRetention);
    }
    map['updated_hlc'] = Variable<String>(updatedHlc);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      globalId: Value(globalId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      examDate: examDate == null && nullToAbsent
          ? const Value.absent()
          : Value(examDate),
      targetRetention: targetRetention == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRetention),
      updatedHlc: Value(updatedHlc),
    );
  }

  factory Deck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deck(
      id: serializer.fromJson<int>(json['id']),
      globalId: serializer.fromJson<String>(json['globalId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      examDate: serializer.fromJson<DateTime?>(json['examDate']),
      targetRetention: serializer.fromJson<double?>(json['targetRetention']),
      updatedHlc: serializer.fromJson<String>(json['updatedHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'globalId': serializer.toJson<String>(globalId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'examDate': serializer.toJson<DateTime?>(examDate),
      'targetRetention': serializer.toJson<double?>(targetRetention),
      'updatedHlc': serializer.toJson<String>(updatedHlc),
    };
  }

  Deck copyWith({
    int? id,
    String? globalId,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> examDate = const Value.absent(),
    Value<double?> targetRetention = const Value.absent(),
    String? updatedHlc,
  }) => Deck(
    id: id ?? this.id,
    globalId: globalId ?? this.globalId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    examDate: examDate.present ? examDate.value : this.examDate,
    targetRetention: targetRetention.present
        ? targetRetention.value
        : this.targetRetention,
    updatedHlc: updatedHlc ?? this.updatedHlc,
  );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      globalId: data.globalId.present ? data.globalId.value : this.globalId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      examDate: data.examDate.present ? data.examDate.value : this.examDate,
      targetRetention: data.targetRetention.present
          ? data.targetRetention.value
          : this.targetRetention,
      updatedHlc: data.updatedHlc.present
          ? data.updatedHlc.value
          : this.updatedHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deck(')
          ..write('id: $id, ')
          ..write('globalId: $globalId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('examDate: $examDate, ')
          ..write('targetRetention: $targetRetention, ')
          ..write('updatedHlc: $updatedHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    globalId,
    name,
    description,
    createdAt,
    updatedAt,
    examDate,
    targetRetention,
    updatedHlc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deck &&
          other.id == this.id &&
          other.globalId == this.globalId &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.examDate == this.examDate &&
          other.targetRetention == this.targetRetention &&
          other.updatedHlc == this.updatedHlc);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<int> id;
  final Value<String> globalId;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> examDate;
  final Value<double?> targetRetention;
  final Value<String> updatedHlc;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.globalId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.examDate = const Value.absent(),
    this.targetRetention = const Value.absent(),
    this.updatedHlc = const Value.absent(),
  });
  DecksCompanion.insert({
    this.id = const Value.absent(),
    this.globalId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.examDate = const Value.absent(),
    this.targetRetention = const Value.absent(),
    this.updatedHlc = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Deck> custom({
    Expression<int>? id,
    Expression<String>? globalId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? examDate,
    Expression<double>? targetRetention,
    Expression<String>? updatedHlc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (globalId != null) 'global_id': globalId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (examDate != null) 'exam_date': examDate,
      if (targetRetention != null) 'target_retention': targetRetention,
      if (updatedHlc != null) 'updated_hlc': updatedHlc,
    });
  }

  DecksCompanion copyWith({
    Value<int>? id,
    Value<String>? globalId,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? examDate,
    Value<double?>? targetRetention,
    Value<String>? updatedHlc,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      globalId: globalId ?? this.globalId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      examDate: examDate ?? this.examDate,
      targetRetention: targetRetention ?? this.targetRetention,
      updatedHlc: updatedHlc ?? this.updatedHlc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (globalId.present) {
      map['global_id'] = Variable<String>(globalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (examDate.present) {
      map['exam_date'] = Variable<DateTime>(examDate.value);
    }
    if (targetRetention.present) {
      map['target_retention'] = Variable<double>(targetRetention.value);
    }
    if (updatedHlc.present) {
      map['updated_hlc'] = Variable<String>(updatedHlc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('globalId: $globalId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('examDate: $examDate, ')
          ..write('targetRetention: $targetRetention, ')
          ..write('updatedHlc: $updatedHlc')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _globalIdMeta = const VerificationMeta(
    'globalId',
  );
  @override
  late final GeneratedColumn<String> globalId = GeneratedColumn<String>(
    'global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _deckGlobalIdMeta = const VerificationMeta(
    'deckGlobalId',
  );
  @override
  late final GeneratedColumn<String> deckGlobalId = GeneratedColumn<String>(
    'deck_global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
    'front',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
    'back',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSuspendedMeta = const VerificationMeta(
    'isSuspended',
  );
  @override
  late final GeneratedColumn<bool> isSuspended = GeneratedColumn<bool>(
    'is_suspended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_suspended" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _buriedUntilMeta = const VerificationMeta(
    'buriedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> buriedUntil = GeneratedColumn<DateTime>(
    'buried_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clozeIndexMeta = const VerificationMeta(
    'clozeIndex',
  );
  @override
  late final GeneratedColumn<int> clozeIndex = GeneratedColumn<int>(
    'cloze_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _easinessFactorMeta = const VerificationMeta(
    'easinessFactor',
  );
  @override
  late final GeneratedColumn<double> easinessFactor = GeneratedColumn<double>(
    'easiness_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<int> flag = GeneratedColumn<int>(
    'flag',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentHlcMeta = const VerificationMeta(
    'contentHlc',
  );
  @override
  late final GeneratedColumn<String> contentHlc = GeneratedColumn<String>(
    'content_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scheduleHlcMeta = const VerificationMeta(
    'scheduleHlc',
  );
  @override
  late final GeneratedColumn<String> scheduleHlc = GeneratedColumn<String>(
    'schedule_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    globalId,
    deckId,
    deckGlobalId,
    front,
    back,
    state,
    stability,
    difficulty,
    due,
    lastReview,
    reps,
    lapses,
    createdAt,
    isSuspended,
    buriedUntil,
    clozeIndex,
    easinessFactor,
    flag,
    noteId,
    contentHlc,
    scheduleHlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('global_id')) {
      context.handle(
        _globalIdMeta,
        globalId.isAcceptableOrUnknown(data['global_id']!, _globalIdMeta),
      );
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('deck_global_id')) {
      context.handle(
        _deckGlobalIdMeta,
        deckGlobalId.isAcceptableOrUnknown(
          data['deck_global_id']!,
          _deckGlobalIdMeta,
        ),
      );
    }
    if (data.containsKey('front')) {
      context.handle(
        _frontMeta,
        front.isAcceptableOrUnknown(data['front']!, _frontMeta),
      );
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
        _backMeta,
        back.isAcceptableOrUnknown(data['back']!, _backMeta),
      );
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_suspended')) {
      context.handle(
        _isSuspendedMeta,
        isSuspended.isAcceptableOrUnknown(
          data['is_suspended']!,
          _isSuspendedMeta,
        ),
      );
    }
    if (data.containsKey('buried_until')) {
      context.handle(
        _buriedUntilMeta,
        buriedUntil.isAcceptableOrUnknown(
          data['buried_until']!,
          _buriedUntilMeta,
        ),
      );
    }
    if (data.containsKey('cloze_index')) {
      context.handle(
        _clozeIndexMeta,
        clozeIndex.isAcceptableOrUnknown(data['cloze_index']!, _clozeIndexMeta),
      );
    }
    if (data.containsKey('easiness_factor')) {
      context.handle(
        _easinessFactorMeta,
        easinessFactor.isAcceptableOrUnknown(
          data['easiness_factor']!,
          _easinessFactorMeta,
        ),
      );
    }
    if (data.containsKey('flag')) {
      context.handle(
        _flagMeta,
        flag.isAcceptableOrUnknown(data['flag']!, _flagMeta),
      );
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    }
    if (data.containsKey('content_hlc')) {
      context.handle(
        _contentHlcMeta,
        contentHlc.isAcceptableOrUnknown(data['content_hlc']!, _contentHlcMeta),
      );
    }
    if (data.containsKey('schedule_hlc')) {
      context.handle(
        _scheduleHlcMeta,
        scheduleHlc.isAcceptableOrUnknown(
          data['schedule_hlc']!,
          _scheduleHlcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      globalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}global_id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      deckGlobalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_global_id'],
      )!,
      front: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front'],
      )!,
      back: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSuspended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_suspended'],
      )!,
      buriedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}buried_until'],
      ),
      clozeIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cloze_index'],
      ),
      easinessFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}easiness_factor'],
      )!,
      flag: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flag'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      ),
      contentHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hlc'],
      )!,
      scheduleHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_hlc'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final int id;
  final String globalId;
  final int deckId;
  final String deckGlobalId;
  final String front;
  final String back;
  final int state;
  final double stability;
  final double difficulty;
  final DateTime due;
  final DateTime? lastReview;
  final int reps;
  final int lapses;
  final DateTime createdAt;
  final bool isSuspended;
  final DateTime? buriedUntil;
  final int? clozeIndex;
  final double easinessFactor;
  final int flag;
  final int? noteId;
  final String contentHlc;
  final String scheduleHlc;
  const Card({
    required this.id,
    required this.globalId,
    required this.deckId,
    required this.deckGlobalId,
    required this.front,
    required this.back,
    required this.state,
    required this.stability,
    required this.difficulty,
    required this.due,
    this.lastReview,
    required this.reps,
    required this.lapses,
    required this.createdAt,
    required this.isSuspended,
    this.buriedUntil,
    this.clozeIndex,
    required this.easinessFactor,
    required this.flag,
    this.noteId,
    required this.contentHlc,
    required this.scheduleHlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['global_id'] = Variable<String>(globalId);
    map['deck_id'] = Variable<int>(deckId);
    map['deck_global_id'] = Variable<String>(deckGlobalId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    map['state'] = Variable<int>(state);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['due'] = Variable<DateTime>(due);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_suspended'] = Variable<bool>(isSuspended);
    if (!nullToAbsent || buriedUntil != null) {
      map['buried_until'] = Variable<DateTime>(buriedUntil);
    }
    if (!nullToAbsent || clozeIndex != null) {
      map['cloze_index'] = Variable<int>(clozeIndex);
    }
    map['easiness_factor'] = Variable<double>(easinessFactor);
    map['flag'] = Variable<int>(flag);
    if (!nullToAbsent || noteId != null) {
      map['note_id'] = Variable<int>(noteId);
    }
    map['content_hlc'] = Variable<String>(contentHlc);
    map['schedule_hlc'] = Variable<String>(scheduleHlc);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      globalId: Value(globalId),
      deckId: Value(deckId),
      deckGlobalId: Value(deckGlobalId),
      front: Value(front),
      back: Value(back),
      state: Value(state),
      stability: Value(stability),
      difficulty: Value(difficulty),
      due: Value(due),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      reps: Value(reps),
      lapses: Value(lapses),
      createdAt: Value(createdAt),
      isSuspended: Value(isSuspended),
      buriedUntil: buriedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(buriedUntil),
      clozeIndex: clozeIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(clozeIndex),
      easinessFactor: Value(easinessFactor),
      flag: Value(flag),
      noteId: noteId == null && nullToAbsent
          ? const Value.absent()
          : Value(noteId),
      contentHlc: Value(contentHlc),
      scheduleHlc: Value(scheduleHlc),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<int>(json['id']),
      globalId: serializer.fromJson<String>(json['globalId']),
      deckId: serializer.fromJson<int>(json['deckId']),
      deckGlobalId: serializer.fromJson<String>(json['deckGlobalId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      state: serializer.fromJson<int>(json['state']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      due: serializer.fromJson<DateTime>(json['due']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSuspended: serializer.fromJson<bool>(json['isSuspended']),
      buriedUntil: serializer.fromJson<DateTime?>(json['buriedUntil']),
      clozeIndex: serializer.fromJson<int?>(json['clozeIndex']),
      easinessFactor: serializer.fromJson<double>(json['easinessFactor']),
      flag: serializer.fromJson<int>(json['flag']),
      noteId: serializer.fromJson<int?>(json['noteId']),
      contentHlc: serializer.fromJson<String>(json['contentHlc']),
      scheduleHlc: serializer.fromJson<String>(json['scheduleHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'globalId': serializer.toJson<String>(globalId),
      'deckId': serializer.toJson<int>(deckId),
      'deckGlobalId': serializer.toJson<String>(deckGlobalId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'state': serializer.toJson<int>(state),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'due': serializer.toJson<DateTime>(due),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSuspended': serializer.toJson<bool>(isSuspended),
      'buriedUntil': serializer.toJson<DateTime?>(buriedUntil),
      'clozeIndex': serializer.toJson<int?>(clozeIndex),
      'easinessFactor': serializer.toJson<double>(easinessFactor),
      'flag': serializer.toJson<int>(flag),
      'noteId': serializer.toJson<int?>(noteId),
      'contentHlc': serializer.toJson<String>(contentHlc),
      'scheduleHlc': serializer.toJson<String>(scheduleHlc),
    };
  }

  Card copyWith({
    int? id,
    String? globalId,
    int? deckId,
    String? deckGlobalId,
    String? front,
    String? back,
    int? state,
    double? stability,
    double? difficulty,
    DateTime? due,
    Value<DateTime?> lastReview = const Value.absent(),
    int? reps,
    int? lapses,
    DateTime? createdAt,
    bool? isSuspended,
    Value<DateTime?> buriedUntil = const Value.absent(),
    Value<int?> clozeIndex = const Value.absent(),
    double? easinessFactor,
    int? flag,
    Value<int?> noteId = const Value.absent(),
    String? contentHlc,
    String? scheduleHlc,
  }) => Card(
    id: id ?? this.id,
    globalId: globalId ?? this.globalId,
    deckId: deckId ?? this.deckId,
    deckGlobalId: deckGlobalId ?? this.deckGlobalId,
    front: front ?? this.front,
    back: back ?? this.back,
    state: state ?? this.state,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    due: due ?? this.due,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    createdAt: createdAt ?? this.createdAt,
    isSuspended: isSuspended ?? this.isSuspended,
    buriedUntil: buriedUntil.present ? buriedUntil.value : this.buriedUntil,
    clozeIndex: clozeIndex.present ? clozeIndex.value : this.clozeIndex,
    easinessFactor: easinessFactor ?? this.easinessFactor,
    flag: flag ?? this.flag,
    noteId: noteId.present ? noteId.value : this.noteId,
    contentHlc: contentHlc ?? this.contentHlc,
    scheduleHlc: scheduleHlc ?? this.scheduleHlc,
  );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      globalId: data.globalId.present ? data.globalId.value : this.globalId,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      deckGlobalId: data.deckGlobalId.present
          ? data.deckGlobalId.value
          : this.deckGlobalId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      state: data.state.present ? data.state.value : this.state,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      due: data.due.present ? data.due.value : this.due,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSuspended: data.isSuspended.present
          ? data.isSuspended.value
          : this.isSuspended,
      buriedUntil: data.buriedUntil.present
          ? data.buriedUntil.value
          : this.buriedUntil,
      clozeIndex: data.clozeIndex.present
          ? data.clozeIndex.value
          : this.clozeIndex,
      easinessFactor: data.easinessFactor.present
          ? data.easinessFactor.value
          : this.easinessFactor,
      flag: data.flag.present ? data.flag.value : this.flag,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      contentHlc: data.contentHlc.present
          ? data.contentHlc.value
          : this.contentHlc,
      scheduleHlc: data.scheduleHlc.present
          ? data.scheduleHlc.value
          : this.scheduleHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('globalId: $globalId, ')
          ..write('deckId: $deckId, ')
          ..write('deckGlobalId: $deckGlobalId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('state: $state, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('due: $due, ')
          ..write('lastReview: $lastReview, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSuspended: $isSuspended, ')
          ..write('buriedUntil: $buriedUntil, ')
          ..write('clozeIndex: $clozeIndex, ')
          ..write('easinessFactor: $easinessFactor, ')
          ..write('flag: $flag, ')
          ..write('noteId: $noteId, ')
          ..write('contentHlc: $contentHlc, ')
          ..write('scheduleHlc: $scheduleHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    globalId,
    deckId,
    deckGlobalId,
    front,
    back,
    state,
    stability,
    difficulty,
    due,
    lastReview,
    reps,
    lapses,
    createdAt,
    isSuspended,
    buriedUntil,
    clozeIndex,
    easinessFactor,
    flag,
    noteId,
    contentHlc,
    scheduleHlc,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.globalId == this.globalId &&
          other.deckId == this.deckId &&
          other.deckGlobalId == this.deckGlobalId &&
          other.front == this.front &&
          other.back == this.back &&
          other.state == this.state &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.due == this.due &&
          other.lastReview == this.lastReview &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.createdAt == this.createdAt &&
          other.isSuspended == this.isSuspended &&
          other.buriedUntil == this.buriedUntil &&
          other.clozeIndex == this.clozeIndex &&
          other.easinessFactor == this.easinessFactor &&
          other.flag == this.flag &&
          other.noteId == this.noteId &&
          other.contentHlc == this.contentHlc &&
          other.scheduleHlc == this.scheduleHlc);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<int> id;
  final Value<String> globalId;
  final Value<int> deckId;
  final Value<String> deckGlobalId;
  final Value<String> front;
  final Value<String> back;
  final Value<int> state;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<DateTime> due;
  final Value<DateTime?> lastReview;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<DateTime> createdAt;
  final Value<bool> isSuspended;
  final Value<DateTime?> buriedUntil;
  final Value<int?> clozeIndex;
  final Value<double> easinessFactor;
  final Value<int> flag;
  final Value<int?> noteId;
  final Value<String> contentHlc;
  final Value<String> scheduleHlc;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.globalId = const Value.absent(),
    this.deckId = const Value.absent(),
    this.deckGlobalId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.state = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.due = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSuspended = const Value.absent(),
    this.buriedUntil = const Value.absent(),
    this.clozeIndex = const Value.absent(),
    this.easinessFactor = const Value.absent(),
    this.flag = const Value.absent(),
    this.noteId = const Value.absent(),
    this.contentHlc = const Value.absent(),
    this.scheduleHlc = const Value.absent(),
  });
  CardsCompanion.insert({
    this.id = const Value.absent(),
    this.globalId = const Value.absent(),
    required int deckId,
    this.deckGlobalId = const Value.absent(),
    required String front,
    required String back,
    this.state = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    required DateTime due,
    this.lastReview = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSuspended = const Value.absent(),
    this.buriedUntil = const Value.absent(),
    this.clozeIndex = const Value.absent(),
    this.easinessFactor = const Value.absent(),
    this.flag = const Value.absent(),
    this.noteId = const Value.absent(),
    this.contentHlc = const Value.absent(),
    this.scheduleHlc = const Value.absent(),
  }) : deckId = Value(deckId),
       front = Value(front),
       back = Value(back),
       due = Value(due);
  static Insertable<Card> custom({
    Expression<int>? id,
    Expression<String>? globalId,
    Expression<int>? deckId,
    Expression<String>? deckGlobalId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<int>? state,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? due,
    Expression<DateTime>? lastReview,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSuspended,
    Expression<DateTime>? buriedUntil,
    Expression<int>? clozeIndex,
    Expression<double>? easinessFactor,
    Expression<int>? flag,
    Expression<int>? noteId,
    Expression<String>? contentHlc,
    Expression<String>? scheduleHlc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (globalId != null) 'global_id': globalId,
      if (deckId != null) 'deck_id': deckId,
      if (deckGlobalId != null) 'deck_global_id': deckGlobalId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (state != null) 'state': state,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (due != null) 'due': due,
      if (lastReview != null) 'last_review': lastReview,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (createdAt != null) 'created_at': createdAt,
      if (isSuspended != null) 'is_suspended': isSuspended,
      if (buriedUntil != null) 'buried_until': buriedUntil,
      if (clozeIndex != null) 'cloze_index': clozeIndex,
      if (easinessFactor != null) 'easiness_factor': easinessFactor,
      if (flag != null) 'flag': flag,
      if (noteId != null) 'note_id': noteId,
      if (contentHlc != null) 'content_hlc': contentHlc,
      if (scheduleHlc != null) 'schedule_hlc': scheduleHlc,
    });
  }

  CardsCompanion copyWith({
    Value<int>? id,
    Value<String>? globalId,
    Value<int>? deckId,
    Value<String>? deckGlobalId,
    Value<String>? front,
    Value<String>? back,
    Value<int>? state,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<DateTime>? due,
    Value<DateTime?>? lastReview,
    Value<int>? reps,
    Value<int>? lapses,
    Value<DateTime>? createdAt,
    Value<bool>? isSuspended,
    Value<DateTime?>? buriedUntil,
    Value<int?>? clozeIndex,
    Value<double>? easinessFactor,
    Value<int>? flag,
    Value<int?>? noteId,
    Value<String>? contentHlc,
    Value<String>? scheduleHlc,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      globalId: globalId ?? this.globalId,
      deckId: deckId ?? this.deckId,
      deckGlobalId: deckGlobalId ?? this.deckGlobalId,
      front: front ?? this.front,
      back: back ?? this.back,
      state: state ?? this.state,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      lastReview: lastReview ?? this.lastReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      createdAt: createdAt ?? this.createdAt,
      isSuspended: isSuspended ?? this.isSuspended,
      buriedUntil: buriedUntil ?? this.buriedUntil,
      clozeIndex: clozeIndex ?? this.clozeIndex,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      flag: flag ?? this.flag,
      noteId: noteId ?? this.noteId,
      contentHlc: contentHlc ?? this.contentHlc,
      scheduleHlc: scheduleHlc ?? this.scheduleHlc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (globalId.present) {
      map['global_id'] = Variable<String>(globalId.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (deckGlobalId.present) {
      map['deck_global_id'] = Variable<String>(deckGlobalId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSuspended.present) {
      map['is_suspended'] = Variable<bool>(isSuspended.value);
    }
    if (buriedUntil.present) {
      map['buried_until'] = Variable<DateTime>(buriedUntil.value);
    }
    if (clozeIndex.present) {
      map['cloze_index'] = Variable<int>(clozeIndex.value);
    }
    if (easinessFactor.present) {
      map['easiness_factor'] = Variable<double>(easinessFactor.value);
    }
    if (flag.present) {
      map['flag'] = Variable<int>(flag.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (contentHlc.present) {
      map['content_hlc'] = Variable<String>(contentHlc.value);
    }
    if (scheduleHlc.present) {
      map['schedule_hlc'] = Variable<String>(scheduleHlc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('globalId: $globalId, ')
          ..write('deckId: $deckId, ')
          ..write('deckGlobalId: $deckGlobalId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('state: $state, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('due: $due, ')
          ..write('lastReview: $lastReview, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSuspended: $isSuspended, ')
          ..write('buriedUntil: $buriedUntil, ')
          ..write('clozeIndex: $clozeIndex, ')
          ..write('easinessFactor: $easinessFactor, ')
          ..write('flag: $flag, ')
          ..write('noteId: $noteId, ')
          ..write('contentHlc: $contentHlc, ')
          ..write('scheduleHlc: $scheduleHlc')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTable extends ReviewLogs
    with TableInfo<$ReviewLogsTable, ReviewLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _globalIdMeta = const VerificationMeta(
    'globalId',
  );
  @override
  late final GeneratedColumn<String> globalId = GeneratedColumn<String>(
    'global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cardGlobalIdMeta = const VerificationMeta(
    'cardGlobalId',
  );
  @override
  late final GeneratedColumn<String> cardGlobalId = GeneratedColumn<String>(
    'card_global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastElapsedDaysMeta = const VerificationMeta(
    'lastElapsedDays',
  );
  @override
  late final GeneratedColumn<int> lastElapsedDays = GeneratedColumn<int>(
    'last_elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
    'scheduled_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _easinessFactorMeta = const VerificationMeta(
    'easinessFactor',
  );
  @override
  late final GeneratedColumn<double> easinessFactor = GeneratedColumn<double>(
    'easiness_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    globalId,
    cardId,
    cardGlobalId,
    rating,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    reviewedAt,
    easinessFactor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('global_id')) {
      context.handle(
        _globalIdMeta,
        globalId.isAcceptableOrUnknown(data['global_id']!, _globalIdMeta),
      );
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('card_global_id')) {
      context.handle(
        _cardGlobalIdMeta,
        cardGlobalId.isAcceptableOrUnknown(
          data['card_global_id']!,
          _cardGlobalIdMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    } else if (isInserting) {
      context.missing(_dueMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    } else if (isInserting) {
      context.missing(_stabilityMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedDaysMeta);
    }
    if (data.containsKey('last_elapsed_days')) {
      context.handle(
        _lastElapsedDaysMeta,
        lastElapsedDays.isAcceptableOrUnknown(
          data['last_elapsed_days']!,
          _lastElapsedDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastElapsedDaysMeta);
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDaysMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('easiness_factor')) {
      context.handle(
        _easinessFactorMeta,
        easinessFactor.isAcceptableOrUnknown(
          data['easiness_factor']!,
          _easinessFactorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      globalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}global_id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      cardGlobalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_global_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_days'],
      )!,
      lastElapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_elapsed_days'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_days'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
      easinessFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}easiness_factor'],
      )!,
    );
  }

  @override
  $ReviewLogsTable createAlias(String alias) {
    return $ReviewLogsTable(attachedDatabase, alias);
  }
}

class ReviewLog extends DataClass implements Insertable<ReviewLog> {
  final int id;
  final String globalId;
  final int cardId;
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
  const ReviewLog({
    required this.id,
    required this.globalId,
    required this.cardId,
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['global_id'] = Variable<String>(globalId);
    map['card_id'] = Variable<int>(cardId);
    map['card_global_id'] = Variable<String>(cardGlobalId);
    map['rating'] = Variable<int>(rating);
    map['state'] = Variable<int>(state);
    map['due'] = Variable<DateTime>(due);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['last_elapsed_days'] = Variable<int>(lastElapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    map['easiness_factor'] = Variable<double>(easinessFactor);
    return map;
  }

  ReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsCompanion(
      id: Value(id),
      globalId: Value(globalId),
      cardId: Value(cardId),
      cardGlobalId: Value(cardGlobalId),
      rating: Value(rating),
      state: Value(state),
      due: Value(due),
      stability: Value(stability),
      difficulty: Value(difficulty),
      elapsedDays: Value(elapsedDays),
      lastElapsedDays: Value(lastElapsedDays),
      scheduledDays: Value(scheduledDays),
      reviewedAt: Value(reviewedAt),
      easinessFactor: Value(easinessFactor),
    );
  }

  factory ReviewLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLog(
      id: serializer.fromJson<int>(json['id']),
      globalId: serializer.fromJson<String>(json['globalId']),
      cardId: serializer.fromJson<int>(json['cardId']),
      cardGlobalId: serializer.fromJson<String>(json['cardGlobalId']),
      rating: serializer.fromJson<int>(json['rating']),
      state: serializer.fromJson<int>(json['state']),
      due: serializer.fromJson<DateTime>(json['due']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      lastElapsedDays: serializer.fromJson<int>(json['lastElapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
      easinessFactor: serializer.fromJson<double>(json['easinessFactor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'globalId': serializer.toJson<String>(globalId),
      'cardId': serializer.toJson<int>(cardId),
      'cardGlobalId': serializer.toJson<String>(cardGlobalId),
      'rating': serializer.toJson<int>(rating),
      'state': serializer.toJson<int>(state),
      'due': serializer.toJson<DateTime>(due),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'lastElapsedDays': serializer.toJson<int>(lastElapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
      'easinessFactor': serializer.toJson<double>(easinessFactor),
    };
  }

  ReviewLog copyWith({
    int? id,
    String? globalId,
    int? cardId,
    String? cardGlobalId,
    int? rating,
    int? state,
    DateTime? due,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? lastElapsedDays,
    int? scheduledDays,
    DateTime? reviewedAt,
    double? easinessFactor,
  }) => ReviewLog(
    id: id ?? this.id,
    globalId: globalId ?? this.globalId,
    cardId: cardId ?? this.cardId,
    cardGlobalId: cardGlobalId ?? this.cardGlobalId,
    rating: rating ?? this.rating,
    state: state ?? this.state,
    due: due ?? this.due,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    lastElapsedDays: lastElapsedDays ?? this.lastElapsedDays,
    scheduledDays: scheduledDays ?? this.scheduledDays,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    easinessFactor: easinessFactor ?? this.easinessFactor,
  );
  ReviewLog copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLog(
      id: data.id.present ? data.id.value : this.id,
      globalId: data.globalId.present ? data.globalId.value : this.globalId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      cardGlobalId: data.cardGlobalId.present
          ? data.cardGlobalId.value
          : this.cardGlobalId,
      rating: data.rating.present ? data.rating.value : this.rating,
      state: data.state.present ? data.state.value : this.state,
      due: data.due.present ? data.due.value : this.due,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      lastElapsedDays: data.lastElapsedDays.present
          ? data.lastElapsedDays.value
          : this.lastElapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      easinessFactor: data.easinessFactor.present
          ? data.easinessFactor.value
          : this.easinessFactor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLog(')
          ..write('id: $id, ')
          ..write('globalId: $globalId, ')
          ..write('cardId: $cardId, ')
          ..write('cardGlobalId: $cardGlobalId, ')
          ..write('rating: $rating, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('lastElapsedDays: $lastElapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('easinessFactor: $easinessFactor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    globalId,
    cardId,
    cardGlobalId,
    rating,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    reviewedAt,
    easinessFactor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLog &&
          other.id == this.id &&
          other.globalId == this.globalId &&
          other.cardId == this.cardId &&
          other.cardGlobalId == this.cardGlobalId &&
          other.rating == this.rating &&
          other.state == this.state &&
          other.due == this.due &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.elapsedDays == this.elapsedDays &&
          other.lastElapsedDays == this.lastElapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.reviewedAt == this.reviewedAt &&
          other.easinessFactor == this.easinessFactor);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLog> {
  final Value<int> id;
  final Value<String> globalId;
  final Value<int> cardId;
  final Value<String> cardGlobalId;
  final Value<int> rating;
  final Value<int> state;
  final Value<DateTime> due;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> elapsedDays;
  final Value<int> lastElapsedDays;
  final Value<int> scheduledDays;
  final Value<DateTime> reviewedAt;
  final Value<double> easinessFactor;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.globalId = const Value.absent(),
    this.cardId = const Value.absent(),
    this.cardGlobalId = const Value.absent(),
    this.rating = const Value.absent(),
    this.state = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.lastElapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.easinessFactor = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    this.id = const Value.absent(),
    this.globalId = const Value.absent(),
    required int cardId,
    this.cardGlobalId = const Value.absent(),
    required int rating,
    required int state,
    required DateTime due,
    required double stability,
    required double difficulty,
    required int elapsedDays,
    required int lastElapsedDays,
    required int scheduledDays,
    required DateTime reviewedAt,
    this.easinessFactor = const Value.absent(),
  }) : cardId = Value(cardId),
       rating = Value(rating),
       state = Value(state),
       due = Value(due),
       stability = Value(stability),
       difficulty = Value(difficulty),
       elapsedDays = Value(elapsedDays),
       lastElapsedDays = Value(lastElapsedDays),
       scheduledDays = Value(scheduledDays),
       reviewedAt = Value(reviewedAt);
  static Insertable<ReviewLog> custom({
    Expression<int>? id,
    Expression<String>? globalId,
    Expression<int>? cardId,
    Expression<String>? cardGlobalId,
    Expression<int>? rating,
    Expression<int>? state,
    Expression<DateTime>? due,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? elapsedDays,
    Expression<int>? lastElapsedDays,
    Expression<int>? scheduledDays,
    Expression<DateTime>? reviewedAt,
    Expression<double>? easinessFactor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (globalId != null) 'global_id': globalId,
      if (cardId != null) 'card_id': cardId,
      if (cardGlobalId != null) 'card_global_id': cardGlobalId,
      if (rating != null) 'rating': rating,
      if (state != null) 'state': state,
      if (due != null) 'due': due,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (lastElapsedDays != null) 'last_elapsed_days': lastElapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (easinessFactor != null) 'easiness_factor': easinessFactor,
    });
  }

  ReviewLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? globalId,
    Value<int>? cardId,
    Value<String>? cardGlobalId,
    Value<int>? rating,
    Value<int>? state,
    Value<DateTime>? due,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? elapsedDays,
    Value<int>? lastElapsedDays,
    Value<int>? scheduledDays,
    Value<DateTime>? reviewedAt,
    Value<double>? easinessFactor,
  }) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      globalId: globalId ?? this.globalId,
      cardId: cardId ?? this.cardId,
      cardGlobalId: cardGlobalId ?? this.cardGlobalId,
      rating: rating ?? this.rating,
      state: state ?? this.state,
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      lastElapsedDays: lastElapsedDays ?? this.lastElapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      easinessFactor: easinessFactor ?? this.easinessFactor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (globalId.present) {
      map['global_id'] = Variable<String>(globalId.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (cardGlobalId.present) {
      map['card_global_id'] = Variable<String>(cardGlobalId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (lastElapsedDays.present) {
      map['last_elapsed_days'] = Variable<int>(lastElapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (easinessFactor.present) {
      map['easiness_factor'] = Variable<double>(easinessFactor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('globalId: $globalId, ')
          ..write('cardId: $cardId, ')
          ..write('cardGlobalId: $cardGlobalId, ')
          ..write('rating: $rating, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('lastElapsedDays: $lastElapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('easinessFactor: $easinessFactor')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _globalIdMeta = const VerificationMeta(
    'globalId',
  );
  @override
  late final GeneratedColumn<String> globalId = GeneratedColumn<String>(
    'global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedHlcMeta = const VerificationMeta(
    'updatedHlc',
  );
  @override
  late final GeneratedColumn<String> updatedHlc = GeneratedColumn<String>(
    'updated_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    globalId,
    name,
    color,
    createdAt,
    updatedHlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('global_id')) {
      context.handle(
        _globalIdMeta,
        globalId.isAcceptableOrUnknown(data['global_id']!, _globalIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_hlc')) {
      context.handle(
        _updatedHlcMeta,
        updatedHlc.isAcceptableOrUnknown(data['updated_hlc']!, _updatedHlcMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      globalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}global_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_hlc'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String globalId;
  final String name;
  final int color;
  final DateTime createdAt;
  final String updatedHlc;
  const Tag({
    required this.id,
    required this.globalId,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedHlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['global_id'] = Variable<String>(globalId);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_hlc'] = Variable<String>(updatedHlc);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      globalId: Value(globalId),
      name: Value(name),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedHlc: Value(updatedHlc),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      globalId: serializer.fromJson<String>(json['globalId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedHlc: serializer.fromJson<String>(json['updatedHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'globalId': serializer.toJson<String>(globalId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedHlc': serializer.toJson<String>(updatedHlc),
    };
  }

  Tag copyWith({
    int? id,
    String? globalId,
    String? name,
    int? color,
    DateTime? createdAt,
    String? updatedHlc,
  }) => Tag(
    id: id ?? this.id,
    globalId: globalId ?? this.globalId,
    name: name ?? this.name,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
    updatedHlc: updatedHlc ?? this.updatedHlc,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      globalId: data.globalId.present ? data.globalId.value : this.globalId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedHlc: data.updatedHlc.present
          ? data.updatedHlc.value
          : this.updatedHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('globalId: $globalId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedHlc: $updatedHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, globalId, name, color, createdAt, updatedHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.globalId == this.globalId &&
          other.name == this.name &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedHlc == this.updatedHlc);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> globalId;
  final Value<String> name;
  final Value<int> color;
  final Value<DateTime> createdAt;
  final Value<String> updatedHlc;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.globalId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedHlc = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    this.globalId = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedHlc = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? globalId,
    Expression<String>? name,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
    Expression<String>? updatedHlc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (globalId != null) 'global_id': globalId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedHlc != null) 'updated_hlc': updatedHlc,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? globalId,
    Value<String>? name,
    Value<int>? color,
    Value<DateTime>? createdAt,
    Value<String>? updatedHlc,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      globalId: globalId ?? this.globalId,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedHlc: updatedHlc ?? this.updatedHlc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (globalId.present) {
      map['global_id'] = Variable<String>(globalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedHlc.present) {
      map['updated_hlc'] = Variable<String>(updatedHlc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('globalId: $globalId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedHlc: $updatedHlc')
          ..write(')'))
        .toString();
  }
}

class $CardTagsTable extends CardTags with TableInfo<$CardTagsTable, CardTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cardGlobalIdMeta = const VerificationMeta(
    'cardGlobalId',
  );
  @override
  late final GeneratedColumn<String> cardGlobalId = GeneratedColumn<String>(
    'card_global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagGlobalIdMeta = const VerificationMeta(
    'tagGlobalId',
  );
  @override
  late final GeneratedColumn<String> tagGlobalId = GeneratedColumn<String>(
    'tag_global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedHlcMeta = const VerificationMeta(
    'updatedHlc',
  );
  @override
  late final GeneratedColumn<String> updatedHlc = GeneratedColumn<String>(
    'updated_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    tagId,
    cardGlobalId,
    tagGlobalId,
    updatedHlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('card_global_id')) {
      context.handle(
        _cardGlobalIdMeta,
        cardGlobalId.isAcceptableOrUnknown(
          data['card_global_id']!,
          _cardGlobalIdMeta,
        ),
      );
    }
    if (data.containsKey('tag_global_id')) {
      context.handle(
        _tagGlobalIdMeta,
        tagGlobalId.isAcceptableOrUnknown(
          data['tag_global_id']!,
          _tagGlobalIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_hlc')) {
      context.handle(
        _updatedHlcMeta,
        updatedHlc.isAcceptableOrUnknown(data['updated_hlc']!, _updatedHlcMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, tagId};
  @override
  CardTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTag(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
      cardGlobalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_global_id'],
      )!,
      tagGlobalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_global_id'],
      )!,
      updatedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_hlc'],
      )!,
    );
  }

  @override
  $CardTagsTable createAlias(String alias) {
    return $CardTagsTable(attachedDatabase, alias);
  }
}

class CardTag extends DataClass implements Insertable<CardTag> {
  final int cardId;
  final int tagId;
  final String cardGlobalId;
  final String tagGlobalId;
  final String updatedHlc;
  const CardTag({
    required this.cardId,
    required this.tagId,
    required this.cardGlobalId,
    required this.tagGlobalId,
    required this.updatedHlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<int>(cardId);
    map['tag_id'] = Variable<int>(tagId);
    map['card_global_id'] = Variable<String>(cardGlobalId);
    map['tag_global_id'] = Variable<String>(tagGlobalId);
    map['updated_hlc'] = Variable<String>(updatedHlc);
    return map;
  }

  CardTagsCompanion toCompanion(bool nullToAbsent) {
    return CardTagsCompanion(
      cardId: Value(cardId),
      tagId: Value(tagId),
      cardGlobalId: Value(cardGlobalId),
      tagGlobalId: Value(tagGlobalId),
      updatedHlc: Value(updatedHlc),
    );
  }

  factory CardTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTag(
      cardId: serializer.fromJson<int>(json['cardId']),
      tagId: serializer.fromJson<int>(json['tagId']),
      cardGlobalId: serializer.fromJson<String>(json['cardGlobalId']),
      tagGlobalId: serializer.fromJson<String>(json['tagGlobalId']),
      updatedHlc: serializer.fromJson<String>(json['updatedHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<int>(cardId),
      'tagId': serializer.toJson<int>(tagId),
      'cardGlobalId': serializer.toJson<String>(cardGlobalId),
      'tagGlobalId': serializer.toJson<String>(tagGlobalId),
      'updatedHlc': serializer.toJson<String>(updatedHlc),
    };
  }

  CardTag copyWith({
    int? cardId,
    int? tagId,
    String? cardGlobalId,
    String? tagGlobalId,
    String? updatedHlc,
  }) => CardTag(
    cardId: cardId ?? this.cardId,
    tagId: tagId ?? this.tagId,
    cardGlobalId: cardGlobalId ?? this.cardGlobalId,
    tagGlobalId: tagGlobalId ?? this.tagGlobalId,
    updatedHlc: updatedHlc ?? this.updatedHlc,
  );
  CardTag copyWithCompanion(CardTagsCompanion data) {
    return CardTag(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      cardGlobalId: data.cardGlobalId.present
          ? data.cardGlobalId.value
          : this.cardGlobalId,
      tagGlobalId: data.tagGlobalId.present
          ? data.tagGlobalId.value
          : this.tagGlobalId,
      updatedHlc: data.updatedHlc.present
          ? data.updatedHlc.value
          : this.updatedHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTag(')
          ..write('cardId: $cardId, ')
          ..write('tagId: $tagId, ')
          ..write('cardGlobalId: $cardGlobalId, ')
          ..write('tagGlobalId: $tagGlobalId, ')
          ..write('updatedHlc: $updatedHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cardId, tagId, cardGlobalId, tagGlobalId, updatedHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTag &&
          other.cardId == this.cardId &&
          other.tagId == this.tagId &&
          other.cardGlobalId == this.cardGlobalId &&
          other.tagGlobalId == this.tagGlobalId &&
          other.updatedHlc == this.updatedHlc);
}

class CardTagsCompanion extends UpdateCompanion<CardTag> {
  final Value<int> cardId;
  final Value<int> tagId;
  final Value<String> cardGlobalId;
  final Value<String> tagGlobalId;
  final Value<String> updatedHlc;
  final Value<int> rowid;
  const CardTagsCompanion({
    this.cardId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.cardGlobalId = const Value.absent(),
    this.tagGlobalId = const Value.absent(),
    this.updatedHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTagsCompanion.insert({
    required int cardId,
    required int tagId,
    this.cardGlobalId = const Value.absent(),
    this.tagGlobalId = const Value.absent(),
    this.updatedHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       tagId = Value(tagId);
  static Insertable<CardTag> custom({
    Expression<int>? cardId,
    Expression<int>? tagId,
    Expression<String>? cardGlobalId,
    Expression<String>? tagGlobalId,
    Expression<String>? updatedHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (tagId != null) 'tag_id': tagId,
      if (cardGlobalId != null) 'card_global_id': cardGlobalId,
      if (tagGlobalId != null) 'tag_global_id': tagGlobalId,
      if (updatedHlc != null) 'updated_hlc': updatedHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTagsCompanion copyWith({
    Value<int>? cardId,
    Value<int>? tagId,
    Value<String>? cardGlobalId,
    Value<String>? tagGlobalId,
    Value<String>? updatedHlc,
    Value<int>? rowid,
  }) {
    return CardTagsCompanion(
      cardId: cardId ?? this.cardId,
      tagId: tagId ?? this.tagId,
      cardGlobalId: cardGlobalId ?? this.cardGlobalId,
      tagGlobalId: tagGlobalId ?? this.tagGlobalId,
      updatedHlc: updatedHlc ?? this.updatedHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (cardGlobalId.present) {
      map['card_global_id'] = Variable<String>(cardGlobalId.value);
    }
    if (tagGlobalId.present) {
      map['tag_global_id'] = Variable<String>(tagGlobalId.value);
    }
    if (updatedHlc.present) {
      map['updated_hlc'] = Variable<String>(updatedHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTagsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('tagId: $tagId, ')
          ..write('cardGlobalId: $cardGlobalId, ')
          ..write('tagGlobalId: $tagGlobalId, ')
          ..write('updatedHlc: $updatedHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaTable extends Media with TableInfo<$MediaTable, MediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fileName,
    checksum,
    sizeBytes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaTable createAlias(String alias) {
    return $MediaTable(attachedDatabase, alias);
  }
}

class MediaData extends DataClass implements Insertable<MediaData> {
  final int id;
  final String fileName;
  final String checksum;
  final int sizeBytes;
  final DateTime createdAt;
  const MediaData({
    required this.id,
    required this.fileName,
    required this.checksum,
    required this.sizeBytes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_name'] = Variable<String>(fileName);
    map['checksum'] = Variable<String>(checksum);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      id: Value(id),
      fileName: Value(fileName),
      checksum: Value(checksum),
      sizeBytes: Value(sizeBytes),
      createdAt: Value(createdAt),
    );
  }

  factory MediaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaData(
      id: serializer.fromJson<int>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      checksum: serializer.fromJson<String>(json['checksum']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fileName': serializer.toJson<String>(fileName),
      'checksum': serializer.toJson<String>(checksum),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MediaData copyWith({
    int? id,
    String? fileName,
    String? checksum,
    int? sizeBytes,
    DateTime? createdAt,
  }) => MediaData(
    id: id ?? this.id,
    fileName: fileName ?? this.fileName,
    checksum: checksum ?? this.checksum,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaData copyWithCompanion(MediaCompanion data) {
    return MediaData(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaData(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('checksum: $checksum, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fileName, checksum, sizeBytes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaData &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.checksum == this.checksum &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt);
}

class MediaCompanion extends UpdateCompanion<MediaData> {
  final Value<int> id;
  final Value<String> fileName;
  final Value<String> checksum;
  final Value<int> sizeBytes;
  final Value<DateTime> createdAt;
  const MediaCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.checksum = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MediaCompanion.insert({
    this.id = const Value.absent(),
    required String fileName,
    required String checksum,
    required int sizeBytes,
    this.createdAt = const Value.absent(),
  }) : fileName = Value(fileName),
       checksum = Value(checksum),
       sizeBytes = Value(sizeBytes);
  static Insertable<MediaData> custom({
    Expression<int>? id,
    Expression<String>? fileName,
    Expression<String>? checksum,
    Expression<int>? sizeBytes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (checksum != null) 'checksum': checksum,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MediaCompanion copyWith({
    Value<int>? id,
    Value<String>? fileName,
    Value<String>? checksum,
    Value<int>? sizeBytes,
    Value<DateTime>? createdAt,
  }) {
    return MediaCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      checksum: checksum ?? this.checksum,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('checksum: $checksum, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncTombstonesTable extends SyncTombstones
    with TableInfo<$SyncTombstonesTable, SyncTombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncTombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _globalIdMeta = const VerificationMeta(
    'globalId',
  );
  @override
  late final GeneratedColumn<String> globalId = GeneratedColumn<String>(
    'global_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedHlcMeta = const VerificationMeta(
    'deletedHlc',
  );
  @override
  late final GeneratedColumn<String> deletedHlc = GeneratedColumn<String>(
    'deleted_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<int> entityType = GeneratedColumn<int>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [globalId, deletedHlc, entityType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncTombstone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('global_id')) {
      context.handle(
        _globalIdMeta,
        globalId.isAcceptableOrUnknown(data['global_id']!, _globalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_globalIdMeta);
    }
    if (data.containsKey('deleted_hlc')) {
      context.handle(
        _deletedHlcMeta,
        deletedHlc.isAcceptableOrUnknown(data['deleted_hlc']!, _deletedHlcMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedHlcMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {globalId};
  @override
  SyncTombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncTombstone(
      globalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}global_id'],
      )!,
      deletedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_hlc'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_type'],
      )!,
    );
  }

  @override
  $SyncTombstonesTable createAlias(String alias) {
    return $SyncTombstonesTable(attachedDatabase, alias);
  }
}

class SyncTombstone extends DataClass implements Insertable<SyncTombstone> {
  final String globalId;
  final String deletedHlc;
  final int entityType;
  const SyncTombstone({
    required this.globalId,
    required this.deletedHlc,
    required this.entityType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['global_id'] = Variable<String>(globalId);
    map['deleted_hlc'] = Variable<String>(deletedHlc);
    map['entity_type'] = Variable<int>(entityType);
    return map;
  }

  SyncTombstonesCompanion toCompanion(bool nullToAbsent) {
    return SyncTombstonesCompanion(
      globalId: Value(globalId),
      deletedHlc: Value(deletedHlc),
      entityType: Value(entityType),
    );
  }

  factory SyncTombstone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncTombstone(
      globalId: serializer.fromJson<String>(json['globalId']),
      deletedHlc: serializer.fromJson<String>(json['deletedHlc']),
      entityType: serializer.fromJson<int>(json['entityType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'globalId': serializer.toJson<String>(globalId),
      'deletedHlc': serializer.toJson<String>(deletedHlc),
      'entityType': serializer.toJson<int>(entityType),
    };
  }

  SyncTombstone copyWith({
    String? globalId,
    String? deletedHlc,
    int? entityType,
  }) => SyncTombstone(
    globalId: globalId ?? this.globalId,
    deletedHlc: deletedHlc ?? this.deletedHlc,
    entityType: entityType ?? this.entityType,
  );
  SyncTombstone copyWithCompanion(SyncTombstonesCompanion data) {
    return SyncTombstone(
      globalId: data.globalId.present ? data.globalId.value : this.globalId,
      deletedHlc: data.deletedHlc.present
          ? data.deletedHlc.value
          : this.deletedHlc,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstone(')
          ..write('globalId: $globalId, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('entityType: $entityType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(globalId, deletedHlc, entityType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncTombstone &&
          other.globalId == this.globalId &&
          other.deletedHlc == this.deletedHlc &&
          other.entityType == this.entityType);
}

class SyncTombstonesCompanion extends UpdateCompanion<SyncTombstone> {
  final Value<String> globalId;
  final Value<String> deletedHlc;
  final Value<int> entityType;
  final Value<int> rowid;
  const SyncTombstonesCompanion({
    this.globalId = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.entityType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncTombstonesCompanion.insert({
    required String globalId,
    required String deletedHlc,
    required int entityType,
    this.rowid = const Value.absent(),
  }) : globalId = Value(globalId),
       deletedHlc = Value(deletedHlc),
       entityType = Value(entityType);
  static Insertable<SyncTombstone> custom({
    Expression<String>? globalId,
    Expression<String>? deletedHlc,
    Expression<int>? entityType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (globalId != null) 'global_id': globalId,
      if (deletedHlc != null) 'deleted_hlc': deletedHlc,
      if (entityType != null) 'entity_type': entityType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncTombstonesCompanion copyWith({
    Value<String>? globalId,
    Value<String>? deletedHlc,
    Value<int>? entityType,
    Value<int>? rowid,
  }) {
    return SyncTombstonesCompanion(
      globalId: globalId ?? this.globalId,
      deletedHlc: deletedHlc ?? this.deletedHlc,
      entityType: entityType ?? this.entityType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (globalId.present) {
      map['global_id'] = Variable<String>(globalId.value);
    }
    if (deletedHlc.present) {
      map['deleted_hlc'] = Variable<String>(deletedHlc.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<int>(entityType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstonesCompanion(')
          ..write('globalId: $globalId, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('entityType: $entityType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPeerCursorsTable extends SyncPeerCursors
    with TableInfo<$SyncPeerCursorsTable, SyncPeerCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPeerCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerIdMeta = const VerificationMeta('peerId');
  @override
  late final GeneratedColumn<String> peerId = GeneratedColumn<String>(
    'peer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genMeta = const VerificationMeta('gen');
  @override
  late final GeneratedColumn<int> gen = GeneratedColumn<int>(
    'gen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _byteOffsetMeta = const VerificationMeta(
    'byteOffset',
  );
  @override
  late final GeneratedColumn<int> byteOffset = GeneratedColumn<int>(
    'byte_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [peerId, gen, byteOffset, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_peer_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPeerCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_id')) {
      context.handle(
        _peerIdMeta,
        peerId.isAcceptableOrUnknown(data['peer_id']!, _peerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_peerIdMeta);
    }
    if (data.containsKey('gen')) {
      context.handle(
        _genMeta,
        gen.isAcceptableOrUnknown(data['gen']!, _genMeta),
      );
    }
    if (data.containsKey('byte_offset')) {
      context.handle(
        _byteOffsetMeta,
        byteOffset.isAcceptableOrUnknown(data['byte_offset']!, _byteOffsetMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerId};
  @override
  SyncPeerCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPeerCursor(
      peerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_id'],
      )!,
      gen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gen'],
      )!,
      byteOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_offset'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $SyncPeerCursorsTable createAlias(String alias) {
    return $SyncPeerCursorsTable(attachedDatabase, alias);
  }
}

class SyncPeerCursor extends DataClass implements Insertable<SyncPeerCursor> {
  final String peerId;
  final int gen;
  final int byteOffset;
  final DateTime lastSyncedAt;
  const SyncPeerCursor({
    required this.peerId,
    required this.gen,
    required this.byteOffset,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_id'] = Variable<String>(peerId);
    map['gen'] = Variable<int>(gen);
    map['byte_offset'] = Variable<int>(byteOffset);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  SyncPeerCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncPeerCursorsCompanion(
      peerId: Value(peerId),
      gen: Value(gen),
      byteOffset: Value(byteOffset),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory SyncPeerCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPeerCursor(
      peerId: serializer.fromJson<String>(json['peerId']),
      gen: serializer.fromJson<int>(json['gen']),
      byteOffset: serializer.fromJson<int>(json['byteOffset']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerId': serializer.toJson<String>(peerId),
      'gen': serializer.toJson<int>(gen),
      'byteOffset': serializer.toJson<int>(byteOffset),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  SyncPeerCursor copyWith({
    String? peerId,
    int? gen,
    int? byteOffset,
    DateTime? lastSyncedAt,
  }) => SyncPeerCursor(
    peerId: peerId ?? this.peerId,
    gen: gen ?? this.gen,
    byteOffset: byteOffset ?? this.byteOffset,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  SyncPeerCursor copyWithCompanion(SyncPeerCursorsCompanion data) {
    return SyncPeerCursor(
      peerId: data.peerId.present ? data.peerId.value : this.peerId,
      gen: data.gen.present ? data.gen.value : this.gen,
      byteOffset: data.byteOffset.present
          ? data.byteOffset.value
          : this.byteOffset,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPeerCursor(')
          ..write('peerId: $peerId, ')
          ..write('gen: $gen, ')
          ..write('byteOffset: $byteOffset, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(peerId, gen, byteOffset, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPeerCursor &&
          other.peerId == this.peerId &&
          other.gen == this.gen &&
          other.byteOffset == this.byteOffset &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncPeerCursorsCompanion extends UpdateCompanion<SyncPeerCursor> {
  final Value<String> peerId;
  final Value<int> gen;
  final Value<int> byteOffset;
  final Value<DateTime> lastSyncedAt;
  final Value<int> rowid;
  const SyncPeerCursorsCompanion({
    this.peerId = const Value.absent(),
    this.gen = const Value.absent(),
    this.byteOffset = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncPeerCursorsCompanion.insert({
    required String peerId,
    this.gen = const Value.absent(),
    this.byteOffset = const Value.absent(),
    required DateTime lastSyncedAt,
    this.rowid = const Value.absent(),
  }) : peerId = Value(peerId),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<SyncPeerCursor> custom({
    Expression<String>? peerId,
    Expression<int>? gen,
    Expression<int>? byteOffset,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerId != null) 'peer_id': peerId,
      if (gen != null) 'gen': gen,
      if (byteOffset != null) 'byte_offset': byteOffset,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncPeerCursorsCompanion copyWith({
    Value<String>? peerId,
    Value<int>? gen,
    Value<int>? byteOffset,
    Value<DateTime>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncPeerCursorsCompanion(
      peerId: peerId ?? this.peerId,
      gen: gen ?? this.gen,
      byteOffset: byteOffset ?? this.byteOffset,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerId.present) {
      map['peer_id'] = Variable<String>(peerId.value);
    }
    if (gen.present) {
      map['gen'] = Variable<int>(gen.value);
    }
    if (byteOffset.present) {
      map['byte_offset'] = Variable<int>(byteOffset.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPeerCursorsCompanion(')
          ..write('peerId: $peerId, ')
          ..write('gen: $gen, ')
          ..write('byteOffset: $byteOffset, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $ReviewLogsTable reviewLogs = $ReviewLogsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $CardTagsTable cardTags = $CardTagsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $MediaTable media = $MediaTable(this);
  late final $SyncTombstonesTable syncTombstones = $SyncTombstonesTable(this);
  late final $SyncPeerCursorsTable syncPeerCursors = $SyncPeerCursorsTable(
    this,
  );
  late final Index idxDecksGlobalId = Index(
    'idx_decks_global_id',
    'CREATE INDEX idx_decks_global_id ON decks (global_id)',
  );
  late final Index idxCardsDeckId = Index(
    'idx_cards_deck_id',
    'CREATE INDEX idx_cards_deck_id ON cards (deck_id)',
  );
  late final Index idxCardsDue = Index(
    'idx_cards_due',
    'CREATE INDEX idx_cards_due ON cards (due)',
  );
  late final Index idxCardsNoteId = Index(
    'idx_cards_note_id',
    'CREATE INDEX idx_cards_note_id ON cards (note_id)',
  );
  late final Index idxCardsGlobalId = Index(
    'idx_cards_global_id',
    'CREATE INDEX idx_cards_global_id ON cards (global_id)',
  );
  late final Index idxReviewLogsCardId = Index(
    'idx_review_logs_card_id',
    'CREATE INDEX idx_review_logs_card_id ON review_logs (card_id)',
  );
  late final Index idxReviewLogsReviewedAt = Index(
    'idx_review_logs_reviewed_at',
    'CREATE INDEX idx_review_logs_reviewed_at ON review_logs (reviewed_at)',
  );
  late final Index idxReviewLogsGlobalId = Index(
    'idx_review_logs_global_id',
    'CREATE INDEX idx_review_logs_global_id ON review_logs (global_id)',
  );
  late final Index idxTagsGlobalId = Index(
    'idx_tags_global_id',
    'CREATE INDEX idx_tags_global_id ON tags (global_id)',
  );
  late final Index idxCardTagsTagId = Index(
    'idx_card_tags_tag_id',
    'CREATE INDEX idx_card_tags_tag_id ON card_tags (tag_id)',
  );
  late final Index idxMediaChecksum = Index(
    'idx_media_checksum',
    'CREATE INDEX idx_media_checksum ON media (checksum)',
  );
  late final DecksDao decksDao = DecksDao(this as AppDatabase);
  late final CardsDao cardsDao = CardsDao(this as AppDatabase);
  late final StudySessionDao studySessionDao = StudySessionDao(
    this as AppDatabase,
  );
  late final StatsDao statsDao = StatsDao(this as AppDatabase);
  late final TagsDao tagsDao = TagsDao(this as AppDatabase);
  late final MediaDao mediaDao = MediaDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    decks,
    cards,
    reviewLogs,
    tags,
    cardTags,
    appSettings,
    media,
    syncTombstones,
    syncPeerCursors,
    idxDecksGlobalId,
    idxCardsDeckId,
    idxCardsDue,
    idxCardsNoteId,
    idxCardsGlobalId,
    idxReviewLogsCardId,
    idxReviewLogsReviewedAt,
    idxReviewLogsGlobalId,
    idxTagsGlobalId,
    idxCardTagsTagId,
    idxMediaChecksum,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('review_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DecksTableCreateCompanionBuilder = DecksCompanion Function({
  Value<int> id,
  Value<String> globalId,
  required String name,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> examDate,
  Value<double?> targetRetention,
  Value<String> updatedHlc,
});
typedef $$DecksTableUpdateCompanionBuilder = DecksCompanion Function({
  Value<int> id,
  Value<String> globalId,
  Value<String> name,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> examDate,
  Value<double?> targetRetention,
  Value<String> updatedHlc,
});

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<Card>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: 'decks__id__cards__deck_id',
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get examDate => $composableBuilder(
    column: $table.examDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetRetention => $composableBuilder(
    column: $table.targetRetention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get examDate => $composableBuilder(
    column: $table.examDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetRetention => $composableBuilder(
    column: $table.targetRetention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get globalId =>
      $composableBuilder(column: $table.globalId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get examDate =>
      $composableBuilder(column: $table.examDate, builder: (column) => column);

  GeneratedColumn<double> get targetRetention => $composableBuilder(
    column: $table.targetRetention,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => column,
  );

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          Deck,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (Deck, $$DecksTableReferences),
          Deck,
          PrefetchHooks Function({bool cardsRefs})
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> globalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> examDate = const Value.absent(),
                Value<double?> targetRetention = const Value.absent(),
                Value<String> updatedHlc = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                globalId: globalId,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                examDate: examDate,
                targetRetention: targetRetention,
                updatedHlc: updatedHlc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> globalId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> examDate = const Value.absent(),
                Value<double?> targetRetention = const Value.absent(),
                Value<String> updatedHlc = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                globalId: globalId,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                examDate: examDate,
                targetRetention: targetRetention,
                updatedHlc: updatedHlc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DecksTable, Deck>(table),
                  $$DecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardsRefs) db.cards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedData<Deck, $DecksTable, Card>(
                      currentTable: table,
                      referencedTable: $$DecksTableReferences._cardsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$DecksTableReferences(db, table, p0).cardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deckId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      Deck,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (Deck, $$DecksTableReferences),
      Deck,
      PrefetchHooks Function({bool cardsRefs})
    >;
typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  Value<int> id,
  Value<String> globalId,
  required int deckId,
  Value<String> deckGlobalId,
  required String front,
  required String back,
  Value<int> state,
  Value<double> stability,
  Value<double> difficulty,
  required DateTime due,
  Value<DateTime?> lastReview,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime> createdAt,
  Value<bool> isSuspended,
  Value<DateTime?> buriedUntil,
  Value<int?> clozeIndex,
  Value<double> easinessFactor,
  Value<int> flag,
  Value<int?> noteId,
  Value<String> contentHlc,
  Value<String> scheduleHlc,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<int> id,
  Value<String> globalId,
  Value<int> deckId,
  Value<String> deckGlobalId,
  Value<String> front,
  Value<String> back,
  Value<int> state,
  Value<double> stability,
  Value<double> difficulty,
  Value<DateTime> due,
  Value<DateTime?> lastReview,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime> createdAt,
  Value<bool> isSuspended,
  Value<DateTime?> buriedUntil,
  Value<int?> clozeIndex,
  Value<double> easinessFactor,
  Value<int> flag,
  Value<int?> noteId,
  Value<String> contentHlc,
  Value<String> scheduleHlc,
});

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, Card> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias('cards__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewLogsTable, List<ReviewLog>>
  _reviewLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewLogs,
    aliasName: 'cards__id__review_logs__card_id',
  );

  $$ReviewLogsTableProcessedTableManager get reviewLogsRefs {
    final manager = $$ReviewLogsTableTableManager(
      $_db,
      $_db.reviewLogs,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardTagsTable, List<CardTag>> _cardTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cardTags,
    aliasName: 'cards__id__card_tags__card_id',
  );

  $$CardTagsTableProcessedTableManager get cardTagsRefs {
    final manager = $$CardTagsTableTableManager(
      $_db,
      $_db.cardTags,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deckGlobalId => $composableBuilder(
    column: $table.deckGlobalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSuspended => $composableBuilder(
    column: $table.isSuspended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get buriedUntil => $composableBuilder(
    column: $table.buriedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clozeIndex => $composableBuilder(
    column: $table.clozeIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flag => $composableBuilder(
    column: $table.flag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHlc => $composableBuilder(
    column: $table.contentHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleHlc => $composableBuilder(
    column: $table.scheduleHlc,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reviewLogsRefs(
    Expression<bool> Function($$ReviewLogsTableFilterComposer f) f,
  ) {
    final $$ReviewLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableFilterComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardTagsRefs(
    Expression<bool> Function($$CardTagsTableFilterComposer f) f,
  ) {
    final $$CardTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTags,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTagsTableFilterComposer(
            $db: $db,
            $table: $db.cardTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deckGlobalId => $composableBuilder(
    column: $table.deckGlobalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSuspended => $composableBuilder(
    column: $table.isSuspended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get buriedUntil => $composableBuilder(
    column: $table.buriedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clozeIndex => $composableBuilder(
    column: $table.clozeIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flag => $composableBuilder(
    column: $table.flag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHlc => $composableBuilder(
    column: $table.contentHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleHlc => $composableBuilder(
    column: $table.scheduleHlc,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get globalId =>
      $composableBuilder(column: $table.globalId, builder: (column) => column);

  GeneratedColumn<String> get deckGlobalId => $composableBuilder(
    column: $table.deckGlobalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSuspended => $composableBuilder(
    column: $table.isSuspended,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get buriedUntil => $composableBuilder(
    column: $table.buriedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clozeIndex => $composableBuilder(
    column: $table.clozeIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<int> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get contentHlc => $composableBuilder(
    column: $table.contentHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleHlc => $composableBuilder(
    column: $table.scheduleHlc,
    builder: (column) => column,
  );

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reviewLogsRefs<T extends Object>(
    Expression<T> Function($$ReviewLogsTableAnnotationComposer a) f,
  ) {
    final $$ReviewLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardTagsRefs<T extends Object>(
    Expression<T> Function($$CardTagsTableAnnotationComposer a) f,
  ) {
    final $$CardTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTags,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          Card,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (Card, $$CardsTableReferences),
          Card,
          PrefetchHooks Function({
            bool deckId,
            bool reviewLogsRefs,
            bool cardTagsRefs,
          })
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> globalId = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<String> deckGlobalId = const Value.absent(),
                Value<String> front = const Value.absent(),
                Value<String> back = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSuspended = const Value.absent(),
                Value<DateTime?> buriedUntil = const Value.absent(),
                Value<int?> clozeIndex = const Value.absent(),
                Value<double> easinessFactor = const Value.absent(),
                Value<int> flag = const Value.absent(),
                Value<int?> noteId = const Value.absent(),
                Value<String> contentHlc = const Value.absent(),
                Value<String> scheduleHlc = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                globalId: globalId,
                deckId: deckId,
                deckGlobalId: deckGlobalId,
                front: front,
                back: back,
                state: state,
                stability: stability,
                difficulty: difficulty,
                due: due,
                lastReview: lastReview,
                reps: reps,
                lapses: lapses,
                createdAt: createdAt,
                isSuspended: isSuspended,
                buriedUntil: buriedUntil,
                clozeIndex: clozeIndex,
                easinessFactor: easinessFactor,
                flag: flag,
                noteId: noteId,
                contentHlc: contentHlc,
                scheduleHlc: scheduleHlc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> globalId = const Value.absent(),
                required int deckId,
                Value<String> deckGlobalId = const Value.absent(),
                required String front,
                required String back,
                Value<int> state = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                required DateTime due,
                Value<DateTime?> lastReview = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSuspended = const Value.absent(),
                Value<DateTime?> buriedUntil = const Value.absent(),
                Value<int?> clozeIndex = const Value.absent(),
                Value<double> easinessFactor = const Value.absent(),
                Value<int> flag = const Value.absent(),
                Value<int?> noteId = const Value.absent(),
                Value<String> contentHlc = const Value.absent(),
                Value<String> scheduleHlc = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                globalId: globalId,
                deckId: deckId,
                deckGlobalId: deckGlobalId,
                front: front,
                back: back,
                state: state,
                stability: stability,
                difficulty: difficulty,
                due: due,
                lastReview: lastReview,
                reps: reps,
                lapses: lapses,
                createdAt: createdAt,
                isSuspended: isSuspended,
                buriedUntil: buriedUntil,
                clozeIndex: clozeIndex,
                easinessFactor: easinessFactor,
                flag: flag,
                noteId: noteId,
                contentHlc: contentHlc,
                scheduleHlc: scheduleHlc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardsTable, Card>(table),
                  $$CardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({deckId = false, reviewLogsRefs = false, cardTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reviewLogsRefs) db.reviewLogs,
                    if (cardTagsRefs) db.cardTags,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (deckId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.deckId,
                            referencedTable: $$CardsTableReferences
                                ._deckIdTable(db),
                            referencedColumn: $$CardsTableReferences
                                ._deckIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reviewLogsRefs)
                        await $_getPrefetchedData<Card, $CardsTable, ReviewLog>(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._reviewLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardTagsRefs)
                        await $_getPrefetchedData<Card, $CardsTable, CardTag>(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._cardTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      Card,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (Card, $$CardsTableReferences),
      Card,
      PrefetchHooks Function({
        bool deckId,
        bool reviewLogsRefs,
        bool cardTagsRefs,
      })
    >;
typedef $$ReviewLogsTableCreateCompanionBuilder = ReviewLogsCompanion Function({
  Value<int> id,
  Value<String> globalId,
  required int cardId,
  Value<String> cardGlobalId,
  required int rating,
  required int state,
  required DateTime due,
  required double stability,
  required double difficulty,
  required int elapsedDays,
  required int lastElapsedDays,
  required int scheduledDays,
  required DateTime reviewedAt,
  Value<double> easinessFactor,
});
typedef $$ReviewLogsTableUpdateCompanionBuilder = ReviewLogsCompanion Function({
  Value<int> id,
  Value<String> globalId,
  Value<int> cardId,
  Value<String> cardGlobalId,
  Value<int> rating,
  Value<int> state,
  Value<DateTime> due,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> elapsedDays,
  Value<int> lastElapsedDays,
  Value<int> scheduledDays,
  Value<DateTime> reviewedAt,
  Value<double> easinessFactor,
});

final class $$ReviewLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLog> {
  $$ReviewLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('review_logs__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardGlobalId => $composableBuilder(
    column: $table.cardGlobalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardGlobalId => $composableBuilder(
    column: $table.cardGlobalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get globalId =>
      $composableBuilder(column: $table.globalId, builder: (column) => column);

  GeneratedColumn<String> get cardGlobalId => $composableBuilder(
    column: $table.cardGlobalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastElapsedDays => $composableBuilder(
    column: $table.lastElapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easinessFactor => $composableBuilder(
    column: $table.easinessFactor,
    builder: (column) => column,
  );

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogsTable,
          ReviewLog,
          $$ReviewLogsTableFilterComposer,
          $$ReviewLogsTableOrderingComposer,
          $$ReviewLogsTableAnnotationComposer,
          $$ReviewLogsTableCreateCompanionBuilder,
          $$ReviewLogsTableUpdateCompanionBuilder,
          (ReviewLog, $$ReviewLogsTableReferences),
          ReviewLog,
          PrefetchHooks Function({bool cardId})
        > {
  $$ReviewLogsTableTableManager(_$AppDatabase db, $ReviewLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> globalId = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> cardGlobalId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> lastElapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<double> easinessFactor = const Value.absent(),
              }) => ReviewLogsCompanion(
                id: id,
                globalId: globalId,
                cardId: cardId,
                cardGlobalId: cardGlobalId,
                rating: rating,
                state: state,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                lastElapsedDays: lastElapsedDays,
                scheduledDays: scheduledDays,
                reviewedAt: reviewedAt,
                easinessFactor: easinessFactor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> globalId = const Value.absent(),
                required int cardId,
                Value<String> cardGlobalId = const Value.absent(),
                required int rating,
                required int state,
                required DateTime due,
                required double stability,
                required double difficulty,
                required int elapsedDays,
                required int lastElapsedDays,
                required int scheduledDays,
                required DateTime reviewedAt,
                Value<double> easinessFactor = const Value.absent(),
              }) => ReviewLogsCompanion.insert(
                id: id,
                globalId: globalId,
                cardId: cardId,
                cardGlobalId: cardGlobalId,
                rating: rating,
                state: state,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                lastElapsedDays: lastElapsedDays,
                scheduledDays: scheduledDays,
                reviewedAt: reviewedAt,
                easinessFactor: easinessFactor,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewLogsTable, ReviewLog>(table),
                  $$ReviewLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$ReviewLogsTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$ReviewLogsTableReferences
                            ._cardIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogsTable,
      ReviewLog,
      $$ReviewLogsTableFilterComposer,
      $$ReviewLogsTableOrderingComposer,
      $$ReviewLogsTableAnnotationComposer,
      $$ReviewLogsTableCreateCompanionBuilder,
      $$ReviewLogsTableUpdateCompanionBuilder,
      (ReviewLog, $$ReviewLogsTableReferences),
      ReviewLog,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> globalId,
  required String name,
  Value<int> color,
  Value<DateTime> createdAt,
  Value<String> updatedHlc,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> globalId,
  Value<String> name,
  Value<int> color,
  Value<DateTime> createdAt,
  Value<String> updatedHlc,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardTagsTable, List<CardTag>> _cardTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cardTags,
    aliasName: 'tags__id__card_tags__tag_id',
  );

  $$CardTagsTableProcessedTableManager get cardTagsRefs {
    final manager = $$CardTagsTableTableManager(
      $_db,
      $_db.cardTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardTagsRefs(
    Expression<bool> Function($$CardTagsTableFilterComposer f) f,
  ) {
    final $$CardTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTagsTableFilterComposer(
            $db: $db,
            $table: $db.cardTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get globalId =>
      $composableBuilder(column: $table.globalId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => column,
  );

  Expression<T> cardTagsRefs<T extends Object>(
    Expression<T> Function($$CardTagsTableAnnotationComposer a) f,
  ) {
    final $$CardTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool cardTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> globalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> updatedHlc = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                globalId: globalId,
                name: name,
                color: color,
                createdAt: createdAt,
                updatedHlc: updatedHlc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> globalId = const Value.absent(),
                required String name,
                Value<int> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> updatedHlc = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                globalId: globalId,
                name: name,
                color: color,
                createdAt: createdAt,
                updatedHlc: updatedHlc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, Tag>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardTagsRefs) db.cardTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, CardTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._cardTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).cardTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool cardTagsRefs})
    >;
typedef $$CardTagsTableCreateCompanionBuilder = CardTagsCompanion Function({
  required int cardId,
  required int tagId,
  Value<String> cardGlobalId,
  Value<String> tagGlobalId,
  Value<String> updatedHlc,
  Value<int> rowid,
});
typedef $$CardTagsTableUpdateCompanionBuilder = CardTagsCompanion Function({
  Value<int> cardId,
  Value<int> tagId,
  Value<String> cardGlobalId,
  Value<String> tagGlobalId,
  Value<String> updatedHlc,
  Value<int> rowid,
});

final class $$CardTagsTableReferences
    extends BaseReferences<_$AppDatabase, $CardTagsTable, CardTag> {
  $$CardTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('card_tags__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('card_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardTagsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTagsTable> {
  $$CardTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardGlobalId => $composableBuilder(
    column: $table.cardGlobalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagGlobalId => $composableBuilder(
    column: $table.tagGlobalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTagsTable> {
  $$CardTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardGlobalId => $composableBuilder(
    column: $table.cardGlobalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagGlobalId => $composableBuilder(
    column: $table.tagGlobalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTagsTable> {
  $$CardTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardGlobalId => $composableBuilder(
    column: $table.cardGlobalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagGlobalId => $composableBuilder(
    column: $table.tagGlobalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedHlc => $composableBuilder(
    column: $table.updatedHlc,
    builder: (column) => column,
  );

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTagsTable,
          CardTag,
          $$CardTagsTableFilterComposer,
          $$CardTagsTableOrderingComposer,
          $$CardTagsTableAnnotationComposer,
          $$CardTagsTableCreateCompanionBuilder,
          $$CardTagsTableUpdateCompanionBuilder,
          (CardTag, $$CardTagsTableReferences),
          CardTag,
          PrefetchHooks Function({bool cardId, bool tagId})
        > {
  $$CardTagsTableTableManager(_$AppDatabase db, $CardTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> cardId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<String> cardGlobalId = const Value.absent(),
                Value<String> tagGlobalId = const Value.absent(),
                Value<String> updatedHlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTagsCompanion(
                cardId: cardId,
                tagId: tagId,
                cardGlobalId: cardGlobalId,
                tagGlobalId: tagGlobalId,
                updatedHlc: updatedHlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int cardId,
                required int tagId,
                Value<String> cardGlobalId = const Value.absent(),
                Value<String> tagGlobalId = const Value.absent(),
                Value<String> updatedHlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTagsCompanion.insert(
                cardId: cardId,
                tagId: tagId,
                cardGlobalId: cardGlobalId,
                tagGlobalId: tagGlobalId,
                updatedHlc: updatedHlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardTagsTable, CardTag>(table),
                  $$CardTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$CardTagsTableReferences._cardIdTable(
                          db,
                        ),
                        referencedColumn: $$CardTagsTableReferences
                            ._cardIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$CardTagsTableReferences._tagIdTable(
                          db,
                        ),
                        referencedColumn: $$CardTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTagsTable,
      CardTag,
      $$CardTagsTableFilterComposer,
      $$CardTagsTableOrderingComposer,
      $$CardTagsTableAnnotationComposer,
      $$CardTagsTableCreateCompanionBuilder,
      $$CardTagsTableUpdateCompanionBuilder,
      (CardTag, $$CardTagsTableReferences),
      CardTag,
      PrefetchHooks Function({bool cardId, bool tagId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$MediaTableCreateCompanionBuilder = MediaCompanion Function({
  Value<int> id,
  required String fileName,
  required String checksum,
  required int sizeBytes,
  Value<DateTime> createdAt,
});
typedef $$MediaTableUpdateCompanionBuilder = MediaCompanion Function({
  Value<int> id,
  Value<String> fileName,
  Value<String> checksum,
  Value<int> sizeBytes,
  Value<DateTime> createdAt,
});

class $$MediaTableFilterComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaTable,
          MediaData,
          $$MediaTableFilterComposer,
          $$MediaTableOrderingComposer,
          $$MediaTableAnnotationComposer,
          $$MediaTableCreateCompanionBuilder,
          $$MediaTableUpdateCompanionBuilder,
          (MediaData, BaseReferences<_$AppDatabase, $MediaTable, MediaData>),
          MediaData,
          PrefetchHooks Function()
        > {
  $$MediaTableTableManager(_$AppDatabase db, $MediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MediaCompanion(
                id: id,
                fileName: fileName,
                checksum: checksum,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fileName,
                required String checksum,
                required int sizeBytes,
                Value<DateTime> createdAt = const Value.absent(),
              }) => MediaCompanion.insert(
                id: id,
                fileName: fileName,
                checksum: checksum,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaTable, MediaData>(table),
                  BaseReferences<_$AppDatabase, $MediaTable, MediaData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaTable,
      MediaData,
      $$MediaTableFilterComposer,
      $$MediaTableOrderingComposer,
      $$MediaTableAnnotationComposer,
      $$MediaTableCreateCompanionBuilder,
      $$MediaTableUpdateCompanionBuilder,
      (MediaData, BaseReferences<_$AppDatabase, $MediaTable, MediaData>),
      MediaData,
      PrefetchHooks Function()
    >;
typedef $$SyncTombstonesTableCreateCompanionBuilder =
    SyncTombstonesCompanion Function({
      required String globalId,
      required String deletedHlc,
      required int entityType,
      Value<int> rowid,
    });
typedef $$SyncTombstonesTableUpdateCompanionBuilder =
    SyncTombstonesCompanion Function({
      Value<String> globalId,
      Value<String> deletedHlc,
      Value<int> entityType,
      Value<int> rowid,
    });

class $$SyncTombstonesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncTombstonesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get globalId => $composableBuilder(
    column: $table.globalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncTombstonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncTombstonesTable> {
  $$SyncTombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get globalId =>
      $composableBuilder(column: $table.globalId, builder: (column) => column);

  GeneratedColumn<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );
}

class $$SyncTombstonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncTombstonesTable,
          SyncTombstone,
          $$SyncTombstonesTableFilterComposer,
          $$SyncTombstonesTableOrderingComposer,
          $$SyncTombstonesTableAnnotationComposer,
          $$SyncTombstonesTableCreateCompanionBuilder,
          $$SyncTombstonesTableUpdateCompanionBuilder,
          (
            SyncTombstone,
            BaseReferences<_$AppDatabase, $SyncTombstonesTable, SyncTombstone>,
          ),
          SyncTombstone,
          PrefetchHooks Function()
        > {
  $$SyncTombstonesTableTableManager(
    _$AppDatabase db,
    $SyncTombstonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncTombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncTombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncTombstonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> globalId = const Value.absent(),
                Value<String> deletedHlc = const Value.absent(),
                Value<int> entityType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncTombstonesCompanion(
                globalId: globalId,
                deletedHlc: deletedHlc,
                entityType: entityType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String globalId,
                required String deletedHlc,
                required int entityType,
                Value<int> rowid = const Value.absent(),
              }) => SyncTombstonesCompanion.insert(
                globalId: globalId,
                deletedHlc: deletedHlc,
                entityType: entityType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncTombstonesTable, SyncTombstone>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncTombstonesTable,
                    SyncTombstone
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncTombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncTombstonesTable,
      SyncTombstone,
      $$SyncTombstonesTableFilterComposer,
      $$SyncTombstonesTableOrderingComposer,
      $$SyncTombstonesTableAnnotationComposer,
      $$SyncTombstonesTableCreateCompanionBuilder,
      $$SyncTombstonesTableUpdateCompanionBuilder,
      (
        SyncTombstone,
        BaseReferences<_$AppDatabase, $SyncTombstonesTable, SyncTombstone>,
      ),
      SyncTombstone,
      PrefetchHooks Function()
    >;
typedef $$SyncPeerCursorsTableCreateCompanionBuilder =
    SyncPeerCursorsCompanion Function({
      required String peerId,
      Value<int> gen,
      Value<int> byteOffset,
      required DateTime lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SyncPeerCursorsTableUpdateCompanionBuilder =
    SyncPeerCursorsCompanion Function({
      Value<String> peerId,
      Value<int> gen,
      Value<int> byteOffset,
      Value<DateTime> lastSyncedAt,
      Value<int> rowid,
    });

class $$SyncPeerCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncPeerCursorsTable> {
  $$SyncPeerCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerId => $composableBuilder(
    column: $table.peerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gen => $composableBuilder(
    column: $table.gen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteOffset => $composableBuilder(
    column: $table.byteOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncPeerCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncPeerCursorsTable> {
  $$SyncPeerCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerId => $composableBuilder(
    column: $table.peerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gen => $composableBuilder(
    column: $table.gen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteOffset => $composableBuilder(
    column: $table.byteOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncPeerCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncPeerCursorsTable> {
  $$SyncPeerCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerId =>
      $composableBuilder(column: $table.peerId, builder: (column) => column);

  GeneratedColumn<int> get gen =>
      $composableBuilder(column: $table.gen, builder: (column) => column);

  GeneratedColumn<int> get byteOffset => $composableBuilder(
    column: $table.byteOffset,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncPeerCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncPeerCursorsTable,
          SyncPeerCursor,
          $$SyncPeerCursorsTableFilterComposer,
          $$SyncPeerCursorsTableOrderingComposer,
          $$SyncPeerCursorsTableAnnotationComposer,
          $$SyncPeerCursorsTableCreateCompanionBuilder,
          $$SyncPeerCursorsTableUpdateCompanionBuilder,
          (
            SyncPeerCursor,
            BaseReferences<
              _$AppDatabase,
              $SyncPeerCursorsTable,
              SyncPeerCursor
            >,
          ),
          SyncPeerCursor,
          PrefetchHooks Function()
        > {
  $$SyncPeerCursorsTableTableManager(
    _$AppDatabase db,
    $SyncPeerCursorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPeerCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPeerCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPeerCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> peerId = const Value.absent(),
                Value<int> gen = const Value.absent(),
                Value<int> byteOffset = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPeerCursorsCompanion(
                peerId: peerId,
                gen: gen,
                byteOffset: byteOffset,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String peerId,
                Value<int> gen = const Value.absent(),
                Value<int> byteOffset = const Value.absent(),
                required DateTime lastSyncedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncPeerCursorsCompanion.insert(
                peerId: peerId,
                gen: gen,
                byteOffset: byteOffset,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncPeerCursorsTable, SyncPeerCursor>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncPeerCursorsTable,
                    SyncPeerCursor
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncPeerCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncPeerCursorsTable,
      SyncPeerCursor,
      $$SyncPeerCursorsTableFilterComposer,
      $$SyncPeerCursorsTableOrderingComposer,
      $$SyncPeerCursorsTableAnnotationComposer,
      $$SyncPeerCursorsTableCreateCompanionBuilder,
      $$SyncPeerCursorsTableUpdateCompanionBuilder,
      (
        SyncPeerCursor,
        BaseReferences<_$AppDatabase, $SyncPeerCursorsTable, SyncPeerCursor>,
      ),
      SyncPeerCursor,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db, _db.reviewLogs);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$CardTagsTableTableManager get cardTags =>
      $$CardTagsTableTableManager(_db, _db.cardTags);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db, _db.media);
  $$SyncTombstonesTableTableManager get syncTombstones =>
      $$SyncTombstonesTableTableManager(_db, _db.syncTombstones);
  $$SyncPeerCursorsTableTableManager get syncPeerCursors =>
      $$SyncPeerCursorsTableTableManager(_db, _db.syncPeerCursors);
}
