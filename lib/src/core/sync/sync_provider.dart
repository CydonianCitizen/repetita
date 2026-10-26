import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import 'directory_sync_storage_adapter.dart';
import 'file_based_sync_service.dart';

class SyncUIState {
  const SyncUIState({
    this.isSyncing = false,
    this.lastSyncAt,
    this.lastError,
    this.lastPulledCount = 0,
  });

  final bool isSyncing;
  final DateTime? lastSyncAt;
  final String? lastError;
  final int lastPulledCount;

  SyncUIState copyWith({
    bool? isSyncing,
    DateTime? lastSyncAt,
    String? lastError,
    int? lastPulledCount,
  }) {
    return SyncUIState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError,
      lastPulledCount: lastPulledCount ?? this.lastPulledCount,
    );
  }
}

final syncDirectoryPathProvider =
    NotifierProvider<SyncDirectoryNotifier, AsyncValue<String?>>(
      SyncDirectoryNotifier.new,
    );

class SyncDirectoryNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final path = await db.getSetting('sync_directory_path');
    state = AsyncValue.data(path);
  }

  Future<void> setDirectory(String? path) async {
    final db = ref.read(databaseProvider);
    if (path == null || path.isEmpty) {
      await db.setSetting('sync_directory_path', '');
      state = const AsyncValue.data(null);
    } else {
      await db.setSetting('sync_directory_path', path);
      state = AsyncValue.data(path);
    }
  }
}

final syncServiceProvider = FutureProvider<FileBasedSyncService?>((ref) async {
  final dirPathAsync = ref.watch(syncDirectoryPathProvider);
  final dirPath = dirPathAsync.asData?.value;
  if (dirPath == null || dirPath.isEmpty) return null;

  final db = ref.watch(databaseProvider);
  final deviceId = await db.getOrCreateDeviceId();

  final adapter = DirectorySyncStorageAdapter(
    rootDir: Directory(dirPath),
    ownDeviceId: deviceId,
  );

  return FileBasedSyncService(
    db: db,
    storage: adapter,
    localDeviceId: deviceId,
  );
});

final syncStateProvider = NotifierProvider<SyncStateNotifier, SyncUIState>(
  SyncStateNotifier.new,
);

class SyncStateNotifier extends Notifier<SyncUIState> {
  @override
  SyncUIState build() => const SyncUIState();

  Future<SyncSummary?> triggerSync() async {
    if (state.isSyncing) return null;

    final service = await ref.read(syncServiceProvider.future);
    if (service == null) return null;

    state = state.copyWith(isSyncing: true, lastError: null);

    try {
      final summary = await service.sync();
      if (summary.success) {
        state = state.copyWith(
          isSyncing: false,
          lastSyncAt: DateTime.now().toUtc(),
          lastPulledCount: summary.eventsPulled,
          lastError: null,
        );
      } else {
        state = state.copyWith(
          isSyncing: false,
          lastError: summary.errorMessage,
        );
      }
      return summary;
    } catch (e) {
      state = state.copyWith(isSyncing: false, lastError: e.toString());
      return null;
    }
  }
}
