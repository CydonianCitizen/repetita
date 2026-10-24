import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:repetita/src/core/algorithms/image_occlusion/image_occlusion_box.dart';
import 'package:repetita/src/core/algorithms/image_occlusion/image_occlusion_parser.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/cards/domain/card_entity.dart';
import 'package:repetita/src/features/media/data/services/media_service.dart';
import 'package:repetita/src/features/study_session/presentation/widgets/flip_card_view.dart';
import 'package:repetita/src/features/study_session/presentation/widgets/image_occlusion_card_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('repetita_io_study_test_');
    db = AppDatabase.forTesting(NativeDatabase.memory());

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
    final imageFile = File(p.join(tempDir.path, 'brain.png'));
    imageFile.writeAsBytesSync(dummyBytes);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets(
    'FlipCardView renders ImageOcclusionCardView and reveals active answer label on flip',
    (tester) async {
      final boxes = [
        const ImageOcclusionBox(
          id: 'box_1',
          x: 0.1,
          y: 0.1,
          width: 0.3,
          height: 0.2,
          label: 'Frontal Lobe',
        ),
        const ImageOcclusionBox(
          id: 'box_2',
          x: 0.5,
          y: 0.5,
          width: 0.3,
          height: 0.2,
          label: 'Occipital Lobe',
        ),
      ];

      final ioPrompt = ImageOcclusionParser.encode(
        mediaReference: 'brain.png',
        activeBoxId: 'box_1',
        boxes: boxes,
      );

      final card = CardEntity(
        id: 101,
        deckId: 1,
        front: ioPrompt,
        back: 'Extra notes on the brain',
        state: 0,
        stability: 1.0,
        difficulty: 5.0,
        due: DateTime.now(),
        reps: 0,
        lapses: 0,
        createdAt: DateTime.now(),
      );

      // 1. Initial front (unrevealed)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            mediaServiceProvider.overrideWithValue(
              MediaService(mediaDao: db.mediaDao, mediaDirectory: tempDir),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: FlipCardView(card: card, isAnswerRevealed: false),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify ImageOcclusionCardView is mounted
      expect(find.byType(ImageOcclusionCardView), findsOneWidget);
      expect(find.text('IMAGE OCCLUSION'), findsOneWidget);
      // Answer label should not be visible before reveal
      expect(find.byKey(const Key('occlusion_revealed_label')), findsNothing);

      // 2. Flip to revealed back
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            mediaServiceProvider.overrideWithValue(
              MediaService(mediaDao: db.mediaDao, mediaDirectory: tempDir),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: FlipCardView(card: card, isAnswerRevealed: true),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Answer banner with active box label is revealed
      expect(find.byKey(const Key('occlusion_revealed_label')), findsOneWidget);
      expect(find.text('Frontal Lobe'), findsOneWidget);
    },
  );
}
