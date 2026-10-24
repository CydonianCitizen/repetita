import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/study_session/presentation/controllers/whiteboard_controller.dart';

void main() {
  group('WhiteboardController Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is closed and empty', () {
      final state = container.read(whiteboardControllerProvider);
      expect(state.isOpen, isFalse);
      expect(state.strokes, isEmpty);
      expect(state.activeStroke, isNull);
      expect(state.isEmpty, isTrue);
    });

    test('toggle, open and close manage isOpen state', () {
      final notifier = container.read(whiteboardControllerProvider.notifier);

      notifier.toggle();
      expect(container.read(whiteboardControllerProvider).isOpen, isTrue);

      notifier.close();
      expect(container.read(whiteboardControllerProvider).isOpen, isFalse);

      notifier.open();
      expect(container.read(whiteboardControllerProvider).isOpen, isTrue);
    });

    test('stroke drawing lifecycle: start, addPoint, endStroke', () {
      final notifier = container.read(whiteboardControllerProvider.notifier);

      notifier.startStroke(const Offset(10, 10));
      var state = container.read(whiteboardControllerProvider);
      expect(state.activeStroke, isNotNull);
      expect(state.activeStroke!.points, equals([const Offset(10, 10)]));

      notifier.addPoint(const Offset(20, 20));
      state = container.read(whiteboardControllerProvider);
      expect(state.activeStroke!.points.length, equals(2));

      notifier.endStroke();
      state = container.read(whiteboardControllerProvider);
      expect(state.activeStroke, isNull);
      expect(state.strokes.length, equals(1));
      expect(state.strokes.first.points.length, equals(2));
      expect(state.isEmpty, isFalse);
    });

    test('undo removes only the last completed stroke', () {
      final notifier = container.read(whiteboardControllerProvider.notifier);

      notifier.startStroke(const Offset(0, 0));
      notifier.addPoint(const Offset(1, 1));
      notifier.endStroke();

      notifier.startStroke(const Offset(10, 10));
      notifier.addPoint(const Offset(11, 11));
      notifier.endStroke();

      expect(
        container.read(whiteboardControllerProvider).strokes.length,
        equals(2),
      );

      notifier.undo();
      expect(
        container.read(whiteboardControllerProvider).strokes.length,
        equals(1),
      );

      notifier.undo();
      expect(container.read(whiteboardControllerProvider).strokes, isEmpty);

      // Subsequent undo is a no-op without error
      notifier.undo();
      expect(container.read(whiteboardControllerProvider).strokes, isEmpty);
    });

    test('clear resets strokes and activeStroke', () {
      final notifier = container.read(whiteboardControllerProvider.notifier);

      notifier.startStroke(const Offset(5, 5));
      notifier.endStroke();
      expect(
        container.read(whiteboardControllerProvider).strokes.length,
        equals(1),
      );

      notifier.clear();
      expect(container.read(whiteboardControllerProvider).strokes, isEmpty);
      expect(container.read(whiteboardControllerProvider).activeStroke, isNull);
    });

    test('color and strokeWidth configuration', () {
      final notifier = container.read(whiteboardControllerProvider.notifier);

      notifier.setColor(Colors.amber);
      notifier.setStrokeWidth(5.0);

      final state = container.read(whiteboardControllerProvider);
      expect(state.selectedColor, equals(Colors.amber));
      expect(state.strokeWidth, equals(5.0));

      notifier.startStroke(const Offset(0, 0));
      expect(
        container.read(whiteboardControllerProvider).activeStroke!.color,
        equals(Colors.amber),
      );
      expect(
        container.read(whiteboardControllerProvider).activeStroke!.strokeWidth,
        equals(5.0),
      );
    });
  });
}
