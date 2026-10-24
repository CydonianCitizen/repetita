import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/study_session/presentation/controllers/whiteboard_controller.dart';
import 'package:repetita/src/features/study_session/presentation/widgets/whiteboard_canvas.dart';

void main() {
  Widget buildTestableWidget({required WidgetRefCallback onInitRef}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              onInitRef(ref);
              return const SizedBox(
                width: 400,
                height: 600,
                child: WhiteboardCanvas(),
              );
            },
          ),
        ),
      ),
    );
  }

  group('WhiteboardCanvas Widget Tests', () {
    testWidgets('renders nothing when isOpen is false', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          onInitRef: (ref) {
            // initial state isOpen is false
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('whiteboard_container')), findsNothing);
    });

    testWidgets('renders canvas and controls when isOpen is true', (
      tester,
    ) async {
      late WidgetRef savedRef;
      await tester.pumpWidget(
        buildTestableWidget(
          onInitRef: (ref) {
            savedRef = ref;
          },
        ),
      );
      await tester.pumpAndSettle();

      savedRef.read(whiteboardControllerProvider.notifier).open();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('whiteboard_container')), findsOneWidget);
      expect(
        find.byKey(const Key('whiteboard_gesture_detector')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('whiteboard_undo_button')), findsOneWidget);
      expect(find.byKey(const Key('whiteboard_clear_button')), findsOneWidget);
      expect(find.byKey(const Key('whiteboard_close_button')), findsOneWidget);
    });

    testWidgets('drag gesture adds stroke and updates painter', (tester) async {
      late WidgetRef savedRef;
      await tester.pumpWidget(
        buildTestableWidget(
          onInitRef: (ref) {
            savedRef = ref;
          },
        ),
      );
      await tester.pumpAndSettle();

      savedRef.read(whiteboardControllerProvider.notifier).open();
      await tester.pumpAndSettle();

      // Perform drawing gesture
      final gestureLocation = tester.getCenter(
        find.byKey(const Key('whiteboard_gesture_detector')),
      );
      final gesture = await tester.startGesture(gestureLocation);
      await gesture.moveBy(const Offset(20, 20));
      await gesture.moveBy(const Offset(20, 20));
      await gesture.up();
      await tester.pumpAndSettle();

      final state = savedRef.read(whiteboardControllerProvider);
      expect(state.strokes.length, equals(1));
      expect(state.strokes.first.points.length, greaterThanOrEqualTo(2));
    });

    testWidgets('clear button clears all strokes on canvas', (tester) async {
      late WidgetRef savedRef;
      await tester.pumpWidget(
        buildTestableWidget(
          onInitRef: (ref) {
            savedRef = ref;
          },
        ),
      );
      await tester.pumpAndSettle();

      savedRef.read(whiteboardControllerProvider.notifier).open();
      await tester.pumpAndSettle();

      // Add stroke programmatically
      savedRef
          .read(whiteboardControllerProvider.notifier)
          .startStroke(const Offset(10, 10));
      savedRef.read(whiteboardControllerProvider.notifier).endStroke();
      await tester.pumpAndSettle();

      expect(savedRef.read(whiteboardControllerProvider).strokes, isNotEmpty);

      // Tap clear
      await tester.tap(find.byKey(const Key('whiteboard_clear_button')));
      await tester.pumpAndSettle();

      expect(savedRef.read(whiteboardControllerProvider).strokes, isEmpty);
    });

    testWidgets('close button hides whiteboard canvas', (tester) async {
      late WidgetRef savedRef;
      await tester.pumpWidget(
        buildTestableWidget(
          onInitRef: (ref) {
            savedRef = ref;
          },
        ),
      );
      await tester.pumpAndSettle();

      savedRef.read(whiteboardControllerProvider.notifier).open();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('whiteboard_container')), findsOneWidget);

      await tester.tap(find.byKey(const Key('whiteboard_close_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('whiteboard_container')), findsNothing);
      expect(savedRef.read(whiteboardControllerProvider).isOpen, isFalse);
    });
  });
}

typedef WidgetRefCallback = void Function(WidgetRef ref);
