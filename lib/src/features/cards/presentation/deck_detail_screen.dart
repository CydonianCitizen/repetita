import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/algorithms/cloze/cloze_parser.dart';
import '../../../core/database/app_database.dart' show Deck;
import '../../../core/database/database_provider.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/card_state_colors.dart';
import '../../../core/utils/clock_provider.dart';
import '../../../core/widgets/error_view.dart';
import '../../decks/presentation/widgets/exam_plan_card.dart';
import '../../study_session/presentation/study_screen.dart';
import '../../study_session/presentation/widgets/custom_study_dialog.dart';
import '../../tags/domain/tag_entity.dart';
import '../../tags/presentation/controllers/tags_controller.dart';
import '../domain/card_entity.dart';
import 'card_editor_screen.dart';
import 'controllers/card_list_controller.dart';
import 'widgets/card_flag_color.dart';

class DeckDetailScreen extends ConsumerStatefulWidget {
  const DeckDetailScreen({super.key, required this.deck});

  final Deck deck;

  @override
  ConsumerState<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends ConsumerState<DeckDetailScreen> {
  bool _isSearching = false;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    ref.read(deckCardSearchQueryProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cardsAsync = ref.watch(cardListControllerProvider(widget.deck.id));
    final deckTagsAsync = ref.watch(deckTagsProvider(widget.deck.id));

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                key: const Key('deck_search_field'),
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n?.searchCards ?? 'Search cards...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => ref
                    .read(deckCardSearchQueryProvider.notifier)
                    .setQuery(val),
              )
            : Text(widget.deck.name),
        actions: [
          if (_isSearching)
            IconButton(
              key: const Key('clear_search_button'),
              tooltip: l10n?.clearSearch ?? 'Clear search',
              icon: const Icon(Icons.close),
              onPressed: _closeSearch,
            )
          else
            IconButton(
              key: const Key('search_cards_button'),
              icon: const Icon(Icons.search),
              tooltip: l10n?.search ?? 'Search',
              onPressed: () => setState(() => _isSearching = true),
            ),
        ],
      ),
      body: SafeArea(
        child: cardsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(
            title: 'Error loading cards',
            error: error,
            onRetry: () =>
                ref.invalidate(cardListControllerProvider(widget.deck.id)),
          ),
          data: (cards) {
            final cardTagsMap = deckTagsAsync.value ?? <int, List<TagEntity>>{};
            final allDeckTags =
                cardTagsMap.values
                    .expand((tags) => tags)
                    .fold<Map<int, TagEntity>>({}, (map, tag) {
                      map[tag.id] = tag;
                      return map;
                    })
                    .values
                    .toList()
                  ..sort((a, b) => a.name.compareTo(b.name));

            final now = ref.watch(clockProvider)();
            final dueCount = cards.where((c) => c.isDue(now)).length;

            final deckStream = ref
                .watch(decksDaoProvider)
                .watchDeckById(widget.deck.id);

            return StreamBuilder<Deck?>(
              stream: deckStream,
              initialData: widget.deck,
              builder: (context, deckSnap) {
                final currentDeck = deckSnap.data ?? widget.deck;
                return Column(
                  children: [
                    _DeckStudyHeader(
                      deck: currentDeck,
                      cards: cards,
                      dueCount: dueCount,
                      allDeckTags: allDeckTags,
                    ),
                    ExamPlanCard(
                      deck: currentDeck,
                      cards: cards,
                      now: now,
                      onSetExamDate: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              currentDeck.examDate ??
                              now.add(const Duration(days: 30)),
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          await ref
                              .read(decksDaoProvider)
                              .setDeckExamDate(
                                deckId: currentDeck.id,
                                examDate: picked,
                              );
                        }
                      },
                      onClearExamDate: () async {
                        await ref
                            .read(decksDaoProvider)
                            .setDeckExamDate(
                              deckId: currentDeck.id,
                              examDate: null,
                              targetRetention: null,
                            );
                      },
                    ),
                    Expanded(
                      child: _DeckCardsSection(
                        deck: currentDeck,
                        cards: cards,
                        allDeckTags: allDeckTags,
                        cardTagsMap: cardTagsMap,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_card_fab'),
        tooltip: l10n?.addCard ?? 'Add Card',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CardEditorScreen(deckId: widget.deck.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    super.key,
    required this.card,
    this.tags = const [],
    required this.now,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleSuspend,
    required this.onToggleBury,
    required this.onSetDueDate,
    required this.onResetProgress,
    required this.onDuplicate,
    required this.onSetFlag,
  });

  final CardEntity card;
  final List<TagEntity> tags;
  final DateTime now;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final Future<void> Function() onToggleSuspend;
  final Future<void> Function() onToggleBury;
  final Future<void> Function(DateTime newDue) onSetDueDate;
  final Future<void> Function() onResetProgress;
  final Future<void> Function() onDuplicate;
  final Future<void> Function(int flag) onSetFlag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: ValueKey('dismiss_${card.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: scheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n?.delete ?? 'Delete'),
                content: Text(
                  l10n?.deleteCardConfirmation ??
                      'Are you sure you want to delete this card?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l10n?.cancel ?? 'Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(l10n?.delete ?? 'Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) async => await onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        card.isCloze
                            ? ClozeParser.renderClozePrompt(
                                card.front,
                                activeIndex: card.activeClozeIndex,
                              )
                            : card.front,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (card.isCloze)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n?.clozeBadge(card.activeClozeIndex) ??
                                  'Cloze c${card.activeClozeIndex}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (card.isSuspended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n?.suspendedBadge ?? 'Suspended',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (card.isBuried(now))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n?.buriedBadge ?? 'Buried',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (card.flag > 0)
                          Icon(
                            Icons.flag_rounded,
                            size: 16,
                            color: getCardFlagColor(card.flag),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme
                                .cardStateColor(card.state)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cardStateName(card.state, l10n),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.cardStateColor(card.state),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      onSelected: (value) async {
                        if (value == 'edit') onEdit();
                        if (value == 'setDueDate') {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: card.due,
                            firstDate: now.subtract(const Duration(days: 365)),
                            lastDate: now.add(const Duration(days: 3650)),
                          );
                          if (picked != null) {
                            await onSetDueDate(picked);
                          }
                        }
                        if (value == 'resetProgress') {
                          if (!context.mounted) return;
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                l10n?.resetProgress ?? 'Reset Progress',
                              ),
                              content: Text(
                                l10n?.resetProgressConfirmation ?? 'Are you sure you want to reset this card\'s SRS progress? It will become a new card, but review logs are kept.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(l10n?.cancel ?? 'Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(l10n?.resetProgress ?? 'Reset'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await onResetProgress();
                          }
                        }

                        if (value == 'duplicate') await onDuplicate();
                        if (value == 'flag') {
                          if (!context.mounted) return;
                          final chosen = await showDialog<int>(
                            context: context,
                            builder: (ctx) => SimpleDialog(
                              title: Text(l10n?.flag ?? 'Flag'),
                              children: [
                                SimpleDialogOption(
                                  onPressed: () => Navigator.of(ctx).pop(0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.outlined_flag, size: 20),
                                      const SizedBox(width: 12),
                                      Text(l10n?.flagNone ?? 'No Flag'),
                                    ],
                                  ),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => Navigator.of(ctx).pop(1),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.flag,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(l10n?.flagRed ?? 'Red Flag'),
                                    ],
                                  ),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => Navigator.of(ctx).pop(2),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.flag,
                                        size: 20,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(l10n?.flagOrange ?? 'Orange Flag'),
                                    ],
                                  ),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => Navigator.of(ctx).pop(3),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.flag,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(l10n?.flagGreen ?? 'Green Flag'),
                                    ],
                                  ),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => Navigator.of(ctx).pop(4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.flag,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(l10n?.flagBlue ?? 'Blue Flag'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (chosen != null) {
                            await onSetFlag(chosen);
                          }
                        }
                        if (value == 'suspend') await onToggleSuspend();
                        if (value == 'bury') await onToggleBury();
                        if (value == 'delete') await onDelete();
                      },
                      itemBuilder: (context) {
                        final itemL10n = AppLocalizations.of(context);
                        final isBuried = card.isBuried(now);
                        return [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(itemL10n?.edit ?? 'Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'setDueDate',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(itemL10n?.setDueDate ?? 'Set Due Date'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'resetProgress',
                            child: Row(
                              children: [
                                const Icon(Icons.restart_alt_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  itemL10n?.resetProgress ?? 'Reset Progress',
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                const Icon(Icons.copy_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  itemL10n?.duplicateCard ?? 'Duplicate Card',
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'flag',
                            child: Row(
                              children: [
                                Icon(
                                  card.flag > 0
                                      ? Icons.flag
                                      : Icons.outlined_flag,
                                  size: 18,
                                  color: card.flag > 0
                                      ? getCardFlagColor(card.flag)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(itemL10n?.flag ?? 'Flag'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),

                          PopupMenuItem(
                            value: 'suspend',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.pause_circle_outline,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  card.isSuspended
                                      ? (itemL10n?.unsuspendCard ??
                                            'Unsuspend Card')
                                      : (itemL10n?.suspendCard ??
                                            'Suspend Card'),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'bury',
                            child: Row(
                              children: [
                                const Icon(Icons.alarm_off, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  isBuried
                                      ? (itemL10n?.unburyCard ?? 'Unbury Card')
                                      : (itemL10n?.buryCard ?? 'Bury Card'),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: scheme.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  itemL10n?.delete ?? 'Delete',
                                  style: TextStyle(color: scheme.error),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  card.back,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags.map((tag) {
                      final tagColor = tag.color != 0
                          ? Color(tag.color)
                          : scheme.secondary;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: tagColor.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '#${tag.name}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tagColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (card.state == 0)
                      Text(
                        'New card • Unreviewed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      )
                    else ...[
                      Text(
                        'S: ${card.stability.toStringAsFixed(1)}d',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'D: ${card.difficulty.toStringAsFixed(1)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reps: ${card.reps}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckStudyHeader extends StatelessWidget {
  const _DeckStudyHeader({
    required this.deck,
    required this.cards,
    required this.dueCount,
    required this.allDeckTags,
  });

  final Deck deck;
  final List<CardEntity> cards;
  final int dueCount;
  final List<TagEntity> allDeckTags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.cardsDueForReview(dueCount) ??
                    '$dueCount cards due for review',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const Key('start_study_button'),
                onPressed: dueCount > 0
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StudyScreen(deckId: deck.id),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n?.startStudySession ?? 'Start Study Session'),
              ),
              OutlinedButton.icon(
                key: const Key('custom_study_button'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onPrimaryContainer,
                  side: BorderSide(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                onPressed: cards.isEmpty
                    ? null
                    : () async {
                        final config = await CustomStudyDialog.show(
                          context,
                          deckId: deck.id,
                          initialTags: allDeckTags,
                        );
                        if (config != null && context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StudyScreen(
                                deckId: deck.id,
                                customStudyConfig: config,
                              ),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.tune_rounded),
                label: Text(l10n?.customStudy ?? 'Custom Study'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeckCardsSection extends ConsumerWidget {
  const _DeckCardsSection({
    required this.deck,
    required this.cards,
    required this.allDeckTags,
    required this.cardTagsMap,
  });

  final Deck deck;
  final List<CardEntity> cards;
  final List<TagEntity> allDeckTags;
  final Map<int, List<TagEntity>> cardTagsMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final selectedTagId = ref.watch(deckTagFilterProvider);
    final selectedFlag = ref.watch(deckCardFlagFilterProvider);
    final displayedCards = ref.watch(filteredDeckCardsProvider(deck.id));
    final now = ref.watch(clockProvider)();

    final cardIndexMap = <int, int>{
      for (int i = 0; i < displayedCards.length; i++) displayedCards[i].id: i,
    };

    Future<void> runCardAction(
      Future<void> Function() action,
      String errorMessage,
    ) async {
      try {
        await action();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$errorMessage: $e'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    }

    return Column(
      children: [
        if (allDeckTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allDeckTags.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: const Key('filter_tag_all'),
                        label: Text(l10n?.filterAll ?? 'All'),
                        selected: selectedTagId == null,
                        onSelected: (_) => ref
                            .read(deckTagFilterProvider.notifier)
                            .selectTag(null),
                      ),
                    );
                  }
                  final tag = allDeckTags[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      key: Key('filter_tag_${tag.id}'),
                      label: Text('#${tag.name}'),
                      selected: selectedTagId == tag.id,
                      onSelected: (selected) => ref
                          .read(deckTagFilterProvider.notifier)
                          .selectTag(selected ? tag.id : null),
                      onDeleted: () => _showDeleteTagDialog(context, ref, tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      deleteButtonTooltipMessage: 'Delete tag',
                    ),
                  );
                },
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    key: const Key('filter_flag_all'),
                    label: Text(l10n?.filterFlag ?? 'Flag'),
                    selected: selectedFlag == null,
                    onSelected: (_) =>
                        ref.read(deckCardFlagFilterProvider.notifier).clear(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: const Icon(Icons.flag, size: 16, color: Colors.red),
                    label: Text(l10n?.flagRed ?? 'Red'),
                    selected: selectedFlag == 1,
                    onSelected: (selected) {
                      ref
                          .read(deckCardFlagFilterProvider.notifier)
                          .setFilter(selected ? 1 : null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: const Icon(
                      Icons.flag,
                      size: 16,
                      color: Colors.orange,
                    ),
                    label: Text(l10n?.flagOrange ?? 'Orange'),
                    selected: selectedFlag == 2,
                    onSelected: (selected) {
                      ref
                          .read(deckCardFlagFilterProvider.notifier)
                          .setFilter(selected ? 2 : null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: const Icon(
                      Icons.flag,
                      size: 16,
                      color: Colors.green,
                    ),
                    label: Text(l10n?.flagGreen ?? 'Green'),
                    selected: selectedFlag == 3,
                    onSelected: (selected) {
                      ref
                          .read(deckCardFlagFilterProvider.notifier)
                          .setFilter(selected ? 3 : null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: const Icon(
                      Icons.flag,
                      size: 16,
                      color: Colors.blue,
                    ),
                    label: Text(l10n?.flagBlue ?? 'Blue'),
                    selected: selectedFlag == 4,
                    onSelected: (selected) {
                      ref
                          .read(deckCardFlagFilterProvider.notifier)
                          .setFilter(selected ? 4 : null);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    label: Text(l10n?.filterLeech ?? 'Leech'),
                    selected: selectedFlag == -1,
                    onSelected: (selected) {
                      ref
                          .read(deckCardFlagFilterProvider.notifier)
                          .setFilter(selected ? -1 : null);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Cards (${displayedCards.length}${displayedCards.length != cards.length ? ' / ${cards.length}' : ''})',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: cards.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.post_add_rounded,
                            size: 36,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cards in this deck yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    CardEditorScreen(deckId: deck.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n?.addCard ?? 'Add Card'),
                        ),
                      ],
                    ),
                  ),
                )
              : displayedCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_outlined,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.noCardsMatchingSearch ??
                            'No cards match your search.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(deckTagFilterProvider.notifier)
                              .selectTag(null);
                          ref
                              .read(deckCardSearchQueryProvider.notifier)
                              .clear();
                        },
                        child: Text(l10n?.filterAll ?? 'Show all cards'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  scrollCacheExtent: const ScrollCacheExtent.pixels(500.0),
                  padding: const EdgeInsets.only(bottom: 80),
                  findChildIndexCallback: (Key key) {
                    if (key is ValueKey<int>) {
                      return cardIndexMap[key.value];
                    }
                    return null;
                  },
                  itemCount: displayedCards.length,
                  itemBuilder: (context, index) {
                    final card = displayedCards[index];
                    final cardTags =
                        cardTagsMap[card.id] ?? const <TagEntity>[];
                    return _CardTile(
                      key: ValueKey(card.id),
                      card: card,
                      tags: cardTags,
                      now: now,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CardEditorScreen(
                              deckId: deck.id,
                              cardId: card.id,
                              initialFront: card.front,
                              initialBack: card.back,
                            ),
                          ),
                        );
                      },
                      onDelete: () => runCardAction(
                        () => ref
                            .read(cardListControllerProvider(deck.id).notifier)
                            .deleteCard(card.id),
                        'Failed to delete card',
                      ),
                      onToggleSuspend: () => runCardAction(
                        () => ref
                            .read(cardListControllerProvider(deck.id).notifier)
                            .toggleSuspendCard(card.id, card.isSuspended),
                        'Failed to update card',
                      ),
                      onToggleBury: () => runCardAction(() async {
                        final now = ref.read(clockProvider)();
                        final notifier = ref.read(
                          cardListControllerProvider(deck.id).notifier,
                        );
                        if (card.isBuried(now)) {
                          await notifier.unburyCard(card.id);
                        } else {
                          await notifier.buryCard(card.id);
                        }
                      }, 'Failed to update card'),
                      onSetDueDate: (newDue) => runCardAction(
                        () => ref
                            .read(cardListControllerProvider(deck.id).notifier)
                            .setCardDueDate(card.id, newDue),
                        'Failed to set due date',
                      ),
                      onResetProgress: () => runCardAction(
                        () => ref
                            .read(cardListControllerProvider(deck.id).notifier)
                            .resetCardProgress(card.id),
                        'Failed to reset progress',
                      ),
                      onDuplicate: () => runCardAction(
                        () => ref
                            .read(cardListControllerProvider(deck.id).notifier)
                            .duplicateCard(card.id),
                        'Failed to duplicate card',
                      ),
                      onSetFlag: (flag) => runCardAction(
                        () => ref
                            .read(cardListControllerProvider(deck.id).notifier)
                            .setCardFlag(card.id, flag),
                        'Failed to set flag',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showDeleteTagDialog(
    BuildContext context,
    WidgetRef ref,
    TagEntity tag,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.delete ?? 'Delete Tag'),
        content: Text(
          'Are you sure you want to delete "#${tag.name}"? It will be removed from all cards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_tag_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        if (ref.read(deckTagFilterProvider) == tag.id) {
          ref.read(deckTagFilterProvider.notifier).selectTag(null);
        }
        await ref.read(tagsControllerProvider.notifier).deleteTag(tag.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tag "#${tag.name}" deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }
}
