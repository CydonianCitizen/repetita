import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:repetita/src/core/algorithms/image_occlusion/image_occlusion_box.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/cards/presentation/image_occlusion_editor_screen.dart';
import 'package:repetita/src/features/media/data/services/media_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('repetita_io_editor_test_');
    db = AppDatabase.forTesting(NativeDatabase.memory());

    // Write a dummy PNG
    final dummyBytes = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ]);
    final imageFile = File(p.join(tempDir.path, 'sample.png'));
    imageFile.writeAsBytesSync(dummyBytes);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget buildTestScreen({
    required int deckId,
    required String mediaReference,
    List<ImageOcclusionBox>? initialBoxes,
  }) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        mediaServiceProvider.overrideWithValue(
          MediaService(mediaDao: db.mediaDao, mediaDirectory: tempDir),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ImageOcclusionEditorScreen(
          deckId: deckId,
          mediaReference: mediaReference,
          initialBoxes: initialBoxes,
        ),
      ),
    );
  }

  testWidgets(
    'ImageOcclusionEditorScreen renders header, initial boxes and supports undo and clear',
    (tester) async {
      final boxes = [
        const ImageOcclusionBox(
          id: 'box_1',
          x: 0.1,
          y: 0.1,
          width: 0.3,
          height: 0.2,
          label: 'Anatomy 1',
        ),
        const ImageOcclusionBox(
          id: 'box_2',
          x: 0.5,
          y: 0.5,
          width: 0.2,
          height: 0.3,
          label: 'Anatomy 2',
        ),
      ];

      await tester.pumpWidget(
        buildTestScreen(
          deckId: 1,
          mediaReference: 'sample.png',
          initialBoxes: boxes,
        ),
      );
      await tester.pump();

      // Verify canvas painter rendered with 2 boxes
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('2 masks (2 cards)'), findsOneWidget);

      // Test Undo
      final undoButton = find.byKey(const Key('undo_occlusion_button'));
      expect(undoButton, findsOneWidget);
      await tester.tap(undoButton);
      await tester.pump();

      expect(find.text('1 mask (1 card)'), findsOneWidget);

      // Test Clear
      final clearButton = find.byKey(const Key('clear_occlusion_button'));
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      expect(find.text('No masks'), findsOneWidget);
    },
  );
}
