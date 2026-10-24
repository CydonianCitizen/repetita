import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/fsrs_engine.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_parameters.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/settings/presentation/controllers/fsrs_optimizer_controller.dart';
import 'package:repetita/src/features/settings/presentation/controllers/fsrs_parameters_controller.dart';
import 'package:repetita/src/features/settings/presentation/widgets/fsrs_optimizer_card.dart';
import 'package:repetita/src/features/study_session/presentation/controllers/srs_scheduler_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FsrsOptimizerCard(),
          ),
        ),
      ),
    );
  }

  group('FsrsOptimizerCard & Persistence Widget Tests', () {
    testWidgets('renders review count and disables optimize button when reviews < 500', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(FsrsOptimizerCard), findsOneWidget);
      expect(find.text('0 / 500 min.'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);

      final buttonFinder = find.byKey(const Key('btn_optimize_fsrs'));
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('enables optimize button when reviews >= 500', (tester) async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          fsrsOptimizerControllerProvider.overrideWith(
            () => _FakeFsrsOptimizerController(
              const FsrsOptimizerState(reviewCount: 520),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FsrsOptimizerCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('520 / 500 min.'), findsOneWidget);
      final buttonFinder = find.byKey(const Key('btn_optimize_fsrs'));
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('displays custom weights badge and resets to default on confirmation', (tester) async {
      final customWeights = List<double>.from(FsrsParameters.defaultWeights);
      customWeights[0] = 0.85;

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      // Set custom weights
      await container
          .read(fsrsParametersControllerProvider.notifier)
          .setCustomWeights(customWeights);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FsrsOptimizerCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personalizzato'), findsOneWidget);
      final resetBtn = find.byKey(const Key('btn_reset_fsrs_weights'));
      expect(resetBtn, findsOneWidget);

      // Tap reset button and confirm dialog
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      expect(find.text('Ripristina Pesi Predefiniti'), findsOneWidget);
      final confirmBtn = find.byKey(const Key('btn_confirm_reset_weights'));
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsOneWidget);
      expect(
        container.read(fsrsParametersControllerProvider).hasCustomWeights,
        isFalse,
      );
    });

    testWidgets('srsSchedulerProvider updates scheduler instance with custom weights', (tester) async {
      final customWeights = List<double>.from(FsrsParameters.defaultWeights);
      customWeights[0] = 1.25;

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(srsSchedulerProvider, (_, _) {});
      expect((sub.read() as FsrsEngine).parameters.w[0], 0.4);

      await container
          .read(fsrsParametersControllerProvider.notifier)
          .setCustomWeights(customWeights);

      expect((sub.read() as FsrsEngine).parameters.w[0], 1.25);
      expect((sub.read() as FsrsEngine).parameters.hasCustomWeights, isTrue);

      sub.close();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}

class _FakeFsrsOptimizerController extends FsrsOptimizerController {
  _FakeFsrsOptimizerController(this._initialState);
  final FsrsOptimizerState _initialState;

  @override
  Future<FsrsOptimizerState> build() async => _initialState;
}
