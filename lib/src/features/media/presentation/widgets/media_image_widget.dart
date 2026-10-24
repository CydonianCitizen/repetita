import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../dialogs/image_viewer_dialog.dart';

class MediaImageWidget extends ConsumerWidget {
  const MediaImageWidget({
    super.key,
    required this.mediaReference,
    this.fit = BoxFit.contain,
    this.height,
    this.width,
    this.enableZoom = true,
  });

  final String mediaReference;
  final BoxFit fit;
  final double? height;
  final double? width;
  final bool enableZoom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaService = ref.watch(mediaServiceProvider);
    final file = mediaService.getMediaFile(mediaReference);

    if (!file.existsSync()) {
      return _buildError(context);
    }

    try {
      final bytes = file.readAsBytesSync();
      final imageWidget = Image.memory(
        bytes,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, _, _) => _buildError(context),
      );

      if (!enableZoom) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: const Key('media_image_tap_to_zoom'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => ImageViewerDialog.show(context, file),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              imageWidget,
              Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      return _buildError(context);
    }
  }

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      height: height ?? 80,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: theme.colorScheme.error,
            size: 22,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n?.imageNotFound ?? 'Image not found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
