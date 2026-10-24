import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/media/data/media_dao.dart';
import 'package:repetita/src/features/media/data/services/media_service.dart';
import 'package:repetita/src/features/media/presentation/dialogs/image_viewer_dialog.dart';
import 'package:repetita/src/features/media/presentation/widgets/media_image_widget.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late MediaService mediaService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('media_widget_test_');
    mediaService = MediaService(
      mediaDao: MediaDao(db),
      mediaDirectory: tempDir,
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget createSubject(String ref) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        mediaServiceProvider.overrideWithValue(mediaService),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MediaImageWidget(mediaReference: ref)),
      ),
    );
  }

  group('MediaImageWidget Tests', () {
    testWidgets('displays error fallback when image file is missing', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject('non_existent.png'));
      await tester.pump();

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(find.text('Image not found'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('renders image and zoom indicator', (tester) async {
      final pngBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );

      final media = await mediaService.saveImageBytes(
        pngBytes,
        originalFileName: 'pixel.png',
      );

      await tester.pumpWidget(createSubject(media.fileName));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.zoom_in), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('ImageViewerDialog renders image and close button', (
      tester,
    ) async {
      final pngBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );
      final media = await mediaService.saveImageBytes(
        pngBytes,
        originalFileName: 'pixel.png',
      );
      final file = mediaService.getMediaFile(media.fileName);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ImageViewerDialog(imageFile: file)),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('close_image_viewer_button')),
        findsOneWidget,
      );
      expect(find.byType(Image), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}
