import 'package:flutter/material.dart';

import '../../domain/stats_models.dart';

class RatingBreakdownWidget extends StatelessWidget {
  const RatingBreakdownWidget({super.key, required this.data});

  final RatingBreakdownData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final againPct = (data.againRate * 100).round();
    final hardPct = (data.hardRate * 100).round();
    final goodPct = (data.goodRate * 100).round();
    final easyPct = (data.easyRate * 100).round();

    return Card(
      key: const Key('rating_breakdown_widget'),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.touch_app_outlined,
                    size: 20,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Answer Buttons Breakdown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Frequency of review ratings',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${data.total} total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRatingItem(
                    context,
                    label: 'Again',
                    count: data.againCount,
                    percentage: againPct,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRatingItem(
                    context,
                    label: 'Hard',
                    count: data.hardCount,
                    percentage: hardPct,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRatingItem(
                    context,
                    label: 'Good',
                    count: data.goodCount,
                    percentage: goodPct,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRatingItem(
                    context,
                    label: 'Easy',
                    count: data.easyCount,
                    percentage: easyPct,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: data.total == 0
                    ? Container(color: colorScheme.surfaceContainerHighest)
                    : Row(
                        children: [
                          if (data.againCount > 0)
                            Expanded(
                              flex: data.againCount,
                              child: Container(color: colorScheme.error),
                            ),
                          if (data.hardCount > 0)
                            Expanded(
                              flex: data.hardCount,
                              child: Container(color: Colors.orange),
                            ),
                          if (data.goodCount > 0)
                            Expanded(
                              flex: data.goodCount,
                              child: Container(color: Colors.teal),
                            ),
                          if (data.easyCount > 0)
                            Expanded(
                              flex: data.easyCount,
                              child: Container(color: colorScheme.primary),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(
    BuildContext context, {
    required String label,
    required int count,
    required int percentage,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            '$count',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
