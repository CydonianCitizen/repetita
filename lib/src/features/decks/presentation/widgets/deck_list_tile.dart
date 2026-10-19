import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../data/decks_dao.dart';
import '../../domain/deck_hierarchy.dart';
import 'deck_form_dialog.dart';

class DeckListTile extends StatelessWidget {
  const DeckListTile({
    super.key,
    required this.deckWithCounts,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.node,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  final DeckWithCounts deckWithCounts;
  final void Function(String name, String? description) onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final DeckNode? node;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteDeckConfirmTitle ?? 'Delete Deck?'),
        content: Text(
          l10n?.deleteDeckConfirmMessage(deckWithCounts.deck.name) ??
              'Are you sure you want to delete "${deckWithCounts.deck.name}"? All cards in this deck will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onDelete();
    }
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final result = await DeckFormDialog.show(
      context,
      initialName: deckWithCounts.deck.name,
      initialDescription: deckWithCounts.deck.description,
    );
    if (result != null) {
      onEdit(result.name, result.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final deck = deckWithCounts.deck;

    final depth = node?.depth ?? 0;
    final isSubdeck = depth > 0;
    final displayName = node != null ? node!.shortName : deck.name;
    final hasSubdecks = node?.hasSubdecks ?? false;
    final dueCount = hasSubdecks
        ? node!.aggregateDueCards
        : deckWithCounts.dueCards;
    final totalCount = hasSubdecks
        ? node!.aggregateTotalCards
        : deckWithCounts.totalCards;

    return Card(
      margin: EdgeInsets.only(
        left: 16.0 + (depth * 16.0),
        right: 16,
        top: 4,
        bottom: 4,
      ),
      elevation: 0,
      color: isSubdeck
          ? colorScheme.surfaceContainer
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isSubdeck) ...[
                              Icon(
                                Icons.subdirectory_arrow_right,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (hasSubdecks) ...[
                              IconButton(
                                icon: Icon(
                                  isCollapsed
                                      ? Icons.chevron_right
                                      : Icons.expand_more,
                                  size: 20,
                                ),
                                onPressed: onToggleCollapse,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ],
                        ),
                        if (deck.description != null &&
                            deck.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            deck.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!deck.id.isNegative)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context);
                        }
                      },
                      itemBuilder: (context) {
                        final itemL10n = AppLocalizations.of(context);
                        return [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text(itemL10n?.edit ?? 'Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  itemL10n?.delete ?? 'Delete',
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Badge(
                    label: l10n?.dueBadge ?? 'Due',
                    count: dueCount,
                    backgroundColor: dueCount > 0
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    textColor: dueCount > 0
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  _Badge(
                    label: l10n?.totalBadge ?? 'Total',
                    count: totalCount,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    textColor: colorScheme.onSurfaceVariant,
                  ),
                  if (hasSubdecks) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n?.subdecksCount(node!.children.length) ??
                            '${node!.children.length} subdecks',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.count,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final int count;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $count',
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
