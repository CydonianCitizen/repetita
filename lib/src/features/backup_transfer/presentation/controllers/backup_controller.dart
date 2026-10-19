import 'dart:convert';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/file_picker_service.dart';
import '../../domain/models/anki_models.dart';
import '../../domain/models/backup_payload.dart';

part 'backup_controller.g.dart';

@riverpod
class BackupController extends _$BackupController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String> exportJson() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.exportJsonPayload();
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> importJson(
    String jsonString, {
    bool replaceExisting = true,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(backupServiceProvider);
      await service.importJsonPayload(
        jsonString,
        replaceExisting: replaceExisting,
      );
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<String> exportCsv({int? deckId}) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.exportCardsToCsv(deckId: deckId);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<CsvImportResult> importCsv(
    String csvString, {
    required int targetDeckId,
  }) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.importCardsFromCsv(
        csvString,
        targetDeckId: targetDeckId,
      );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<AnkiImportResult> importAnkiPackage(
    List<int> bytes, {
    int? targetDeckId,
  }) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(ankiPackageServiceProvider);
      final result = await service.importApkgBytes(
        bytes,
        targetDeckId: targetDeckId,
      );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<AnkiImportResult?> pickAndImportAnkiPackage({
    int? targetDeckId,
  }) async {
    final picker = ref.read(filePickerServiceProvider);
    final file = await picker.pickFile(allowedExtensions: ['apkg']);
    if (file == null) return null;
    final bytes = await file.readBytes();
    return importAnkiPackage(bytes, targetDeckId: targetDeckId);
  }

  Future<bool> pickAndImportJson({bool replaceExisting = false}) async {
    final picker = ref.read(filePickerServiceProvider);
    final file = await picker.pickFile(allowedExtensions: ['json']);
    if (file == null) return false;
    final jsonString = await file.readAsString();
    await importJson(jsonString, replaceExisting: replaceExisting);
    return true;
  }

  Future<CsvImportResult?> pickAndImportCsv({required int targetDeckId}) async {
    final picker = ref.read(filePickerServiceProvider);
    final file = await picker.pickFile(allowedExtensions: ['csv']);
    if (file == null) return null;
    final csvString = await file.readAsString();
    return importCsv(csvString, targetDeckId: targetDeckId);
  }

  Future<String?> exportJsonToFile() async {
    final jsonStr = await exportJson();
    final picker = ref.read(filePickerServiceProvider);
    final dateStr = DateTime.now().toIso8601String().split('T').first;
    return picker.saveFile(
      dialogTitle: 'Save Backup JSON',
      fileName: 'repetita_backup_$dateStr.json',
      bytes: Uint8List.fromList(utf8.encode(jsonStr)),
    );
  }

  Future<String?> exportCsvToFile({int? deckId}) async {
    final csvStr = await exportCsv(deckId: deckId);
    final picker = ref.read(filePickerServiceProvider);
    final dateStr = DateTime.now().toIso8601String().split('T').first;
    return picker.saveFile(
      dialogTitle: 'Save Flashcards CSV',
      fileName: 'repetita_cards_$dateStr.csv',
      bytes: Uint8List.fromList(utf8.encode(csvStr)),
    );
  }

  Future<List<int>> exportAnki({
    int? deckId,
    bool includeRevlog = false,
  }) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(ankiExportServiceProvider);
      final result = deckId != null
          ? await service.exportDeckToApkg(deckId, includeRevlog: includeRevlog)
          : await service.exportAllToApkg(includeRevlog: includeRevlog);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<String?> exportAnkiToFile({
    int? deckId,
    String? deckName,
    bool includeRevlog = false,
  }) async {
    final bytes = await exportAnki(
      deckId: deckId,
      includeRevlog: includeRevlog,
    );
    final picker = ref.read(filePickerServiceProvider);
    final dateStr = DateTime.now().toIso8601String().split('T').first;
    final cleanName = deckName != null
        ? 'repetita_${deckName.replaceAll(RegExp(r'[^\w]+'), '_')}'
        : 'repetita_collection';
    return picker.saveFile(
      dialogTitle: 'Save Anki Package (.apkg)',
      fileName: '${cleanName}_$dateStr.apkg',
      bytes: Uint8List.fromList(bytes),
    );
  }
}
