import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/tags/domain/tag_entity.dart';
import 'package:repetita/src/features/tags/presentation/controllers/tags_controller.dart';

void main() {
  group('distinctDeckTags Unit Tests', () {
    test('returns empty list when tags map is empty or null', () {
      final container = ProviderContainer(
        overrides: [
          deckTagsProvider(1)
              .overrideWith((ref) => Stream.value(<int, List<TagEntity>>{})),
        ],
      );
      addTearDown(container.dispose);

      final tags = container.read(distinctDeckTagsProvider(1));
      expect(tags, isEmpty);
    });

    test('deduplicates and sorts tags alphabetically by name', () async {
      final now = DateTime(2026, 1, 1);
      final tagB = TagEntity(
        id: 2,
        name: 'Beta',
        color: 0xFF222222,
        createdAt: now,
      );
      final tagA = TagEntity(
        id: 1,
        name: 'Alpha',
        color: 0xFF111111,
        createdAt: now,
      );
      final tagC = TagEntity(
        id: 3,
        name: 'Gamma',
        color: 0xFF333333,
        createdAt: now,
      );

      final controller = StreamController<Map<int, List<TagEntity>>>();
      addTearDown(controller.close);

      final container = ProviderContainer(
        overrides: [
          deckTagsProvider(10).overrideWith((ref) => controller.stream),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(distinctDeckTagsProvider(10), (_, _) {});
      addTearDown(sub.close);

      controller.add(<int, List<TagEntity>>{
        101: [tagB, tagA],
        102: [tagA, tagC],
        103: [tagB],
      });
      await pumpEventQueue();

      final tags = container.read(distinctDeckTagsProvider(10));
      expect(tags, hasLength(3));
      expect(tags.map((t) => t.name).toList(), ['Alpha', 'Beta', 'Gamma']);
    });
  });
}
