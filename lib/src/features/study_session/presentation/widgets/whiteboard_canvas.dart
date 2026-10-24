import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../controllers/whiteboard_controller.dart';

/// Interactive drawing canvas overlay for active motor recall during study.
class WhiteboardCanvas extends ConsumerWidget {
  const WhiteboardCanvas({super.key});

  static const List<Color> _palette = [
    Colors.deepPurple,
    Colors.blue,
    Colors.teal,
    Colors.amber,
    Colors.deepOrange,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whiteboard = ref.watch(whiteboardControllerProvider);
    final notifier = ref.read(whiteboardControllerProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (!whiteboard.isOpen) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        key: const Key('whiteboard_container'),
        color: theme.colorScheme.surface.withValues(alpha: 0.94),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                key: const Key('whiteboard_gesture_detector'),
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) =>
                    notifier.startStroke(details.localPosition),
                onPanUpdate: (details) =>
                    notifier.addPoint(details.localPosition),
                onPanEnd: (_) => notifier.endStroke(),
                child: CustomPaint(
                  painter: WhiteboardPainter(
                    strokes: whiteboard.strokes,
                    activeStroke: whiteboard.activeStroke,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.85,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.draw_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _palette.map((color) {
                            final isSelected =
                                whiteboard.selectedColor.toARGB32() ==
                                color.toARGB32();
                            return GestureDetector(
                              key: Key(
                                'whiteboard_color_${color.toARGB32().toRadixString(16)}',
                              ),
                              onTap: () => notifier.setColor(color),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.onSurface
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('whiteboard_undo_button'),
                      icon: const Icon(Icons.undo, size: 20),
                      tooltip: l10n?.undoReview ?? 'Undo',
                      onPressed: whiteboard.strokes.isNotEmpty
                          ? () => notifier.undo()
                          : null,
                    ),
                    IconButton(
                      key: const Key('whiteboard_clear_button'),
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: l10n?.clearWhiteboard ?? 'Clear',
                      onPressed: !whiteboard.isEmpty
                          ? () => notifier.clear()
                          : null,
                    ),
                    IconButton(
                      key: const Key('whiteboard_close_button'),
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: l10n?.close ?? 'Close',
                      onPressed: () => notifier.close(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WhiteboardPainter extends CustomPainter {
  WhiteboardPainter({required this.strokes, this.activeStroke});

  final List<WhiteboardStroke> strokes;
  final WhiteboardStroke? activeStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final allStrokes = [...strokes, ?activeStroke];

    for (final stroke in allStrokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
      } else {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WhiteboardPainter oldDelegate) => true;
}
