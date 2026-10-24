import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/cards/presentation/dialogs/audio_recorder_dialog.dart';

void main() {
  group('AudioRecorderDialog Widget Tests', () {
    testWidgets('renders recording dialog with record button and timer', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: Center(child: AudioRecorderDialog())),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Audio Recording'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.byKey(const Key('start_recording_button')), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
