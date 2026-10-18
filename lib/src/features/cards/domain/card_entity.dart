import '../../../core/algorithms/cloze/cloze_parser.dart';
import '../../../core/algorithms/fsrs/models/fsrs_card.dart';
import '../../../core/algorithms/fsrs/models/fsrs_models.dart';

class CardEntity {
  const CardEntity({
    required this.id,
    required this.deckId,
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
    this.isSuspended = false,
    this.buriedUntil,
    this.clozeIndex,
    this.easinessFactor = 2.5,
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

  bool get isCloze => ClozeParser.isCloze(front);

  int get activeClozeIndex =>
      clozeIndex ?? (ClozeParser.extractClozeIndices(front).firstOrNull ?? 1);

  bool isBuried(DateTime now) {
    if (buriedUntil == null) return false;
    return buriedUntil!.isAfter(now.toUtc());
  }

  bool isDue(DateTime now) {
    if (isSuspended || isBuried(now)) return false;
    return state == 0 || !due.isAfter(now.toUtc());
  }

  FsrsCard toFsrsCard() => FsrsCard(
    state: CardState.values.firstWhere(
      (s) => s.value == state,
      orElse: () => CardState.newCard,
    ),
    stability: stability,
    difficulty: difficulty,
    due: due,
    lastReview: lastReview,
    reps: reps,
    lapses: lapses,
    easinessFactor: easinessFactor,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deckId == other.deckId &&
          front == other.front &&
          back == other.back &&
          state == other.state &&
          stability == other.stability &&
          difficulty == other.difficulty &&
          due == other.due &&
          lastReview == other.lastReview &&
          reps == other.reps &&
          lapses == other.lapses &&
          createdAt == other.createdAt &&
          isSuspended == other.isSuspended &&
          buriedUntil == other.buriedUntil &&
          clozeIndex == other.clozeIndex &&
          easinessFactor == other.easinessFactor &&
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
  );
}
