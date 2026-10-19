import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_models.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/utils/clock_provider.dart';
import 'package:repetita/src/features/settings/presentation/controllers/auto_bury_siblings_controller.dart';
import 'package:repetita/src/features/study_session/domain/models/custom_study_config.dart';
import 'package:repetita/src/features/study_session/presentation/controllers/study_session_controller.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'Controller Deck');

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        studySessionDaoProvider.overrideWithValue(db.studySessionDao),
        clockProvider.overrideWithValue(
          () => DateTime.utc(2026, 10, 18, 10, 0),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('StudySessionController - Custom Study & Cram Mode Tests', () {
    test(
      'Cram mode loads all cards and does not write to database on rating',
      () async {
        final card1Id = await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Front 1',
          back: 'Back 1',
        );
        final card2Id = await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Front 2',
          back: 'Back 2',
        );

        const config = CustomStudyConfig(
          scope: CustomStudyScope.allCards,
          isCram: true,
        );

        final provider = studySessionControllerProvider(testDeckId, config);
        final state = await container.read(provider.future);

        expect(state.isCram, isTrue);
        expect(state.totalCards, equals(2));
        expect(state.currentIndex, equals(0));
        expect(state.currentCard?.id, equals(card1Id));

        // Submit Rating.good in Cram Mode
        await container.read(provider.notifier).submitRating(Rating.good);

        final stateAfterRating = container.read(provider).value!;
        expect(stateAfterRating.currentIndex, equals(1));
        expect(stateAfterRating.currentCard?.id, equals(card2Id));
        expect(stateAfterRating.undoStack.last.reviewLogId, isNull);

        // Verify DB remains untouched (0 review logs)
        final logs = await db.select(db.reviewLogs).get();
        expect(logs, isEmpty);

        // Verify card in DB has not changed state (still state 0)
        final cardInDb = await (db.select(
          db.cards,
        )..where((t) => t.id.equals(card1Id))).getSingle();
        expect(cardInDb.state, equals(0));
        expect(cardInDb.reps, equals(0));
      },
    );

    test('Cram mode requeues card on Rating.again', () async {
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Question A',
        back: 'Answer A',
      );

      const config = CustomStudyConfig(
        scope: CustomStudyScope.allCards,
        isCram: true,
      );

      final provider = studySessionControllerProvider(testDeckId, config);
      await container.read(provider.future);

      // Submit Rating.again in Cram Mode
      await container.read(provider.notifier).submitRating(Rating.again);

      final state = container.read(provider).value!;
      // Total cards in queue should now be 2 because the failed card was re-appended
      expect(state.queue, hasLength(2));
      expect(state.isCompleted, isFalse);
      expect(state.currentIndex, equals(1));
    });

    test('Cram mode undo reverts index in-memory', () async {
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Question 1',
        back: 'Answer 1',
      );
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Question 2',
        back: 'Answer 2',
      );

      const config = CustomStudyConfig(
        scope: CustomStudyScope.allCards,
        isCram: true,
      );

      final provider = studySessionControllerProvider(testDeckId, config);
      await container.read(provider.future);

      await container.read(provider.notifier).submitRating(Rating.good);
      expect(container.read(provider).value!.currentIndex, equals(1));
      expect(container.read(provider).value!.canUndo, isTrue);

      await container.read(provider.notifier).undoReview();
      expect(container.read(provider).value!.currentIndex, equals(0));
    });

    test(
      'Advance review (isCram: false) updates FSRS and persists ReviewLog',
      () async {
        final cardId = await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Advance Prompt',
          back: 'Advance Answer',
        );

        const config = CustomStudyConfig(
          scope: CustomStudyScope.allCards,
          isCram: false,
        );

        final provider = studySessionControllerProvider(testDeckId, config);
        await container.read(provider.future);

        await container.read(provider.notifier).submitRating(Rating.good);

        // Verify review log was created
        final logs = await db.select(db.reviewLogs).get();
        expect(logs, hasLength(1));
        expect(logs.first.cardId, equals(cardId));
        expect(logs.first.rating, equals(Rating.good.value));

        // Verify card was transitioned to review state (state 2)
        final cardInDb = await (db.select(
          db.cards,
        )..where((t) => t.id.equals(cardId))).getSingle();
        expect(cardInDb.state, equals(2));
        expect(cardInDb.reps, equals(1));
      },
    );

    test(
      'Multi-step undo stack restores previous states sequentially',
      () async {
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Card 1',
          back: 'Ans 1',
        );
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Card 2',
          back: 'Ans 2',
        );

        const config = CustomStudyConfig(
          scope: CustomStudyScope.allCards,
          isCram: false,
        );

        final provider = studySessionControllerProvider(testDeckId, config);
        await container.read(provider.future);

        final notifier = container.read(provider.notifier);

        // Review card 1
        await notifier.submitRating(Rating.good);
        expect(container.read(provider).value!.currentIndex, equals(1));
        expect(container.read(provider).value!.undoStack, hasLength(1));

        // Review card 2
        await notifier.submitRating(Rating.easy);
        expect(container.read(provider).value!.currentIndex, equals(2));
        expect(container.read(provider).value!.isCompleted, isTrue);
        expect(container.read(provider).value!.undoStack, hasLength(2));

        // First undo: back to card 2
        await notifier.undoReview();
        expect(container.read(provider).value!.currentIndex, equals(1));
        expect(container.read(provider).value!.isCompleted, isFalse);
        expect(container.read(provider).value!.canUndo, isTrue);

        // Second undo: back to card 1
        await notifier.undoReview();
        expect(container.read(provider).value!.currentIndex, equals(0));
        expect(container.read(provider).value!.canUndo, isFalse);
      },
    );

    test('reviewAhead scope with recordReviews: false advances queue without writing to DB', () async {
      final cardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Ahead Prompt',
        back: 'Ahead Answer',
      );

      const config = CustomStudyConfig(
        scope: CustomStudyScope.reviewAhead,
        daysAhead: 3,
        isCram: true,
        recordReviews: false,
      );

      final provider = studySessionControllerProvider(testDeckId, config);
      await container.read(provider.future);

      final state = container.read(provider).value!;
      expect(state.recordReviews, isFalse);
      expect(state.intervalPreviews[Rating.again], equals('Re-queue'));
      expect(state.intervalPreviews[Rating.good], equals('Pass'));

      await container.read(provider.notifier).submitRating(Rating.good);

      // Verify no ReviewLogs created
      final logs = await db.select(db.reviewLogs).get();
      expect(logs, isEmpty);

      // Verify card FSRS state unchanged (still state 0)
      final cardInDb = await (db.select(
        db.cards,
      )..where((t) => t.id.equals(cardId))).getSingle();
      expect(cardInDb.state, equals(0));
      expect(cardInDb.reps, equals(0));

      // In-memory queue completed
      final finalState = container.read(provider).value!;
      expect(finalState.isCompleted, isTrue);
      expect(finalState.reviewedCount, equals(1));
    });

    test('reviewAhead scope with recordReviews: true calculates FSRS intervals and writes ReviewLog', () async {
      final cardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Ahead Early Prompt',
        back: 'Ahead Early Answer',
      );

      const config = CustomStudyConfig(
        scope: CustomStudyScope.reviewAhead,
        daysAhead: 3,
        isCram: false,
        recordReviews: true,
      );

      final provider = studySessionControllerProvider(testDeckId, config);
      await container.read(provider.future);

      final state = container.read(provider).value!;
      expect(state.recordReviews, isTrue);
      expect(state.intervalPreviews[Rating.again], equals('10m'));

      await container.read(provider.notifier).submitRating(Rating.good);

      // Verify ReviewLog created
      final logs = await db.select(db.reviewLogs).get();
      expect(logs, hasLength(1));
      expect(logs.first.cardId, equals(cardId));
      expect(logs.first.rating, equals(Rating.good.value));

      // Verify card transitioned to review state (state 2)
      final cardInDb = await (db.select(
        db.cards,
      )..where((t) => t.id.equals(cardId))).getSingle();
      expect(cardInDb.state, equals(2));
      expect(cardInDb.reps, equals(1));
    });

    test('submitRating with sibling cards buries sibling until tomorrow and removes sibling from remaining queue', () async {
      final now = DateTime.utc(2026, 10, 18, 10, 0);
      final cardIds = await db.cardsDao.createReversedCards(
        deckId: testDeckId,
        front: 'Capital of Italy',
        back: 'Rome',
        now: now,
      );

      const config = CustomStudyConfig(
        scope: CustomStudyScope.allCards,
        isCram: false,
        recordReviews: true,
      );

      final provider = studySessionControllerProvider(testDeckId, config);
      await container.read(provider.future);

      final initialState = container.read(provider).value!;
      expect(initialState.totalCards, equals(2));

      // Review card 1
      await container.read(provider.notifier).submitRating(Rating.good);

      // Verify sibling card in DB is buried until tomorrow
      final siblingInDb = await db.cardsDao.getCardById(cardIds[1]);
      expect(siblingInDb!.buriedUntil, isNotNull);
      expect(
        siblingInDb.buriedUntil!.toUtc(),
        equals(DateTime.utc(2026, 10, 19, 0, 0)),
      );

      // In-memory queue should have removed the sibling and marked session completed
      final stateAfterRating = container.read(provider).value!;
      expect(stateAfterRating.isCompleted, isTrue);
    });

    test(
      'submitRating does not bury siblings when auto_bury_siblings is false',
      () async {
        await container
            .read(autoBurySiblingsControllerProvider.notifier)
            .setValue(false);

        final now = DateTime.utc(2026, 10, 18, 10, 0);
        final cardIds = await db.cardsDao.createReversedCards(
          deckId: testDeckId,
          front: 'Dog',
          back: 'Cane',
          now: now,
        );

        const config = CustomStudyConfig(
          scope: CustomStudyScope.allCards,
          isCram: false,
          recordReviews: true,
        );

        final provider = studySessionControllerProvider(testDeckId, config);
        await container.read(provider.future);

        final initialState = container.read(provider).value!;
        expect(initialState.totalCards, equals(2));

        // Review card 1
        await container.read(provider.notifier).submitRating(Rating.good);

        // Sibling should NOT be buried
        final siblingInDb = await db.cardsDao.getCardById(cardIds[1]);
        expect(siblingInDb!.buriedUntil, isNull);

        // Remaining queue still contains sibling
        final stateAfterRating = container.read(provider).value!;
        expect(stateAfterRating.isCompleted, isFalse);
        expect(stateAfterRating.currentCard?.id, equals(cardIds[1]));
      },
    );
  });
}
