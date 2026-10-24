import 'dart:math';

class CurvePoint {
  const CurvePoint({required this.day, required this.retrievability});

  final double day;
  final double retrievability;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurvePoint &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          retrievability == other.retrievability;

  @override
  int get hashCode => Object.hash(day, retrievability);
}

abstract final class StabilityCurveCalculator {
  static const double factor = 19.0 / 81.0;

  static double retrievability(double elapsedDays, double stability) {
    if (stability <= 0.0) return 0.0;
    if (elapsedDays <= 0.0) return 1.0;
    return pow(1.0 + factor * (elapsedDays / stability), -0.5).toDouble();
  }

  static double daysToRetention(double targetR, double stability) {
    if (stability <= 0.0 || targetR <= 0.0 || targetR >= 1.0) return 0.0;
    final days = (stability / factor) * (pow(targetR, -2) - 1.0);
    return max(0.0, days);
  }

  static double daysToHalfLife(double stability) {
    return daysToRetention(0.5, stability);
  }

  static List<CurvePoint> generateCurvePoints({
    required double stability,
    int pointCount = 50,
    double? maxDays,
  }) {
    if (pointCount < 2) pointCount = 2;
    if (stability <= 0.0) {
      return List.generate(
        pointCount,
        (i) => CurvePoint(day: i.toDouble(), retrievability: 0.0),
      );
    }

    final endDay = maxDays ?? max(daysToRetention(0.7, stability), 30.0);
    final step = endDay / (pointCount - 1);

    return List.generate(pointCount, (i) {
      final t = i * step;
      return CurvePoint(day: t, retrievability: retrievability(t, stability));
    });
  }
}
