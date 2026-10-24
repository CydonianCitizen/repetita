import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/cards/presentation/card_editor_screen.dart';
import 'package:repetita/src/features/cards/presentation/widgets/card_content_renderer.dart';

void main() {
  late AppDatabase db;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'Test Deck');
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject({
    int? cardId,
    String? initialFront,
    String? initialBack,
  }) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const Key('open_editor_button'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CardEditorScreen(
                        deckId: testDeckId,
                        cardId: cardId,
                        initialFront: initialFront,
                        initialBack: initialBack,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('CardEditorScreen Widget Tests', () {
    testWidgets('displays validation error when front or back is empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_editor_button')));
      await tester.pumpAndSettle();

      expect(find.text('New Card'), findsOneWidget);

      // Tap Save without entering any text
      await tester.tap(find.byKey(const Key('save_card_button')));
      await tester.pumpAndSettle();

      expect(find.text('Front prompt cannot be empty'), findsOneWidget);

      // Enter front only and submit
      await tester.enterText(
        find.byKey(const Key('card_front_field')),
        'Valid Front',
      );
      await tester.tap(find.byKey(const Key('save_card_button')));
      await tester.pumpAndSettle();

      expect(find.text('Front prompt cannot be empty'), findsNothing);
      expect(find.text('Back answer cannot be empty'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('submitting valid content creates card in database', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_editor_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('card_front_field')),
        'What is Mitochondria?',
      );
      await tester.enterText(
        find.byKey(const Key('card_back_field')),
        'Powerhouse of the cell',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_card_button')));
      // Bounded frame pumping to let async save finish without waiting on infinite spinners
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final cards = await db.cardsDao.getCardsByDeck(testDeckId);
      expect(cards, hasLength(1));
      expect(cards.first.front, equals('What is Mitochondria?'));
      expect(cards.first.back, equals('Powerhouse of the cell'));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('editing existing card updates content in database', (
      tester,
    ) async {
      final cardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Old Front',
        back: 'Old Back',
      );

      await tester.pumpWidget(
        buildSubject(
          cardId: cardId,
          initialFront: 'Old Front',
          initialBack: 'Old Back',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_editor_button')));
      await tester.pumpAndSettle();

      expect(find.text('Edit Card'), findsOneWidget);
      expect(find.text('Old Front'), findsOneWidget);
      expect(find.text('Old Back'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('card_front_field')),
        'New Front',
      );
      await tester.enterText(
        find.byKey(const Key('card_back_field')),
        'New Back',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_card_button')));
      // Bounded frame pumping to let async save finish without waiting on infinite spinners
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final cards = await db.cardsDao.getCardsByDeck(testDeckId);
      expect(cards, hasLength(1));
      expect(cards.first.front, equals('New Front'));
      expect(cards.first.back, equals('New Back'));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'toggling reverse card switch creates forward and reverse card pair',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('open_editor_button')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('card_front_field')),
          'Front Question',
        );
        await tester.enterText(
          find.byKey(const Key('card_back_field')),
          'Back Answer',
        );

        // Scroll to reveal switch if needed
        await tester.scrollUntilVisible(
          find.byKey(const Key('reverse_card_switch')),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byKey(const Key('reverse_card_switch')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_card_button')));
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        final cards = await db.cardsDao.getCardsByDeck(testDeckId);
        expect(cards, hasLength(2));
        expect(cards[0].noteId, isNotNull);
        expect(cards[1].noteId, equals(cards[0].noteId));
        expect(
          cards.any(
            (c) => c.front == 'Front Question' && c.back == 'Back Answer',
          ),
          isTrue,
        );
        expect(
          cards.any(
            (c) => c.front == 'Back Answer' && c.back == 'Front Question',
          ),
          isTrue,
        );

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('creating multiple cloze cards assigns shared noteId', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_editor_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('card_front_field')),
        '{{c1::Rome}} is the capital of {{c2::Italy}}',
      );
      await tester.enterText(
        find.byKey(const Key('card_back_field')),
        'Geography notes',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_card_button')));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      final cards = await db.cardsDao.getCardsByDeck(testDeckId);
      expect(cards, hasLength(2));
      expect(cards[0].noteId, isNotNull);
      expect(cards[1].noteId, equals(cards[0].noteId));
      expect(cards.map((c) => c.clozeIndex).toSet(), equals({1, 2}));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('tapping preview button shows rendered card preview dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          initialFront: r'Formula $E=mc^2$',
          initialBack: '**Energy** is mass times speed of light squared',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_editor_button')));
      await tester.pumpAndSettle();

      final previewBtn = find.byKey(const Key('preview_card_button'));
      expect(previewBtn, findsOneWidget);
      await tester.tap(previewBtn);
      await tester.pumpAndSettle();

      expect(find.text('Anteprima Carta'), findsOneWidget);
      expect(find.byType(CardContentRenderer), findsNWidgets(2));
      await tester.tap(find.text('Chiudi'));
      await tester.pumpAndSettle();
    });
  });
}
