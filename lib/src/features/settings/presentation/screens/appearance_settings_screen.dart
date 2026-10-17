import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../data/haptic_service.dart';
import '../../domain/animation_level.dart';
import '../../domain/app_theme_mode.dart';
import '../../domain/haptic_intensity.dart';
import '../../domain/refresh_rate_preference.dart';
import '../controllers/animation_level_controller.dart';
import '../controllers/haptic_controller.dart';
import '../controllers/refresh_rate_controller.dart';
import '../controllers/theme_mode_controller.dart';
import '../dialogs/refresh_rate_dialog.dart';
import '../dialogs/theme_selector_dialog.dart';
import '../widgets/level_slider.dart';
import '../widgets/section_header.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_tile.dart';

class AppearanceSettingsScreen extends ConsumerStatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  ConsumerState<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends ConsumerState<AppearanceSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _previewAnimController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _previewAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_previewAnimController);
  }

  @override
  void dispose() {
    _previewAnimController.dispose();
    super.dispose();
  }

  void _triggerMotionPreview(AnimationLevel level) {
    if (level.isReduced) {
      return;
    }
    _previewAnimController.forward(from: 0.0);
  }

  String _themeModeLabel(AppThemeMode mode, AppLocalizations? l10n) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n?.themeSystem ?? 'System Default';
      case AppThemeMode.dark:
        return l10n?.themeDark ?? 'Dark Theme';
      case AppThemeMode.light:
        return l10n?.themeLight ?? 'Light Theme';
      case AppThemeMode.amoled:
        return l10n?.themeAmoled ?? 'AMOLED (Pure Black)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsAppearanceTitle ?? 'Appearance & Display'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Theme and Display
            SectionHeader(title: l10n?.themeMode ?? 'THEME & DISPLAY'),
            SettingsCard(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final themeMode = ref.watch(themeModeControllerProvider);
                    return SettingsTile(
                      key: const Key('setting_theme_tile'),
                      icon: Icons.palette_outlined,
                      iconColor: colorScheme.primary,
                      title: l10n?.themeMode ?? 'Theme Mode',
                      subtitle: _themeModeLabel(themeMode, l10n),
                      onTap: () => ThemeSelectorDialog.show(context),
                    );
                  },
                ),
                if (!isDesktop) ...[
                  const Divider(indent: 56, height: 1),
                  Consumer(
                    builder: (context, ref, _) {
                      final refreshPref = ref.watch(
                        refreshRateControllerProvider,
                      );
                      return SettingsTile(
                        key: const Key('setting_refresh_rate_tile'),
                        icon: Icons.speed_rounded,
                        iconColor: colorScheme.secondary,
                        title: l10n?.refreshRate ?? 'Refresh Rate',
                        subtitle: switch (refreshPref) {
                          RefreshRatePreference.system =>
                            l10n?.refreshRateAuto ?? 'System (Dynamic)',
                          RefreshRatePreference.powerSave =>
                            l10n?.refreshRatePowerSave ?? '60 Hz (Power Save)',
                          RefreshRatePreference.high =>
                            l10n?.refreshRateHigh ?? '90/120 Hz (High)',
                        },
                        onTap: () => RefreshRateDialog.show(context),
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Animations and Motion
            SectionHeader(
              title: l10n?.animationIntensity ?? 'ANIMATIONS & MOTION',
            ),
            SettingsCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final animLevel = ref.watch(
                      animationLevelControllerProvider,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.tertiary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.animation_rounded,
                                color: colorScheme.tertiary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n?.animationIntensity ??
                                        'Animation Intensity',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    l10n?.animationIntensitySubtitle ??
                                        'Motion and transitions',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Expressive pill badge
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      switch (animLevel) {
                                        AnimationLevel.reduced =>
                                          Icons.motion_photos_off_outlined,
                                        AnimationLevel.standard =>
                                          Icons.motion_photos_auto_outlined,
                                        AnimationLevel.expressive =>
                                          Icons.auto_awesome_rounded,
                                      },
                                      size: 14,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      switch (animLevel) {
                                        AnimationLevel.reduced =>
                                          l10n?.animationReduced ?? 'Reduced',
                                        AnimationLevel.standard =>
                                          l10n?.animationStandard ?? 'Standard',
                                        AnimationLevel.expressive =>
                                          l10n?.animationExpressive ??
                                              'Expressive',
                                      },
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme
                                                .onSecondaryContainer,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LevelSlider(
                          sliderKey: const Key('setting_animation_slider'),
                          value: animLevel.value.toDouble(),
                          divisions: 2,
                          labels: [
                            l10n?.animationReduced ?? 'Reduced',
                            l10n?.animationStandard ?? 'Standard',
                            l10n?.animationExpressive ?? 'Expressive',
                          ],
                          activeIndex: animLevel.value,
                          onChanged: (val) {
                            final newLevel = AnimationLevel.fromValue(
                              val.round(),
                            );
                            ref
                                .read(animationLevelControllerProvider.notifier)
                                .setLevel(newLevel);
                            _triggerMotionPreview(newLevel);
                          },
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  switch (animLevel) {
                                    AnimationLevel.reduced =>
                                      l10n?.animationReducedDesc ??
                                          'Instant, battery saver',
                                    AnimationLevel.standard =>
                                      l10n?.animationStandardDesc ??
                                          'Fluid, balanced motion',
                                    AnimationLevel.expressive =>
                                      l10n?.animationExpressiveDesc ??
                                          'Dynamic spring motion',
                                  },
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                key: const Key('test_motion_button'),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(48, 36),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () =>
                                    _triggerMotionPreview(animLevel),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.touch_app_rounded,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n?.testMotion ?? 'Test Motion',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            if (!isDesktop) ...[
              const SizedBox(height: 20),
              SectionHeader(title: l10n?.hapticFeedback ?? 'HAPTIC FEEDBACK'),
              SettingsCard(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final hapticIntensity = ref.watch(
                        hapticFeedbackControllerProvider,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.vibration_rounded,
                                  color: colorScheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.hapticFeedback ?? 'Haptic Feedback',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      l10n?.hapticFeedbackSubtitle ??
                                          'Touch vibration response',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      switch (hapticIntensity) {
                                        HapticIntensity.off =>
                                          Icons.notifications_off_outlined,
                                        HapticIntensity.light =>
                                          Icons.touch_app_outlined,
                                        HapticIntensity.medium =>
                                          Icons.vibration_rounded,
                                        HapticIntensity.strong =>
                                          Icons.sensors_rounded,
                                      },
                                      size: 14,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      switch (hapticIntensity) {
                                        HapticIntensity.off =>
                                          l10n?.hapticOff ?? 'Off',
                                        HapticIntensity.light =>
                                          l10n?.hapticLight ?? 'Light',
                                        HapticIntensity.medium =>
                                          l10n?.hapticMedium ?? 'Medium',
                                        HapticIntensity.strong =>
                                          l10n?.hapticStrong ?? 'Strong',
                                      },
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme
                                                .onSecondaryContainer,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LevelSlider(
                            sliderKey: const Key('setting_haptic_slider'),
                            value: hapticIntensity.level.toDouble(),
                            divisions: 3,
                            labels: [
                              l10n?.hapticOff ?? 'Off',
                              l10n?.hapticLight ?? 'Light',
                              l10n?.hapticMedium ?? 'Medium',
                              l10n?.hapticStrong ?? 'Strong',
                            ],
                            activeIndex: hapticIntensity.level,
                            onChanged: (val) {
                              final newIntensity = HapticIntensity.fromLevel(
                                val.round(),
                              );
                              ref
                                  .read(
                                    hapticFeedbackControllerProvider.notifier,
                                  )
                                  .setIntensity(newIntensity);
                              ref
                                  .read(hapticServiceProvider)
                                  .triggerTest(newIntensity);
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    switch (hapticIntensity) {
                                      HapticIntensity.off =>
                                        l10n?.hapticOffDesc ?? 'No vibration',
                                      HapticIntensity.light =>
                                        l10n?.hapticLightDesc ??
                                            'Subtle clicks',
                                      HapticIntensity.medium =>
                                        l10n?.hapticMediumDesc ??
                                            'Balanced pulse',
                                      HapticIntensity.strong =>
                                        l10n?.hapticStrongDesc ??
                                            'Strong pulse',
                                    },
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonal(
                                  key: const Key('test_haptic_button'),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(48, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => ref
                                      .read(hapticServiceProvider)
                                      .triggerTest(hapticIntensity),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.vibration_rounded,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n?.testHaptic ?? 'Test Haptics',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
