import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/algorithms/cloze/cloze_parser.dart';
import '../../../../core/algorithms/cloze/cloze_segment.dart';
import '../../../../core/algorithms/type_in/type_in_differ.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/text_direction_utils.dart';
import '../../../cards/domain/card_entity.dart';
import '../../../media/presentation/widgets/media_image_widget.dart';
import '../../../media/utils/media_content_renderer.dart';
import '../../../settings/presentation/controllers/animation_level_controller.dart';
import '../controllers/type_in_controller.dart';

class FlipCardView extends ConsumerStatefulWidget {
  const FlipCardView({
    super.key,
    required this.card,
    required this.isAnswerRevealed,
    this.onCardTap,
  });

  final CardEntity card;
  final bool isAnswerRevealed;
  final VoidCallback? onCardTap;

  @override
  ConsumerState<FlipCardView> createState() => _FlipCardViewState();
}

class _FlipCardViewState extends ConsumerState<FlipCardView> {
  late bool _isCloze;
  late String _promptText;
  late String _answerText;
  late List<ClozeSegment> _promptSegments;
  late List<ClozeSegment> _answerSegments;
  late final TextEditingController _typeInController;

  @override
  void initState() {
    super.initState();
    _typeInController = TextEditingController();
    _recomputeCardData();
  }

