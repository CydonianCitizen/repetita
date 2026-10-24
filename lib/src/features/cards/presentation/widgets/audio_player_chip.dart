import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../media/data/services/audio_playback_service.dart';

class AudioPlayerChip extends ConsumerStatefulWidget {
  const AudioPlayerChip({super.key, required this.audioReference, this.label});

  final String audioReference;
  final String? label;

  @override
  ConsumerState<AudioPlayerChip> createState() => _AudioPlayerChipState();
}

class _AudioPlayerChipState extends ConsumerState<AudioPlayerChip> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final mediaService = ref.watch(mediaServiceProvider);
    final audioFile = mediaService.getMediaFile(widget.audioReference);
    final playbackService = ref.watch(audioPlaybackServiceProvider);

    final cleanName = widget.audioReference.startsWith('media://')
        ? widget.audioReference.substring('media://'.length)
        : widget.audioReference;

    final displayName = widget.label ?? cleanName;

    return StreamBuilder<PlayerState>(
      stream: playbackService.onPlayerStateChanged,
      builder: (context, snapshot) {
        final isThisPlaying =
            snapshot.data == PlayerState.playing &&
            playbackService.currentSource == audioFile.path;
        _isPlaying = isThisPlaying;

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: ActionChip(
            avatar: Icon(
              _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
              size: 18,
              color: _isPlaying ? colorScheme.error : colorScheme.primary,
            ),
            label: Text(
              displayName,
              style: TextStyle(
                fontWeight: _isPlaying ? FontWeight.bold : FontWeight.normal,
                color: _isPlaying
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            backgroundColor: _isPlaying
                ? colorScheme.errorContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            side: BorderSide(
              color: _isPlaying
                  ? colorScheme.error
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            onPressed: () async {
              if (_isPlaying) {
                await playbackService.stop();
              } else {
                if (audioFile.existsSync()) {
                  await playbackService.playFile(audioFile);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Audio file not found: $cleanName'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}
