import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/media/data/media_dao.dart';

void main() {
  late AppDatabase db;
  late MediaDao mediaDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mediaDao = MediaDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('MediaDao Unit Tests', () {
    test('inserts and retrieves media by id, checksum, and filename', () async {
      final checksum = 'a' * 64;
      final id = await mediaDao.insertMedia(
        MediaCompanion.insert(
          fileName: 'test_image.png',
          checksum: checksum,
          sizeBytes: 1024,
        ),
      );

      expect(id, isPositive);

      final byId = await mediaDao.getMediaById(id);
      expect(byId, isNotNull);
      expect(byId!.fileName, 'test_image.png');
      expect(byId.checksum, checksum);
      expect(byId.sizeBytes, 1024);

      final byChecksum = await mediaDao.getMediaByChecksum(checksum);
      expect(byChecksum, isNotNull);
      expect(byChecksum!.id, id);

      final byName = await mediaDao.getMediaByFileName('test_image.png');
      expect(byName, isNotNull);
      expect(byName!.id, id);
    });

    test('deletes media by id and filename', () async {
      final id1 = await mediaDao.insertMedia(
        MediaCompanion.insert(
          fileName: 'img1.png',
          checksum: 'b' * 64,
          sizeBytes: 500,
        ),
      );
      final id2 = await mediaDao.insertMedia(
        MediaCompanion.insert(
          fileName: 'img2.png',
          checksum: 'c' * 64,
          sizeBytes: 600,
        ),
      );

      final countBefore = await mediaDao.getAllMedia();
      expect(countBefore.length, 2);

      await mediaDao.deleteMedia(id1);
      expect(await mediaDao.getMediaById(id1), isNull);

      await mediaDao.deleteMediaByFileName('img2.png');
      expect(await mediaDao.getMediaById(id2), isNull);

      final countAfter = await mediaDao.getAllMedia();
      expect(countAfter, isEmpty);
    });
  });
}
