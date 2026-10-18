import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../backup_transfer/presentation/backup_screen.dart';
import 'screens/about_settings_screen.dart';
import 'screens/appearance_settings_screen.dart';
import 'screens/language_settings_screen.dart';
import 'screens/study_algorithm_settings_screen.dart';
import 'screens/updates_settings_screen.dart';
import 'widgets/section_header.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTitle ?? 'Settings'),
        automaticallyImplyLeading: !isEmbedded,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Section 1: Appearance & Motion
            SectionHeader(title: l10n?.sectionAppearance ?? 'APPEARANCE'),
            SettingsCard(
              children: [
                SettingsTile(
                  key: const Key('setting_appearance_tile'),
                  icon: Icons.palette_outlined,
                  iconColor: colorScheme.primary,
                  title:
                      l10n?.settingsAppearanceTitle ?? 'Appearance & Display',
                  subtitle:
                      l10n?.settingsAppearanceDesc ?? 'Theme, display, motion',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AppearanceSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 2: Study & Algorithm
            SectionHeader(
              title: l10n?.sectionStudyAlgorithm ?? 'STUDY & ALGORITHM',
            ),
            SettingsCard(
              children: [
                SettingsTile(
                  key: const Key('setting_study_algorithm_tile'),
                  icon: Icons.psychology_rounded,
                  iconColor: colorScheme.secondary,
                  title:
                      l10n?.settingsStudyAlgorithmTitle ?? 'Study & Scheduling',
                  subtitle:
                      l10n?.settingsStudyAlgorithmDesc ??
                      'FSRS, retention, reminders',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const StudyAlgorithmSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 3: Language & Localization
            SectionHeader(
              title: l10n?.sectionLanguage ?? 'LANGUAGE & LOCALIZATION',
            ),
            SettingsCard(
              children: [
                SettingsTile(
                  key: const Key('setting_language_tile'),
                  icon: Icons.translate_rounded,
                  iconColor: colorScheme.secondary,
                  title: l10n?.language ?? 'Language',
                  subtitle: l10n?.settingsLanguageDesc ?? 'Interface language',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LanguageSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 4: Data & Backup
            SectionHeader(title: l10n?.sectionDataBackup ?? 'DATA & BACKUP'),
            SettingsCard(
              children: [
                SettingsTile(
                  key: const Key('setting_backup_tile'),
                  icon: Icons.backup_outlined,
                  iconColor: colorScheme.primary,
                  title: l10n?.backup ?? 'Backup & Restore',
                  subtitle: l10n?.settingsBackupDesc ?? 'JSON & CSV transfer',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BackupScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 5: Updates & Releases
            SectionHeader(title: l10n?.sectionUpdates ?? 'UPDATES & RELEASES'),
            SettingsCard(
              children: [
                SettingsTile(
                  key: const Key('setting_updates_tile'),
                  icon: Icons.system_update_alt_rounded,
                  iconColor: colorScheme.primary,
                  title: l10n?.settingsUpdatesTitle ?? 'Updates',
                  subtitle:
                      l10n?.settingsUpdatesDesc ?? 'Check GitHub releases',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const UpdatesSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 6: About & Privacy
            SectionHeader(title: l10n?.sectionAbout ?? 'ABOUT & PRIVACY'),
            SettingsCard(
              children: [
                SettingsTile(
                  key: const Key('setting_about_tile'),
                  icon: Icons.info_outline_rounded,
                  iconColor: colorScheme.outline,
                  title: l10n?.settingsAboutTitle ?? 'About & Credits',
                  subtitle: l10n?.settingsAboutDesc ?? 'MIT License & credits',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutSettingsScreen(),
                      ),
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
