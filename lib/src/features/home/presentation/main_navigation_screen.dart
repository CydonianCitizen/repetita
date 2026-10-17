import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../decks/presentation/deck_list_screen.dart';
import '../../settings/data/haptic_service.dart';
import '../../settings/presentation/controllers/haptic_controller.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stats/presentation/stats_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;
  final Set<int> _activatedIndices = {0};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _activatedIndices.add(_currentIndex);

    const MethodChannel('com.repetita.app/menu')
        .setMethodCallHandler((call) async {
          if (call.method == 'openPreferences') {
            _onDestinationSelected(2);
          }
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rollingBackupServiceProvider).checkAndPerformAutoBackup();
    });
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    final hapticIntensity = ref.read(hapticFeedbackControllerProvider);
    ref.read(hapticServiceProvider).triggerSelection(hapticIntensity);
    setState(() {
      _currentIndex = index;
      _activatedIndices.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final bodyStack = IndexedStack(
      index: _currentIndex,
      children: [
        const DeckListScreen(),
        _activatedIndices.contains(1)
            ? const StatsScreen(isEmbedded: true)
            : const SizedBox.shrink(),
        _activatedIndices.contains(2)
            ? const SettingsScreen(isEmbedded: true)
            : const SizedBox.shrink(),
      ],
    );

    Widget screen = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.comma, meta: true): () {
          _onDestinationSelected(2);
        },
        const SingleActivator(LogicalKeyboardKey.comma, control: true): () {
          _onDestinationSelected(2);
        },
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 640;

            if (isWideScreen) {
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: _onDestinationSelected,
                      labelType: NavigationRailLabelType.all,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Icon(
                            Icons.school_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                      destinations: [
                        NavigationRailDestination(
                          icon: const Icon(
                            Icons.style_outlined,
                            key: Key('nav_decks'),
                          ),
                          selectedIcon: const Icon(Icons.style),
                          label: Text(l10n?.navHome ?? 'Decks'),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(
                            Icons.bar_chart_outlined,
                            key: Key('nav_stats'),
                          ),
                          selectedIcon: const Icon(Icons.bar_chart),
                          label: Text(l10n?.navStats ?? 'Stats'),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(
                            Icons.settings_outlined,
                            key: Key('nav_settings'),
                          ),
                          selectedIcon: const Icon(Icons.settings),
                          label: Text(l10n?.navSettings ?? 'Settings'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: bodyStack),
                  ],
                ),
              );
            }

            return Scaffold(
              body: bodyStack,
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onDestinationSelected,
                destinations: [
                  NavigationDestination(
                    key: const Key('nav_decks'),
                    icon: const Icon(Icons.style_outlined),
                    selectedIcon: const Icon(Icons.style),
                    label: l10n?.navHome ?? 'Decks',
                  ),
                  NavigationDestination(
                    key: const Key('nav_stats'),
                    icon: const Icon(Icons.bar_chart_outlined),
                    selectedIcon: const Icon(Icons.bar_chart),
                    label: l10n?.navStats ?? 'Stats',
                  ),
                  NavigationDestination(
                    key: const Key('nav_settings'),
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    label: l10n?.navSettings ?? 'Settings',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      screen = PlatformMenuBar(
        menus: [
          PlatformMenu(
            label: 'Repetita',
            menus: [
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.about,
              ),
              PlatformMenuItem(
                label: 'Preferences…',
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.comma,
                  meta: true,
                ),
                onSelected: () => _onDestinationSelected(2),
              ),
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.servicesSubmenu,
              ),
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.hide,
              ),
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.hideOtherApplications,
              ),
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.showAllApplications,
              ),
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit,
              ),
            ],
          ),
        ],
        child: screen,
      );
    }

    return screen;
  }
}
