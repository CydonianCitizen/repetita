import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart' show Deck;
import '../../data/decks_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/home_widget_service.dart';

part 'deck_list_controller.g.dart';

final watchDeckProvider = StreamProvider.family<Deck?, int>((ref, deckId) {
  final dao = ref.watch(decksDaoProvider);
  return dao.watchDeckById(deckId);
});

@riverpod
class DeckListController extends _$DeckListController {
  @override
  Stream<List<DeckWithCounts>> build() {
    final dao = ref.watch(decksDaoProvider);
    return dao.watchAllDecksWithCounts().map((decks) {
      final db = ref.read(databaseProvider);
      ref.read(homeWidgetServiceProvider).syncWithDatabase(db);
      return decks;
    });
  }

  Future<void> createDeck({required String name, String? description}) async {
    final dao = ref.read(decksDaoProvider);
    await dao.createDeck(name: name, description: description);
  }

  Future<void> updateDeck({
    required int id,
    required String name,
    String? description,
  }) async {
    final dao = ref.read(decksDaoProvider);
    await dao.updateDeck(id: id, name: name, description: description);
  }

  Future<void> deleteDeck(int id) async {
    final dao = ref.read(decksDaoProvider);
    await dao.deleteDeck(id);
  }
}
