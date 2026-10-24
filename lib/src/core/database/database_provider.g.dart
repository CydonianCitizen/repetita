// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ankiExportService)
final ankiExportServiceProvider = AnkiExportServiceProvider._();

final class AnkiExportServiceProvider
    extends
        $FunctionalProvider<
          AnkiExportService,
          AnkiExportService,
          AnkiExportService
        >
    with $Provider<AnkiExportService> {
  AnkiExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ankiExportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ankiExportServiceHash();

  @$internal
  @override
  $ProviderElement<AnkiExportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnkiExportService create(Ref ref) {
    return ankiExportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnkiExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnkiExportService>(value),
    );
  }
}

String _$ankiExportServiceHash() => r'0650200cbe8122492eedc68b20f27ce64d2c0c25';

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

final class DatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$databaseHash() => r'0fe56aaf5bde72ce9021e425b918c495557124c1';

@ProviderFor(decksDao)
final decksDaoProvider = DecksDaoProvider._();

final class DecksDaoProvider
    extends $FunctionalProvider<DecksDao, DecksDao, DecksDao>
    with $Provider<DecksDao> {
  DecksDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'decksDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$decksDaoHash();

  @$internal
  @override
  $ProviderElement<DecksDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DecksDao create(Ref ref) {
    return decksDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DecksDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DecksDao>(value),
    );
  }
}

String _$decksDaoHash() => r'30897c928283b1167366d77ea72dcca748fc31d6';

@ProviderFor(cardsDao)
final cardsDaoProvider = CardsDaoProvider._();

final class CardsDaoProvider
    extends $FunctionalProvider<CardsDao, CardsDao, CardsDao>
    with $Provider<CardsDao> {
  CardsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardsDaoHash();

  @$internal
  @override
  $ProviderElement<CardsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CardsDao create(Ref ref) {
    return cardsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardsDao>(value),
    );
  }
}

String _$cardsDaoHash() => r'895c6723a1f338d7967d87da368ac75f0875e787';

@ProviderFor(studySessionDao)
final studySessionDaoProvider = StudySessionDaoProvider._();

final class StudySessionDaoProvider
    extends
        $FunctionalProvider<StudySessionDao, StudySessionDao, StudySessionDao>
    with $Provider<StudySessionDao> {
  StudySessionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studySessionDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studySessionDaoHash();

  @$internal
  @override
  $ProviderElement<StudySessionDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudySessionDao create(Ref ref) {
    return studySessionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudySessionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudySessionDao>(value),
    );
  }
}

String _$studySessionDaoHash() => r'2a218a1678e4d081ee63b53a4f79e00a197ea400';

@ProviderFor(statsDao)
final statsDaoProvider = StatsDaoProvider._();

final class StatsDaoProvider
    extends $FunctionalProvider<StatsDao, StatsDao, StatsDao>
    with $Provider<StatsDao> {
  StatsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsDaoHash();

  @$internal
  @override
  $ProviderElement<StatsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsDao create(Ref ref) {
    return statsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsDao>(value),
    );
  }
}

String _$statsDaoHash() => r'0dc7aa129f9ed1a03ac603adf4894c3c148b7a3a';

@ProviderFor(tagsDao)
final tagsDaoProvider = TagsDaoProvider._();

final class TagsDaoProvider
    extends $FunctionalProvider<TagsDao, TagsDao, TagsDao>
    with $Provider<TagsDao> {
  TagsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagsDaoHash();

  @$internal
  @override
  $ProviderElement<TagsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagsDao create(Ref ref) {
    return tagsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagsDao>(value),
    );
  }
}

String _$tagsDaoHash() => r'caeb7b9a777c785f6eb216a680197de9e1db1cb8';

@ProviderFor(mediaDao)
final mediaDaoProvider = MediaDaoProvider._();

final class MediaDaoProvider
    extends $FunctionalProvider<MediaDao, MediaDao, MediaDao>
    with $Provider<MediaDao> {
  MediaDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaDaoHash();

  @$internal
  @override
  $ProviderElement<MediaDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaDao create(Ref ref) {
    return mediaDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaDao>(value),
    );
  }
}

String _$mediaDaoHash() => r'b4060778524d36c2ddcc0d4aab746e10b4c937c4';

@ProviderFor(mediaService)
final mediaServiceProvider = MediaServiceProvider._();

final class MediaServiceProvider
    extends $FunctionalProvider<MediaService, MediaService, MediaService>
    with $Provider<MediaService> {
  MediaServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaServiceHash();

  @$internal
  @override
  $ProviderElement<MediaService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaService create(Ref ref) {
    return mediaService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaService>(value),
    );
  }
}

String _$mediaServiceHash() => r'e831e6d17038e9da4e9f576a922e76ee1e53afc4';

@ProviderFor(backupService)
final backupServiceProvider = BackupServiceProvider._();

final class BackupServiceProvider
    extends $FunctionalProvider<BackupService, BackupService, BackupService>
    with $Provider<BackupService> {
  BackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupServiceHash();

  @$internal
  @override
  $ProviderElement<BackupService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupService create(Ref ref) {
    return backupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupService>(value),
    );
  }
}

String _$backupServiceHash() => r'0c0fa92bf66179c32f39f95b2278dbdcd18408a3';

@ProviderFor(rollingBackupService)
final rollingBackupServiceProvider = RollingBackupServiceProvider._();

final class RollingBackupServiceProvider
    extends
        $FunctionalProvider<
          RollingBackupService,
          RollingBackupService,
          RollingBackupService
        >
    with $Provider<RollingBackupService> {
  RollingBackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rollingBackupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rollingBackupServiceHash();

  @$internal
  @override
  $ProviderElement<RollingBackupService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RollingBackupService create(Ref ref) {
    return rollingBackupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RollingBackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RollingBackupService>(value),
    );
  }
}

String _$rollingBackupServiceHash() =>
    r'db8c0bb510c5cb6dede3febbfb5e0fe696a1032d';

@ProviderFor(vacationModeService)
final vacationModeServiceProvider = VacationModeServiceProvider._();

final class VacationModeServiceProvider
    extends
        $FunctionalProvider<
          VacationModeService,
          VacationModeService,
          VacationModeService
        >
    with $Provider<VacationModeService> {
  VacationModeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vacationModeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vacationModeServiceHash();

  @$internal
  @override
  $ProviderElement<VacationModeService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VacationModeService create(Ref ref) {
    return vacationModeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VacationModeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VacationModeService>(value),
    );
  }
}

String _$vacationModeServiceHash() =>
    r'f617fdec504756b403539e8d25d92a8d8b33e977';

@ProviderFor(ankiPackageService)
final ankiPackageServiceProvider = AnkiPackageServiceProvider._();

final class AnkiPackageServiceProvider
    extends
        $FunctionalProvider<
          AnkiPackageService,
          AnkiPackageService,
          AnkiPackageService
        >
    with $Provider<AnkiPackageService> {
  AnkiPackageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ankiPackageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ankiPackageServiceHash();

  @$internal
  @override
  $ProviderElement<AnkiPackageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnkiPackageService create(Ref ref) {
    return ankiPackageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnkiPackageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnkiPackageService>(value),
    );
  }
}

String _$ankiPackageServiceHash() =>
    r'203f0f42ba1880a70865e0282f1b44778805808f';
