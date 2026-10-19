import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/cards/presentation/card_browser_screen.dart';
import 'package:repetita/src/features/cards/presentation/card_editor_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CardBrowserScreen(),
      ),
    );
  }

  group('CardBrowserScreen Widget Tests', () {
    testWidgets('renders empty state when no cards exist', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.text('No cards found'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'renders cards with front, back, deck badge and filters by text',
      (tester) async {
        final deckId = await db.decksDao.createDeck(name: 'Neuroscience');
        await db.cardsDao.createCard(
          deckId: deckId,
          front: 'Action Potential',
          back: 'Rapid depolarization of membrane',
        );
        await db.cardsDao.createCard(
          deckId: deckId,
          front: 'Synapse',
          back: 'Junction between two neurons',
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Action Potential'), findsOneWidget);
        expect(find.text('Synapse'), findsOneWidget);
        expect(find.text('Neuroscience'), findsNWidgets(2));
        expect(find.text('2 cards found'), findsOneWidget);

        // Type in search bar
        final searchInput = find.byKey(const Key('card_browser_search_input'));
        await tester.enterText(searchInput, 'Action');
        await tester.pumpAndSettle();

        expect(find.text('Action Potential'), findsOneWidget);
        expect(find.text('Synapse'), findsNothing);
        expect(find.text('1 card found'), findsOneWidget);

        // Clear search via clear button
        final clearButton = find.byIcon(Icons.clear);
        expect(clearButton, findsOneWidget);
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        expect(find.text('Action Potential'), findsOneWidget);
        expect(find.text('Synapse'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'filters by suspended filter chip and opens editor on card tap',
      (tester) async {
        final deckId = await db.decksDao.createDeck(name: 'Biology');
        await db.cardsDao.createCard(
          deckId: deckId,
          front: 'Active Card',
          back: 'Not suspended',
        );
        final c2 = await db.cardsDao.createCard(
          deckId: deckId,
          front: 'Suspended Card',
          back: 'Suspended item',
        );
        await db.cardsDao.setCardSuspended(c2, true);

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Active Card'), findsOneWidget);
        expect(find.text('Suspended Card'), findsOneWidget);

        // Tap Suspended chip
        final suspendedChip = find.byKey(
          const Key('card_browser_suspended_chip'),
        );
        await tester.tap(suspendedChip);
        await tester.pumpAndSettle();

        expect(find.text('Active Card'), findsNothing);
        expect(find.text('Suspended Card'), findsOneWidget);

        // Tap on Suspended Card to open CardEditorScreen
        await tester.tap(find.text('Suspended Card'));
        await tester.pumpAndSettle();

        expect(find.byType(CardEditorScreen), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('reset button appears when filter active and clears filter', (
      tester,
    ) async {
      final deckId = await db.decksDao.createDeck(name: 'Chemistry');
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Helium',
        back: 'Noble gas',
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Initially no reset button
      expect(find.byIcon(Icons.filter_alt_off_outlined), findsNothing);

      // Type search
      final searchInput = find.byKey(const Key('card_browser_search_input'));
      await tester.enterText(searchInput, 'Helium');
      await tester.pumpAndSettle();

      // Reset button appears
      final resetButton = find.byIcon(Icons.filter_alt_off_outlined);
      expect(resetButton, findsOneWidget);

      // Tap reset
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_alt_off_outlined), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
