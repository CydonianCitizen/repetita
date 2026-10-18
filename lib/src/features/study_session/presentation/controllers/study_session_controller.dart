import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/clock_provider.dart';

import '../../../../core/algorithms/fsrs/models/fsrs_models.dart';
import '../../../../core/database/app_database.dart' show Card;
import '../../../../core/database/database_provider.dart';
import '../../../cards/data/cards_dao.dart';
import '../../../cards/domain/card_entity.dart';
import '../../../settings/presentation/controllers/fsrs_parameters_controller.dart';
import '../../../stats/presentation/controllers/stats_controller.dart';
import '../../domain/models/custom_study_config.dart';
import 'srs_scheduler_provider.dart';

part 'study_session_controller.g.dart';

class StudySessionHistoryEntry {
  const StudySessionHistoryEntry({
    required this.card,
    required this.index,
    this.rating,
    this.reviewLogId,
    this.requeued = false,
  });

  final CardEntity card;
  final int index;
  final Rating? rating;
  final int? reviewLogId;
  final bool requeued;
}

class StudySessionState {
  const StudySessionState({
    required this.deckId,
    this.queue = const [],
    this.currentIndex = 0,
    this.isAnswerRevealed = false,
    this.isCompleted = false,
    this.undoStack = const [],
    this.isCram = false,
    this.recordReviews = true,
    this.customStudyConfig,
    this.intervalPreviews = const {},
    this.lastLeechDetected = false,
  });

  final int deckId;
  final List<CardEntity> queue;
  final int currentIndex;
  final bool isAnswerRevealed;
  final bool isCompleted;
  final List<StudySessionHistoryEntry> undoStack;
  final bool isCram;
  final bool recordReviews;
  final CustomStudyConfig? customStudyConfig;
  final Map<Rating, String> intervalPreviews;
  final bool lastLeechDetected;

  bool get canUndo => undoStack.isNotEmpty;
  int get reviewedCount => undoStack.length;

  CardEntity? get currentCard {
    if (isCompleted || currentIndex >= queue.length) return null;
    return queue[currentIndex];
  }

  int get totalCards => queue.length;
  int get remainingCards => isCompleted ? 0 : queue.length - currentIndex;

  StudySessionState copyWith({
    int? deckId,
    List<CardEntity>? queue,
    int? currentIndex,
    bool? isAnswerRevealed,
    bool? isCompleted,
    List<StudySessionHistoryEntry>? undoStack,
    bool? isCram,
    bool? recordReviews,
    CustomStudyConfig? customStudyConfig,
    Map<Rating, String>? intervalPreviews,
    bool? lastLeechDetected,
  }) {
    return StudySessionState(
      deckId: deckId ?? this.deckId,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      isCompleted: isCompleted ?? this.isCompleted,
      undoStack: undoStack ?? this.undoStack,
      isCram: isCram ?? this.isCram,
      recordReviews: recordReviews ?? this.recordReviews,
      customStudyConfig: customStudyConfig ?? this.customStudyConfig,
      intervalPreviews: intervalPreviews ?? this.intervalPreviews,
      lastLeechDetected: lastLeechDetected ?? this.lastLeechDetected,
    );
  }
}

@riverpod
class StudySessionController extends _$StudySessionController {
  @override
  FutureOr<StudySessionState> build(
    int deckId, [
    CustomStudyConfig? customStudyConfig,
  ]) async {
    await ref.read(fsrsParametersControllerProvider.notifier).ensureLoaded();
    final dao = ref.watch(studySessionDaoProvider);
    final now = ref.read(clockProvider)();
    final List<Card> cards;

    if (customStudyConfig != null) {
      cards = await dao.fetchCustomStudyCards(
        deckId: deckId,
        now: now,
        scope: customStudyConfig.scope,
        tagId: customStudyConfig.tagId,
        daysAhead: customStudyConfig.daysAhead,
      );
    } else {
      cards = await dao.fetchDueCards(deckId, cutoff: now);
    }

    final cardEntities = cards.map((c) => c.toEntity()).toList();
    final isCram = customStudyConfig?.isCram ?? false;
    final recordReviews = customStudyConfig?.recordReviews ?? true;
    final firstCard = cardEntities.isNotEmpty ? cardEntities.first : null;

    return StudySessionState(
      deckId: deckId,
      queue: cardEntities,
      currentIndex: 0,
      isAnswerRevealed: false,
      isCompleted: cardEntities.isEmpty,
      isCram: isCram,
      recordReviews: recordReviews,
      customStudyConfig: customStudyConfig,
      intervalPreviews: _calculateIntervalPreviews(firstCard, !recordReviews),
    );
  }

