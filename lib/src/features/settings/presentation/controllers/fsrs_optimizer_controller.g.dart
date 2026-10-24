// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fsrs_optimizer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FsrsOptimizerController)
final fsrsOptimizerControllerProvider = FsrsOptimizerControllerProvider._();

final class FsrsOptimizerControllerProvider
    extends
        $AsyncNotifierProvider<FsrsOptimizerController, FsrsOptimizerState> {
  FsrsOptimizerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fsrsOptimizerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fsrsOptimizerControllerHash();

  @$internal
  @override
  FsrsOptimizerController create() => FsrsOptimizerController();
}

String _$fsrsOptimizerControllerHash() =>
    r'303c58cbe9166368fd7b1ea8f669171802c4b3c2';

abstract class _$FsrsOptimizerController
    extends $AsyncNotifier<FsrsOptimizerState> {
  FutureOr<FsrsOptimizerState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<FsrsOptimizerState>, FsrsOptimizerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FsrsOptimizerState>, FsrsOptimizerState>,
              AsyncValue<FsrsOptimizerState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
