// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeckListController)
final deckListControllerProvider = DeckListControllerProvider._();

final class DeckListControllerProvider
    extends $StreamNotifierProvider<DeckListController, List<DeckWithCounts>> {
  DeckListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckListControllerHash();

  @$internal
  @override
  DeckListController create() => DeckListController();
}

String _$deckListControllerHash() =>
    r'62fd04f213a9ad72033867d1cc63498865373eaf';

abstract class _$DeckListController
    extends $StreamNotifier<List<DeckWithCounts>> {
  Stream<List<DeckWithCounts>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<DeckWithCounts>>, List<DeckWithCounts>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<DeckWithCounts>>,
                List<DeckWithCounts>
              >,
              AsyncValue<List<DeckWithCounts>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