  void revealAnswer() {
    final current = state.value;
    if (current == null || current.isCompleted) return;
    state = AsyncData(current.copyWith(isAnswerRevealed: true));
  }

  bool _isSubmitting = false;

  Future<void> submitRating(Rating rating) async {
    if (_isSubmitting) return;
    final current = state.value;
    if (current == null || current.currentCard == null) return;
    _isSubmitting = true;

    final currentCard = current.currentCard!;
    final now = ref.read(clockProvider)();

    try {
      if (!current.recordReviews) {
        final updatedQueue = List<CardEntity>.from(current.queue);
        final isRequeued = rating == Rating.again;
        if (isRequeued) {
          updatedQueue.add(currentCard);
        }
        final nextIndex = current.currentIndex + 1;
        final isCompleted = nextIndex >= updatedQueue.length;
        final nextCard = !isCompleted && nextIndex < updatedQueue.length
            ? updatedQueue[nextIndex]
            : null;

        final undoEntry = StudySessionHistoryEntry(
          card: currentCard,
          index: current.currentIndex,
          rating: rating,
          requeued: isRequeued,
        );

        state = AsyncData(
          current.copyWith(
            queue: updatedQueue,
            currentIndex: nextIndex,
            isAnswerRevealed: false,
            isCompleted: isCompleted,
            undoStack: [...current.undoStack, undoEntry],
            intervalPreviews: _calculateIntervalPreviews(nextCard, true),
          ),
        );
        return;
      }

      final fsrsCard = currentCard.toFsrsCard();
      final scheduler = ref.read(srsSchedulerProvider);
      final recordLog = scheduler.schedule(fsrsCard, rating, now);

      final dao = ref.read(studySessionDaoProvider);
      final reviewLogId = await dao.recordReview(
        cardId: currentCard.id,
        updatedCard: recordLog.card,
        logSnapshot: recordLog.log,
      );

      bool isLeech = false;
      if (rating == Rating.again) {
        final db = ref.read(databaseProvider);
        final thresholdStr = await db.getSetting('leech_threshold');
        final threshold = int.tryParse(thresholdStr ?? '') ?? 8;
        if (recordLog.card.lapses >= threshold) {
          isLeech = true;
          final tagsDao = ref.read(tagsDaoProvider);
          final tagId = await tagsDao.getOrCreateTag('leech');
          await tagsDao.addTagToCard(currentCard.id, tagId);

          final action = await db.getSetting('leech_action') ?? 'tag';
          if (action == 'tag_and_suspend') {
            await ref
                .read(cardsDaoProvider)
                .setCardSuspended(currentCard.id, true);
          }
        }
      }

      var queue = current.queue;
      if (currentCard.noteId != null) {
        final db = ref.read(databaseProvider);
        final autoBurySetting = await db.getSetting('auto_bury_siblings');
        final shouldBury = autoBurySetting == null || autoBurySetting == 'true';
        if (shouldBury) {
          await ref.read(cardsDaoProvider).burySiblingCards(
            noteId: currentCard.noteId!,
            excludeCardId: currentCard.id,
            now: now,
          );
          final prefix = queue.sublist(0, current.currentIndex + 1);
          final remaining = queue
              .sublist(current.currentIndex + 1)
              .where((c) => c.noteId != currentCard.noteId)
              .toList();
          queue = [...prefix, ...remaining];
        }
      }

      final nextIndex = current.currentIndex + 1;
      final isCompleted = nextIndex >= queue.length;
      final nextCard = !isCompleted && nextIndex < queue.length
          ? queue[nextIndex]
          : null;

      final undoEntry = StudySessionHistoryEntry(
        card: currentCard,
        index: current.currentIndex,
        rating: rating,
        reviewLogId: reviewLogId,
      );

      state = AsyncData(
        current.copyWith(
          queue: queue,
          currentIndex: nextIndex,
          isAnswerRevealed: false,
          isCompleted: isCompleted,
          undoStack: [...current.undoStack, undoEntry],
          intervalPreviews: _calculateIntervalPreviews(nextCard, false),
          lastLeechDetected: isLeech,
        ),
      );
      ref.invalidate(statsControllerProvider);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> undoReview() async {
    final current = state.value;
    if (current == null || !current.canUndo) return;

    try {
      final lastEntry = current.undoStack.last;
      final newUndoStack = List<StudySessionHistoryEntry>.from(
        current.undoStack,
      )..removeLast();

      if (current.recordReviews && lastEntry.reviewLogId != null) {
        final dao = ref.read(studySessionDaoProvider);
        await dao.undoReview(
          cardId: lastEntry.card.id,
          previousCard: lastEntry.card.toFsrsCard(),
          reviewLogId: lastEntry.reviewLogId!,
        );
      }

      final updatedQueue = List<CardEntity>.from(current.queue);
      if (lastEntry.requeued && updatedQueue.isNotEmpty) {
        updatedQueue.removeLast();
      }
      if (lastEntry.index < updatedQueue.length) {
        updatedQueue[lastEntry.index] = lastEntry.card;
      }

      final prevCard = updatedQueue[lastEntry.index];
      state = AsyncData(
        current.copyWith(
          queue: updatedQueue,
          currentIndex: lastEntry.index,
          isAnswerRevealed: false,
          isCompleted: false,
          undoStack: newUndoStack,
          intervalPreviews: _calculateIntervalPreviews(
            prevCard,
            !current.recordReviews,
          ),
        ),
      );
      if (current.recordReviews) {
        ref.invalidate(statsControllerProvider);
      }
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  void _advanceQueueWithoutCurrentCard(StudySessionState current) {
    final updatedQueue = List<CardEntity>.from(current.queue)
      ..removeAt(current.currentIndex);
    final isCompleted =
        updatedQueue.isEmpty || current.currentIndex >= updatedQueue.length;
    final nextCard = !isCompleted && current.currentIndex < updatedQueue.length
        ? updatedQueue[current.currentIndex]
        : null;

    state = AsyncData(
      current.copyWith(
        queue: updatedQueue,
        isAnswerRevealed: false,
        isCompleted: isCompleted,
        undoStack: const [],
        intervalPreviews: _calculateIntervalPreviews(
          nextCard,
          !current.recordReviews,
        ),
      ),
    );
  }

  Future<void> suspendCurrentCard() async {
    final current = state.value;
    if (current == null || current.currentCard == null) return;
    final card = current.currentCard!;

    try {
      await ref.read(cardsDaoProvider).setCardSuspended(card.id, true);
      _advanceQueueWithoutCurrentCard(current);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> buryCurrentCard() async {
    final current = state.value;
    if (current == null || current.currentCard == null) return;
    final card = current.currentCard!;

    try {
      await ref.read(cardsDaoProvider).buryCardUntilTomorrow(card.id);
      _advanceQueueWithoutCurrentCard(current);
    } catch (e) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Map<Rating, String> _calculateIntervalPreviews(
    CardEntity? card,
    bool isNonRecording,
  ) {
    if (card == null) return const {};

    if (isNonRecording) {
      return const {
        Rating.again: 'Re-queue',
        Rating.hard: 'Pass',
        Rating.good: 'Pass',
        Rating.easy: 'Pass',
      };
    }

    final now = ref.read(clockProvider)();
    final fsrsCard = card.toFsrsCard();
    final scheduler = ref.read(srsSchedulerProvider);
    final repeats = scheduler.repeat(fsrsCard, now);

    return repeats.map((rating, recordLog) {
      final days = recordLog.log.scheduledDays;
      final text = _formatInterval(rating, days);
      return MapEntry(rating, text);
    });
  }

  String _formatInterval(Rating rating, int days) {
    if (rating == Rating.again) {
      return '10m';
    }
    if (days < 30) {
      return '${days}d';
    } else if (days < 365) {
      final months = (days / 30).round();
      return '${months}mo';
    } else {
      final years = (days / 365).round();
      return '${years}y';
    }
  }
}
