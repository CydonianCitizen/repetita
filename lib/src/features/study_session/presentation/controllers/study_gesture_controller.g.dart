// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_gesture_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyGestureController)
final studyGestureControllerProvider = StudyGestureControllerProvider._();

final class StudyGestureControllerProvider
    extends $NotifierProvider<StudyGestureController, StudyGestureConfig> {
  StudyGestureControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studyGestureControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studyGestureControllerHash();

  @$internal
  @override
  StudyGestureController create() => StudyGestureController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyGestureConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyGestureConfig>(value),
    );
  }
}

String _$studyGestureControllerHash() =>
    r'5bcebbb43bdfb3a69f08e05ab0cf776d54c9d02a';

abstract class _$StudyGestureController extends $Notifier<StudyGestureConfig> {
  StudyGestureConfig build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StudyGestureConfig, StudyGestureConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudyGestureConfig, StudyGestureConfig>,
              StudyGestureConfig,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
