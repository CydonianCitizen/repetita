// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_advance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AutoAdvanceController)
final autoAdvanceControllerProvider = AutoAdvanceControllerProvider._();

final class AutoAdvanceControllerProvider
    extends $NotifierProvider<AutoAdvanceController, int> {
  AutoAdvanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoAdvanceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoAdvanceControllerHash();

  @$internal
  @override
  AutoAdvanceController create() => AutoAdvanceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$autoAdvanceControllerHash() =>
    r'2ad5d75e277409625d7cae62d60a0d7aa66a3440';

abstract class _$AutoAdvanceController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
