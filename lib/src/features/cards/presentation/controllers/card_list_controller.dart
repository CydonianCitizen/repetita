import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../data/cards_dao.dart';
import '../../domain/card_entity.dart';

part 'card_list_controller.g.dart';

@riverpod
class DeckCardSearchQuery extends _$DeckCardSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) => state = query.trim();
  void clear() => state = '';
}

@riverpod
class DeckCardFlagFilter extends _$DeckCardFlagFilter {
  @override
  int? build() => null;

  void setFilter(int? flag) => state = flag;
  void clear() => state = null;
}

/// Cards of [deckId] filtered by the currently selected tag, flag, and search query.
/// Recomputed only when the card list, the tag map, the tag filter, or search query change.
@riverpod
List<CardEntity> filteredDeckCards(Ref ref, int deckId) {
  final cards =
      ref.watch(cardListControllerProvider(deckId)).value ??
      const <CardEntity>[];
  final selectedTagId = ref.watch(deckTagFilterProvider);
  final selectedFlag = ref.watch(deckCardFlagFilterProvider);
  final searchQuery = ref.watch(deckCardSearchQueryProvider).toLowerCase();

  var result = cards;
  if (selectedTagId != null) {
    final tagsMap = ref.watch(deckTagsProvider(deckId)).value;
    result = result
        .where(
          (c) => (tagsMap?[c.id] ?? const []).any((t) => t.id == selectedTagId),
        )
        .toList();
  }

  if (selectedFlag != null) {
    if (selectedFlag == -1) {
      final tagsMap = ref.watch(deckTagsProvider(deckId)).value;
      result = result
          .where(
            (c) => (tagsMap?[c.id] ?? const []).any(
              (t) => t.name.toLowerCase() == 'leech',
            ),
          )
          .toList();
    } else {
      result = result.where((c) => c.flag == selectedFlag).toList();
    }
  }

  if (searchQuery.isNotEmpty) {
    result = result
        .where(
          (c) =>
              c.front.toLowerCase().contains(searchQuery) ||
              c.back.toLowerCase().contains(searchQuery),
        )
        .toList();
  }

  return result;
}

@riverpod
class CardListController extends _$CardListController {
  @override
  Stream<List<CardEntity>> build(int deckId) {
    final dao = ref.watch(cardsDaoProvider);
    return dao
        .watchCardsByDeck(deckId)
        .map((cards) => cards.map((c) => c.toEntity()).toList());
  }

  Future<int> createCard({
    required String front,
    required String back,
    int? clozeIndex,
    List<int> tagIds = const [],
  }) async {
    final dao = ref.read(cardsDaoProvider);
    final tagsDao = ref.read(tagsDaoProvider);
    return dao.attachedDatabase.transaction(() async {
      final cardId = await dao.createCard(
        deckId: deckId,
        front: front,
        back: back,
        clozeIndex: clozeIndex,
      );
      if (tagIds.isNotEmpty) {
        await tagsDao.setCardTags(cardId, tagIds);
      }
      return cardId;
    });
  }

  Future<List<int>> createClozeCards({
    required String front,
    required String back,
    required Iterable<int> clozeIndices,
    List<int> tagIds = const [],
    int? noteId,
  }) async {
    final dao = ref.read(cardsDaoProvider);
    final tagsDao = ref.read(tagsDaoProvider);
    final sharedNoteId =
        noteId ?? DateTime.now().toUtc().microsecondsSinceEpoch;
    return dao.attachedDatabase.transaction(() async {
      final cardIds = <int>[];
      for (final idx in clozeIndices) {
        final cardId = await dao.createCard(
          deckId: deckId,
          front: front,
          back: back,
          clozeIndex: idx,
          noteId: sharedNoteId,
        );
        if (tagIds.isNotEmpty) {
          await tagsDao.setCardTags(cardId, tagIds);
        }
        cardIds.add(cardId);
      }
      return cardIds;
    });
  }

  Future<void> updateCard({
    required int id,
    required String front,
    required String back,
    List<int>? tagIds,
  }) async {
    final dao = ref.read(cardsDaoProvider);
    final tagsDao = ref.read(tagsDaoProvider);
    await dao.attachedDatabase.transaction(() async {
      await dao.updateCardContent(id: id, front: front, back: back);
      if (tagIds != null) {
        await tagsDao.setCardTags(id, tagIds);
      }
    });
  }

  Future<void> deleteCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.deleteCard(id);
  }

  Future<void> toggleSuspendCard(int id, bool currentSuspended) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.setCardSuspended(id, !currentSuspended);
  }

  Future<void> buryCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.buryCardUntilTomorrow(id);
  }

  Future<void> unburyCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.unburyCard(id);
  }

  Future<void> setCardFlag(int id, int flag) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.setCardFlag(id, flag);
  }

  Future<void> setCardDueDate(int id, DateTime newDue) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.setCardDueDate(id, newDue);
  }

  Future<void> resetCardProgress(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.resetCardProgress(id);
  }

  Future<int> duplicateCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    return dao.duplicateCard(id);
  }

  Future<List<int>> createReversedCard({
    required String front,
    required String back,
    List<int> tagIds = const [],
  }) async {
    final dao = ref.read(cardsDaoProvider);
    final tagsDao = ref.read(tagsDaoProvider);
    return dao.attachedDatabase.transaction(() async {
      final cardIds = await dao.createReversedCards(
        deckId: deckId,
        front: front,
        back: back,
      );
      if (tagIds.isNotEmpty) {
        for (final id in cardIds) {
          await tagsDao.setCardTags(id, tagIds);
        }
      }
      return cardIds;
    });
  }

  Future<int> unburyDeckCards() async {
    final dao = ref.read(cardsDaoProvider);
    return dao.unburyDeckCards(deckId);
  }
}
