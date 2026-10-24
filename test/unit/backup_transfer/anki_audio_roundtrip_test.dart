import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/backup_transfer/data/services/anki_export_service.dart';
import 'package:repetita/src/features/backup_transfer/data/services/anki_package_service.dart';
import 'package:repetita/src/features/media/data/services/media_service.dart';

void main() {
  late AppDatabase db;
  late Directory tempMediaDir;
  late MediaService mediaService;
  late AnkiExportService exportService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempMediaDir = Directory.systemTemp.createTempSync('repetita_media_test_');
    mediaService = MediaService(
      mediaDao: db.mediaDao,
      mediaDirectory: tempMediaDir,
    );
    exportService = AnkiExportService(db, mediaService: mediaService);
  });

  tearDown(() async {
    await db.close();
    try {
      if (tempMediaDir.existsSync()) {
        tempMediaDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Anki Audio Packaging & Roundtrip Tests', () {
    test('exporting deck with audio packages sound file and media map into .apkg ZIP', () async {
      // 1. Create deck & card with sound tag
      final deckId = await db.decksDao.createDeck(name: 'Audio Deck');
      const soundName = 'test_pronunciation.mp3';
      final dummyAudioBytes = utf8.encode('ID3_DUMMY_MP3_CONTENT');

      // Save media file to media service
      final targetFile = mediaService.getMediaFile(soundName);
      targetFile.writeAsBytesSync(dummyAudioBytes);

      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Word [sound:$soundName]',
        back: 'Translation',
      );

      // 2. Export deck to .apkg
      final apkgBytes = await exportService.exportDeckToApkg(deckId);
      expect(apkgBytes, isNotEmpty);

      // 3. Inspect archive contents
      final archive = ZipDecoder().decodeBytes(apkgBytes);
      ArchiveFile? mediaJsonEntry;
      final filesByName = <String, ArchiveFile>{};
      for (final f in archive) {
        if (f.name == 'media') {
          mediaJsonEntry = f;
        } else {
          filesByName[f.name] = f;
        }
      }

      expect(mediaJsonEntry, isNotNull);
      final mediaMap = jsonDecode(
        utf8.decode(mediaJsonEntry!.content as List<int>),
      ) as Map<String, dynamic>;
      expect(mediaMap.values, contains(soundName));

      final indexKey = mediaMap.entries
          .firstWhere((e) => e.value == soundName)
          .key;
      expect(filesByName.containsKey(indexKey), isTrue);
      expect(filesByName[indexKey]!.content, equals(dummyAudioBytes));
    });

    test('importing .apkg with media map extracts audio file into media directory', () async {
      // 1. Create a minimal valid .apkg archive with SQLite DB and media entry
      final deckId = await db.decksDao.createDeck(name: 'Source Deck');
      const soundName = 'imported_audio.m4a';
      final dummyAudioBytes = utf8.encode('M4A_SAMPLE_BYTES');

      final soundFile = mediaService.getMediaFile(soundName);
      soundFile.writeAsBytesSync(dummyAudioBytes);

      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Phrase [sound:$soundName]',
        back: 'Meaning',
      );

      // Export using exportService which now bundles media
      final apkgBytes = await exportService.exportDeckToApkg(deckId);

      // 2. Clear local media directory & DB
      soundFile.deleteSync();
      expect(soundFile.existsSync(), isFalse);

      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      final mediaService2 = MediaService(
        mediaDao: db2.mediaDao,
        mediaDirectory: tempMediaDir,
      );
      final packageService2 = AnkiPackageService(
        db2,
        mediaService: mediaService2,
      );

      // 3. Import package into new DB
      final result = await packageService2.importApkgBytes(apkgBytes);
      expect(result.cardsImported, equals(1));

      // 4. Verify sound file extracted
      final extractedFile = mediaService2.getMediaFile(soundName);
      expect(extractedFile.existsSync(), isTrue);
      expect(extractedFile.readAsBytesSync(), equals(dummyAudioBytes));

      await db2.close();
    });
  });
}
