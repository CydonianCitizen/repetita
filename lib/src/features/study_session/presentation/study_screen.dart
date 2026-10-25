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
import '../domain/study_gesture_config.dart';
import 'controllers/auto_advance_controller.dart';
import 'controllers/study_gesture_controller.dart';
import 'controllers/study_session_controller.dart';
import 'controllers/timebox_controller.dart';
import 'controllers/type_in_controller.dart';
import 'controllers/autoplay_audio_controller.dart';
import 'controllers/tts_settings_controller.dart';
import '../../media/data/services/tts_service.dart';
import '../../media/data/services/audio_playback_service.dart';
import '../../media/data/services/audio_service.dart';
import 'controllers/whiteboard_controller.dart';
import 'widgets/whiteboard_canvas.dart';
import 'widgets/flip_card_view.dart';
import 'widgets/rating_bar.dart';

import '../../cards/presentation/dialogs/card_info_dialog.dart';
import '../../cards/presentation/widgets/card_flag_color.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key, required this.deckId, this.customStudyConfig});

  final int deckId;
  final CustomStudyConfig? customStudyConfig;

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  Timer? _timeboxTimer;
  Timer? _autoAdvanceTimer;
  int? _lastAutoCardId;
  bool _timeboxTriggered = false;
  AudioPlaybackService? _audioPlaybackService;
  TtsService? _ttsService;

  @override
  void initState() {
    super.initState();
    _audioPlaybackService = ref.read(audioPlaybackServiceProvider);
    _ttsService = ref.read(ttsServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTimebox();
    });
  }

  void _initTimebox() {
    final minutes = ref.read(timeboxControllerProvider);
    if (minutes > 0) {
      _timeboxTimer = Timer(Duration(minutes: minutes), _onTimeboxReached);
    }
  }

  void _onTimeboxReached() {
    if (!mounted || _timeboxTriggered) return;
    _timeboxTriggered = true;
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        key: const Key('timebox_dialog'),
        title: Row(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.timeboxReachedTitle ?? 'Timebox reached',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          l10n?.timeboxReachedMessage ?? 'Your session time limit has expired. Would you like to wrap up or continue?',
        ),
        actions: [
          TextButton(
            key: const Key('timebox_continue_button'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n?.continueStudying ?? 'Continue studying'),
          ),
          FilledButton(
            key: const Key('timebox_finish_button'),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n?.finishSession ?? 'Finish session'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timeboxTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _audioPlaybackService?.stop();
    _ttsService?.stop();
    super.dispose();
  }

  Future<void> _playSideAudio(String content) async {
    final sounds = AudioService.extractSoundTags(content);
    if (sounds.isNotEmpty) {
      final mediaService = ref.read(mediaServiceProvider);
      final file = mediaService.getMediaFile(sounds.first);
      if (file.existsSync()) {
        await ref.read(audioPlaybackServiceProvider).playFile(file);
        return;
      }
    }

    final ttsSettings = ref.read(ttsSettingsControllerProvider);
    if (ttsSettings.autoTtsEnabled) {
      await ref
          .read(ttsServiceProvider)
          .speak(
            content,
            language: ttsSettings.language,
            speechRate: ttsSettings.speechRate,
          );
    }
  }

  String _getFlagLabel(int flag, AppLocalizations? l10n) {
    switch (flag) {
      case 1:
        return l10n?.flagRed ?? 'Red';
      case 2:
        return l10n?.flagOrange ?? 'Orange';
      case 3:
        return l10n?.flagGreen ?? 'Green';
      case 4:
        return l10n?.flagBlue ?? 'Blue';
      default:
        return l10n?.flag ?? 'Flag';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final provider = studySessionControllerProvider(
      widget.deckId,
      widget.customStudyConfig,
    );

    ref.listen(provider, (previous, next) {
      final prevCardId = previous?.value?.currentCard?.id;
      final nextCardId = next.value?.currentCard?.id;
      final prevAnswerRevealed = previous?.value?.isAnswerRevealed ?? false;
      final nextAnswerRevealed = next.value?.isAnswerRevealed ?? false;

      if (prevCardId != nextCardId) {
        ref.read(audioPlaybackServiceProvider).stop();
        ref.read(whiteboardControllerProvider.notifier).clear();
        ref.read(ttsServiceProvider).stop();
      }

      final autoPlay = ref.read(autoPlayAudioControllerProvider);
      if (autoPlay && next.value?.currentCard != null) {
        if (prevCardId != nextCardId) {
          _playSideAudio(next.value!.currentCard!.front);
        } else if (!prevAnswerRevealed && nextAnswerRevealed) {
          _playSideAudio(next.value!.currentCard!.back);
        }
      }

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
                (s) =>
                    s.value?.isCram ??
                    (widget.customStudyConfig?.isCram ?? false),
              ),
            );
            final titleText = isCram
                ? (l10n?.cramSessionTitle ?? 'Cram Session')
                : (l10n?.studySessionTitle ?? 'Study Session');
            final titleStyle = theme.textTheme.titleMedium?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w600,
            );
            if (!isCram) {
              return Text(
                titleText,
                style: titleStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    titleText,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
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
              final isWhiteboardOpen = ref.watch(
                whiteboardControllerProvider.select((s) => s.isOpen),
              );
              return IconButton(
                key: const Key('study_whiteboard_button'),
                icon: Icon(
                  isWhiteboardOpen ? Icons.draw : Icons.draw_outlined,
                  color: isWhiteboardOpen ? colorScheme.primary : null,
                ),
                tooltip: l10n?.whiteboard ?? 'Whiteboard',
                onPressed: () {
                  ref.read(whiteboardControllerProvider.notifier).toggle();
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final currentCard = ref.watch(
                provider.select((s) => s.value?.currentCard),
              );
              final isAnswerRevealed = ref.watch(
                provider.select((s) => s.value?.isAnswerRevealed ?? false),
              );
              if (currentCard == null) return const SizedBox.shrink();
              return IconButton(
                key: const Key('study_tts_button'),
                icon: const Icon(Icons.record_voice_over_outlined),
                tooltip: l10n?.ttsSpeak ?? 'Listen (TTS)',
                onPressed: () {
                  final text = isAnswerRevealed
                      ? (currentCard.back.isNotEmpty
                            ? currentCard.back
                            : currentCard.front)
                      : currentCard.front;
                  final ttsSettings = ref.read(ttsSettingsControllerProvider);
                  ref
                      .read(ttsServiceProvider)
                      .speak(
                        text,
                        language: ttsSettings.language,
                        speechRate: ttsSettings.speechRate,
                      );
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
                    if (value == 'info') {
                      final current = ref.read(provider).value?.currentCard;
                      if (current != null && context.mounted) {
                        await showDialog<void>(
                          context: context,
                          builder: (_) => CardInfoDialog(card: current),
                        );
                        return;
                      }
                    } else if (value == 'suspend') {
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
                    const PopupMenuItem(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.analytics_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Card Info'),
                        ],
                      ),
                    ),
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
                studySessionControllerProvider(
                  widget.deckId,
                  widget.customStudyConfig,
                ),
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

              Future<void> submitRating(Rating rating) async {
                _lastAutoCardId = null;
                _autoAdvanceTimer?.cancel();
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
                _lastAutoCardId = null;
                _autoAdvanceTimer?.cancel();
                final intensity = ref.read(hapticFeedbackControllerProvider);
                ref.read(hapticServiceProvider).triggerSelection(intensity);
                controller.revealAnswer();
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

                void handleGestureAction(StudyGestureAction action) {
                  if (action == StudyGestureAction.none) return;

                  switch (action) {
                    case StudyGestureAction.flipCard:
                      if (!sessionState.isAnswerRevealed) {
                        revealAnswer();
                      }
                    case StudyGestureAction.rateAgain:
                      if (sessionState.isAnswerRevealed) {
                        submitRating(Rating.again);
                      } else {
                        revealAnswer();
                      }
                    case StudyGestureAction.rateHard:
                      if (sessionState.isAnswerRevealed) {
                        submitRating(Rating.hard);
                      } else {
                        revealAnswer();
                      }
                    case StudyGestureAction.rateGood:
                      if (sessionState.isAnswerRevealed) {
                        submitRating(Rating.good);
                      } else {
                        revealAnswer();
                      }
                    case StudyGestureAction.rateEasy:
                      if (sessionState.isAnswerRevealed) {
                        submitRating(Rating.easy);
                      } else {
                        revealAnswer();
                      }
                    case StudyGestureAction.undo:
                      if (sessionState.canUndo) {
                        undoReview();
                      }
                    case StudyGestureAction.buryCard:
                      controller.buryCurrentCard();
                    case StudyGestureAction.suspendCard:
                      controller.suspendCurrentCard();
                    case StudyGestureAction.none:
                      break;
                  }
                }

                if (!sessionState.isAnswerRevealed) {
                  final seconds = ref.watch(autoAdvanceControllerProvider);
                  if (seconds > 0) {
                    if (_lastAutoCardId != currentCard.id) {
                      _lastAutoCardId = currentCard.id;
                      _autoAdvanceTimer?.cancel();
                      _autoAdvanceTimer = Timer(Duration(seconds: seconds), () {
                        if (mounted) revealAnswer();
                      });
                    }
                  } else {
                    _autoAdvanceTimer?.cancel();
                    _lastAutoCardId = null;
                  }
                } else {
                  _autoAdvanceTimer?.cancel();
                  _lastAutoCardId = null;
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
                                    Flexible(
                                      child: Text(
                                        l10n?.cardProgress(currentNum, total) ??
                                            'Card $currentNum of $total',
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                              child: Stack(
                                children: [
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final gestureConfig = ref.watch(
                                        studyGestureControllerProvider,
                                      );

                                      final cardWidget = FlipCardView(
                                        card: currentCard,
                                        isAnswerRevealed:
                                            sessionState.isAnswerRevealed,
                                        onCardTap:
                                            !sessionState.isAnswerRevealed
                                            ? revealAnswer
                                            : null,
                                      );

                                      if (!gestureConfig.enableGestures) {
                                        return cardWidget;
                                      }

                                      return GestureDetector(
                                        key: const Key(
                                          'study_gesture_detector',
                                        ),
                                        behavior: HitTestBehavior.translucent,
                                        onDoubleTap: () => handleGestureAction(
                                          gestureConfig.doubleTap,
                                        ),
                                        onHorizontalDragEnd: (details) {
                                          final vx =
                                              details.primaryVelocity ?? 0.0;
                                          if (vx < -200) {
                                            handleGestureAction(
                                              gestureConfig.swipeLeft,
                                            );
                                          } else if (vx > 200) {
                                            handleGestureAction(
                                              gestureConfig.swipeRight,
                                            );
                                          }
                                        },
                                        onVerticalDragEnd: (details) {
                                          final vy =
                                              details.primaryVelocity ?? 0.0;
                                          if (vy < -200) {
                                            handleGestureAction(
                                              gestureConfig.swipeUp,
                                            );
                                          } else if (vy > 200) {
                                            handleGestureAction(
                                              gestureConfig.swipeDown,
                                            );
                                          }
                                        },
                                        child: cardWidget,
                                      );
                                    },
                                  ),
                                  Positioned.fill(
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final isWhiteboardOpen = ref.watch(
                                          whiteboardControllerProvider.select(
                                            (s) => s.isOpen,
                                          ),
                                        );
                                        return IgnorePointer(
                                          ignoring: !isWhiteboardOpen,
                                          child: isWhiteboardOpen
                                              ? const WhiteboardCanvas()
                                              : const SizedBox.shrink(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!sessionState.isAnswerRevealed) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final isTypeIn = ref.watch(
                                          typeInPracticeControllerProvider,
                                        );
                                        return OutlinedButton.icon(
                                          key: const Key(
                                            'toggle_type_in_button',
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: isTypeIn
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                            side: BorderSide(
                                              color: isTypeIn
                                                  ? colorScheme.primary
                                                  : colorScheme.outlineVariant,
                                              width: isTypeIn ? 1.5 : 1.0,
                                            ),
                                            backgroundColor: isTypeIn
                                                ? colorScheme.primaryContainer
                                                      .withValues(alpha: 0.35)
                                                : null,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 8,
                                            ),
                                          ),
                                          onPressed: () => ref
                                              .read(
                                                typeInPracticeControllerProvider
                                                    .notifier,
                                              )
                                              .toggle(),
                                          icon: Icon(
                                            isTypeIn
                                                ? Icons.keyboard_rounded
                                                : Icons.keyboard_alt_outlined,
                                            size: 18,
                                          ),
                                          label: Text(
                                            l10n?.typeInAnswer ?? 'Type answer',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final flag = currentCard.flag;
                                        final flagColor = flag > 0
                                            ? getCardFlagColor(flag)
                                            : null;

                                        return PopupMenuButton<int>(
                                          key: const Key(
                                            'study_card_flag_button',
                                          ),
                                          tooltip: l10n?.flag ?? 'Flag',
                                          onSelected: (newFlag) async {
                                            await ref
                                                .read(cardsDaoProvider)
                                                .setCardFlag(
                                                  currentCard.id,
                                                  newFlag,
                                                );
                                          },
                                          itemBuilder: (context) {
                                            final itemL10n =
                                                AppLocalizations.of(context);
                                            return [
                                              PopupMenuItem(
                                                value: 0,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.outlined_flag,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      itemL10n?.flagNone ??
                                                          'No Flag',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 1,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.flag,
                                                      size: 18,
                                                      color: Colors.red,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      itemL10n?.flagRed ??
                                                          'Red Flag',
                                                    ),
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
                                                    Text(
                                                      itemL10n?.flagOrange ??
                                                          'Orange Flag',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 3,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.flag,
                                                      size: 18,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      itemL10n?.flagGreen ??
                                                          'Green Flag',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 4,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.flag,
                                                      size: 18,
                                                      color: Colors.blue,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      itemL10n?.flagBlue ??
                                                          'Blue Flag',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ];
                                          },
                                          child: IgnorePointer(
                                            child: OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    flagColor ??
                                                    colorScheme
                                                        .onSurfaceVariant,
                                                side: BorderSide(
                                                  color:
                                                      flagColor ??
                                                      colorScheme
                                                          .outlineVariant,
                                                  width: flag > 0 ? 1.5 : 1.0,
                                                ),
                                                backgroundColor: flagColor
                                                    ?.withValues(alpha: 0.12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 8,
                                                    ),
                                              ),
                                              onPressed: () {},
                                              icon: Icon(
                                                flag > 0
                                                    ? Icons.flag_rounded
                                                    : Icons
                                                          .outlined_flag_rounded,
                                                color: flagColor,
                                                size: 18,
                                              ),
                                              label: Text(
                                                flag > 0
                                                    ? _getFlagLabel(flag, l10n)
                                                    : (l10n?.flag ?? 'Flag'),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                            ),
                          ] else
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
                        revealAnswer();
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.enter): () {
                      if (!sessionState.isAnswerRevealed) {
                        revealAnswer();
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.digit1): () {
                      if (sessionState.isAnswerRevealed) {
                        submitRating(Rating.again);
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.digit2): () {
                      if (sessionState.isAnswerRevealed) {
                        submitRating(Rating.hard);
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.digit3): () {
                      if (sessionState.isAnswerRevealed) {
                        submitRating(Rating.good);
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.digit4): () {
                      if (sessionState.isAnswerRevealed) {
                        submitRating(Rating.easy);
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.keyW): () {
                      ref.read(whiteboardControllerProvider.notifier).toggle();
                    },
                    const SingleActivator(LogicalKeyboardKey.keyT): () {
                      final current = sessionState.currentCard;
                      if (current != null) {
                        final text = sessionState.isAnswerRevealed
                            ? (current.back.isNotEmpty
                                  ? current.back
                                  : current.front)
                            : current.front;
                        final ttsSettings = ref.read(
                          ttsSettingsControllerProvider,
                        );
                        ref
                            .read(ttsServiceProvider)
                            .speak(
                              text,
                              language: ttsSettings.language,
                              speechRate: ttsSettings.speechRate,
                            );
                      }
                    },
                    const SingleActivator(LogicalKeyboardKey.keyR): () {
                      final current = sessionState.currentCard;
                      if (current != null) {
                        final text = sessionState.isAnswerRevealed
                            ? (current.back.isNotEmpty
                                  ? current.back
                                  : current.front)
                            : current.front;
                        _playSideAudio(text);
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
