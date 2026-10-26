import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/cards/presentation/card_editor_screen.dart';
import 'package:repetita/src/features/cards/presentation/deck_detail_screen.dart';
import 'package:repetita/src/features/study_session/presentation/study_screen.dart';

void main() {
  late AppDatabase db;
  late Deck testDeck;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final deckId = await db.decksDao.createDeck(
      name: 'Biology 101',
      description: 'Introductory biology deck',
    );
    testDeck = Deck(
      id: deckId,
      name: 'Biology 101',
      description: 'Introductory biology deck',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      globalId: '',
      updatedHlc: '',
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DeckDetailScreen(deck: testDeck),
      ),
    );
  }

  group('DeckDetailScreen Widget Tests', () {
    testWidgets('renders empty state when deck has no cards', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Biology 101'), findsOneWidget);
      expect(find.text('0 cards due for review'), findsOneWidget);
      expect(
        find.text('No cards in this deck yet.\nTap + to add one.'),
        findsOneWidget,
      );
      expect(find.text('Cards (0)'), findsOneWidget);

      final buttonFinder = find.byKey(const Key('start_study_button'));
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('renders cards list and due count banner correctly', (
      tester,
    ) async {
      final now = DateTime.now().toUtc();
      await db.cardsDao.createCard(
        deckId: testDeck.id,
        front: 'What is DNA?',
        back: 'Deoxyribonucleic acid',
      );

      final futureDue = now.add(const Duration(days: 5));
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: testDeck.id,
              front: 'What is RNA?',
              back: 'Ribonucleic acid',
              state: const drift.Value(2), // Review
              due: futureDue,
            ),
          );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Only the New card (state 0) is due, since RNA is due in 5 days
      expect(find.text('1 cards due for review'), findsOneWidget);
      expect(find.text('Cards (2)'), findsOneWidget);

      expect(find.text('What is DNA?'), findsOneWidget);
      expect(find.text('Deoxyribonucleic acid'), findsOneWidget);
      expect(find.text('What is RNA?'), findsOneWidget);
      expect(find.text('Ribonucleic acid'), findsOneWidget);

      expect(find.text('New'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);

      final buttonFinder = find.byKey(const Key('start_study_button'));
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNotNull);

      await tester.tap(buttonFinder);
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(StudyScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('tapping FAB navigates to CardEditorScreen', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_card_fab')));
      await tester.pumpAndSettle();

      expect(find.byType(CardEditorScreen), findsOneWidget);
      expect(find.text('New Card'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('deleting card removes it from list and database', (
      tester,
    ) async {
      await db.cardsDao.createCard(
        deckId: testDeck.id,
        front: 'Card to Delete',
        back: 'Back to Delete',
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Card to Delete'), findsOneWidget);
      expect(find.text('Cards (1)'), findsOneWidget);

      // Open popup menu and tap delete
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Card to Delete'), findsNothing);
      expect(find.text('Cards (0)'), findsOneWidget);

      final cards = await db.cardsDao.getCardsByDeck(testDeck.id);
      expect(cards, isEmpty);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'suspending and unsuspending card shows badge and updates due count',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeck.id,
          front: 'Card to Suspend',
          back: 'Back to Suspend',
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('1 cards due for review'), findsOneWidget);
        expect(find.text('Suspended'), findsNothing);

        // Open popup menu and tap Suspend
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Suspend Card'));
        await tester.pumpAndSettle();

        expect(find.text('Suspended'), findsOneWidget);
        expect(find.text('0 cards due for review'), findsOneWidget);

        // Unsuspend
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Unsuspend Card'));
        await tester.pumpAndSettle();

        expect(find.text('Suspended'), findsNothing);
        expect(find.text('1 cards due for review'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('burying card shows badge and updates due count', (
      tester,
    ) async {
      await db.cardsDao.createCard(
        deckId: testDeck.id,
        front: 'Card to Bury',
        back: 'Back to Bury',
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('1 cards due for review'), findsOneWidget);
      expect(find.text('Buried'), findsNothing);

      // Open popup menu and tap Bury Card
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bury Card'));
      await tester.pumpAndSettle();

      expect(find.text('Buried'), findsOneWidget);
      expect(find.text('0 cards due for review'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'searching cards filters the list and clearing search resets it',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeck.id,
          front: 'What is Mitochondria?',
          back: 'Powerhouse of the cell',
        );
        await db.cardsDao.createCard(
          deckId: testDeck.id,
          front: 'What is Chloroplast?',
          back: 'Site of photosynthesis',
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('What is Mitochondria?'), findsOneWidget);
        expect(find.text('What is Chloroplast?'), findsOneWidget);

        // Tap search icon button in AppBar
        await tester.tap(find.byKey(const Key('search_cards_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('deck_search_field')), findsOneWidget);

        // Search for "Mito"
        await tester.enterText(
          find.byKey(const Key('deck_search_field')),
          'Mito',
        );
        await tester.pumpAndSettle();

        expect(find.text('What is Mitochondria?'), findsOneWidget);
        expect(find.text('What is Chloroplast?'), findsNothing);

        // Clear search
        await tester.tap(find.byKey(const Key('clear_search_button')));
        await tester.pumpAndSettle();

        expect(find.text('What is Mitochondria?'), findsOneWidget);
        expect(find.text('What is Chloroplast?'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('duplicating card creates a copy with reset progress', (
      tester,
    ) async {
      await db.cardsDao.createCard(
        deckId: testDeck.id,
        front: 'Original Question',
        back: 'Original Answer',
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Original Question'), findsOneWidget);
      expect(find.text('Cards (1)'), findsOneWidget);

      // Open context menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap Duplicate Card
      await tester.tap(find.text('Duplicate Card'));
      await tester.pumpAndSettle();

      expect(find.text('Cards (2)'), findsOneWidget);
      expect(find.text('Original Question'), findsNWidgets(2));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'setting card flag updates the card flag and renders flag icon',
      (tester) async {
        await db.cardsDao.createCard(
          deckId: testDeck.id,
          front: 'Flag Test Question',
          back: 'Flag Test Answer',
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Open context menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Tap Flag menu item within PopupMenuItem
        final flagMenuItem = find.descendant(
          of: find.byType(PopupMenuItem<String>),
          matching: find.text('Flag'),
        );
        await tester.tap(flagMenuItem);
        await tester.pumpAndSettle();

        // Choose Red Flag from dialog
        await tester.tap(find.text('Red Flag').last);
        await tester.pumpAndSettle();

        // Should find flag icon in card tile
        expect(find.byIcon(Icons.flag_rounded), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'unbury all cards menu action clears buriedUntil on all deck cards',
      (tester) async {
        final now = DateTime.now().toUtc();
        final cardId = await db.cardsDao.createCard(
          deckId: testDeck.id,
          front: 'Buried Card',
          back: 'Buried Answer',
        );
        await db.cardsDao.buryCardUntilTomorrow(cardId, now);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Buried'), findsOneWidget);

        // Tap Unbury all cards button
        await tester.tap(find.byKey(const Key('unbury_deck_cards_button')));
        await tester.pumpAndSettle();

        expect(find.text('Buried'), findsNothing);
        expect(find.text('1 card unburied'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
  });
}
