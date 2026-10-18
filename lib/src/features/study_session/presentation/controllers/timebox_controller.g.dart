// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timebox_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimeboxController)
final timeboxControllerProvider = TimeboxControllerProvider._();

final class TimeboxControllerProvider
    extends $NotifierProvider<TimeboxController, int> {
  TimeboxControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeboxControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeboxControllerHash();

  @$internal
  @override
  TimeboxController create() => TimeboxController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$timeboxControllerHash() => r'4ea8085f433df1ea7aa9bd53c74d72fc0f9c376b';

abstract class _$TimeboxController extends $Notifier<int> {
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
