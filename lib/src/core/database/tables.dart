import 'package:drift/drift.dart';

class Decks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get examDate => dateTime().nullable()();
  RealColumn get targetRetention => real().nullable()();
}

@TableIndex(name: 'idx_cards_deck_id', columns: {#deckId})
@TableIndex(name: 'idx_cards_due', columns: {#due})
@TableIndex(name: 'idx_cards_note_id', columns: {#noteId})
class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId =>
      integer().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get front => text()();
  TextColumn get back => text()();
  IntColumn get state => integer().withDefault(const Constant(0))();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  DateTimeColumn get due => dateTime()();
  DateTimeColumn get lastReview => dateTime().nullable()();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSuspended => boolean().withDefault(const Constant(false))();
  DateTimeColumn get buriedUntil => dateTime().nullable()();
  IntColumn get clozeIndex => integer().nullable()();
  RealColumn get easinessFactor => real().withDefault(const Constant(2.5))();
  IntColumn get flag => integer().withDefault(const Constant(0))();
  IntColumn get noteId => integer().nullable()();
}

@TableIndex(name: 'idx_review_logs_card_id', columns: {#cardId})
@TableIndex(name: 'idx_review_logs_reviewed_at', columns: {#reviewedAt})
class ReviewLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId =>
      integer().references(Cards, #id, onDelete: KeyAction.cascade)();
  IntColumn get rating => integer()();
  IntColumn get state => integer()();
  DateTimeColumn get due => dateTime()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  IntColumn get elapsedDays => integer()();
  IntColumn get lastElapsedDays => integer()();
  IntColumn get scheduledDays => integer()();
  DateTimeColumn get reviewedAt => dateTime()();
  RealColumn get easinessFactor => real().withDefault(const Constant(2.5))();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@TableIndex(name: 'idx_card_tags_tag_id', columns: {#tagId})
class CardTags extends Table {
  IntColumn get cardId =>
      integer().references(Cards, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {cardId, tagId};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
