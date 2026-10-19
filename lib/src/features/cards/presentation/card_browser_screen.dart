import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/card_state_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../decks/presentation/controllers/deck_list_controller.dart';
import 'card_editor_screen.dart';
import 'controllers/card_browser_controller.dart';
import 'widgets/card_flag_color.dart';

class CardBrowserScreen extends ConsumerStatefulWidget {
  const CardBrowserScreen({super.key});

  @override
  ConsumerState<CardBrowserScreen> createState() => _CardBrowserScreenState();
}

class _CardBrowserScreenState extends ConsumerState<CardBrowserScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(cardBrowserFilterProvider).query;
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final filter = ref.watch(cardBrowserFilterProvider);
    final resultsAsync = ref.watch(cardBrowserResultsProvider);
    final decksAsync = ref.watch(deckListControllerProvider);

    final decks = decksAsync.value ?? [];
    final selectedDeck = filter.deckId != null
        ? decks.where((d) => d.deck.id == filter.deckId).firstOrNull?.deck.name
        : null;

    final hasActiveFilters = filter.query.isNotEmpty ||
        filter.deckId != null ||
        filter.flag != null ||
        filter.isSuspended != null ||
        filter.dueOnly;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.cardBrowserTitle ?? 'Card Browser'),
        actions: [
          if (hasActiveFilters)
            IconButton(
              tooltip: 'Reset filters',
              icon: const Icon(Icons.filter_alt_off_outlined),
              onPressed: () {
                _searchController.clear();
                ref.read(cardBrowserFilterProvider.notifier).reset();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              key: const Key('card_browser_search_input'),
              controller: _searchController,
              hintText:
                  l10n?.cardBrowserSearchHint ?? 'Search cards, tags, contents...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(cardBrowserFilterProvider.notifier)
                          .setQuery('');
                    },
                  ),
              ],
              onChanged: (value) {
                ref.read(cardBrowserFilterProvider.notifier).setQuery(value);
              },
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Deck Selector Chip
                PopupMenuButton<int?>(
                  tooltip: 'Filter by Deck',
                  initialValue: filter.deckId,
                  onSelected: (deckId) {
                    ref
                        .read(cardBrowserFilterProvider.notifier)
                        .setDeckId(deckId);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<int?>(
                      value: null,
                      child: Text(l10n?.filterAllDecks ?? 'All Decks'),
                    ),
                    const PopupMenuDivider(),
                    ...decks.map(
                      (d) => PopupMenuItem<int?>(
                        value: d.deck.id,
                        child: Text(d.deck.name),
                      ),
                    ),
                  ],
                  child: FilterChip(
                    avatar: const Icon(Icons.folder_outlined, size: 16),
                    label: Text(
                      selectedDeck ?? l10n?.filterAllDecks ?? 'All Decks',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: filter.deckId != null,
                    onSelected: null,
                  ),
                ),
                const SizedBox(width: 8),

                // Flag Selector Chip
                PopupMenuButton<int?>(
                  tooltip: 'Filter by Flag',
                  initialValue: filter.flag,
                  onSelected: (flag) {
                    ref.read(cardBrowserFilterProvider.notifier).setFlag(flag);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<int?>(
                      value: null,
                      child: Text('All Flags'),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<int?>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: getCardFlagColor(1), size: 18),
                          const SizedBox(width: 8),
                          const Text('Red Flag'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int?>(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: getCardFlagColor(2), size: 18),
                          const SizedBox(width: 8),
                          const Text('Orange Flag'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int?>(
                      value: 3,
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: getCardFlagColor(3), size: 18),
                          const SizedBox(width: 8),
                          const Text('Green Flag'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int?>(
                      value: 4,
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: getCardFlagColor(4), size: 18),
                          const SizedBox(width: 8),
                          const Text('Blue Flag'),
                        ],
                      ),
                    ),
                  ],
                  child: FilterChip(
                    avatar: Icon(
                      Icons.flag,
                      size: 16,
                      color: filter.flag != null
                          ? getCardFlagColor(filter.flag!)
                          : null,
                    ),
                    label: Text(
                      filter.flag != null
                          ? 'Flag ${filter.flag}'
                          : (l10n?.filterFlag ?? 'Flag'),
                    ),
                    selected: filter.flag != null,
                    onSelected: null,
                  ),
                ),
                const SizedBox(width: 8),

                // Suspended Filter Chip
                FilterChip(
                  key: const Key('card_browser_suspended_chip'),
                  avatar: const Icon(Icons.pause_circle_outline, size: 16),
                  label: Text(l10n?.filterSuspended ?? 'Suspended'),
                  selected: filter.isSuspended == true,
                  onSelected: (selected) {
                    ref
                        .read(cardBrowserFilterProvider.notifier)
                        .setSuspended(selected ? true : null);
                  },
                ),
                const SizedBox(width: 8),

                // Due Filter Chip
                FilterChip(
                  key: const Key('card_browser_due_chip'),
                  avatar: const Icon(Icons.schedule, size: 16),
                  label: Text(l10n?.filterDue ?? 'Due'),
                  selected: filter.dueOnly,
                  onSelected: (selected) {
                    ref
                        .read(cardBrowserFilterProvider.notifier)
                        .setDueOnly(selected);
                  },
                ),
              ],
            ),
          ),

          // Count indicator & Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                resultsAsync.maybeWhen(
                  data: (results) {
                    if (results.isEmpty) return const SizedBox.shrink();
                    return Text(
                      l10n?.cardsFoundCount(results.length) ??
                          '${results.length} cards found',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results list
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ErrorView(
                title: l10n?.cards ?? 'Cards',
                error: err,
                onRetry: () => ref.invalidate(globalCardsStreamProvider),
              ),
              data: (cards) {
                if (cards.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 48,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n?.cardsFoundCount(0) ?? 'No cards found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try adjusting your search query or filter chips.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: cards.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = cards[index];
                    final card = item.card;

                    return Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CardEditorScreen(
                                deckId: card.deckId,
                                cardId: card.id,
                                initialFront: card.front,
                                initialBack: card.back,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top badges row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.deckName,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme
                                          .cardStateColor(card.state)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      cardStateName(card.state, l10n),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.cardStateColor(
                                          card.state,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (card.isSuspended) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        l10n?.filterSuspended ?? 'Suspended',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onErrorContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  if (card.flag > 0)
                                    Icon(
                                      Icons.flag,
                                      size: 16,
                                      color: getCardFlagColor(card.flag),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Front text
                              Text(
                                card.front,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Back text
                              Text(
                                card.back,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
