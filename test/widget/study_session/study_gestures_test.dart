import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/study_session/domain/study_gesture_config.dart';
import 'package:repetita/src/features/study_session/presentation/controllers/study_gesture_controller.dart';
import 'package:repetita/src/features/study_session/presentation/dialogs/study_gestures_dialog.dart';
import 'package:repetita/src/features/study_session/presentation/study_screen.dart';

void main() {
  late AppDatabase db;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'Gesture Test Deck');
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject({ProviderContainer? container}) {
    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: StudyScreen(deckId: testDeckId)),
      );
    }
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: StudyScreen(deckId: testDeckId)),
    );
  }

  Future<void> pumpFrames(WidgetTester tester, [int count = 10]) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('Study Gestures Widget Tests', () {
    testWidgets('double tap on card reveals answer', (tester) async {
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Front Gesture Q',
        back: 'Back Gesture A',
      );

      await tester.pumpWidget(buildSubject());
      await pumpFrames(tester);

      expect(find.byKey(const Key('card_front_text')), findsOneWidget);
      expect(find.byKey(const Key('card_back_text')), findsNothing);

      // Double tap card
      final detector = find.byKey(const Key('study_gesture_detector'));
      expect(detector, findsOneWidget);

      await tester.tap(detector);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(detector);
      await pumpFrames(tester);

      // Answer should now be revealed
      expect(find.byKey(const Key('card_back_text')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('swipe right on revealed card submits Good rating', (
      tester,
    ) async {
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Front Q1',
        back: 'Back A1',
      );
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Front Q2',
        back: 'Back A2',
      );

      await tester.pumpWidget(buildSubject());
      await pumpFrames(tester);

      // Reveal answer via button
      await tester.tap(find.byKey(const Key('show_answer_button')));
      await pumpFrames(tester);
      expect(find.byKey(const Key('card_back_text')), findsOneWidget);

      // Fling right (positive vx)
      final detector = find.byKey(const Key('study_gesture_detector'));
      await tester.fling(detector, const Offset(300, 0), 1000);
      await pumpFrames(tester);

      // Card 1 rated, now on Card 2
      expect(find.text('Front Q2'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'disabling gestures disables detector and swipe has no effect',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Front No Gesture',
          back: 'Back No Gesture',
        );

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            studyGestureControllerProvider.overrideWith(
              () => _DisabledGestureController(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildSubject(container: container));
        await pumpFrames(tester);

        // study_gesture_detector should not be in widget tree
        expect(find.byKey(const Key('study_gesture_detector')), findsNothing);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'StudyGesturesDialog allows toggling and setting custom gestures',
      (tester) async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(body: StudyGesturesDialog()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gesti Touch Studio'), findsOneWidget);
        expect(find.text('Abilita gesti touch'), findsOneWidget);
        expect(find.text('Swipe Sinistra'), findsOneWidget);

        // Toggle switch
        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();

        expect(
          container.read(studyGestureControllerProvider).enableGestures,
          isFalse,
        );

        // Reset to defaults
        await tester.tap(find.text('Predefiniti'));
        await tester.pumpAndSettle();

        expect(
          container.read(studyGestureControllerProvider).enableGestures,
          isTrue,
        );
      },
    );
  });
}

class _DisabledGestureController extends StudyGestureController {
  @override
  StudyGestureConfig build() => const StudyGestureConfig(enableGestures: false);
}
