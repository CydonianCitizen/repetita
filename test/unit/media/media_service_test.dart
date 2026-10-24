import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/media/data/media_dao.dart';
import 'package:repetita/src/features/media/data/services/media_service.dart';

void main() {
  late AppDatabase db;
  late MediaDao mediaDao;
  late Directory tempDir;
  late MediaService mediaService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mediaDao = MediaDao(db);
    tempDir = await Directory.systemTemp.createTemp('repetita_media_test_');
    mediaService = MediaService(mediaDao: mediaDao, mediaDirectory: tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('MediaService Unit Tests', () {
    test('computes deterministic SHA-256 checksum', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final hash1 = mediaService.computeChecksum(bytes);
      final hash2 = mediaService.computeChecksum(bytes);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64));
    });

    test('saves image bytes and deduplicates identical contents', () async {
      final imageBytes = Uint8List.fromList([10, 20, 30, 40, 50, 60]);

      final media1 = await mediaService.saveImageBytes(
        imageBytes,
        originalFileName: 'photo.jpg',
      );

      expect(media1.id, isPositive);
      expect(media1.sizeBytes, 6);
      expect(media1.fileName.endsWith('.jpg'), isTrue);

      final file1 = mediaService.getMediaFile(media1.fileName);
      expect(await file1.exists(), isTrue);

      // Attempt to save identical bytes with a different name
      final media2 = await mediaService.saveImageBytes(
        imageBytes,
        originalFileName: 'duplicate.jpg',
      );

      // Should return the exact same entity and file, avoiding duplicate storage
      expect(media2.id, equals(media1.id));
      expect(media2.fileName, equals(media1.fileName));

      final allRecords = await mediaDao.getAllMedia();
      expect(allRecords.length, 1);
    });

    test('deletes media record and physical file from disk', () async {
      final bytes = Uint8List.fromList([100, 101, 102]);
      final media = await mediaService.saveImageBytes(
        bytes,
        originalFileName: 'to_delete.png',
      );

      final file = mediaService.getMediaFile(media.fileName);
      expect(await file.exists(), isTrue);

      await mediaService.deleteMedia(media.id);

      expect(await mediaDao.getMediaById(media.id), isNull);
      expect(await file.exists(), isFalse);
    });
  });
}
