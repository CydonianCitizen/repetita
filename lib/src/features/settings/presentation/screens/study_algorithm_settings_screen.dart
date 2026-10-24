import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/srs_algorithm.dart';
import '../../../study_session/presentation/controllers/auto_advance_controller.dart';
import '../../../study_session/presentation/controllers/autoplay_audio_controller.dart';
import '../../../study_session/presentation/controllers/study_gesture_controller.dart';
import '../../../study_session/presentation/controllers/timebox_controller.dart';
import '../../../study_session/presentation/controllers/type_in_controller.dart';
import '../../../study_session/presentation/dialogs/study_gestures_dialog.dart';
import '../controllers/auto_bury_siblings_controller.dart';
import '../controllers/fsrs_parameters_controller.dart';
import '../controllers/reminder_controller.dart';
import '../controllers/srs_algorithm_controller.dart';
import '../controllers/vacation_mode_controller.dart';
import '../dialogs/fsrs_settings_dialog.dart';
import '../dialogs/reminder_dialog.dart';
import '../widgets/fsrs_optimizer_card.dart';
import '../widgets/section_header.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_tile.dart';

class StudyAlgorithmSettingsScreen extends ConsumerWidget {
  const StudyAlgorithmSettingsScreen({super.key});

  void _showTimeboxDialog(BuildContext context, WidgetRef ref, int current) {
    final l10n = AppLocalizations.of(context);
    final options = [0, 5, 10, 15, 20, 25, 30];
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n?.timeboxing ?? 'Session timeboxing'),
        content: RadioGroup<int>(
          groupValue: current,
          onChanged: (val) {
            if (val != null) {
              ref.read(timeboxControllerProvider.notifier).setMinutes(val);
              Navigator.of(dialogCtx).pop();
            }
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((mins) {
                return RadioListTile<int>(
                  value: mins,
                  title: Text(
                    mins == 0
                        ? (l10n?.timeboxMinutes(0) ?? 'Disabled')
                        : (l10n?.timeboxMinutes(mins) ?? '$mins minutes'),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  void _showAutoAdvanceDialog(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) {
    final l10n = AppLocalizations.of(context);
    final options = [0, 3, 5, 10, 15];
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n?.autoAdvance ?? 'Auto-advance'),
        content: RadioGroup<int>(
          groupValue: current,
          onChanged: (val) {
            if (val != null) {
              ref.read(autoAdvanceControllerProvider.notifier).setSeconds(val);
              Navigator.of(dialogCtx).pop();
            }
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((secs) {
                return RadioListTile<int>(
                  value: secs,
                  title: Text(
                    secs == 0
                        ? (l10n?.autoAdvanceSeconds(0) ?? 'Disabled')
                        : (l10n?.autoAdvanceSeconds(secs) ?? '$secs seconds'),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  void _showAlgorithmDialog(
    BuildContext context,
    WidgetRef ref,
    SrsAlgorithm current,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n?.srsAlgorithm ?? 'SRS Algorithm'),
          content: RadioGroup<SrsAlgorithm>(
            groupValue: current,
            onChanged: (val) {
              if (val != null) {
                ref
                    .read(srsAlgorithmControllerProvider.notifier)
                    .setAlgorithm(val);
                Navigator.of(dialogContext).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<SrsAlgorithm>(
                  key: const Key('algo_radio_fsrs'),
                  value: SrsAlgorithm.fsrs,
                  title: Text(l10n?.fsrsAlgorithmName ?? 'FSRS (Default)'),
                  subtitle: Text(
                    l10n?.fsrsAlgorithmDesc ?? 'Modern stability model',
                  ),
                ),
                RadioListTile<SrsAlgorithm>(
                  key: const Key('algo_radio_sm2'),
                  value: SrsAlgorithm.sm2,
                  title: Text(l10n?.sm2AlgorithmName ?? 'SM-2 (Classic)'),
                  subtitle: Text(
                    l10n?.sm2AlgorithmDesc ?? 'Classic SuperMemo 2 model',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n?.close ?? 'Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsStudyAlgorithmTitle ?? 'Study & Scheduling'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            SectionHeader(title: l10n?.srsAlgorithm ?? 'Scheduling Engine'),
            SettingsCard(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final currentAlgo = ref.watch(
                      srsAlgorithmControllerProvider,
                    );
                    return SettingsTile(
                      key: const Key('setting_algorithm_tile'),
                      icon: Icons.psychology_rounded,
                      iconColor: colorScheme.secondary,
                      title: l10n?.srsAlgorithm ?? 'SRS Algorithm',
                      subtitle: currentAlgo == SrsAlgorithm.fsrs
                          ? (l10n?.fsrsAlgorithmName ?? 'FSRS (Default)')
                          : (l10n?.sm2AlgorithmName ?? 'SM-2 (Classic)'),
                      onTap: () =>
                          _showAlgorithmDialog(context, ref, currentAlgo),
                    );
                  },
                ),
                const Divider(indent: 56, height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final fsrsParams = ref.watch(
                      fsrsParametersControllerProvider,
                    );
                    return SettingsTile(
                      key: const Key('setting_fsrs_tile'),
                      icon: Icons.tune_rounded,
                      iconColor: colorScheme.tertiary,
                      title:
                          l10n?.fsrsParameters ?? 'FSRS Scheduling Parameters',
                      subtitle:
                          '${(fsrsParams.requestRetention * 100).round()}% ${l10n?.retention ?? 'retention'} • ${fsrsParams.maximumInterval}d',
                      onTap: () => FsrsSettingsDialog.show(context),
                    );
                  },
                ),
                const Divider(indent: 56, height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final vacationActive =
                        ref.watch(vacationModeControllerProvider).value ??
                        false;
                    return SettingsTile(
                      key: const Key('setting_vacation_mode_tile'),
                      icon: Icons.beach_access_rounded,
                      iconColor: Colors.amber,
                      title: l10n?.vacationMode ?? 'Vacation Mode',
                      subtitle: vacationActive
                          ? (l10n?.vacationModeActive ??
                                'Active • Review dates paused')
                          : (l10n?.vacationModeInactive ??
                                'Disabled • Normal scheduling'),
                      trailing: Switch(
                        value: vacationActive,
                        onChanged: (_) {
                          ref
                              .read(vacationModeControllerProvider.notifier)
                              .toggleVacation();
                        },
                      ),
                      showChevron: false,
                      onTap: () {
                        ref
                            .read(vacationModeControllerProvider.notifier)
                            .toggleVacation();
                      },
                    );
                  },
                ),
                const Divider(indent: 56, height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final autoBury = ref.watch(
                      autoBurySiblingsControllerProvider,
                    );
                    return SettingsTile(
                      key: const Key('setting_auto_bury_siblings_tile'),
                      icon: Icons.alt_route_rounded,
                      iconColor: colorScheme.primary,
                      title:
                          l10n?.autoBurySiblings ??
                          'Bury siblings automatically',
                      subtitle:
                          l10n?.autoBurySiblingsSubtitle ??
                          'Postpone sibling cards until tomorrow upon review',
                      trailing: Switch(
                        value: autoBury,
                        onChanged: (_) {
                          ref
                              .read(autoBurySiblingsControllerProvider.notifier)
                              .toggle();
                        },
                      ),
                      showChevron: false,
                      onTap: () {
                        ref
                            .read(autoBurySiblingsControllerProvider.notifier)
                            .toggle();
                      },
                    );
                  },
                ),
                const Divider(indent: 56, height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final gestureConfig = ref.watch(
                      studyGestureControllerProvider,
                    );
                    return SettingsTile(
                      key: const Key('setting_study_gestures_tile'),
                      icon: Icons.gesture_rounded,
                      iconColor: colorScheme.secondary,
                      title: 'Gesti touch in studio',
                      subtitle: gestureConfig.enableGestures
                          ? 'Attivi • Swipe & doppio tocco personalizzati'
                          : 'Disattivati',
                      onTap: () => StudyGesturesDialog.show(context),
                    );
                  },
                ),
              ],
            ),
            Consumer(
              builder: (context, ref, _) {
                final currentAlgo = ref.watch(srsAlgorithmControllerProvider);
                if (currentAlgo != SrsAlgorithm.fsrs) {
                  return const SizedBox.shrink();
                }
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    SectionHeader(title: 'FSRS OPTIMIZER ON-DEVICE'),
                    FsrsOptimizerCard(),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: isDesktop
                  ? 'NOTIFICATIONS'
                  : (l10n?.studyReminders ?? 'STUDY REMINDERS'),
            ),
            SettingsCard(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final reminderSettings = ref.watch(
                      reminderControllerProvider,
                    );
                    return SettingsTile(
                      key: const Key('setting_notifications_tile'),
                      icon: reminderSettings.enabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      iconColor: colorScheme.primary,
                      title: isDesktop
                          ? (l10n?.desktopNotifications ??
                                'Desktop Notifications')
                          : (l10n?.studyReminders ?? 'Study Reminders'),
                      subtitle: isDesktop
                          ? (reminderSettings.enabled
                                ? (l10n?.desktopNotificationsActive ??
                                      'System notifications enabled')
                                : (l10n?.desktopNotificationsDisabled ??
                                      'System notifications disabled'))
                          : (reminderSettings.enabled
                                ? (l10n?.reminderAtTime(
                                        reminderSettings.formattedTime,
                                      ) ??
                                      'Daily at ${reminderSettings.formattedTime}')
                                : (l10n?.studyRemindersSubtitle ??
                                      'Daily review alerts')),
                      onTap: () => ReminderDialog.show(context),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: (l10n?.studySessionTitle ?? 'STUDY SESSION').toUpperCase(),
            ),
            SettingsCard(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final timeboxMins = ref.watch(timeboxControllerProvider);
                    return SettingsTile(
                      key: const Key('setting_timebox_tile'),
                      icon: Icons.timer_outlined,
                      iconColor: Colors.deepOrange,
                      title: l10n?.timeboxing ?? 'Session timeboxing',
                      subtitle: timeboxMins == 0
                          ? (l10n?.timeboxMinutes(0) ?? 'Disabled')
                          : (l10n?.timeboxMinutes(timeboxMins) ??
                                '$timeboxMins min'),
                      onTap: () =>
                          _showTimeboxDialog(context, ref, timeboxMins),
                    );
                  },
                ),
                const Divider(indent: 56, height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final advanceSecs = ref.watch(
                      autoAdvanceControllerProvider,
                    );
                    return SettingsTile(
                      key: const Key('setting_auto_advance_tile'),
                      icon: Icons.speed_rounded,
                      iconColor: Colors.teal,
                      title: l10n?.autoAdvance ?? 'Auto-advance',
                      subtitle: advanceSecs == 0
                          ? (l10n?.autoAdvanceSeconds(0) ?? 'Disabled')
                          : (l10n?.autoAdvanceSeconds(advanceSecs) ??
                                '$advanceSecs sec'),
                      onTap: () =>
                          _showAutoAdvanceDialog(context, ref, advanceSecs),
                    );
                  },
                ),
                const Divider(indent: 56, height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final typeIn = ref.watch(typeInPracticeControllerProvider);
                    return SettingsTile(
                      key: const Key('setting_type_in_tile'),
                      icon: Icons.keyboard_alt_outlined,
                      iconColor: colorScheme.primary,
                      title:
                          l10n?.typeInAnswerToggle ?? 'Type-in answer practice',
                      subtitle:
                          l10n?.typeInAnswerToggleSubtitle ??
                          'Type your answer before revealing the card',
                      trailing: Switch(
                        value: typeIn,
                        onChanged: (_) {
                          ref
                              .read(typeInPracticeControllerProvider.notifier)
                              .toggle();
                        },
                      ),
                      showChevron: false,
                      onTap: () {
                        ref
                            .read(typeInPracticeControllerProvider.notifier)
                            .toggle();
                      },
                    );
                  },
                ),
                const Divider(indent: 56, height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final autoPlay = ref.watch(autoPlayAudioControllerProvider);
                    return SettingsTile(
                      key: const Key('setting_autoplay_audio_tile'),
                      icon: Icons.volume_up_outlined,
                      iconColor: Colors.blueAccent,
                      title: l10n?.autoPlayAudio ?? 'Autoplay Audio',
                      subtitle:
                          l10n?.autoPlayAudioSubtitle ??
                          'Play card audio notes automatically upon review',
                      trailing: Switch(
                        value: autoPlay,
                        onChanged: (_) {
                          ref
                              .read(autoPlayAudioControllerProvider.notifier)
                              .toggle();
                        },
                      ),
                      showChevron: false,
                      onTap: () {
                        ref
                            .read(autoPlayAudioControllerProvider.notifier)
                            .toggle();
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
