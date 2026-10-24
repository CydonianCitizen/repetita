// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StatsController)
final statsControllerProvider = StatsControllerFamily._();

final class StatsControllerProvider
    extends $AsyncNotifierProvider<StatsController, StatsData> {
  StatsControllerProvider._({
    required StatsControllerFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'statsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statsControllerHash();

  @override
  String toString() {
    return r'statsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StatsController create() => StatsController();

  @override
  bool operator ==(Object other) {
    return other is StatsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statsControllerHash() => r'a42ee21f111ec12d6244ccf52516414b2e621ca2';

final class StatsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StatsController,
          AsyncValue<StatsData>,
          StatsData,
          FutureOr<StatsData>,
          int?
        > {
  StatsControllerFamily._()
    : super(
        retry: null,
        name: r'statsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StatsControllerProvider call({int? deckId}) =>
      StatsControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'statsControllerProvider';
}

abstract class _$StatsController extends $AsyncNotifier<StatsData> {
  late final _$args = ref.$arg as int?;
  int? get deckId => _$args;

  FutureOr<StatsData> build({int? deckId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StatsData>, StatsData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StatsData>, StatsData>,
              AsyncValue<StatsData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(deckId: _$args));
  }
}
