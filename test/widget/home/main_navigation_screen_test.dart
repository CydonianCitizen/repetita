import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/decks/data/decks_dao.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/decks/presentation/deck_list_screen.dart';
import 'package:repetita/src/features/home/presentation/main_navigation_screen.dart';
import 'package:repetita/src/features/settings/presentation/settings_screen.dart';
import 'package:repetita/src/features/stats/presentation/stats_screen.dart';

class _FakeDecksDao implements DecksDao {
  @override
  Stream<List<DeckWithCounts>> watchAllDecksWithCounts() {
    return Stream.value([
      DeckWithCounts(
        deck: Deck(
          id: 1,
          name: 'Vocabulary',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
          globalId: '',
          updatedHlc: '',
        ),
        totalCards: 5,
        dueCards: 2,
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildSubject() {
    return ProviderScope(
      overrides: [decksDaoProvider.overrideWithValue(_FakeDecksDao())],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainNavigationScreen(),
      ),
    );
  }

  group('MainNavigationScreen Widget Tests', () {
    testWidgets(
      'renders NavigationBar with Decks, Stats, Settings and switches tabs',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // 1. Initial tab is Decks (Home)
        expect(find.byType(DeckListScreen), findsOneWidget);
        expect(find.text('Vocabulary'), findsOneWidget);
        expect(find.byKey(const Key('nav_decks')), findsOneWidget);
        expect(find.byKey(const Key('nav_stats')), findsOneWidget);
        expect(find.byKey(const Key('nav_settings')), findsOneWidget);

        // 2. Tap Stats destination
        await tester.tap(find.byKey(const Key('nav_stats')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(StatsScreen), findsOneWidget);

        // 3. Tap Settings destination
        await tester.tap(find.byKey(const Key('nav_settings')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(
          find.byKey(const Key('setting_appearance_tile')),
          findsOneWidget,
        );

        // 4. Tap Decks destination back
        await tester.tap(find.byKey(const Key('nav_decks')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('Vocabulary'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'renders NavigationRail on wide desktop displays and switches tabs',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // 1. NavigationRail is shown on desktop displays
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(DeckListScreen), findsOneWidget);

        // 2. Switch to Stats via rail
        await tester.tap(find.byKey(const Key('nav_stats')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.byType(StatsScreen), findsOneWidget);

        // 3. Switch to Settings via rail
        await tester.tap(find.byKey(const Key('nav_settings')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.byType(SettingsScreen), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
  });
}
