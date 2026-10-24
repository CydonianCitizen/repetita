import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:repetita/src/core/algorithms/image_occlusion/image_occlusion_box.dart';
import 'package:repetita/src/core/algorithms/image_occlusion/image_occlusion_parser.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/cards/data/cards_dao.dart';
import 'package:repetita/src/features/cards/presentation/controllers/card_list_controller.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );

    final decksDao = container.read(decksDaoProvider);
    testDeckId = await decksDao.createDeck(name: 'Anatomy Deck');
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('createImageOcclusionCards generates N sibling cards with shared noteId and tags', () async {
    final boxes = [
      const ImageOcclusionBox(
        id: 'box_1',
        x: 0.1,
        y: 0.2,
        width: 0.3,
        height: 0.4,
        label: 'Cerebrum',
      ),
      const ImageOcclusionBox(
        id: 'box_2',
        x: 0.5,
        y: 0.6,
        width: 0.2,
        height: 0.3,
        label: 'Cerebellum',
      ),
    ];

    final controller = container.read(
      cardListControllerProvider(testDeckId).notifier,
    );
    final cardIds = await controller.createImageOcclusionCards(
      mediaReference: 'media://brain.png',
      boxes: boxes,
      backNotes: 'Extra anatomical notes',
    );

    expect(cardIds.length, 2);

    final cardsDao = container.read(cardsDaoProvider);
    final card1 = await cardsDao.getCardById(cardIds[0]);
    final card2 = await cardsDao.getCardById(cardIds[1]);

    expect(card1, isNotNull);
    expect(card2, isNotNull);

    // Shared noteId for sibling burying
    expect(card1!.noteId, isNotNull);
    expect(card1.noteId, equals(card2!.noteId));

    // Proper parser parsing and active box assignment
    final entity1 = card1.toEntity();
    final entity2 = card2.toEntity();
    expect(entity1.isImageOcclusion, isTrue);
    expect(entity2.isImageOcclusion, isTrue);

    final data1 = ImageOcclusionParser.parse(entity1.front);
    final data2 = ImageOcclusionParser.parse(entity2.front);

    expect(data1?.activeBoxId, 'box_1');
    expect(data2?.activeBoxId, 'box_2');
    expect(card1.back, contains('Cerebrum'));
    expect(card1.back, contains('Extra anatomical notes'));
    expect(card2.back, contains('Cerebellum'));
  });
}
