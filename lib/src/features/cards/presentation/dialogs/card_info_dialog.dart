import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/algorithms/fsrs/stability_curve_calculator.dart';
import '../../../../core/theme/card_state_colors.dart';
import '../../domain/card_entity.dart';
import '../widgets/card_flag_color.dart';
import '../widgets/retrievability_curve_painter.dart';

class CardInfoDialog extends StatelessWidget {
  const CardInfoDialog({super.key, required this.card, this.deckName});

  final CardEntity card;
  final String? deckName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now().toUtc();

    final stability = card.stability;
    final difficulty = card.difficulty;

    double? elapsedDays;
    double? currentR;
    if (card.lastReview != null) {
      final diffSeconds = max(
        0,
        now.difference(card.lastReview!.toUtc()).inSeconds,
      );
      elapsedDays = diffSeconds / 86400.0;
      currentR = StabilityCurveCalculator.retrievability(
        elapsedDays,
        stability,
      );
    }

    final curvePoints = StabilityCurveCalculator.generateCurvePoints(
      stability: stability,
      pointCount: 40,
    );

    final dateFormat = DateFormat.yMMMd().add_Hm();
    final dueDateStr = dateFormat.format(card.due.toLocal());
    final lastReviewStr = card.lastReview != null
        ? dateFormat.format(card.lastReview!.toLocal())
        : 'Never';

    final stateName = cardStateName(card.state, null);
    final stateColor = colorScheme.cardStateColor(card.state);

    return AlertDialog(
      key: const Key('card_info_dialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.analytics_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Info',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  deckName != null ? '$deckName • #${card.id}' : '#${card.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (card.flag > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.flag,
                size: 20,
                color: getCardFlagColor(card.flag),
              ),
            ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: stateColor.withValues(alpha: 0.15),
                    side: BorderSide.none,
                    label: Text(
                      stateName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: stateColor,
                      ),
                    ),
                  ),
                  if (card.isSuspended)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.amber.withValues(alpha: 0.15),
                      side: BorderSide.none,
                      label: const Text(
                        'Suspended',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  if (card.noteId != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.secondaryContainer,
                      side: BorderSide.none,
                      label: Text(
                        'Note #${card.noteId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        context,
                        label: 'Stability',
                        value: '${stability.toStringAsFixed(1)} d',
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        context,
                        label: 'Difficulty',
                        value: '${difficulty.toStringAsFixed(1)} / 10',
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        context,
                        label: 'Reps',
                        value: '${card.reps}',
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        context,
                        label: 'Lapses',
                        value: '${card.lapses}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Memory Retention Curve',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentR != null
                    ? 'Current recall probability: ${(currentR * 100).round()}%'
                    : 'Retention drops to 90% at day ${stability.toStringAsFixed(1)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: CustomPaint(
                  key: const Key('retrievability_curve_canvas'),
                  painter: RetrievabilityCurvePainter(
                    points: curvePoints,
                    curveColor: colorScheme.primary,
                    thresholdColor: Colors.orange,
                    gridColor: colorScheme.outlineVariant,
                    currentElapsedDays: elapsedDays,
                    currentR: currentR,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due: $dueDateStr',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Last: $lastReviewStr',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
