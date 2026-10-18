import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/algorithms/fsrs/models/fsrs_models.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/error_view.dart';
import '../../settings/data/haptic_service.dart';
import '../../settings/presentation/controllers/animation_level_controller.dart';
import '../../settings/presentation/controllers/haptic_controller.dart';
import '../../../core/database/database_provider.dart';
import '../domain/models/custom_study_config.dart';
import 'controllers/study_session_controller.dart';
import 'widgets/flip_card_view.dart';
import 'widgets/rating_bar.dart';

import '../../cards/presentation/widgets/card_flag_color.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key, required this.deckId, this.customStudyConfig});

  final int deckId;
  final CustomStudyConfig? customStudyConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final provider = studySessionControllerProvider(deckId, customStudyConfig);

    ref.listen(provider, (previous, next) {
      final prevLeech = previous?.value?.lastLeechDetected ?? false;
      final nextLeech = next.value?.lastLeechDetected ?? false;
      if (nextLeech && !prevLeech) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.leechDetectedAlert ??
                  'Leech detected! Card lapsed multiple times.',
            ),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final isCram = ref.watch(
              provider.select(
                (s) => s.value?.isCram ?? (customStudyConfig?.isCram ?? false),
              ),
            );
            final titleText = isCram
                ? (l10n?.cramSessionTitle ?? 'Cram Session')
                : (l10n?.studySessionTitle ?? 'Study Session');
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titleText),
                if (isCram) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n?.cramBadge ?? 'CRAM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final canUndo = ref.watch(
                provider.select((s) => s.value?.canUndo ?? false),
              );
              if (!canUndo) return const SizedBox.shrink();
              return IconButton(
                key: const Key('undo_review_button'),
                icon: const Icon(Icons.undo_rounded),
                tooltip: l10n?.undoReview ?? 'Undo Review',
                onPressed: () async {
                  try {
                    await ref.read(provider.notifier).undoReview();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final currentCard = ref.watch(
                provider.select((s) => s.value?.currentCard),
              );
              if (currentCard == null) return const SizedBox.shrink();
              final flag = currentCard.flag;
              return PopupMenuButton<int>(
                key: const Key('study_card_flag_button'),
                icon: Icon(
                  flag > 0 ? Icons.flag_rounded : Icons.outlined_flag_rounded,
                  color: flag > 0 ? getCardFlagColor(flag) : null,
                ),
                tooltip: l10n?.flag ?? 'Flag',
                onSelected: (newFlag) async {
                  await ref
                      .read(cardsDaoProvider)
                      .setCardFlag(currentCard.id, newFlag);
                },
                itemBuilder: (context) {
                  final itemL10n = AppLocalizations.of(context);
                  return [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          const Icon(Icons.outlined_flag, size: 18),
                          const SizedBox(width: 8),
                          Text(itemL10n?.flagNone ?? 'No Flag'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          const Icon(Icons.flag, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(itemL10n?.flagRed ?? 'Red Flag'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(itemL10n?.flagOrange ?? 'Orange Flag'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Row(
                        children: [
                          const Icon(Icons.flag, size: 18, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(itemL10n?.flagGreen ?? 'Green Flag'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 4,
                      child: Row(
                        children: [
                          const Icon(Icons.flag, size: 18, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(itemL10n?.flagBlue ?? 'Blue Flag'),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final hasCurrentCard = ref.watch(
                provider.select((s) => s.value?.currentCard != null),
              );
              if (!hasCurrentCard) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                key: const Key('study_card_actions_menu'),
                icon: const Icon(Icons.more_vert),
                tooltip: l10n?.cardOptions ?? 'Card options',
                onSelected: (value) async {
                  final controller = ref.read(provider.notifier);
                  try {
                    if (value == 'suspend') {
                      await controller.suspendCurrentCard();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.cardSuspended ?? 'Card suspended',
                            ),
                          ),
                        );
                      }
                    } else if (value == 'bury') {
                      await controller.buryCurrentCard();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.cardBuried ?? 'Card buried until tomorrow',
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                itemBuilder: (context) {
                  final itemL10n = AppLocalizations.of(context);
                  return [
                    PopupMenuItem(
                      value: 'bury',
                      child: Row(
                        children: [
                          const Icon(Icons.alarm_off_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(itemL10n?.buryCard ?? 'Bury Card'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'suspend',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.pause_circle_outline_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(itemL10n?.suspendCard ?? 'Suspend Card'),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final stateAsync = ref.watch(provider);
          return stateAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorView(
              title:
                  l10n?.errorLoadingStudySession ??
                  'Error loading study session',
              error: error,
              onRetry: () => ref.invalidate(
                studySessionControllerProvider(deckId, customStudyConfig),
              ),
            ),
            data: (sessionState) {
              final controller = ref.read(provider.notifier);

              Future<void> undoReview() async {
                try {
                  await controller.undoReview();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              }

              final animLevel = ref.watch(animationLevelControllerProvider);
              final isReduced =
                  animLevel.isReduced ||
                  MediaQuery.of(context).disableAnimations;

              Widget bodyWidget;
              if (sessionState.isCompleted ||
                  sessionState.currentCard == null) {
                Widget titleWidget = Text(
                  sessionState.isCram
                      ? (l10n?.cramCompletedTitle ?? 'Cram session completed!')
                      : (l10n?.allCardsReviewedTitle ??
                            'All cards reviewed for today!'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                );
                Widget descWidget = Text(
                  sessionState.isCram
                      ? (l10n?.cramCompletedDesc ??
                            'You finished your practice run.')
                      : (l10n?.greatJobUpcomingReviews ??
                            'Great job! Check back later for upcoming reviews.'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                );
                Widget backButton = FilledButton.icon(
                  key: const Key('back_to_deck_button'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n?.backToDeck ?? 'Back to Deck'),
                );

                if (!isReduced) {
                  titleWidget = titleWidget
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 300.ms)
                      .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
                  descWidget = descWidget.animate().fadeIn(
                    delay: 250.ms,
                    duration: 300.ms,
                  );
                  backButton = backButton
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 300.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        curve: Curves.easeOutBack,
                      );
                }

                Widget? statsBox;
                if (sessionState.reviewedCount > 0) {
                  Widget box = Container(
                    key: const Key('session_completion_stats'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${l10n?.totalReviews ?? 'Total Reviews'}: ${sessionState.reviewedCount}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                  if (!isReduced) {
                    box = box.animate().fadeIn(delay: 300.ms, duration: 300.ms);
                  }
                  statsBox = box;
                }

                bodyWidget = Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(
                          builder: (context) {
                            Widget trophy = Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              child: Icon(
                                Icons.emoji_events_rounded,
                                size: 56,
                                color: colorScheme.primary,
                              ),
                            );

                            if (!isReduced) {
                              var animatedTrophy = trophy
                                  .animate()
                                  .scale(
                                    duration: 450.ms,
                                    curve: Curves.elasticOut,
                                    begin: const Offset(0.35, 0.35),
                                  )
                                  .fadeIn(duration: 250.ms);
                              if (animLevel.isExpressive) {
                                animatedTrophy = animatedTrophy.then().shimmer(
                                  duration: 1200.ms,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                );
                              }
                              trophy = animatedTrophy;
                            }
                            return RepaintBoundary(child: trophy);
                          },
                        ),
                        const SizedBox(height: 28),
                        titleWidget,
                        const SizedBox(height: 12),
                        descWidget,
                        if (statsBox != null) ...[
                          const SizedBox(height: 20),
                          statsBox,
                        ],
                        const SizedBox(height: 36),
                        backButton,
                      ],
                    ),
                  ),
                );
              } else {
                final currentCard = sessionState.currentCard!;
                final total = sessionState.totalCards;
                final currentNum = sessionState.currentIndex + 1;
                final progress = total > 0 ? currentNum / total : 0.0;

                Future<void> submitRating(Rating rating) async {
                  final haptic = ref.read(hapticServiceProvider);
                  final intensity = ref.read(hapticFeedbackControllerProvider);
                  unawaited(haptic.triggerRatingFeedback(rating, intensity));
                  try {
                    await controller.submitRating(rating);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                }

                void revealAnswer() {
                  final intensity = ref.read(hapticFeedbackControllerProvider);
                  ref.read(hapticServiceProvider).triggerSelection(intensity);
                  controller.revealAnswer();
                }

                final isDesktop =
                    defaultTargetPlatform == TargetPlatform.windows ||
                    defaultTargetPlatform == TargetPlatform.macOS ||
                    defaultTargetPlatform == TargetPlatform.linux;

                bodyWidget = SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n?.cardProgress(currentNum, total) ??
                                          'Card $currentNum of $total',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      l10n?.cardsRemaining(
                                            sessionState.remainingCards,
                                          ) ??
                                          '${sessionState.remainingCards} remaining',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(end: progress),
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    builder: (context, animatedProgress, _) {
                                      return LinearProgressIndicator(
                                        key: const Key('study_progress_bar'),
                                        value: animatedProgress,
                                        minHeight: 6,
                                        semanticsLabel:
                                            l10n?.cardProgress(
                                              currentNum,
                                              total,
                                            ) ??
                                            'Session progress',
                                        semanticsValue:
                                            '${(progress * 100).round()}%',
                                        backgroundColor:
                                            colorScheme.surfaceContainerHighest,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              colorScheme.primary,
                                            ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: FlipCardView(
                                card: currentCard,
                                isAnswerRevealed: sessionState.isAnswerRevealed,
                                onCardTap: !sessionState.isAnswerRevealed
                                    ? revealAnswer
                                    : null,
                              ),
                            ),
                          ),
                          if (!sessionState.isAnswerRevealed)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton.icon(
                                  key: const Key('show_answer_button'),
                                  onPressed: revealAnswer,
                                  icon: const Icon(Icons.flip_rounded),
                                  label: Text(
                                    isDesktop
                                        ? '${l10n?.showAnswer ?? 'Show Answer'}  [Space]'
                                        : (l10n?.showAnswer ?? 'Show Answer'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 150.ms),
                            )
                          else
                            RatingBar(
                              intervals: sessionState.intervalPreviews,
                              onRatingSelected: submitRating,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return CallbackShortcuts(
                bindings: {
                  const SingleActivator(
                    LogicalKeyboardKey.keyZ,
                    control: true,
                  ): () {
                    if (sessionState.canUndo) {
                      undoReview();
                    }
                  },
                  const SingleActivator(
                    LogicalKeyboardKey.keyZ,
                    meta: true,
                  ): () {
                    if (sessionState.canUndo) {
                      undoReview();
                    }
                  },
                  if (!sessionState.isCompleted &&
                      sessionState.currentCard != null) ...{
                    const SingleActivator(LogicalKeyboardKey.space): () {
                      if (!sessionState.isAnswerRevealed) {
                        final intensity = ref.read(
                          hapticFeedbackControllerProvider,
                        );
                        ref
                            .read(hapticServiceProvider)
                            .triggerSelection(intensity);
                        controller.revealAnswer();
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.enter): () {
                      if (!sessionState.isAnswerRevealed) {
                        final intensity = ref.read(
                          hapticFeedbackControllerProvider,
                        );
                        ref
                            .read(hapticServiceProvider)
                            .triggerSelection(intensity);
                        controller.revealAnswer();
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.digit1): () {
                      if (sessionState.isAnswerRevealed) {
                        final haptic = ref.read(hapticServiceProvider);
                        final intensity = ref.read(
                          hapticFeedbackControllerProvider,
                        );
                        unawaited(
                          haptic.triggerRatingFeedback(Rating.again, intensity),
                        );
                        controller.submitRating(Rating.again);
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.digit2): () {
                      if (sessionState.isAnswerRevealed) {
                        final haptic = ref.read(hapticServiceProvider);
                        final intensity = ref.read(
                          hapticFeedbackControllerProvider,
                        );
                        unawaited(
                          haptic.triggerRatingFeedback(Rating.hard, intensity),
                        );
                        controller.submitRating(Rating.hard);
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.digit3): () {
                      if (sessionState.isAnswerRevealed) {
                        final haptic = ref.read(hapticServiceProvider);
                        final intensity = ref.read(
                          hapticFeedbackControllerProvider,
                        );
                        unawaited(
                          haptic.triggerRatingFeedback(Rating.good, intensity),
                        );
                        controller.submitRating(Rating.good);
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.digit4): () {
                      if (sessionState.isAnswerRevealed) {
                        final haptic = ref.read(hapticServiceProvider);
                        final intensity = ref.read(
                          hapticFeedbackControllerProvider,
                        );
                        unawaited(
                          haptic.triggerRatingFeedback(Rating.easy, intensity),
                        );
                        controller.submitRating(Rating.easy);
                      }
                    },
                  },
                },
                child: Focus(autofocus: true, child: bodyWidget),
              );
            },
          );
        },
      ),
    );
  }
}
