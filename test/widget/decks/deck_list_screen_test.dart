import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/decks/presentation/deck_list_screen.dart';

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
      child: const MaterialApp(home: DeckListScreen()),
    );
  }

  group('DeckListScreen Widget Tests', () {
    testWidgets('renders empty state message when no decks exist', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No decks yet. Tap + to create one.'), findsOneWidget);
      expect(find.byKey(const Key('create_deck_fab')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('renders list of decks with Due and Total badges', (
      tester,
    ) async {
      final deckId = await db.decksDao.createDeck(
        name: 'Spanish',
        description: 'Spanish vocab',
      );

      // Add a card that is due
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Hola',
              back: 'Hello',
              due: DateTime.now().toUtc(),
            ),
          );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text('Spanish vocab'), findsOneWidget);
      expect(find.text('Due: 1'), findsOneWidget);
      expect(find.text('Total: 1'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'validates empty deck name and creates a deck when input is valid',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Tap FAB to open creation dialog
        await tester.tap(find.byKey(const Key('create_deck_fab')));
        await tester.pumpAndSettle();

        expect(find.text('Create Deck'), findsOneWidget);

        // Submit with empty name -> triggers validation error
        await tester.tap(find.byKey(const Key('deck_form_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Deck name is required'), findsOneWidget);

        // Enter valid name
        await tester.enterText(
          find.byKey(const Key('deck_name_field')),
          'Computer Science',
        );
        await tester.enterText(
          find.byKey(const Key('deck_description_field')),
          'Algorithms & DS',
        );
        await tester.pumpAndSettle();

        // Submit valid form
        await tester.tap(find.byKey(const Key('deck_form_submit_button')));
        await tester.pumpAndSettle();

        // Verify dialog closed and new deck rendered
        expect(find.text('Create Deck'), findsNothing);
        expect(find.text('Computer Science'), findsOneWidget);
        expect(find.text('Algorithms & DS'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('delete confirmation dialog cancels or deletes deck', (
      tester,
    ) async {
      await db.decksDao.createDeck(name: 'Disposable Deck');

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Disposable Deck'), findsOneWidget);

      // Open context menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Deck?'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Deck should still exist
      expect(find.text('Disposable Deck'), findsOneWidget);

      // Open menu and Delete again
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm Delete
      final deleteConfirmButton = find.widgetWithText(FilledButton, 'Delete');
      await tester.tap(deleteConfirmButton);
      await tester.pumpAndSettle();

      // Verify deck deleted and empty state restored
      expect(find.text('Disposable Deck'), findsNothing);
      expect(find.text('No decks yet. Tap + to create one.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'AppBar shows title repetita and top action buttons are removed',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('repetita'), findsOneWidget);
        expect(find.byKey(const Key('open_stats_button')), findsNothing);
        expect(find.byKey(const Key('open_backup_button')), findsNothing);
        expect(find.byKey(const Key('open_settings_button')), findsNothing);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'desktop hides FAB, shows desktop AppBar button and sample deck button',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        try {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          // FAB is removed on desktop
          expect(find.byKey(const Key('create_deck_fab')), findsNothing);

          // Desktop action buttons are rendered
          expect(
            find.byKey(const Key('create_deck_desktop_button')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('load_sample_deck_appbar_button')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('seed_sample_deck_button')),
            findsOneWidget,
          );

          // Tapping load sample deck button seeds demo cards
          await tester.tap(find.byKey(const Key('seed_sample_deck_button')));
          await tester.pumpAndSettle();

          expect(
            find.text('Mazzo Dimostrativo • FSRS & Spaced Repetition'),
            findsOneWidget,
          );
          expect(find.text('Total: 8'), findsOneWidget);

          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(milliseconds: 50));
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );

    testWidgets('renders hierarchical subdecks indented and collapses on toggle', (
      tester,
    ) async {
      await db.decksDao.createDeck(name: 'Languages');
      await db.decksDao.createDeck(name: 'Languages::Japanese');

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Languages'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);

      // Find collapse icon button and tap it
      final collapseButton = find.byIcon(Icons.expand_more);
      expect(collapseButton, findsOneWidget);

      await tester.tap(collapseButton);
      await tester.pumpAndSettle();

      // Japanese is now collapsed/hidden
      expect(find.text('Languages'), findsOneWidget);
      expect(find.text('Japanese'), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
