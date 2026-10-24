import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../media_dao.dart';

class MediaService {
  MediaService({
    required this.mediaDao,
    Directory? mediaDirectory,
  }) : _mediaDirectoryOverride = mediaDirectory;

  final MediaDao mediaDao;
  final Directory? _mediaDirectoryOverride;

  Future<Directory> getMediaDirectory() async {
    if (_mediaDirectoryOverride != null) {
      if (!await _mediaDirectoryOverride.exists()) {
        await _mediaDirectoryOverride.create(recursive: true);
      }
      return _mediaDirectoryOverride;
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(appDocDir.path, 'media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
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
      final mediaDir = await getMediaDirectory();
      final existingFile = File(p.join(mediaDir.path, existing.fileName));
      if (await existingFile.exists()) {
        return existing;
      }
    }

    final ext = p.extension(originalFileName).toLowerCase();
    final sanitizedExt = ext.isNotEmpty ? ext : '.png';
    final fileName = '${checksum.substring(0, 16)}$sanitizedExt';

    final mediaDir = await getMediaDirectory();
    final targetFile = File(p.join(mediaDir.path, fileName));
    await targetFile.writeAsBytes(bytes);

    final mediaId = await mediaDao.insertMedia(
      MediaCompanion.insert(
        fileName: fileName,
        checksum: checksum,
        sizeBytes: bytes.length,
      ),
    );

    return (await mediaDao.getMediaById(mediaId))!;
  }

  /// Imports an image file into media storage.
  Future<MediaData> saveImageFile(File file) async {
    final bytes = await file.readAsBytes();
    final name = p.basename(file.path);
    return saveImageBytes(bytes, originalFileName: name);
  }

  /// Resolves a file reference (e.g. "image.png" or "media://image.png") to a local File.
  Future<File> getMediaFile(String mediaReference) async {
    final cleanName = mediaReference.startsWith('media://')
        ? mediaReference.substring('media://'.length)
        : mediaReference;
    final mediaDir = await getMediaDirectory();
    return File(p.join(mediaDir.path, cleanName));
  }

  /// Deletes a media file and database entry.
  Future<void> deleteMedia(int id) async {
    final media = await mediaDao.getMediaById(id);
    if (media != null) {
      final file = await getMediaFile(media.fileName);
      if (await file.exists()) {
        await file.delete();
      }
      await mediaDao.deleteMedia(id);
    }
  }
}
