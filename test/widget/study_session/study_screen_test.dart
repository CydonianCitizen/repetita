import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/study_session/domain/models/custom_study_config.dart';
import 'package:repetita/src/features/study_session/presentation/study_screen.dart';

void main() {
  late AppDatabase db;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'Study Test Deck');
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: StudyScreen(deckId: testDeckId)),
    );
  }

  group('StudyScreen Widget Tests', () {
    testWidgets('displays completion message when deck has no due cards', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('All cards reviewed for today!'), findsOneWidget);
      expect(find.byKey(const Key('back_to_deck_button')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'displays front only initially, reveals back on Show Answer, and shows rating buttons with intervals',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'What is photosynthesis?',
          back: 'Process by which plants convert light into chemical energy',
        );

        await tester.pumpWidget(buildSubject());
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify initial state
        expect(find.text('Card 1 of 1'), findsOneWidget);
        expect(find.text('What is photosynthesis?'), findsOneWidget);
        expect(
          find.text(
            'Process by which plants convert light into chemical energy',
          ),
          findsNothing,
        );
        expect(find.byKey(const Key('show_answer_button')), findsOneWidget);
        expect(find.byKey(const Key('rating_button_good')), findsNothing);

        // Tap Show Answer
        await tester.tap(find.byKey(const Key('show_answer_button')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Verify answer revealed and rating buttons present
        expect(
          find.text(
            'Process by which plants convert light into chemical energy',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('show_answer_button')), findsNothing);
        expect(find.byKey(const Key('rating_button_again')), findsOneWidget);
        expect(find.byKey(const Key('rating_button_hard')), findsOneWidget);
        expect(find.byKey(const Key('rating_button_good')), findsOneWidget);
        expect(find.byKey(const Key('rating_button_easy')), findsOneWidget);

        // Verify interval preview texts
        expect(find.text('10m'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'submitting ratings advances through multiple cards until session completion',
      (tester) async {
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

        await tester.pumpWidget(buildSubject());
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Card 1
        expect(find.text('Card 1 of 2'), findsOneWidget);
        expect(find.text('Question 1'), findsOneWidget);

        await tester.tap(find.byKey(const Key('show_answer_button')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Rate Good on Card 1
        await tester.tap(find.byKey(const Key('rating_button_good')));
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Now on Card 2
        expect(find.text('Card 2 of 2'), findsOneWidget);
        expect(find.text('Question 2'), findsOneWidget);
        expect(find.text('Answer 2'), findsNothing);
        expect(find.byKey(const Key('show_answer_button')), findsOneWidget);

        // Reveal Card 2 and Rate Easy
        await tester.tap(find.byKey(const Key('show_answer_button')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.tap(find.byKey(const Key('rating_button_easy')));
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // All cards finished
        expect(find.text('All cards reviewed for today!'), findsOneWidget);
        expect(find.byKey(const Key('back_to_deck_button')), findsOneWidget);

        // Verify ReviewLogs recorded 2 reviews
        final logs = await db.select(db.reviewLogs).get();
        expect(logs, hasLength(2));

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'tapping undo button rolls back previous rating and restores card',
      (tester) async {
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

        await tester.pumpWidget(buildSubject());
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Initially no undo button
        expect(find.byKey(const Key('undo_review_button')), findsNothing);

        // Rate Question 1 Good
        await tester.tap(find.byKey(const Key('show_answer_button')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.tap(find.byKey(const Key('rating_button_good')));
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Now on Question 2, undo button is present
        expect(find.text('Question 2'), findsOneWidget);
        expect(find.byKey(const Key('undo_review_button')), findsOneWidget);

        // Tap Undo
        await tester.tap(find.byKey(const Key('undo_review_button')));
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // We are back on Question 1!
        expect(find.text('Card 1 of 2'), findsOneWidget);
        expect(find.text('Question 1'), findsOneWidget);
        expect(find.byKey(const Key('show_answer_button')), findsOneWidget);

        // And undo button is gone (only 1 step undo)
        expect(find.byKey(const Key('undo_review_button')), findsNothing);

        // Verify reviewLogs has 0 records (was deleted by undo)
        final logs = await db.select(db.reviewLogs).get();
        expect(logs, isEmpty);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'suspending current card removes it from queue and updates database',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Question to Suspend',
          back: 'Answer',
        );

        await tester.pumpWidget(buildSubject());
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Question to Suspend'), findsOneWidget);
        expect(
          find.byKey(const Key('study_card_actions_menu')),
          findsOneWidget,
        );

        // Open options menu
        await tester.tap(find.byKey(const Key('study_card_actions_menu')));
        await tester.pumpAndSettle();

        // Tap Suspend
        await tester.tap(find.text('Suspend Card'));
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Queue now empty -> session completed
        expect(find.text('All cards reviewed for today!'), findsOneWidget);

        // Check card is suspended in DB
        final cards = await db.cardsDao.getCardsByDeck(testDeckId);
        expect(cards.first.isSuspended, isTrue);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'burying current card removes it from queue and sets buriedUntil',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Question to Bury',
          back: 'Answer',
        );

        await tester.pumpWidget(buildSubject());
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Question to Bury'), findsOneWidget);
        expect(
          find.byKey(const Key('study_card_actions_menu')),
          findsOneWidget,
        );

        // Open options menu
        await tester.tap(find.byKey(const Key('study_card_actions_menu')));
        await tester.pumpAndSettle();

        // Tap Bury
        await tester.tap(find.text('Bury Card'));
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Queue now empty -> session completed
        expect(find.text('All cards reviewed for today!'), findsOneWidget);

        // Check card is buried in DB
        final cards = await db.cardsDao.getCardsByDeck(testDeckId);
        expect(cards.first.buriedUntil, isNotNull);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'renders cram badge and session title when customStudyConfig is Cram',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Cram Card',
          back: 'Cram Answer',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: MaterialApp(
              home: StudyScreen(
                deckId: testDeckId,
                customStudyConfig: const CustomStudyConfig(
                  scope: CustomStudyScope.allCards,
                  isCram: true,
                ),
              ),
            ),
          ),
        );
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('CRAM'), findsOneWidget);
        expect(find.text('Cram Session'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'supports desktop keyboard shortcuts (Space to reveal, 1-4 to rate)',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Keyboard Question',
          back: 'Keyboard Answer',
        );

        await tester.pumpWidget(buildSubject());
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Keyboard Question'), findsOneWidget);
        expect(find.text('Keyboard Answer'), findsNothing);

        // 1. Press Space to reveal answer
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Keyboard Answer'), findsOneWidget);
        expect(find.byKey(const Key('rating_button_good')), findsOneWidget);

        // 2. Press digit 3 to select Good
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(
          find.byKey(const Key('session_completion_stats')),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'type-in practice reveals typed input diff when card is revealed',
      (tester) async {
        await db.setSetting('type_in_answer_enabled', 'true');
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Capital of France',
          back: 'Paris',
        );

        await tester.pumpWidget(buildSubject());
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byKey(const Key('type_in_answer_field')), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('type_in_answer_field')),
          'Paris',
        );
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tap(find.byKey(const Key('show_answer_button')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Paris'), findsWidgets);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('auto-advance timer automatically reveals answer after delay', (
      tester,
    ) async {
      await db.setSetting('study_auto_advance_seconds', '1');
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Auto Advance Front',
        back: 'Auto Advance Back',
      );

      await tester.pumpWidget(buildSubject());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Auto Advance Front'), findsOneWidget);
      expect(find.text('Auto Advance Back'), findsNothing);

      // Advance by 1 second to trigger auto advance timer
      await tester.pump(const Duration(seconds: 1));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Auto Advance Back'), findsOneWidget);
      expect(find.byKey(const Key('rating_button_good')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'auto-advance re-arms when single card is failed and repeated in cram mode',
      (tester) async {
        await db.setSetting('study_auto_advance_seconds', '1');
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Repeat Front',
          back: 'Repeat Back',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: MaterialApp(
              home: StudyScreen(
                deckId: testDeckId,
                customStudyConfig: const CustomStudyConfig(
                  scope: CustomStudyScope.allCards,
                  isCram: true,
                ),
              ),
            ),
          ),
        );
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Repeat Front'), findsOneWidget);
        expect(find.text('Repeat Back'), findsNothing);

        // 1st auto-advance
        await tester.pump(const Duration(seconds: 1));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.text('Repeat Back'), findsOneWidget);

        // Fail card (Again) -> requeues in cram mode
        await tester.tap(find.byKey(const Key('rating_button_again')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Card front is shown again (same card id)
        expect(find.text('Repeat Front'), findsOneWidget);
        expect(find.text('Repeat Back'), findsNothing);

        // 2nd auto-advance should re-arm and reveal answer!
        await tester.pump(const Duration(seconds: 1));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.text('Repeat Back'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
    testWidgets(
      'tapping whiteboard button in AppBar opens and closes whiteboard overlay',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Whiteboard Question',
          back: 'Whiteboard Answer',
        );

        await tester.pumpWidget(buildSubject());
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(
          find.byKey(const Key('study_whiteboard_button')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('whiteboard_container')), findsNothing);

        // Open whiteboard
        await tester.tap(find.byKey(const Key('study_whiteboard_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('whiteboard_container')), findsOneWidget);
        expect(
          find.byKey(const Key('whiteboard_clear_button')),
          findsOneWidget,
        );

        // Close whiteboard via AppBar button
        await tester.tap(find.byKey(const Key('study_whiteboard_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('whiteboard_container')), findsNothing);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
  });
}
