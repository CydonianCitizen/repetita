import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/error_view.dart';
import '../domain/stats_models.dart';
import 'controllers/stats_controller.dart';
import 'widgets/forecast_list_tile.dart';
import 'widgets/interval_distribution_widget.dart';
import 'widgets/metric_summary_card.dart';
import 'widgets/rating_breakdown_widget.dart';
import 'widgets/review_heatmap_widget.dart';
import 'widgets/state_distribution_bar.dart';
import 'widgets/true_retention_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({
    super.key,
    this.deckId,
    this.deckName,
    this.isEmbedded = false,
  });

  final int? deckId;
  final String? deckName;
  final bool isEmbedded;

  Widget _buildForecastCard(
    BuildContext context, {
    required StatsData stats,
    required int maxForecast,
    bool isDense = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDense ? 14 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n?.reviewForecastTitle ?? '7-Day Review Forecast',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: colorScheme.outline,
                ),
              ],
            ),
            SizedBox(height: isDense ? 10 : 16),
            if (stats.forecast.isEmpty)
              Text(
                l10n?.noUpcomingReviews ?? 'No upcoming reviews scheduled.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...stats.forecast.asMap().entries.map((entry) {
                return ForecastListTile(
                  forecast: entry.value,
                  index: entry.key,
                  maxCount: maxForecast,
                  isDense: isDense,
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(statsControllerProvider(deckId: deckId));

    final title = deckName != null
        ? (l10n?.deckStatsTitle(deckName!) ?? '$deckName Stats')
        : (l10n?.stats ?? 'Statistics');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: !isEmbedded,
      ),
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorView(
            title: l10n?.errorLoadingStats ?? 'Error loading statistics',
            error: error,
            onRetry: () =>
                ref.invalidate(statsControllerProvider(deckId: deckId)),
          ),
          data: (stats) {
            final retentionPct = (stats.retentionRate * 100).round();
            final maxForecast = stats.forecast.fold<int>(
              0,
              (maxVal, item) => max(maxVal, item.count),
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 840;

                final content = ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MetricSummaryCard(
                            icon: Icons.percent,
                            value: '$retentionPct%',
                            title: l10n?.retention ?? 'Retention',
                            subtitle: l10n?.recallAccuracy ?? 'Recall accuracy',
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricSummaryCard(
                            icon: Icons.history,
                            value: '${stats.totalReviews}',
                            title: l10n?.reviews ?? 'Reviews',
                            subtitle:
                                l10n?.reviewsCompleted ?? 'Total completed',
                            color: colorScheme.secondary,
                          ),
                        ),
                        if (stats.leechCardsCount > 0) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricSummaryCard(
                              icon: Icons.warning_amber_rounded,
                              value: '${stats.leechCardsCount}',
                              title: l10n?.filterLeech ?? 'Leech',
                              subtitle:
                                  l10n?.leechCardsSubtitle ?? 'Lapsed cards',
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isWide) ...[
                      // Desktop 2-Column Row (Review Heatmap + 7-Day Forecast side-by-side)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: Review Heatmap (compact, proportioned)
                          Expanded(
                            flex: 6,
                            child: ReviewHeatmapWidget(
                              dailyCounts: stats.dailyReviewCounts,
                              currentStreak: stats.currentStreak,
                              isDesktop: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right column: 7-Day Review Forecast (compact, proportioned)
                          Expanded(
                            flex: 5,
                            child: _buildForecastCard(
                              context,
                              stats: stats,
                              maxForecast: maxForecast,
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // State Distribution Bar (Deck breakdown)
                      StateDistributionBar(counts: stats.stateCounts),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TrueRetentionCard(data: stats.trueRetention),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: RatingBreakdownWidget(
                              data: stats.ratingBreakdown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      IntervalDistributionWidget(
                        data: stats.intervalDistribution,
                      ),
                    ] else ...[
                      // Mobile single-column stacked layout
                      ReviewHeatmapWidget(
                        dailyCounts: stats.dailyReviewCounts,
                        currentStreak: stats.currentStreak,
                      ),
                      const SizedBox(height: 16),
                      StateDistributionBar(counts: stats.stateCounts),
                      const SizedBox(height: 16),
                      TrueRetentionCard(data: stats.trueRetention),
                      const SizedBox(height: 16),
                      RatingBreakdownWidget(data: stats.ratingBreakdown),
                      const SizedBox(height: 16),
                      IntervalDistributionWidget(
                        data: stats.intervalDistribution,
                      ),
                      const SizedBox(height: 16),
                      _buildForecastCard(
                        context,
                        stats: stats,
                        maxForecast: maxForecast,
                      ),
                    ],
                  ],
                );

                if (isWide) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1040),
                      child: content,
                    ),
                  );
                }
                return content;
              },
            );
          },
        ),
      ),
    );
  }
}