  @override
  void didUpdateWidget(FlipCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _typeInController.clear();
    }
    if (oldWidget.card.front != widget.card.front ||
        oldWidget.card.clozeIndex != widget.card.clozeIndex) {
      _recomputeCardData();
    }
  }

  @override
  void dispose() {
    _typeInController.dispose();
    super.dispose();
  }

  void _recomputeCardData() {
    final activeIndex = widget.card.activeClozeIndex;
    _isCloze = widget.card.isCloze;
    _promptText = ClozeParser.renderClozePrompt(
      widget.card.front,
      activeIndex: activeIndex,
    );
    _answerText = ClozeParser.renderClozeAnswer(
      widget.card.front,
      activeIndex: activeIndex,
    );
    _promptSegments = ClozeParser.getPromptSegments(
      widget.card.front,
      activeIndex: activeIndex,
    );
    _answerSegments = ClozeParser.getAnswerSegments(
      widget.card.front,
      activeIndex: activeIndex,
    );
  }

  Widget _buildMediaImages(String content) {
    final fileNames = MediaContentRenderer.extractMediaFilenames(content);
    if (fileNames.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: fileNames.map((fileName) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: MediaImageWidget(
                mediaReference: fileName,
                fit: BoxFit.contain,
                enableZoom: true,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final animLevel = ref.watch(animationLevelControllerProvider);
    final isReduced =
        animLevel.isReduced || MediaQuery.of(context).disableAnimations;

    final frontCard = RepaintBoundary(
      child: _buildFrontCard(context, colorScheme, theme, l10n),
    );
    final backCard = RepaintBoundary(
      child: _buildBackCard(context, colorScheme, theme, l10n),
    );

    Widget cardBody;
    if (isReduced) {
      cardBody = widget.isAnswerRevealed ? backCard : frontCard;
    } else {
      cardBody = TweenAnimationBuilder<double>(
        key: ValueKey(widget.card.id),
        tween: Tween<double>(
          begin: 0.0,
          end: widget.isAnswerRevealed ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        builder: (context, value, _) {
          final isBack = value >= 0.5;
          final angle = value * math.pi;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D depth perspective
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: backCard,
                  )
                : frontCard,
          );
        },
      );
    }

    Widget result = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, minHeight: 280),
        child: cardBody,
      ),
    );

    if (!isReduced) {
      result = result
          .animate(key: ValueKey(widget.card.id))
          .fadeIn(duration: 200.ms)
          .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
    }

    return result;
  }

  Widget _buildFrontCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final isCloze = _isCloze;
    final typeInEnabled = ref.watch(typeInPracticeControllerProvider);
    final promptBadgeText = isCloze
        ? (l10n?.clozeBadge(widget.card.activeClozeIndex) ??
              'CLOZE c${widget.card.activeClozeIndex}')
        : (l10n?.promptBadge ?? 'PROMPT');
    final promptText = isCloze ? _promptText : widget.card.front;
    final promptDirection = TextDirectionUtils.getDirection(promptText);

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: widget.onCardTap,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          promptBadgeText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.flip_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Semantics(
                label:
                    l10n?.cardPromptSemantics(promptText) ??
                    'Card Prompt: $promptText',
                readOnly: true,
                child: Directionality(
                  textDirection: promptDirection,
                  child: isCloze
                      ? Text.rich(
                          TextSpan(
                            children: _promptSegments.map((s) {
                              if (s.isActive) {
                                return TextSpan(
                                  text: s.text,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: colorScheme.primary
                                            .withValues(alpha: 0.5),
                                      ),
                                );
                              }
                              return TextSpan(
                                text: s.text,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              );
                            }).toList(),
                          ),
                          key: const Key('card_front_text'),
                        )
                      : Text(
                          MediaContentRenderer.stripMediaTags(
                            widget.card.front,
                          ),
                          key: const Key('card_front_text'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                ),
              ),
              _buildMediaImages(widget.card.front),
              if (typeInEnabled) ...[
                const SizedBox(height: 20),
                Directionality(
                  textDirection: TextDirectionUtils.getDirection(
                    isCloze ? _answerText : widget.card.back,
                  ),
                  child: TextField(
                    key: const Key('type_in_answer_field'),
                    controller: _typeInController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n?.typeInAnswer ?? 'Type your answer',
                      hintText:
                          l10n?.typeInAnswerHint ?? 'Type your answer here...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.keyboard_outlined),
                    ),
                    onSubmitted: (_) => widget.onCardTap?.call(),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n?.tapToFlipHint ?? 'Tap or press Show Answer to flip',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final isCloze = _isCloze;
    final typeInEnabled = ref.watch(typeInPracticeControllerProvider);
    final answerText = isCloze ? _answerText : widget.card.back;
    final answerDirection = TextDirectionUtils.getDirection(answerText);
    final typedText = _typeInController.text.trim();
    final hasTyped = typeInEnabled && typedText.isNotEmpty;
    final diff = hasTyped
        ? TypeInDiffer.diff(expected: answerText, actual: typedText)
        : null;

    return Card(
      elevation: 3,
      shadowColor: colorScheme.primary.withValues(alpha: 0.12),
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n?.answerBadge ?? 'ANSWER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isCloze
                  ? _promptText
                  : MediaContentRenderer.stripMediaTags(widget.card.front),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Semantics(
              label:
                  l10n?.cardAnswerSemantics(answerText) ??
                  'Card Answer: $answerText',
              readOnly: true,
              child: Directionality(
                textDirection: answerDirection,
                child: isCloze
                    ? Text.rich(
                        TextSpan(
                          children: _answerSegments.map((s) {
                            if (s.isActive) {
                              return TextSpan(
                                text: s.text,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                  backgroundColor: colorScheme.primaryContainer
                                      .withValues(alpha: 0.45),
                                ),
                              );
                            }
                            return TextSpan(
                              text: s.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                height: 1.5,
                              ),
                            );
                          }).toList(),
                        ),
                        key: const Key('card_back_text'),
                      )
                    : Text(
                        MediaContentRenderer.stripMediaTags(widget.card.back),
                        key: const Key('card_back_text'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
              ),
            ),
            _buildMediaImages(widget.card.back),
            if (diff != null) ...[
              const SizedBox(height: 16),
              Container(
                key: const Key('type_in_diff_box'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: diff.isExactMatch
                      ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : colorScheme.errorContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: diff.isExactMatch
                        ? colorScheme.primary.withValues(alpha: 0.4)
                        : colorScheme.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          diff.isExactMatch
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 16,
                          color: diff.isExactMatch
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.typeInAnswerYourInput ?? 'Your answer:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: diff.isExactMatch
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirectionUtils.getDirection(typedText),
                      child: Text.rich(
                        TextSpan(
                          children: diff.segments.map((seg) {
                            switch (seg.status) {
                              case TypeInCharStatus.correct:
                                return TextSpan(
                                  text: seg.text,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              case TypeInCharStatus.wrong:
                                return TextSpan(
                                  text: seg.text,
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              case TypeInCharStatus.missing:
                                return TextSpan(
                                  text: seg.text,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                    decoration: TextDecoration.underline,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                            }
                          }).toList(),
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isCloze && widget.card.back.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.card.back,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
