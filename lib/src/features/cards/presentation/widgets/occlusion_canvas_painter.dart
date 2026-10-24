import 'package:flutter/material.dart';

import '../../../../core/algorithms/image_occlusion/image_occlusion_box.dart';

class OcclusionCanvasPainter extends CustomPainter {
  const OcclusionCanvasPainter({
    required this.boxes,
    this.selectedBoxId,
    this.currentDragRect,
    this.activeReviewBoxId,
    this.isRevealed = false,
    this.boxColor = const Color(0xE6FFB300), // Amber 700 with high opacity
    this.borderColor = const Color(0xFFFF8F00),
    this.activeBoxColor = const Color(0xFFE53935), // Red / Highlight active
    this.activeBorderColor = const Color(0xFFB71C1C),
    this.selectedBorderColor = const Color(0xFF2979FF),
  });

  final List<ImageOcclusionBox> boxes;
  final String? selectedBoxId;
  final Rect? currentDragRect;
  final String? activeReviewBoxId;
  final bool isRevealed;

  final Color boxColor;
  final Color borderColor;
  final Color activeBoxColor;
  final Color activeBorderColor;
  final Color selectedBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final box in boxes) {
      // In review mode, if this is the active box and answer is revealed, skip mask (revealed!)
      if (activeReviewBoxId == box.id && isRevealed) {
        // Draw green reveal indicator border
        final rect = Rect.fromLTWH(
          box.x * size.width,
          box.y * size.height,
          box.width * size.width,
          box.height * size.height,
        );
        final revealPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFF4CAF50);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          revealPaint,
        );
        continue;
      }

      final rect = Rect.fromLTWH(
        box.x * size.width,
        box.y * size.height,
        box.width * size.width,
        box.height * size.height,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

      final isActiveTest = activeReviewBoxId == box.id;
      final isSelectedEditor = selectedBoxId == box.id;

      fillPaint.color = isActiveTest ? activeBoxColor : boxColor;
      borderPaint.color = isSelectedEditor
          ? selectedBorderColor
          : (isActiveTest ? activeBorderColor : borderColor);
      borderPaint.strokeWidth = (isSelectedEditor || isActiveTest) ? 3.0 : 1.5;

      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, borderPaint);

      // Draw label if available and box is large enough
      if (box.label != null && box.label!.isNotEmpty && rect.height >= 18) {
        final textSpan = TextSpan(
          text: box.label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '...',
        )..layout(maxWidth: rect.width - 8);

        if (textPainter.width <= rect.width - 4) {
          final offset = Offset(
            rect.left + (rect.width - textPainter.width) / 2,
            rect.top + (rect.height - textPainter.height) / 2,
          );
          textPainter.paint(canvas, offset);
        }
      }
    }

    // Draw active user drag rect
    if (currentDragRect != null) {
      final dragFill = Paint()
        ..style = PaintingStyle.fill
        ..color = selectedBorderColor.withValues(alpha: 0.35);
      final dragBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = selectedBorderColor;

      final rrect = RRect.fromRectAndRadius(
        currentDragRect!,
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, dragFill);
      canvas.drawRRect(rrect, dragBorder);
    }
  }

  @override
  bool shouldRepaint(covariant OcclusionCanvasPainter oldDelegate) {
    return oldDelegate.boxes != boxes ||
        oldDelegate.selectedBoxId != selectedBoxId ||
        oldDelegate.currentDragRect != currentDragRect ||
        oldDelegate.activeReviewBoxId != activeReviewBoxId ||
        oldDelegate.isRevealed != isRevealed;
  }
}
