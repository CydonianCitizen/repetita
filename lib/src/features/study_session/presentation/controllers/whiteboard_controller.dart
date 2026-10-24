import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhiteboardStroke {
  const WhiteboardStroke({
    required this.points,
    required this.color,
    this.strokeWidth = 3.5,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  WhiteboardStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
  }) {
    return WhiteboardStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

class WhiteboardState {
  const WhiteboardState({
    this.isOpen = false,
    this.strokes = const [],
    this.activeStroke,
    this.selectedColor = Colors.deepPurple,
    this.strokeWidth = 3.5,
  });

  final bool isOpen;
  final List<WhiteboardStroke> strokes;
  final WhiteboardStroke? activeStroke;
  final Color selectedColor;
  final double strokeWidth;

  bool get isEmpty => strokes.isEmpty && activeStroke == null;

  WhiteboardState copyWith({
    bool? isOpen,
    List<WhiteboardStroke>? strokes,
    WhiteboardStroke? activeStroke,
    bool clearActiveStroke = false,
    Color? selectedColor,
    double? strokeWidth,
  }) {
    return WhiteboardState(
      isOpen: isOpen ?? this.isOpen,
      strokes: strokes ?? this.strokes,
      activeStroke: clearActiveStroke
          ? null
          : (activeStroke ?? this.activeStroke),
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

class WhiteboardController extends Notifier<WhiteboardState> {
  @override
  WhiteboardState build() => const WhiteboardState();

  void toggle() {
    state = state.copyWith(isOpen: !state.isOpen);
  }

  void open() {
    if (!state.isOpen) state = state.copyWith(isOpen: true);
  }

  void close() {
    if (state.isOpen) state = state.copyWith(isOpen: false);
  }

  void startStroke(Offset point, {Color? color, double? strokeWidth}) {
    final strokeColor = color ?? state.selectedColor;
    final width = strokeWidth ?? state.strokeWidth;
    state = state.copyWith(
      activeStroke: WhiteboardStroke(
        points: [point],
        color: strokeColor,
        strokeWidth: width,
      ),
    );
  }

  void addPoint(Offset point) {
    if (state.activeStroke == null) return;
    final updatedPoints = List<Offset>.from(state.activeStroke!.points)
      ..add(point);
    state = state.copyWith(
      activeStroke: state.activeStroke!.copyWith(points: updatedPoints),
    );
  }

  void endStroke() {
    if (state.activeStroke == null) return;
    if (state.activeStroke!.points.isNotEmpty) {
      final updatedStrokes = List<WhiteboardStroke>.from(state.strokes)
        ..add(state.activeStroke!);
      state = state.copyWith(strokes: updatedStrokes, clearActiveStroke: true);
    } else {
      state = state.copyWith(clearActiveStroke: true);
    }
  }

  void undo() {
    if (state.strokes.isNotEmpty) {
      final updated = List<WhiteboardStroke>.from(state.strokes)..removeLast();
      state = state.copyWith(strokes: updated);
    }
  }

  void clear() {
    if (state.strokes.isNotEmpty || state.activeStroke != null) {
      state = state.copyWith(strokes: const [], clearActiveStroke: true);
    }
  }

  void setColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }
}

final whiteboardControllerProvider =
    NotifierProvider<WhiteboardController, WhiteboardState>(
      WhiteboardController.new,
    );
