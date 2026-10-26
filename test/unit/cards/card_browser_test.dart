import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/utils/clock_provider.dart';
import 'package:repetita/src/features/cards/presentation/controllers/card_browser_controller.dart';
import 'package:repetita/src/features/decks/data/decks_dao.dart';
import 'package:repetita/src/features/decks/presentation/controllers/deck_list_controller.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('CardsDao.searchCardsGlobal', () {
    test('filters cards by query text across front and back', () async {
      final deckId = await db.decksDao.createDeck(name: 'General');
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Mitochondria',
        back: 'Powerhouse',
      );
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Ribosome',
        back: 'Protein synthesis',
      );
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Chloroplast',
        back: 'Photosynthesis in plants',
      );

      final results1 = await db.cardsDao.searchCardsGlobal(
        query: 'mitochondria',
      );
      expect(results1.length, equals(1));
      expect(results1.first.front, equals('Mitochondria'));

      final results2 = await db.cardsDao.searchCardsGlobal(query: 'synthesis');
      expect(
        results2.length,
        equals(2),
      ); // Ribosome (back) + Chloroplast (back)
    });

    test('filters cards by deckId, flag, isSuspended, and due date', () async {
      final deck1 = await db.decksDao.createDeck(name: 'Deck 1');
      final deck2 = await db.decksDao.createDeck(name: 'Deck 2');

      final now = DateTime.utc(2026, 10, 19, 12, 0);

      final c1 = await db.cardsDao.createCard(
        deckId: deck1,
        front: 'A',
        back: 'A',
        now: now,
      );
      await db.cardsDao.setCardFlag(c1, 1); // Red flag

      final c2 = await db.cardsDao.createCard(
        deckId: deck2,
        front: 'B',
        back: 'B',
        now: now,
      );
      await db.cardsDao.setCardSuspended(c2, true);

      final c3 = await db.cardsDao.createCard(
        deckId: deck1,
        front: 'C',
        back: 'C',
        now: now,
      );
      await db.cardsDao.setCardDueDate(
        c3,
        now.add(const Duration(days: 10)),
      ); // future

      // Deck filter
      final deck1Cards = await db.cardsDao.searchCardsGlobal(deckId: deck1);
      expect(deck1Cards.length, equals(2));

      // Flag filter
      final flagCards = await db.cardsDao.searchCardsGlobal(flag: 1);
      expect(flagCards.length, equals(1));
      expect(flagCards.first.id, equals(c1));

      // Suspended filter
      final suspendedCards = await db.cardsDao.searchCardsGlobal(
        isSuspended: true,
      );
      expect(suspendedCards.length, equals(1));
      expect(suspendedCards.first.id, equals(c2));

      // Due only
      final dueCards = await db.cardsDao.searchCardsGlobal(
        isDueOnly: true,
        dueCutoff: now,
      );
      // c1 is due (state 0), c2 is suspended so excluded, c3 is in 10 days so excluded
      expect(dueCards.length, equals(1));
      expect(dueCards.first.id, equals(c1));
    });
  });

  group('CardBrowserController & cardBrowserResultsProvider', () {
    test('updates filter state and filters results reactively', () async {
      final deckId = await db.decksDao.createDeck(name: 'Bio');
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Cell wall',
        back: 'Plant protection',
      );
      final c2 = await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Nucleus',
        back: 'Genetic info',
      );
      await db.cardsDao.setCardFlag(c2, 2);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(
            () => DateTime.utc(2026, 10, 19, 12, 0),
          ),
          deckListControllerProvider.overrideWith(
            () => _FakeDeckListNotifier([
              DeckWithCounts(
                deck: Deck(
                  id: deckId,
                  name: 'Bio',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  globalId: '',
                  updatedHlc: '',
                ),
                totalCards: 2,
                dueCards: 2,
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(cardBrowserResultsProvider, (_, _) {});
      addTearDown(sub.close);

      while (container.read(cardBrowserResultsProvider).isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      var results = container.read(cardBrowserResultsProvider).requireValue;
      expect(results.length, equals(2));
      expect(results.first.deckName, equals('Bio'));

      // Filter by query
      container.read(cardBrowserFilterProvider.notifier).setQuery('wall');
      results = container.read(cardBrowserResultsProvider).requireValue;
      expect(results.length, equals(1));
      expect(results.first.card.front, equals('Cell wall'));

      // Reset
      container.read(cardBrowserFilterProvider.notifier).reset();
      results = container.read(cardBrowserResultsProvider).requireValue;
      expect(results.length, equals(2));

      // Filter by flag
      container.read(cardBrowserFilterProvider.notifier).setFlag(2);
      results = container.read(cardBrowserResultsProvider).requireValue;
      expect(results.length, equals(1));
      expect(results.first.card.front, equals('Nucleus'));
    });
  });
}

class _FakeDeckListNotifier extends DeckListController {
  _FakeDeckListNotifier(this.decks);
  final List<DeckWithCounts> decks;

  @override
  Stream<List<DeckWithCounts>> build() => Stream.value(decks);
}
