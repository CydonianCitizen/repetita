import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/tags_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/tag_entity.dart';

part 'tags_controller.g.dart';

@riverpod
class TagsController extends _$TagsController {
  @override
  Stream<List<TagEntity>> build() {
    final dao = ref.watch(tagsDaoProvider);
    return dao.watchAllTags().map(
      (tags) => tags.map((t) => t.toEntity()).toList(),
    );
  }

  Future<int> createTag(String name, {int color = 0}) async {
    final dao = ref.read(tagsDaoProvider);
    return dao.getOrCreateTag(name, color: color);
  }

  Future<void> deleteTag(int tagId) async {
    final dao = ref.read(tagsDaoProvider);
    await dao.deleteTag(tagId);
  }
}

@riverpod
Stream<Map<int, List<TagEntity>>> deckTags(Ref ref, int deckId) {
  final dao = ref.watch(tagsDaoProvider);
  return dao
      .watchTagsForDeck(deckId)
      .map(
        (map) => map.map(
          (cardId, tags) =>
              MapEntry(cardId, tags.map((t) => t.toEntity()).toList()),
        ),
      );
}

@riverpod
class DeckTagFilter extends _$DeckTagFilter {
  @override
  int? build() => null;

  void selectTag(int? tagId) {
    state = tagId;
  }
}

/// Memoized list of unique, sorted tags across all cards in [deckId].
@riverpod
List<TagEntity> distinctDeckTags(Ref ref, int deckId) {
  final tagsMap = ref.watch(deckTagsProvider(deckId)).value;
  if (tagsMap == null || tagsMap.isEmpty) return const [];
  final unique = <int, TagEntity>{};
  for (final tagList in tagsMap.values) {
    for (final tag in tagList) {
      unique[tag.id] = tag;
    }
  }
  return unique.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}
