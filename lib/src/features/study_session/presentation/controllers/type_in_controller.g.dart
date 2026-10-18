// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TypeInPracticeController)
final typeInPracticeControllerProvider = TypeInPracticeControllerProvider._();

final class TypeInPracticeControllerProvider
    extends $NotifierProvider<TypeInPracticeController, bool> {
  TypeInPracticeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'typeInPracticeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$typeInPracticeControllerHash();

  @$internal
  @override
  TypeInPracticeController create() => TypeInPracticeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$typeInPracticeControllerHash() =>
    r'49351fd5fa0cde72d305f482df668335ad352e8c';

abstract class _$TypeInPracticeController extends $Notifier<bool> {
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
