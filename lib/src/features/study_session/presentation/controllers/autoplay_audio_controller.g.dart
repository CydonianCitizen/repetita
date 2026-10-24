// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autoplay_audio_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AutoPlayAudioController)
final autoPlayAudioControllerProvider = AutoPlayAudioControllerProvider._();

final class AutoPlayAudioControllerProvider
    extends $NotifierProvider<AutoPlayAudioController, bool> {
  AutoPlayAudioControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoPlayAudioControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoPlayAudioControllerHash();

  @$internal
  @override
  AutoPlayAudioController create() => AutoPlayAudioController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$autoPlayAudioControllerHash() =>
    r'f97def50afcb8c84d792fbd18bbb397264f6483d';

abstract class _$AutoPlayAudioController extends $Notifier<bool> {
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
