import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/backup_transfer/data/services/backup_service.dart';
import 'package:repetita/src/features/backup_transfer/data/services/rolling_backup_service.dart';

void main() {
  late AppDatabase db;
  late BackupService backupService;
  late Directory tempDir;
  late RollingBackupService rollingService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    backupService = BackupService(db);
    tempDir = Directory.systemTemp.createTempSync('rolling_test_');
    rollingService = RollingBackupService(
      backupService: backupService,
      db: db,
      backupDir: tempDir,
    );

    await db.decksDao.createDeck(name: 'Rolling Test Deck');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('RollingBackupService Tests', () {
    test(
      'checkAndPerformAutoBackup creates initial backup and updates setting',
      () async {
        final now = DateTime.utc(2026, 10, 1, 12, 0, 0);
        final created = await rollingService.checkAndPerformAutoBackup(
          now: now,
        );

        expect(created, isNotNull);
        expect(created!.existsSync(), isTrue);

        final backups = await rollingService.listAutoBackups();
        expect(backups, hasLength(1));

        final lastTimestamp = await db.getSetting('last_auto_backup_timestamp');
        expect(lastTimestamp, equals(now.toIso8601String()));
      },
    );

    test(
      'checkAndPerformAutoBackup skips backup if interval has not elapsed',
      () async {
        final now = DateTime.utc(2026, 10, 1, 12, 0, 0);
        await rollingService.checkAndPerformAutoBackup(now: now);

        // 2 hours later (interval is 5 hours)
        final twoHoursLater = now.add(const Duration(hours: 2));
        final skipped = await rollingService.checkAndPerformAutoBackup(
          now: twoHoursLater,
          intervalHours: 5,
        );

        expect(skipped, isNull);
        final backups = await rollingService.listAutoBackups();
        expect(backups, hasLength(1));
      },
    );

    test('enforces FIFO retention policy deleting oldest files', () async {
      var currentTime = DateTime.utc(2026, 10, 1, 0, 0, 0);

      // Create 5 backups with retentionCount = 3
      for (int i = 0; i < 5; i++) {
        await rollingService.checkAndPerformAutoBackup(
          now: currentTime,
          intervalHours: 1,
          retentionCount: 3,
        );
        currentTime = currentTime.add(const Duration(hours: 6));
      }

      final remaining = await rollingService.listAutoBackups();
      expect(remaining, hasLength(3));
    });

    test('checkAndPerformAutoBackup heals when clock drifts backwards into the past', () async {
      final futureTime = DateTime.utc(2026, 10, 5, 12, 0, 0);
      await rollingService.checkAndPerformAutoBackup(now: futureTime);

      // System clock jumped backward
      final pastTime = DateTime.utc(2026, 10, 1, 12, 0, 0);
      final backup = await rollingService.checkAndPerformAutoBackup(
        now: pastTime,
      );

      expect(backup, isNotNull);
      final lastTimestamp = await db.getSetting('last_auto_backup_timestamp');
      expect(lastTimestamp, equals(pastTime.toIso8601String()));
    });
  });
}
