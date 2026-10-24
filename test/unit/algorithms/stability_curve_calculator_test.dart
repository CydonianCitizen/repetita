import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/stability_curve_calculator.dart';

void main() {
  group('StabilityCurveCalculator Unit Tests', () {
    test(
      'retrievability returns 1.0 at day 0 and 0.9 at day equal to stability',
      () {
        const stability = 10.0;
        final r0 = StabilityCurveCalculator.retrievability(0.0, stability);
        expect(r0, equals(1.0));

        final rS = StabilityCurveCalculator.retrievability(10.0, stability);
        expect(rS, closeTo(0.9, 0.001));

        final rNegative = StabilityCurveCalculator.retrievability(
          -1.0,
          stability,
        );
        expect(rNegative, equals(1.0));

        final rZeroStability = StabilityCurveCalculator.retrievability(
          5.0,
          0.0,
        );
        expect(rZeroStability, equals(0.0));
      },
    );

    test(
      'daysToRetention calculates days required to reach target retention',
      () {
        const stability = 14.0;
        final days90 = StabilityCurveCalculator.daysToRetention(0.9, stability);
        expect(days90, closeTo(14.0, 0.01));

        final days80 = StabilityCurveCalculator.daysToRetention(0.8, stability);
        expect(days80, greaterThan(14.0));

        final halfLife = StabilityCurveCalculator.daysToHalfLife(stability);
        final rHalfLife = StabilityCurveCalculator.retrievability(
          halfLife,
          stability,
        );
        expect(rHalfLife, closeTo(0.5, 0.001));
      },
    );

    test(
      'generateCurvePoints creates discrete points decreasing monotonically',
      () {
        const stability = 20.0;
        final points = StabilityCurveCalculator.generateCurvePoints(
          stability: stability,
          pointCount: 30,
        );

        expect(points.length, equals(30));
        expect(points.first.day, equals(0.0));
        expect(points.first.retrievability, equals(1.0));

        for (int i = 1; i < points.length; i++) {
          expect(points[i].day, greaterThan(points[i - 1].day));
          expect(
            points[i].retrievability,
            lessThanOrEqualTo(points[i - 1].retrievability),
          );
        }

        expect(points.last.retrievability, lessThan(0.9));
      },
    );
  });
}
