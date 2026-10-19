import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/error_view.dart';
import '../../cards/presentation/deck_detail_screen.dart';
import '../data/sample_deck_seeder.dart';
import '../domain/deck_hierarchy.dart';
import 'controllers/deck_list_controller.dart';
import 'widgets/deck_form_dialog.dart';
import 'widgets/deck_list_tile.dart';

class DeckListScreen extends ConsumerStatefulWidget {
  const DeckListScreen({super.key});

  @override
  ConsumerState<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends ConsumerState<DeckListScreen> {
  final Set<String> _collapsedDeckNames = {};

  Future<void> _handleCreateDeck(BuildContext context) async {
    final result = await DeckFormDialog.show(context);
    if (result != null) {
      try {
        await ref
            .read(deckListControllerProvider.notifier)
            .createDeck(name: result.name, description: result.description);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create deck: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _seedSampleDeck(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final db = ref.read(databaseProvider);
      await SampleDeckSeeder.seed(db);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.sampleDeckLoaded ?? 'Sample deck loaded successfully!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sample deck: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(deckListControllerProvider);
    final l10n = AppLocalizations.of(context);
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appTitle ?? 'repetita'),
        actions: [
          if (isDesktop) ...[
            IconButton(
              key: const Key('load_sample_deck_appbar_button'),
              tooltip: l10n?.loadSampleDeck ?? 'Load Sample Deck',
              icon: const Icon(Icons.school_outlined),
              onPressed: () => _seedSampleDeck(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FilledButton.icon(
                key: const Key('create_deck_desktop_button'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n?.newDeck ?? 'New Deck'),
                onPressed: () => _handleCreateDeck(context),
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: decksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ErrorView(
            title: l10n?.failedToLoadDecks ?? 'Failed to load decks',
            error: error,
            onRetry: () => ref.invalidate(deckListControllerProvider),
          ),
          data: (decks) {
            if (decks.isEmpty) {
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.style_outlined,
                          size: 44,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n?.noDecksYet ??
                            'No decks yet. Tap + to create one.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.createFirstDeckPrompt ?? 'Create your first deck to begin spaced repetition studying.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _handleCreateDeck(context),
                        icon: const Icon(Icons.add),
                        label: Text(l10n?.newDeck ?? 'New Deck'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const Key('seed_sample_deck_button'),
                        onPressed: () => _seedSampleDeck(context),
                        icon: const Icon(Icons.school_outlined),
                        label: Text(l10n?.loadSampleDeck ?? 'Load Sample Deck'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final tree = DeckHierarchyHelper.buildTree(decks);
            final flattened = DeckHierarchyHelper.flatten(
              tree,
              collapsedDeckNames: _collapsedDeckNames,
            );

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: flattened.length,
              itemBuilder: (context, index) {
                final item = flattened[index];
                final node = item.node;
                final deckWithCounts = node.deckWithCounts;

                return DeckListTile(
                  key: ValueKey(deckWithCounts.deck.id),
                  deckWithCounts: deckWithCounts,
                  node: node,
                  isCollapsed: item.isCollapsed,
                  onToggleCollapse: () {
                    setState(() {
                      if (item.isCollapsed) {
                        _collapsedDeckNames.remove(node.fullPath);
                      } else {
                        _collapsedDeckNames.add(node.fullPath);
                      }
                    });
                  },
                  onTap: () {
                    if (node.isVirtual) {
                      setState(() {
                        if (item.isCollapsed) {
                          _collapsedDeckNames.remove(node.fullPath);
                        } else {
                          _collapsedDeckNames.add(node.fullPath);
                        }
                      });
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DeckDetailScreen(deck: deckWithCounts.deck),
                      ),
                    );
                  },
                  onEdit: (name, description) async {
                    try {
                      await ref
                          .read(deckListControllerProvider.notifier)
                          .updateDeck(
                            id: deckWithCounts.deck.id,
                            name: name,
                            description: description,
                          );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update deck: $e'),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                        );
                      }
                    }
                  },
                  onDelete: () async {
                    try {
                      await ref
                          .read(deckListControllerProvider.notifier)
                          .deleteDeck(deckWithCounts.deck.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete deck: $e'),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton(
              key: const Key('create_deck_fab'),
              tooltip: l10n?.createDeck ?? 'Create Deck',
              onPressed: () => _handleCreateDeck(context),
              child: const Icon(Icons.add),
            ),
    );
  }
}
