import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/backup_transfer/data/services/anki_package_service.dart';
import '../../features/backup_transfer/data/services/backup_service.dart';
import '../../features/backup_transfer/data/services/rolling_backup_service.dart';
import '../../features/cards/data/cards_dao.dart';
import '../../features/decks/data/decks_dao.dart';
import '../../features/stats/data/stats_dao.dart';
import '../../features/study_session/data/study_session_dao.dart';
import '../../features/tags/data/tags_dao.dart';
import '../../features/settings/domain/vacation_mode_service.dart';
import 'app_database.dart';

part 'database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
DecksDao decksDao(Ref ref) => ref.watch(databaseProvider).decksDao;

@Riverpod(keepAlive: true)
CardsDao cardsDao(Ref ref) => ref.watch(databaseProvider).cardsDao;

@Riverpod(keepAlive: true)
StudySessionDao studySessionDao(Ref ref) =>
    ref.watch(databaseProvider).studySessionDao;

@Riverpod(keepAlive: true)
StatsDao statsDao(Ref ref) => ref.watch(databaseProvider).statsDao;

@Riverpod(keepAlive: true)
TagsDao tagsDao(Ref ref) => ref.watch(databaseProvider).tagsDao;

@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) =>
    BackupService(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
RollingBackupService rollingBackupService(Ref ref) => RollingBackupService(
  backupService: ref.watch(backupServiceProvider),
  db: ref.watch(databaseProvider),
);

@Riverpod(keepAlive: true)
VacationModeService vacationModeService(Ref ref) =>
    VacationModeService(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
AnkiPackageService ankiPackageService(Ref ref) =>
    AnkiPackageService(ref.watch(databaseProvider));
