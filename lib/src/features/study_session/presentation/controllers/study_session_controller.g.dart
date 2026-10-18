// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudySessionController)
final studySessionControllerProvider = StudySessionControllerFamily._();

final class StudySessionControllerProvider
    extends $AsyncNotifierProvider<StudySessionController, StudySessionState> {
  StudySessionControllerProvider._({
    required StudySessionControllerFamily super.from,
    required (int, CustomStudyConfig?) super.argument,
  }) : super(
         retry: null,
         name: r'studySessionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studySessionControllerHash();

  @override
  String toString() {
    return r'studySessionControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  StudySessionController create() => StudySessionController();

  @override
  bool operator ==(Object other) {
    return other is StudySessionControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studySessionControllerHash() =>
    r'43c2f917b8892393a9a9b3c02b01e772e148c4ba';

final class StudySessionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudySessionController,
          AsyncValue<StudySessionState>,
          StudySessionState,
          FutureOr<StudySessionState>,
          (int, CustomStudyConfig?)
        > {
  StudySessionControllerFamily._()
    : super(
        retry: null,
        name: r'studySessionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudySessionControllerProvider call(
    int deckId, [
    CustomStudyConfig? customStudyConfig,
  ]) => StudySessionControllerProvider._(
    argument: (deckId, customStudyConfig),
    from: this,
  );

  @override
  String toString() => r'studySessionControllerProvider';
}

abstract class _$StudySessionController
    extends $AsyncNotifier<StudySessionState> {
  late final _$args = ref.$arg as (int, CustomStudyConfig?);
  int get deckId => _$args.$1;
  CustomStudyConfig? get customStudyConfig => _$args.$2;

  FutureOr<StudySessionState> build(
    int deckId, [
    CustomStudyConfig? customStudyConfig,
  ]);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<StudySessionState>, StudySessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StudySessionState>, StudySessionState>,
              AsyncValue<StudySessionState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
