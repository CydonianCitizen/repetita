import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/app.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/backup_transfer/presentation/backup_screen.dart';
import 'package:repetita/src/features/cards/presentation/card_editor_screen.dart';
import 'package:repetita/src/features/cards/presentation/deck_detail_screen.dart';
import 'package:repetita/src/features/settings/presentation/settings_screen.dart';
import 'package:repetita/src/features/stats/presentation/stats_screen.dart';
import 'package:repetita/src/features/stats/presentation/widgets/metric_summary_card.dart';
import 'package:repetita/src/features/study_session/presentation/study_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const RepetitaApp(),
    );
  }

  Future<void> pumpFrames(WidgetTester tester, [int count = 15]) async {
    for (int i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets(
    'Repetita End-to-End User Journey: Deck -> Card -> Study -> Stats -> Backup',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Boot RepetitaApp
      await tester.pumpWidget(buildApp());
      await pumpFrames(tester);

      expect(find.text('repetita'), findsOneWidget);
      expect(find.text('No decks yet. Tap + to create one.'), findsOneWidget);

      // 2. Flow 1: Create a new deck ("Japanese Basics")
      final createDeckFab = find.byKey(const Key('create_deck_fab'));
      expect(createDeckFab, findsOneWidget);
      await tester.tap(createDeckFab);
      await pumpFrames(tester);

      expect(find.text('Create Deck'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('deck_name_field')),
        'Japanese Basics',
      );
      await tester.enterText(
        find.byKey(const Key('deck_description_field')),
        'Essential vocabulary',
      );
      await pumpFrames(tester, 5);

      await tester.tap(find.byKey(const Key('deck_form_submit_button')));
      await pumpFrames(tester);

      expect(find.text('Japanese Basics'), findsOneWidget);
      expect(find.text('Essential vocabulary'), findsOneWidget);

      // 3. Flow 2: Open deck, tap add card, fill Front ("Neko") and Back ("Cat")
      await tester.tap(find.text('Japanese Basics'));
      await pumpFrames(tester);

      expect(find.byType(DeckDetailScreen), findsOneWidget);
      expect(find.text('0 cards due for review'), findsOneWidget);

      final addCardFab = find.byKey(const Key('add_card_fab'));
      expect(addCardFab, findsOneWidget);
      await tester.tap(addCardFab);
      await pumpFrames(tester);

      expect(find.byType(CardEditorScreen), findsOneWidget);
      expect(find.text('New Card'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('card_front_field')), 'Neko');
      await tester.enterText(find.byKey(const Key('card_back_field')), 'Cat');
      await pumpFrames(tester, 5);

      await tester.tap(find.byKey(const Key('save_card_button')));
      await pumpFrames(tester);

      // Returned to DeckDetailScreen
      expect(find.byType(DeckDetailScreen), findsOneWidget);
      expect(find.text('Neko'), findsOneWidget);
      expect(find.text('Cat'), findsOneWidget);
      expect(find.text('1 cards due for review'), findsOneWidget);

      // 4. Flow 3: Start study session, tap Show Answer, rate Good
      final startStudyButton = find.byKey(const Key('start_study_button'));
      expect(startStudyButton, findsOneWidget);
      await tester.tap(startStudyButton);
      await pumpFrames(tester);

      expect(find.byType(StudyScreen), findsOneWidget);
      expect(find.text('Neko'), findsOneWidget);
      expect(find.text('Cat'), findsNothing);

      final showAnswerButton = find.byKey(const Key('show_answer_button'));
      expect(showAnswerButton, findsOneWidget);
      await tester.tap(showAnswerButton);
      await pumpFrames(tester, 5);

      expect(find.text('Cat'), findsOneWidget);
      final rateGoodButton = find.byKey(const Key('rating_button_good'));
      expect(rateGoodButton, findsOneWidget);
      await tester.tap(rateGoodButton);
      await pumpFrames(tester);

      expect(find.text('All cards reviewed for today!'), findsOneWidget);
      await tester.tap(find.byKey(const Key('back_to_deck_button')));
      await pumpFrames(tester);

      // 5. Flow 4: Navigate back to home and switch to Stats tab via bottom navbar
      await tester.tap(find.byTooltip('Back'));
      await pumpFrames(tester);

      final navStats = find.byKey(const Key('nav_stats'));
      expect(navStats, findsOneWidget);
      await tester.tap(navStats);
      await pumpFrames(tester);

      expect(find.byType(StatsScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MetricSummaryCard),
          matching: find.text('100%'),
        ),
        findsOneWidget,
      ); // 1 Good rating -> 100% in MetricSummaryCard
      expect(find.text('Retention'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // 1 review
      expect(find.text('Reviews'), findsOneWidget);

      // 6. Flow 5: Switch to Settings tab via bottom navbar and open BackupScreen
      final navSettings = find.byKey(const Key('nav_settings'));
      expect(navSettings, findsOneWidget);
      await tester.tap(navSettings);
      await pumpFrames(tester);

      expect(find.byType(SettingsScreen), findsOneWidget);
      final backupTile = find.byKey(const Key('setting_backup_tile'));
      await tester.scrollUntilVisible(backupTile, 200);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await pumpFrames(tester);
      expect(backupTile, findsOneWidget);
      await tester.tap(backupTile);
      await pumpFrames(tester);

      expect(find.byType(BackupScreen), findsOneWidget);
      final exportJsonButton = find.byKey(const Key('export_json_button'));
      expect(exportJsonButton, findsOneWidget);

      await tester.tap(exportJsonButton);
      await pumpFrames(tester, 5);

      expect(find.text('Full Backup JSON'), findsOneWidget);
      expect(find.text('Backup exported successfully!'), findsOneWidget);

      // Unmount cleanly
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    },
  );
}
