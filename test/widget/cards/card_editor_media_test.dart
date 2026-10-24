import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/cards/presentation/card_editor_screen.dart';
import 'package:repetita/src/features/media/presentation/widgets/media_image_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync(
      'repetita_editor_media_test_',
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget buildTestApp({
    required int deckId,
    String? initialFront,
    String? initialBack,
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CardEditorScreen(
          deckId: deckId,
          initialFront: initialFront,
          initialBack: initialBack,
        ),
      ),
    );
  }

  testWidgets(
    'CardEditorScreen displays image insert chips and renders thumbnail when media present',
    (tester) async {
      // Write a dummy test image to tempDir
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
      final imageFile = File(p.join(tempDir.path, 'test_sample.png'));
      imageFile.writeAsBytesSync(dummyBytes);

      await tester.pumpWidget(
        buildTestApp(
          deckId: 1,
          initialFront: 'Prompt with ![alt](media://test_sample.png)',
          initialBack: 'Answer text',
        ),
      );
      await tester.pump();

      // Verify insert chips exist
      expect(find.byKey(const Key('insert_image_button')), findsOneWidget);
      expect(find.byKey(const Key('insert_image_back_button')), findsOneWidget);

      // Verify thumbnail preview widget exists for the front field
      expect(find.byType(MediaImageWidget), findsWidgets);
    },
  );
}
