// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_bury_siblings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AutoBurySiblingsController)
final autoBurySiblingsControllerProvider =
    AutoBurySiblingsControllerProvider._();

final class AutoBurySiblingsControllerProvider
    extends $NotifierProvider<AutoBurySiblingsController, bool> {
  AutoBurySiblingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoBurySiblingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoBurySiblingsControllerHash();

  @$internal
  @override
  AutoBurySiblingsController create() => AutoBurySiblingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$autoBurySiblingsControllerHash() =>
    r'c4b1f5506e45936f9c6b26b0e00a55fab4abe0d7';

abstract class _$AutoBurySiblingsController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
