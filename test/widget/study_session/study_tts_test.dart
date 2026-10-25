import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/media/data/services/tts_service.dart';
import 'package:repetita/src/features/study_session/presentation/study_screen.dart';

import '../../unit/media/tts_service_test.dart';

void main() {
  late AppDatabase db;
  late int testDeckId;
  late FakeTtsEngine fakeEngine;
  late TtsService ttsService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'TTS Test Deck');
    fakeEngine = FakeTtsEngine();
    ttsService = TtsService(engine: fakeEngine);
  });

  tearDown(() async {
    ttsService.dispose();
    await db.close();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        ttsServiceProvider.overrideWithValue(ttsService),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: StudyScreen(deckId: testDeckId),
      ),
    );
  }

  group('StudyScreen Offline TTS Integration Tests', () {
    testWidgets('study_tts_button is present and speaks front text on tap', (
      tester,
    ) async {
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'What is photosynthesis?',
        back: 'Process of plants converting light to energy',
      );

      await tester.pumpWidget(buildSubject());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final ttsButton = find.byKey(const Key('study_tts_button'));
      expect(ttsButton, findsOneWidget);

      await tester.tap(ttsButton);
      await tester.pumpAndSettle();

      expect(fakeEngine.lastSpoken, equals('What is photosynthesis?'));
    });

    testWidgets('study_tts_button speaks back text when answer is revealed', (
      tester,
    ) async {
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Capital of Italy?',
        back: 'Rome is the capital',
      );

      await tester.pumpWidget(buildSubject());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Reveal answer
      await tester.tap(find.byKey(const Key('show_answer_button')));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final ttsButton = find.byKey(const Key('study_tts_button'));
      await tester.tap(ttsButton);
      await tester.pumpAndSettle();

      expect(fakeEngine.lastSpoken, equals('Rome is the capital'));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('hotkey T triggers speech for card content', (tester) async {
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Desktop shortcut card',
        back: 'Triggered with key T',
      );

      await tester.pumpWidget(buildSubject());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.pumpAndSettle();

      expect(fakeEngine.lastSpoken, equals('Desktop shortcut card'));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
