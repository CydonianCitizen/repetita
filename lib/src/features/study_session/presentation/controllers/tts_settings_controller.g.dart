// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TtsSettingsController)
final ttsSettingsControllerProvider = TtsSettingsControllerProvider._();

final class TtsSettingsControllerProvider
    extends $NotifierProvider<TtsSettingsController, TtsSettingsState> {
  TtsSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsSettingsControllerHash();

  @$internal
  @override
  TtsSettingsController create() => TtsSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TtsSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TtsSettingsState>(value),
    );
  }
}

String _$ttsSettingsControllerHash() =>
    r'a165198d85b4095c75f619fdedf1260cdfaa4eaf';

abstract class _$TtsSettingsController extends $Notifier<TtsSettingsState> {
  TtsSettingsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TtsSettingsState, TtsSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TtsSettingsState, TtsSettingsState>,
              TtsSettingsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
