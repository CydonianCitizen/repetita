// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeckCardSearchQuery)
final deckCardSearchQueryProvider = DeckCardSearchQueryProvider._();

final class DeckCardSearchQueryProvider
    extends $NotifierProvider<DeckCardSearchQuery, String> {
  DeckCardSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckCardSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckCardSearchQueryHash();

  @$internal
  @override
  DeckCardSearchQuery create() => DeckCardSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$deckCardSearchQueryHash() =>
    r'6d772951e1375c4aff407b6cc0f6f62ef6e9d96a';

abstract class _$DeckCardSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DeckCardFlagFilter)
final deckCardFlagFilterProvider = DeckCardFlagFilterProvider._();

final class DeckCardFlagFilterProvider
    extends $NotifierProvider<DeckCardFlagFilter, int?> {
  DeckCardFlagFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckCardFlagFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckCardFlagFilterHash();

  @$internal
  @override
  DeckCardFlagFilter create() => DeckCardFlagFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$deckCardFlagFilterHash() =>
    r'bd169e0465011790fed565e5178511cc9614793e';

abstract class _$DeckCardFlagFilter extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Cards of [deckId] filtered by the currently selected tag, flag, and search query.
/// Recomputed only when the card list, the tag map, the tag filter, or search query change.

@ProviderFor(filteredDeckCards)
final filteredDeckCardsProvider = FilteredDeckCardsFamily._();

/// Cards of [deckId] filtered by the currently selected tag, flag, and search query.
/// Recomputed only when the card list, the tag map, the tag filter, or search query change.

final class FilteredDeckCardsProvider
    extends
        $FunctionalProvider<
          List<CardEntity>,
          List<CardEntity>,
          List<CardEntity>
        >
    with $Provider<List<CardEntity>> {
  /// Cards of [deckId] filtered by the currently selected tag, flag, and search query.
  /// Recomputed only when the card list, the tag map, the tag filter, or search query change.
  FilteredDeckCardsProvider._({
    required FilteredDeckCardsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'filteredDeckCardsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredDeckCardsHash();

  @override
  String toString() {
    return r'filteredDeckCardsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<CardEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<CardEntity> create(Ref ref) {
    final argument = this.argument as int;
    return filteredDeckCards(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CardEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CardEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredDeckCardsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredDeckCardsHash() => r'c37d7bfbc6655abaf10ccddb3308e30e00c6594f';

/// Cards of [deckId] filtered by the currently selected tag, flag, and search query.
/// Recomputed only when the card list, the tag map, the tag filter, or search query change.

final class FilteredDeckCardsFamily extends $Family
    with $FunctionalFamilyOverride<List<CardEntity>, int> {
  FilteredDeckCardsFamily._()
    : super(
        retry: null,
        name: r'filteredDeckCardsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cards of [deckId] filtered by the currently selected tag, flag, and search query.
  /// Recomputed only when the card list, the tag map, the tag filter, or search query change.

  FilteredDeckCardsProvider call(int deckId) =>
      FilteredDeckCardsProvider._(argument: deckId, from: this);

  @override
  String toString() => r'filteredDeckCardsProvider';
}

@ProviderFor(CardListController)
final cardListControllerProvider = CardListControllerFamily._();

final class CardListControllerProvider
    extends $StreamNotifierProvider<CardListController, List<CardEntity>> {
  CardListControllerProvider._({
    required CardListControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'cardListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardListControllerHash();

  @override
  String toString() {
    return r'cardListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CardListController create() => CardListController();

  @override
  bool operator ==(Object other) {
    return other is CardListControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardListControllerHash() =>
    r'fc163a0a732c4c7e8ba44a28c49dc9eca985cf20';

final class CardListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CardListController,
          AsyncValue<List<CardEntity>>,
          List<CardEntity>,
          Stream<List<CardEntity>>,
          int
        > {
  CardListControllerFamily._()
    : super(
        retry: null,
        name: r'cardListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CardListControllerProvider call(int deckId) =>
      CardListControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'cardListControllerProvider';
}

abstract class _$CardListController extends $StreamNotifier<List<CardEntity>> {
  late final _$args = ref.$arg as int;
  int get deckId => _$args;

  Stream<List<CardEntity>> build(int deckId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CardEntity>>, List<CardEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CardEntity>>, List<CardEntity>>,
              AsyncValue<List<CardEntity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
