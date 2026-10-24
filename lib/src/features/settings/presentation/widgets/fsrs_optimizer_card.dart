import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/fsrs_optimizer_controller.dart';
import '../controllers/fsrs_parameters_controller.dart';

class FsrsOptimizerCard extends ConsumerWidget {
  const FsrsOptimizerCard({super.key});

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Ripristina Pesi Predefiniti'),
        content: const Text(
          'Sei sicuro di voler rimuovere i pesi personalizzati e tornare ai parametri ufficiali di FSRS v4.5?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            key: const Key('btn_confirm_reset_weights'),
            onPressed: () {
              ref
                  .read(fsrsOptimizerControllerProvider.notifier)
                  .resetToDefaults();
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Ripristina'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fsrsParams = ref.watch(fsrsParametersControllerProvider);
    final optimizerAsync = ref.watch(fsrsOptimizerControllerProvider);

    final optimizerState = optimizerAsync.value ?? const FsrsOptimizerState();
    final reviewCount = optimizerState.reviewCount;
    final isOptimizing = optimizerState.isOptimizing;
    final progress = optimizerState.progress;
    final lastResult = optimizerState.lastResult;
    final canOptimize = optimizerState.canOptimize;

    return Card(
      elevation: 0,
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
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_graph_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FSRS Optimizer On-Device',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        fsrsParams.hasCustomWeights
                            ? 'Pesi personalizzati attivi (17 parametri)'
                            : 'Pesi predefiniti FSRS v4.5',
                        style: theme.textTheme.bodySmall?.copyWith(
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
                    color: fsrsParams.hasCustomWeights
                        ? colorScheme.primary.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fsrsParams.hasCustomWeights ? 'Personalizzato' : 'Default',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: fsrsParams.hasCustomWeights
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recensioni storiche',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$reviewCount / 500 min.',
                  key: const Key('text_review_count'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: reviewCount >= 500
                        ? Colors.green
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (reviewCount / 500).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  reviewCount >= 500 ? Colors.green : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              reviewCount >= 500
                  ? 'Hai abbastanza recensioni per ottimizzare i parametri con precisione.'
                  : 'Servono almeno 500 recensioni per evitare l\'overfitting e trovare i pesi ottimali per la tua memoria.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            if (isOptimizing) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Text(
                'Ottimizzazione in background: ${(progress * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (lastResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ottimizzazione completata: +${lastResult.improvementPercentage.toStringAsFixed(1)}% '
                        '(Loss: ${lastResult.initialLoss.toStringAsFixed(3)} -> ${lastResult.finalLoss.toStringAsFixed(3)})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('btn_optimize_fsrs'),
                    icon: isOptimizing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(
                      isOptimizing ? 'Ottimizzazione...' : 'Ottimizza Pesi',
                    ),
                    onPressed: canOptimize
                        ? () => ref
                              .read(fsrsOptimizerControllerProvider.notifier)
                              .startOptimization()
                        : null,
                  ),
                ),
                if (fsrsParams.hasCustomWeights) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    key: const Key('btn_reset_fsrs_weights'),
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('Default'),
                    onPressed: isOptimizing
                        ? null
                        : () => _showResetConfirmation(context, ref),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
