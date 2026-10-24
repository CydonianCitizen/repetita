import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../media_dao.dart';

class MediaService {
  MediaService({required this.mediaDao, this.mediaDirectory});

  final MediaDao mediaDao;
  Directory? mediaDirectory;

  Future<Directory> getMediaDirectory() async {
    if (mediaDirectory != null) {
      if (!mediaDirectory!.existsSync()) {
        mediaDirectory!.createSync(recursive: true);
      }
      return mediaDirectory!;
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(appDocDir.path, 'media'));
    if (!mediaDir.existsSync()) {
      mediaDir.createSync(recursive: true);
    }
    mediaDirectory = mediaDir;
    return mediaDir;
  }

  /// Calculates SHA-256 checksum string for given [bytes].
  String computeChecksum(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Saves image bytes to disk with SHA-256 deduplication.
  ///
  /// Returns the saved [MediaData] entity.
  Future<MediaData> saveImageBytes(
    Uint8List bytes, {
    required String originalFileName,
  }) async {
    final checksum = computeChecksum(bytes);

    // Check if media with identical checksum already exists
    final existing = await mediaDao.getMediaByChecksum(checksum);
    if (existing != null) {
      final existingFile = getMediaFile(existing.fileName);
      if (existingFile.existsSync()) {
        return existing;
      }
    }

    final ext = p.extension(originalFileName).toLowerCase();
    final sanitizedExt = ext.isNotEmpty ? ext : '.png';
    final fileName = '${checksum.substring(0, 16)}$sanitizedExt';

    await getMediaDirectory();
    final targetFile = getMediaFile(fileName);
    targetFile.writeAsBytesSync(bytes);

    final mediaId = await mediaDao.insertMedia(
      MediaCompanion.insert(
        fileName: fileName,
        checksum: checksum,
        sizeBytes: bytes.length,
      ),
    );

    return (await mediaDao.getMediaById(mediaId))!;
  }

  /// Saves audio bytes to disk with SHA-256 deduplication.
  ///
  /// Returns the saved [MediaData] entity.
  Future<MediaData> saveAudioBytes(
    Uint8List bytes, {
    required String originalFileName,
  }) async {
    final checksum = computeChecksum(bytes);

    final existing = await mediaDao.getMediaByChecksum(checksum);
    if (existing != null) {
      final existingFile = getMediaFile(existing.fileName);
      if (existingFile.existsSync()) {
        return existing;
      }
    }

    final ext = p.extension(originalFileName).toLowerCase();
    final sanitizedExt = ext.isNotEmpty ? ext : '.m4a';
    final fileName = '${checksum.substring(0, 16)}$sanitizedExt';

    await getMediaDirectory();
    final targetFile = getMediaFile(fileName);
    targetFile.writeAsBytesSync(bytes);

    final mediaId = await mediaDao.insertMedia(
      MediaCompanion.insert(
        fileName: fileName,
        checksum: checksum,
        sizeBytes: bytes.length,
      ),
    );

    return (await mediaDao.getMediaById(mediaId))!;
  }

  /// Resolves a file reference (e.g. "image.png" or "media://image.png") to a local File synchronously.
  File getMediaFile(String mediaReference) {
    final cleanName = mediaReference.startsWith('media://')
        ? mediaReference.substring('media://'.length)
        : mediaReference;

    if (mediaDirectory != null) {
      return File(p.join(mediaDirectory!.path, cleanName));
    }
    return File(cleanName);
  }

  /// Deletes a media file and database entry.
  Future<void> deleteMedia(int id) async {
    final media = await mediaDao.getMediaById(id);
    if (media != null) {
      final file = getMediaFile(media.fileName);
      if (file.existsSync()) {
        file.deleteSync();
      }
      await mediaDao.deleteMedia(id);
    }
  }
}
