import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/stats/presentation/stats_screen.dart';
import 'package:repetita/src/features/stats/presentation/widgets/interval_distribution_widget.dart';
import 'package:repetita/src/features/stats/presentation/widgets/metric_summary_card.dart';
import 'package:repetita/src/features/stats/presentation/widgets/rating_breakdown_widget.dart';
import 'package:repetita/src/features/stats/presentation/widgets/review_heatmap_widget.dart';
import 'package:repetita/src/features/stats/presentation/widgets/true_retention_card.dart';

void main() {
  late AppDatabase db;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'Stats Test Deck');
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject({int? deckId, String? deckName}) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: StatsScreen(deckId: deckId, deckName: deckName),
      ),
    );
  }

  group('StatsScreen Widget Tests', () {
    testWidgets('renders empty metrics gracefully', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Statistics'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MetricSummaryCard),
          matching: find.text('0%'),
        ),
        findsOneWidget,
      );
      expect(find.text('Retention'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.byType(ReviewHeatmapWidget), findsOneWidget);
      expect(find.text('Review Heatmap'), findsOneWidget);
      expect(find.text('Card State Breakdown'), findsOneWidget);
      expect(find.text('7-Day Review Forecast'), findsOneWidget);
      expect(find.byType(TrueRetentionCard), findsOneWidget);
      expect(find.byType(RatingBreakdownWidget), findsOneWidget);
      expect(find.byType(IntervalDistributionWidget), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('renders populated metrics accurately', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final card1 = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Front 1',
        back: 'Back 1',
      );
      final card2 = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Front 2',
        back: 'Back 2',
      );

      final now = DateTime.now().toUtc();
      await (db.update(db.cards)..where((t) => t.id.equals(card1))).write(
        CardsCompanion(state: const drift.Value(2), due: drift.Value(now)),
      );
      await (db.update(db.cards)..where((t) => t.id.equals(card2))).write(
        CardsCompanion(
          state: const drift.Value(1),
          due: drift.Value(now.add(const Duration(days: 1))),
        ),
      );

      // Add reviews: 2 Good, 1 Again -> Retention = 2/3 = 67%
      for (int i = 0; i < 2; i++) {
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: card1,
                rating: 3,
                state: 2,
                due: now,
                stability: 2.0,
                difficulty: 5.0,
                elapsedDays: 1,
                lastElapsedDays: 0,
                scheduledDays: 1,
                reviewedAt: now,
              ),
            );
      }
      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: card2,
              rating: 1,
              state: 1,
              due: now,
              stability: 0.5,
              difficulty: 5.0,
              elapsedDays: 2,
              lastElapsedDays: 1,
              scheduledDays: 1,
              reviewedAt: now,
            ),
          );

      await tester.pumpWidget(
        buildSubject(deckId: testDeckId, deckName: 'Biology'),
      );
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Biology Stats'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MetricSummaryCard),
          matching: find.text('67%'),
        ),
        findsOneWidget,
      );
      expect(find.text('Retention'), findsOneWidget);
      expect(find.text('3'), findsWidgets); // 3 reviews
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.byType(ReviewHeatmapWidget), findsOneWidget);
      expect(find.text('Review Heatmap'), findsOneWidget);
      expect(find.text('1 day'), findsOneWidget);
      expect(find.text('7-Day Review Forecast'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.byType(TrueRetentionCard), findsOneWidget);
      expect(find.byType(RatingBreakdownWidget), findsOneWidget);
      expect(find.byType(IntervalDistributionWidget), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('renders desktop wide layout with side-by-side cards', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Statistics'), findsOneWidget);
      expect(find.byType(ReviewHeatmapWidget), findsOneWidget);
      expect(find.text('Review Heatmap'), findsOneWidget);
      expect(find.text('7-Day Review Forecast'), findsOneWidget);
      expect(find.text('Card State Breakdown'), findsOneWidget);
      expect(find.byType(TrueRetentionCard), findsOneWidget);
      expect(find.byType(RatingBreakdownWidget), findsOneWidget);

      final intervalWidgetFinder = find.byType(IntervalDistributionWidget);
      await tester.scrollUntilVisible(
        intervalWidgetFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(intervalWidgetFinder, findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
