import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/settings/data/update_service.dart';
import 'package:repetita/src/features/settings/domain/animation_level.dart';
import 'package:repetita/src/features/settings/domain/app_theme_mode.dart';
import 'package:repetita/src/features/settings/domain/haptic_intensity.dart';
import 'package:repetita/src/features/settings/presentation/controllers/animation_level_controller.dart';
import 'package:repetita/src/features/settings/presentation/controllers/haptic_controller.dart';
import 'package:repetita/src/features/settings/presentation/controllers/locale_controller.dart';
import 'package:repetita/src/features/settings/presentation/controllers/reminder_controller.dart';
import 'package:repetita/src/features/settings/presentation/controllers/theme_mode_controller.dart';
import 'package:repetita/src/features/settings/presentation/controllers/update_controller.dart';
import 'package:repetita/src/features/settings/presentation/settings_screen.dart';

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'repetita',
      packageName: 'dev.repetita.app',
      version: '0.3.0',
      buildNumber: '0',
      buildSignature: '',
    );
  });

  Widget buildSubject({ProviderContainer? container}) {
    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: const ConsumerWidgetApp(),
      );
    }
    return const ProviderScope(child: ConsumerWidgetApp());
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets(
      'renders all settings sections, tiles, branding, and navigates to appearance sub-screen',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);

        // Section headers
        expect(find.text('APPEARANCE'), findsOneWidget);
        expect(find.text('LANGUAGE & LOCALIZATION'), findsOneWidget);
        expect(find.text('STUDY & ALGORITHM'), findsOneWidget);
        expect(find.text('DATA & BACKUP'), findsOneWidget);
        expect(find.text('UPDATES & RELEASES'), findsOneWidget);
        expect(find.text('ABOUT & PRIVACY'), findsOneWidget);

        // Main navigation tiles
        expect(
          find.byKey(const Key('setting_appearance_tile')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('setting_study_algorithm_tile')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('setting_language_tile')), findsOneWidget);
        expect(find.byKey(const Key('setting_backup_tile')), findsOneWidget);
        expect(find.byKey(const Key('setting_updates_tile')), findsOneWidget);
        expect(find.byKey(const Key('setting_about_tile')), findsOneWidget);

        // Tap Appearance tile to navigate to AppearanceSettingsScreen
        await tester.tap(find.byKey(const Key('setting_appearance_tile')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('setting_theme_tile')), findsOneWidget);
        expect(
          find.byKey(const Key('setting_animation_slider')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('setting_haptic_slider')), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Language tile opens language sub-screen, selecting Italiano updates locale',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(buildSubject(container: container));

        await tester.tap(find.byKey(const Key('setting_language_tile')));
        await tester.pumpAndSettle();

        expect(find.text('Language'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Italiano'), findsOneWidget);
        expect(find.text('Español'), findsOneWidget);

        // Tap Italiano
        await tester.tap(find.text('Italiano'));
        await tester.pumpAndSettle();

        expect(container.read(localeControllerProvider), const Locale('it'));

        // Pop back to main settings screen
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Language in Italian now renders 'Impostazioni' and 'ASPETTO'
        expect(find.text('Impostazioni'), findsOneWidget);
        expect(find.text('ASPETTO'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Theme Mode tile in Appearance sub-screen opens dialog and selecting Dark Theme updates mode',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(buildSubject(container: container));

        expect(
          container.read(themeModeControllerProvider),
          AppThemeMode.system,
        );

        // Navigate to Appearance sub-screen
        await tester.tap(find.byKey(const Key('setting_appearance_tile')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('setting_theme_tile')));
        await tester.pumpAndSettle();

        expect(find.text('Theme Mode'), findsWidgets);
        expect(find.text('System Default'), findsWidgets);
        expect(find.text('Dark Theme'), findsOneWidget);
        expect(find.text('AMOLED (Pure Black)'), findsOneWidget);
        expect(find.text('Light Theme'), findsOneWidget);

        // Tap Dark Theme in the dialog
        await tester.tap(find.widgetWithText(ListTile, 'Dark Theme'));
        await tester.pumpAndSettle();

        expect(container.read(themeModeControllerProvider), AppThemeMode.dark);
      },
    );

    testWidgets(
      'animation slider in Appearance sub-screen adjusts intensity and test motion button reacts',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(buildSubject(container: container));

        // Initial default is Standard (1)
        expect(
          container.read(animationLevelControllerProvider),
          AnimationLevel.standard,
        );

        // Navigate to Appearance sub-screen
        await tester.tap(find.byKey(const Key('setting_appearance_tile')));
        await tester.pumpAndSettle();

        // Drag slider to the left (Reduced = 0)
        final sliderFinder = find.byKey(const Key('setting_animation_slider'));
        await tester.drag(sliderFinder, const Offset(-400, 0));
        await tester.pumpAndSettle();

        expect(
          container.read(animationLevelControllerProvider),
          AnimationLevel.reduced,
        );

        // Tap test motion button in reduced mode (no errors)
        final testMotionButton = find.byKey(const Key('test_motion_button'));
        expect(testMotionButton, findsOneWidget);
        await tester.tap(testMotionButton);
        await tester.pumpAndSettle();

        // Drag slider to the right (Expressive = 2)
        await tester.drag(sliderFinder, const Offset(400, 0));
        await tester.pumpAndSettle();

        expect(
          container.read(animationLevelControllerProvider),
          AnimationLevel.expressive,
        );

        // Tap test motion button in expressive mode
        await tester.tap(testMotionButton);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'haptic feedback slider in Appearance sub-screen adjusts intensity and test button triggers haptic feedback',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(buildSubject(container: container));

        // Initial default is Medium (2)
        expect(
          container.read(hapticFeedbackControllerProvider),
          HapticIntensity.medium,
        );

        // Navigate to Appearance sub-screen
        await tester.tap(find.byKey(const Key('setting_appearance_tile')));
        await tester.pumpAndSettle();

        // Find slider and drag to left (Off = 0)
        final hapticSliderFinder = find.byKey(
          const Key('setting_haptic_slider'),
        );
        expect(hapticSliderFinder, findsOneWidget);
        await tester.drag(hapticSliderFinder, const Offset(-400, 0));
        await tester.pumpAndSettle();

        expect(
          container.read(hapticFeedbackControllerProvider),
          HapticIntensity.off,
        );

        // Drag to right (Strong = 3)
        await tester.drag(hapticSliderFinder, const Offset(400, 0));
        await tester.pumpAndSettle();

        expect(
          container.read(hapticFeedbackControllerProvider),
          HapticIntensity.strong,
        );

        // Tap test haptic button
        final testHapticButton = find.byKey(const Key('test_haptic_button'));
        expect(testHapticButton, findsOneWidget);
        await tester.tap(testHapticButton);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'study reminders dialog in Study & Algorithm sub-screen toggles switch and dispatches test notification',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(buildSubject(container: container));

        // Navigate to Study & Algorithm sub-screen
        await tester.tap(find.byKey(const Key('setting_study_algorithm_tile')));
        await tester.pumpAndSettle();

        // Open Study Reminders dialog
        await tester.tap(find.byKey(const Key('setting_notifications_tile')));
        await tester.pumpAndSettle();

        expect(find.text('Study Reminders'), findsWidgets);
        expect(find.byKey(const Key('reminder_switch')), findsOneWidget);

        // Toggle switch to enabled
        await tester.tap(find.byKey(const Key('reminder_switch')));
        await tester.pumpAndSettle();

        expect(container.read(reminderControllerProvider).enabled, isTrue);
        expect(find.byKey(const Key('reminder_time_tile')), findsOneWidget);

        // Tap Send Test Notification button
        await tester.tap(
          find.byKey(const Key('send_test_notification_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('reminder_switch')), findsNothing);
      },
    );

    testWidgets(
      'update check dialog in Updates sub-screen displays up to date message on current version',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockService = UpdateService(
          fetcher: (uri) async => '''
        {
          "tag_name": "v0.2.0",
          "html_url": "https://github.com/CydonianCitizen/Repetita/releases/tag/v0.2.0",
          "body": "Latest release."
        }
        ''',
        );

        final container = ProviderContainer(
          overrides: [updateServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildSubject(container: container));

        // Navigate to Updates sub-screen
        await tester.tap(find.byKey(const Key('setting_updates_tile')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('setting_github_update_tile')));
        await tester.pumpAndSettle();

        expect(find.text('Up to Date'), findsOneWidget);
        expect(
          find.textContaining(
            'repetita is currently running the latest version',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.text('Up to Date'), findsNothing);
      },
    );

    testWidgets(
      'update check dialog in Updates sub-screen displays update available and release notes',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockService = UpdateService(
          fetcher: (uri) async => '''
        {
          "tag_name": "v0.4.0",
          "html_url": "https://github.com/CydonianCitizen/Repetita/releases/tag/v0.4.0",
          "body": "Exciting new features and fixes."
        }
        ''',
        );

        final container = ProviderContainer(
          overrides: [updateServiceProvider.overrideWithValue(mockService)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildSubject(container: container));

        // Navigate to Updates sub-screen
        await tester.tap(find.byKey(const Key('setting_updates_tile')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('setting_github_update_tile')));
        await tester.pumpAndSettle();

        expect(find.text('Update Available!'), findsOneWidget);
        expect(find.textContaining('v0.4.0'), findsWidgets);
        expect(find.text('Exciting new features and fixes.'), findsOneWidget);
        expect(find.text('View on GitHub'), findsOneWidget);

        await tester.tap(find.text('View on GitHub'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'tapping License tile in About sub-screen opens MIT License dialog with open source button',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildSubject());

        // Navigate to About sub-screen
        await tester.tap(find.byKey(const Key('setting_about_tile')));
        await tester.pumpAndSettle();

        // Tap License tile
        await tester.tap(find.byKey(const Key('setting_license_tile')));
        await tester.pumpAndSettle();

        expect(find.text('MIT License'), findsWidgets);
        expect(find.text('Copyright (c) 2026 repetita'), findsOneWidget);
        expect(
          find.byKey(const Key('view_all_licenses_button')),
          findsOneWidget,
        );

        // Tap View on GitHub
        await tester.tap(find.text('View on GitHub'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'tapping FSRS tile in Study & Algorithm sub-screen opens parameters dialog, slider and interval chips interact cleanly',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildSubject());

        // Navigate to Study & Algorithm sub-screen
        await tester.tap(find.byKey(const Key('setting_study_algorithm_tile')));
        await tester.pumpAndSettle();

        // Tap FSRS tile
        await tester.tap(find.byKey(const Key('setting_fsrs_tile')));
        await tester.pumpAndSettle();

        expect(find.text('FSRS Scheduling Parameters'), findsWidgets);
        expect(find.byKey(const Key('fsrs_retention_slider')), findsOneWidget);
        expect(find.byKey(const Key('fsrs_interval_365')), findsOneWidget);
        expect(find.byKey(const Key('fsrs_reset_button')), findsOneWidget);

        // Select interval 365d
        await tester.tap(find.byKey(const Key('fsrs_interval_365')));
        await tester.pumpAndSettle();

        // Tap OK
        await tester.tap(find.byKey(const Key('fsrs_save_button')));
        await tester.pumpAndSettle();

        expect(find.text('FSRS Scheduling Parameters'), findsOneWidget);
      },
    );

    testWidgets(
      'desktop hides haptic slider in Appearance and shows desktop notifications without time picker in Study',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        debugDefaultTargetPlatformOverride = TargetPlatform.windows;
        try {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          // Navigate to Appearance sub-screen
          await tester.tap(find.byKey(const Key('setting_appearance_tile')));
          await tester.pumpAndSettle();

          // Haptic slider is hidden on desktop
          expect(find.byKey(const Key('setting_haptic_slider')), findsNothing);
          expect(find.byKey(const Key('test_haptic_button')), findsNothing);

          // Pop back to root settings
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();

          // Navigate to Study & Algorithm sub-screen
          await tester.tap(
            find.byKey(const Key('setting_study_algorithm_tile')),
          );
          await tester.pumpAndSettle();

          // Notifications tile shows Desktop Notifications
          expect(find.text('Desktop Notifications'), findsOneWidget);

          // Open dialog
          await tester.tap(find.byKey(const Key('setting_notifications_tile')));
          await tester.pumpAndSettle();

          // In desktop dialog, reminder time picker is hidden
          expect(find.byKey(const Key('reminder_time_tile')), findsNothing);
          expect(find.byKey(const Key('reminder_switch')), findsOneWidget);
          expect(
            find.byKey(const Key('send_test_notification_button')),
            findsOneWidget,
          );

          // Close dialog
          await tester.tap(find.text('Close'));
          await tester.pumpAndSettle();
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );
  });
}

class ConsumerWidgetApp extends ConsumerWidget {
  const ConsumerWidgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SettingsScreen(),
    );
  }
}
