import 'package:flutter/material.dart';

import '../../../../core/algorithms/image_occlusion/image_occlusion_parser.dart';
import '../../../cards/presentation/widgets/occlusion_canvas_painter.dart';
import '../../../media/presentation/widgets/media_image_widget.dart';

/// Renders an Image Occlusion card during a study session with Hide-All Reveal-One mechanics.
class ImageOcclusionCardView extends StatelessWidget {
  const ImageOcclusionCardView({
    super.key,
    required this.data,
    required this.isAnswerRevealed,
  });

  final ImageOcclusionData data;
  final bool isAnswerRevealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeBox = data.activeBox;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image with occlusion masks overlay
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 340),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MediaImageWidget(
                    mediaReference: data.mediaReference,
                    fit: BoxFit.contain,
                    enableZoom: true,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: OcclusionCanvasPainter(
                          boxes: data.boxes,
                          activeReviewBoxId: data.activeBoxId,
                          isRevealed: isAnswerRevealed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // If answer is revealed and active box has a label, show highlight banner
        if (isAnswerRevealed &&
            activeBox?.label != null &&
            activeBox!.label!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    activeBox.label!,
                    key: const Key('occlusion_revealed_label'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
