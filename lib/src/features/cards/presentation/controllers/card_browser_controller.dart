import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/clock_provider.dart';
import '../../../decks/presentation/controllers/deck_list_controller.dart';
import '../../data/cards_dao.dart';
import '../../domain/card_entity.dart';

class CardBrowserFilter {
  const CardBrowserFilter({
    this.query = '',
    this.deckId,
    this.flag,
    this.isSuspended,
    this.dueOnly = false,
  });

  final String query;
  final int? deckId;
  final int? flag;
  final bool? isSuspended;
  final bool dueOnly;

  CardBrowserFilter copyWith({
    String? query,
    int? Function()? deckId,
    int? Function()? flag,
    bool? Function()? isSuspended,
    bool? dueOnly,
  }) {
    return CardBrowserFilter(
      query: query ?? this.query,
      deckId: deckId != null ? deckId() : this.deckId,
      flag: flag != null ? flag() : this.flag,
      isSuspended: isSuspended != null ? isSuspended() : this.isSuspended,
      dueOnly: dueOnly ?? this.dueOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardBrowserFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          deckId == other.deckId &&
          flag == other.flag &&
          isSuspended == other.isSuspended &&
          dueOnly == other.dueOnly;

  @override
  int get hashCode => Object.hash(query, deckId, flag, isSuspended, dueOnly);
}

class CardWithDeckInfo {
  const CardWithDeckInfo({
    required this.card,
    required this.deckName,
  });

  final CardEntity card;
  final String deckName;
}

class CardBrowserFilterNotifier extends Notifier<CardBrowserFilter> {
  @override
  CardBrowserFilter build() => const CardBrowserFilter();

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setDeckId(int? deckId) {
    state = state.copyWith(deckId: () => deckId);
  }

  void setFlag(int? flag) {
    state = state.copyWith(flag: () => flag);
  }

  void setSuspended(bool? isSuspended) {
    state = state.copyWith(isSuspended: () => isSuspended);
  }

  void setDueOnly(bool dueOnly) {
    state = state.copyWith(dueOnly: dueOnly);
  }

  void reset() {
    state = const CardBrowserFilter();
  }
}

final cardBrowserFilterProvider =
    NotifierProvider<CardBrowserFilterNotifier, CardBrowserFilter>(
  CardBrowserFilterNotifier.new,
);

final globalCardsStreamProvider = StreamProvider<List<CardEntity>>((ref) {
  final dao = ref.watch(cardsDaoProvider);
  return dao
      .watchAllCards()
      .map((cards) => cards.map((c) => c.toEntity()).toList());
});

final cardBrowserResultsProvider =
    Provider<AsyncValue<List<CardWithDeckInfo>>>((ref) {
  final allCardsAsync = ref.watch(globalCardsStreamProvider);
  final decksAsync = ref.watch(deckListControllerProvider);
  final filter = ref.watch(cardBrowserFilterProvider);
  final now = ref.watch(clockProvider)().toUtc();

  return allCardsAsync.when(
    data: (cards) {
      final decks = decksAsync.value ?? [];
      final deckMap = {for (final d in decks) d.deck.id: d.deck.name};

      final query = filter.query.toLowerCase().trim();
      final filtered = cards.where((c) {
        if (filter.deckId != null && c.deckId != filter.deckId) {
          return false;
        }
        if (filter.flag != null && c.flag != filter.flag) {
          return false;
        }
        if (filter.isSuspended != null && c.isSuspended != filter.isSuspended) {
          return false;
        }
        if (filter.dueOnly) {
          if (c.isSuspended) return false;
          final isBuried = c.buriedUntil != null && c.buriedUntil!.isAfter(now);
          if (isBuried) return false;
          final isDue =
              c.due.isBefore(now) || c.due.isAtSameMomentAs(now);
          if (!isDue) return false;
        }
        if (query.isNotEmpty) {
          final frontMatch = c.front.toLowerCase().contains(query);
          final backMatch = c.back.toLowerCase().contains(query);
          if (!frontMatch && !backMatch) return false;
        }
        return true;
      }).map((c) {
        return CardWithDeckInfo(
          card: c,
          deckName: deckMap[c.deckId] ?? 'Deck #${c.deckId}',
        );
      }).toList();

      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (err, st) => AsyncError(err, st),
  );
});
