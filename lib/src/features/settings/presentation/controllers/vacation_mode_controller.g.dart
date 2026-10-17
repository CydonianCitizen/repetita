// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacation_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VacationModeController)
final vacationModeControllerProvider = VacationModeControllerProvider._();

final class VacationModeControllerProvider
    extends $AsyncNotifierProvider<VacationModeController, bool> {
  VacationModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vacationModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vacationModeControllerHash();

  @$internal
  @override
  VacationModeController create() => VacationModeController();
}

String _$vacationModeControllerHash() =>
    r'68e43d246dc5d152eef42cff0a5bb4c36a315ecb';

abstract class _$VacationModeController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
