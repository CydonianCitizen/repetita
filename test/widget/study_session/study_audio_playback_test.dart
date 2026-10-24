import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/cards/presentation/widgets/audio_player_chip.dart';
import 'package:repetita/src/features/cards/presentation/widgets/card_content_renderer.dart';

void main() {
  group('Study Audio Playback Tests', () {
    testWidgets('CardContentRenderer renders AudioPlayerChip for sound tags', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CardContentRenderer(
                content: 'Listen: [sound:sample_audio.mp3] and repeat.',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AudioPlayerChip), findsOneWidget);
      expect(find.text('sample_audio.mp3'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });

    testWidgets('AudioPlayerChip displays speaker icon and handles taps', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AudioPlayerChip(audioReference: 'test_sound.m4a'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chipFinder = find.byType(ActionChip);
      expect(chipFinder, findsOneWidget);
      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      // Tap handled safely (file not existing triggers snackbar)
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
