// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TagsController)
final tagsControllerProvider = TagsControllerProvider._();

final class TagsControllerProvider
    extends $StreamNotifierProvider<TagsController, List<TagEntity>> {
  TagsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagsControllerHash();

  @$internal
  @override
  TagsController create() => TagsController();
}

String _$tagsControllerHash() => r'9658d2126f3df808ebc66114d00f8f26ad2fc06e';

abstract class _$TagsController extends $StreamNotifier<List<TagEntity>> {
  Stream<List<TagEntity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TagEntity>>, List<TagEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TagEntity>>, List<TagEntity>>,
              AsyncValue<List<TagEntity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(deckTags)
final deckTagsProvider = DeckTagsFamily._();

final class DeckTagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, List<TagEntity>>>,
          Map<int, List<TagEntity>>,
          Stream<Map<int, List<TagEntity>>>
        >
    with
        $FutureModifier<Map<int, List<TagEntity>>>,
        $StreamProvider<Map<int, List<TagEntity>>> {
  DeckTagsProvider._({
    required DeckTagsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'deckTagsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deckTagsHash();

  @override
  String toString() {
    return r'deckTagsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<int, List<TagEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, List<TagEntity>>> create(Ref ref) {
    final argument = this.argument as int;
    return deckTags(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckTagsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deckTagsHash() => r'767095874f790f13541bee2a8bcba8ae056140c1';

final class DeckTagsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<int, List<TagEntity>>>, int> {
  DeckTagsFamily._()
    : super(
        retry: null,
        name: r'deckTagsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeckTagsProvider call(int deckId) =>
      DeckTagsProvider._(argument: deckId, from: this);

  @override
  String toString() => r'deckTagsProvider';
}

@ProviderFor(DeckTagFilter)
final deckTagFilterProvider = DeckTagFilterProvider._();

final class DeckTagFilterProvider
    extends $NotifierProvider<DeckTagFilter, int?> {
  DeckTagFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckTagFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckTagFilterHash();

  @$internal
  @override
  DeckTagFilter create() => DeckTagFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$deckTagFilterHash() => r'd5f176d994b00333337ce85e823836c120bba667';

abstract class _$DeckTagFilter extends $Notifier<int?> {
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

/// Memoized list of unique, sorted tags across all cards in [deckId].

@ProviderFor(distinctDeckTags)
final distinctDeckTagsProvider = DistinctDeckTagsFamily._();

/// Memoized list of unique, sorted tags across all cards in [deckId].

final class DistinctDeckTagsProvider
    extends
        $FunctionalProvider<List<TagEntity>, List<TagEntity>, List<TagEntity>>
    with $Provider<List<TagEntity>> {
  /// Memoized list of unique, sorted tags across all cards in [deckId].
  DistinctDeckTagsProvider._({
    required DistinctDeckTagsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'distinctDeckTagsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$distinctDeckTagsHash();

  @override
  String toString() {
    return r'distinctDeckTagsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<TagEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TagEntity> create(Ref ref) {
    final argument = this.argument as int;
    return distinctDeckTags(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TagEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TagEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DistinctDeckTagsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$distinctDeckTagsHash() => r'a9f9bb0aa3ce9d2d1480cddf287ba2576d8dd1f4';

/// Memoized list of unique, sorted tags across all cards in [deckId].

final class DistinctDeckTagsFamily extends $Family
    with $FunctionalFamilyOverride<List<TagEntity>, int> {
  DistinctDeckTagsFamily._()
    : super(
        retry: null,
        name: r'distinctDeckTagsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Memoized list of unique, sorted tags across all cards in [deckId].

  DistinctDeckTagsProvider call(int deckId) =>
      DistinctDeckTagsProvider._(argument: deckId, from: this);

  @override
  String toString() => r'distinctDeckTagsProvider';
}
