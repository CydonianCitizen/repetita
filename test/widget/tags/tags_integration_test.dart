import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/cards/presentation/card_editor_screen.dart';
import 'package:repetita/src/features/cards/presentation/deck_detail_screen.dart';

void main() {
  late AppDatabase db;
  late Deck testDeck;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final deckId = await db.decksDao.createDeck(name: 'Science');
    testDeck = Deck(
      id: deckId,
      name: 'Science',
      description: null,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject({required Widget child}) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: child,
      ),
    );
  }

  group('Tags Integration Widget Tests', () {
    testWidgets('CardEditorScreen creates tag and associates with card', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(child: CardEditorScreen(deckId: testDeck.id)),
      );
      await tester.pumpAndSettle();

      // Enter Front and Back
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Front (Question / Prompt)'),
        'What is H2O?',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Back (Answer / Explanation)'),
        'Water',
      );
      await tester.pumpAndSettle();

      // Tap Add Tag
      final addTagBtn = find.byKey(const Key('add_tag_button'));
      await tester.scrollUntilVisible(
        addTagBtn,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(addTagBtn, findsOneWidget);
      await tester.tap(addTagBtn);
      await tester.pumpAndSettle();

      // Dialog opens: enter tag name and submit
      expect(find.text('Select Tags'), findsOneWidget);
      final tagInput = find.widgetWithText(TextField, 'Enter tag name...');
      expect(tagInput, findsOneWidget);
      await tester.enterText(tagInput, 'Chemistry');
      await tester.tap(find.byKey(const Key('confirm_add_tag_button')));
      await tester.pumpAndSettle();

      // Verify tag chip is shown on editor
      expect(find.text('Chemistry'), findsOneWidget);

      // Save card
      await tester.tap(find.byKey(const Key('save_card_button')));
      await tester.pumpAndSettle();

      // Verify card and tag relation in DB
      final cards = await db.cardsDao.getCardsByDeck(testDeck.id);
      expect(cards, hasLength(1));
      final tags = await db.tagsDao.getTagsForCard(cards.first.id);
      expect(tags, hasLength(1));
      expect(tags.first.name, equals('Chemistry'));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('DeckDetailScreen filters cards by tag chips', (tester) async {
      // Seed two cards with different tags
      final card1Id = await db.cardsDao.createCard(
        deckId: testDeck.id,
        front: 'Mitochondria function?',
        back: 'Powerhouse of the cell',
      );
      final card2Id = await db.cardsDao.createCard(
        deckId: testDeck.id,
        front: 'Speed of light?',
        back: '300,000 km/s',
      );

      final tagBio = await db.tagsDao.getOrCreateTag('Biology');
      final tagPhys = await db.tagsDao.getOrCreateTag('Physics');

      await db.tagsDao.setCardTags(card1Id, [tagBio]);
      await db.tagsDao.setCardTags(card2Id, [tagPhys]);

      await tester.pumpWidget(
        buildSubject(child: DeckDetailScreen(deck: testDeck)),
      );
      await tester.pumpAndSettle();

      // Initially both cards are visible
      expect(find.text('Mitochondria function?'), findsOneWidget);
      expect(find.text('Speed of light?'), findsOneWidget);
      expect(
        find.text('#Biology'),
        findsNWidgets(2),
      ); // FilterChip + Card badge
      expect(
        find.text('#Physics'),
        findsNWidgets(2),
      ); // FilterChip + Card badge

      // Tag filter chips are present
      expect(find.byKey(const Key('filter_tag_all')), findsOneWidget);
      expect(find.byKey(Key('filter_tag_$tagBio')), findsOneWidget);
      expect(find.byKey(Key('filter_tag_$tagPhys')), findsOneWidget);

      // Filter by Biology
      await tester.tap(find.byKey(Key('filter_tag_$tagBio')));
      await tester.pumpAndSettle();

      expect(find.text('Mitochondria function?'), findsOneWidget);
      expect(find.text('Speed of light?'), findsNothing);
      expect(
        find.text('#Biology'),
        findsNWidgets(2),
      ); // Filter chip + 1 visible card badge
      expect(
        find.text('#Physics'),
        findsNWidgets(1),
      ); // Filter chip only (card hidden)

      // Filter by Physics
      await tester.tap(find.byKey(Key('filter_tag_$tagPhys')));
      await tester.pumpAndSettle();

      expect(find.text('Mitochondria function?'), findsNothing);
      expect(find.text('Speed of light?'), findsOneWidget);

      // Reset to All
      await tester.tap(find.byKey(const Key('filter_tag_all')));
      await tester.pumpAndSettle();

      expect(find.text('Mitochondria function?'), findsOneWidget);
      expect(find.text('Speed of light?'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets(
      'tag deletion from filter chip confirms dialog, removes tag and resets filter',
      (tester) async {
        final tagChemistry = await db.tagsDao.getOrCreateTag('Chemistry');
        final cardId = await db.cardsDao.createCard(
          deckId: testDeck.id,
          front: 'Water formula?',
          back: 'H2O',
        );
        await db.tagsDao.setCardTags(cardId, [tagChemistry]);

        await tester.pumpWidget(
          buildSubject(child: DeckDetailScreen(deck: testDeck)),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(Key('filter_tag_$tagChemistry')), findsOneWidget);

        // Tap delete icon on Chemistry chip
        final deleteIconFinder = find.descendant(
          of: find.byKey(Key('filter_tag_$tagChemistry')),
          matching: find.byIcon(Icons.close),
        );
        expect(deleteIconFinder, findsOneWidget);
        await tester.tap(deleteIconFinder);
        await tester.pumpAndSettle();

        // Confirm dialog visible
        expect(
          find.text(
            'Are you sure you want to delete "#Chemistry"? It will be removed from all cards.',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('confirm_delete_tag_button')),
          findsOneWidget,
        );

        // Tap confirm delete
        await tester.tap(find.byKey(const Key('confirm_delete_tag_button')));
        await tester.pumpAndSettle();

        // Verify chip is gone from filter row
        expect(find.byKey(Key('filter_tag_$tagChemistry')), findsNothing);

        // Verify tag removed from DB
        final allTags = await (db.select(db.tags)).get();
        expect(allTags.any((t) => t.id == tagChemistry), isFalse);

        ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
            .clearSnackBars();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  });
}
