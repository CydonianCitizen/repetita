import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [Media])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  Future<int> insertMedia(MediaCompanion mediaEntry) {
    return into(media).insert(mediaEntry);
  }

  Future<MediaData?> getMediaByChecksum(String checksum) {
    return (select(
      media,
    )..where((t) => t.checksum.equals(checksum))).getSingleOrNull();
  }

  Future<MediaData?> getMediaByFileName(String fileName) {
    return (select(
      media,
    )..where((t) => t.fileName.equals(fileName))).getSingleOrNull();
  }

  Future<MediaData?> getMediaById(int id) {
    return (select(media)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<MediaData>> getAllMedia() {
    return select(media).get();
  }

  Stream<List<MediaData>> watchAllMedia() {
    return select(media).watch();
  }

  Future<int> deleteMedia(int id) {
    return (delete(media)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteMediaByFileName(String fileName) {
    return (delete(media)..where((t) => t.fileName.equals(fileName))).go();
  }
}
