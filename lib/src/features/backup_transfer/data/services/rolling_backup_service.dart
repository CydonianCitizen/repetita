import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import 'backup_service.dart';

class RollingBackupService {
  RollingBackupService({
    required this.backupService,
    required this.db,
    this.backupDir,
  });

  final BackupService backupService;
  final AppDatabase db;
  final Directory? backupDir;

  static const String keyLastAutoBackup = 'last_auto_backup_timestamp';

  Future<Directory> _resolveDirectory() async {
    if (backupDir != null) {
      if (!backupDir!.existsSync()) {
        backupDir!.createSync(recursive: true);
      }
      return backupDir!;
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    final autoBackupDir = Directory(p.join(appDocDir.path, 'backups', 'auto'));
    if (!autoBackupDir.existsSync()) {
      autoBackupDir.createSync(recursive: true);
    }
    return autoBackupDir;
  }

  Future<File?> checkAndPerformAutoBackup({
    int intervalHours = 5,
    int retentionCount = 8,
    DateTime? now,
  }) async {
    final effectiveNow = (now ?? DateTime.now()).toUtc();
    final lastBackupStr = await db.getSetting(keyLastAutoBackup);

    if (lastBackupStr != null && lastBackupStr.isNotEmpty) {
      final lastDate = DateTime.tryParse(lastBackupStr)?.toUtc();
      if (lastDate != null) {
        final diff = effectiveNow.difference(lastDate);
        if (!diff.isNegative && diff.inHours < intervalHours) {
          return null;
        }
      }
    }

    final dir = await _resolveDirectory();
    final dateStr = effectiveNow.toIso8601String().replaceAll(':', '-');
    final backupFile = File(p.join(dir.path, 'backup_$dateStr.json'));

    final payloadJson = await backupService.exportJsonPayload(
      now: effectiveNow,
    );
    await backupFile.writeAsString(payloadJson);

    await db.setSetting(keyLastAutoBackup, effectiveNow.toIso8601String());

    await _enforceRetention(dir, retentionCount);

    return backupFile;
  }

  Future<void> _enforceRetention(Directory dir, int maxCount) async {
    final backups = await listAutoBackups();
    if (backups.length <= maxCount) return;

    // backups is sorted newest to oldest. Oldest are at the end.
    final filesToDelete = backups.sublist(maxCount);
    for (final file in filesToDelete) {
      try {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
  }

  static Future<List<File>> getAutoBackups({Directory? backupDir}) async {
    Directory dir;
    if (backupDir != null) {
      dir = backupDir;
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      dir = Directory(p.join(appDocDir.path, 'backups', 'auto'));
    }
    if (!dir.existsSync()) return [];

    final files = dir
        .listSync()
        .whereType<File>()
        .where(
          (f) =>
              p.basename(f.path).startsWith('backup_') &&
              f.path.endsWith('.json'),
        )
        .toList();

    files.sort((a, b) => b.path.compareTo(a.path)); // Newest first
    return files;
  }

  Future<List<File>> listAutoBackups() async {
    final dir = await _resolveDirectory();
    return getAutoBackups(backupDir: dir);
  }
}
