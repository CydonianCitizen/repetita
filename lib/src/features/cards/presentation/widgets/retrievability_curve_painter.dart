import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/algorithms/fsrs/stability_curve_calculator.dart';

class RetrievabilityCurvePainter extends CustomPainter {
  const RetrievabilityCurvePainter({
    required this.points,
    required this.curveColor,
    required this.thresholdColor,
    required this.gridColor,
    this.currentElapsedDays,
    this.currentR,
  });

  final List<CurvePoint> points;
  final Color curveColor;
  final Color thresholdColor;
  final Color gridColor;
  final double? currentElapsedDays;
  final double? currentR;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    // Draw grid horizontal lines at R = 1.0, 0.9, 0.5, 0.0
    const y100 = 0.0;
    final y90 = size.height * (1.0 - 0.9);
    final y50 = size.height * (1.0 - 0.5);
    final y0 = size.height;

    canvas.drawLine(Offset.zero, Offset(size.width, y100), gridPaint);
    canvas.drawLine(Offset(0, y50), Offset(size.width, y50), gridPaint);
    canvas.drawLine(Offset(0, y0), Offset(size.width, y0), gridPaint);

    // 90% Target threshold line (dashed/colored)
    final thresholdPaint = Paint()
      ..color = thresholdColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, y90), Offset(size.width, y90), thresholdPaint);

    final maxDay = max(1.0, points.last.day);

    // Path for curve
    final curvePath = Path();
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final x = (pt.day / maxDay) * size.width;
      final y = size.height * (1.0 - pt.retrievability.clamp(0.0, 1.0));
      if (i == 0) {
        curvePath.moveTo(x, y);
      } else {
        curvePath.lineTo(x, y);
      }
    }

    final curvePaint = Paint()
      ..color = curveColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(curvePath, curvePaint);

    // Fill under curve
    final fillPath = Path.from(curvePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          curveColor.withValues(alpha: 0.25),
          curveColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // If current elapsed days & R provided, draw point marker
    if (currentElapsedDays != null && currentR != null) {
      final markerX =
          (currentElapsedDays!.clamp(0.0, maxDay) / maxDay) * size.width;
      final markerY = size.height * (1.0 - currentR!.clamp(0.0, 1.0));

      final markerFill = Paint()..color = curveColor;
      final markerStroke = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(Offset(markerX, markerY), 5.0, markerFill);
      canvas.drawCircle(Offset(markerX, markerY), 5.0, markerStroke);
    }
  }

  @override
  bool shouldRepaint(covariant RetrievabilityCurvePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.currentElapsedDays != currentElapsedDays ||
        oldDelegate.currentR != currentR ||
        oldDelegate.curveColor != curveColor;
  }
}
