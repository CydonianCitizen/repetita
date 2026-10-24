import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/stats/domain/stats_models.dart';
import 'package:repetita/src/features/stats/presentation/widgets/interval_distribution_widget.dart';
import 'package:repetita/src/features/stats/presentation/widgets/rating_breakdown_widget.dart';
import 'package:repetita/src/features/stats/presentation/widgets/true_retention_card.dart';

void main() {
  group('Extended Stats Widgets Tests', () {
    testWidgets(
      'TrueRetentionCard displays young and mature retention percentages',
      (tester) async {
        const data = TrueRetentionData(
          youngPassed: 8,
          youngTotal: 10, // 80%
          maturePassed: 19,
          matureTotal: 20, // 95%
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: TrueRetentionCard(data: data)),
          ),
        );

        expect(find.byKey(const Key('true_retention_card')), findsOneWidget);
        expect(find.text('True Retention'), findsOneWidget);
        expect(find.textContaining('80%'), findsOneWidget);
        expect(find.textContaining('95%'), findsOneWidget);
        expect(find.text('90%'), findsOneWidget); // (8 + 19) / 30 = 90%
      },
    );

    testWidgets(
      'IntervalDistributionWidget renders bucket labels and average days',
      (tester) async {
        const data = IntervalDistributionData(
          buckets: [
            IntervalBucket(label: '1-7 d', count: 10, percentage: 0.5),
            IntervalBucket(label: '8-30 d', count: 6, percentage: 0.3),
            IntervalBucket(label: '31-90 d', count: 4, percentage: 0.2),
            IntervalBucket(label: '91-365 d', count: 0, percentage: 0.0),
            IntervalBucket(label: '365+ d', count: 0, percentage: 0.0),
          ],
          totalCards: 20,
          averageIntervalDays: 14.5,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: IntervalDistributionWidget(data: data)),
          ),
        );

        expect(
          find.byKey(const Key('interval_distribution_widget')),
          findsOneWidget,
        );
        expect(find.text('Interval Distribution'), findsOneWidget);
        expect(find.text('1-7 d'), findsOneWidget);
        expect(find.text('8-30 d'), findsOneWidget);
        expect(find.text('15 d avg'), findsOneWidget); // 14.5 rounded to 15
      },
    );

    testWidgets('RatingBreakdownWidget renders all four rating categories', (
      tester,
    ) async {
      const data = RatingBreakdownData(
        againCount: 10, // 10%
        hardCount: 20, // 20%
        goodCount: 50, // 50%
        easyCount: 20, // 20%
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingBreakdownWidget(data: data)),
        ),
      );

      expect(find.byKey(const Key('rating_breakdown_widget')), findsOneWidget);
      expect(find.text('Answer Buttons Breakdown'), findsOneWidget);
      expect(find.text('Again'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });
  });
}
