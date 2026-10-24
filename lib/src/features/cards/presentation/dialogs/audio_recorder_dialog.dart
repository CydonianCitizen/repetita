import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../media/data/services/audio_playback_service.dart';
import '../../../media/data/services/audio_service.dart';

enum RecordState { idle, recording, recorded }

class AudioRecorderDialog extends ConsumerStatefulWidget {
  const AudioRecorderDialog({super.key, this.recorder, this.playbackService});

  final AudioRecorder? recorder;
  final AudioPlaybackService? playbackService;

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const AudioRecorderDialog(),
    );
  }

  @override
  ConsumerState<AudioRecorderDialog> createState() =>
      _AudioRecorderDialogState();
}

class _AudioRecorderDialogState extends ConsumerState<AudioRecorderDialog> {
  late final AudioRecorder _recorder;
  late final AudioPlaybackService _playback;

  RecordState _state = RecordState.idle;
  int _secondsRecorded = 0;
  Timer? _timer;
  String? _tempFilePath;
  bool _isPlayingPreview = false;

  @override
  void initState() {
    super.initState();
    _recorder = widget.recorder ?? AudioRecorder();
    _playback = widget.playbackService ?? AudioPlaybackService();

    _playback.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingPreview = _playback.currentSource != null;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.recorder == null) {
      _recorder.dispose();
    }
    if (widget.playbackService == null) {
      _playback.dispose();
    }
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _startRecording() async {
    final l10n = AppLocalizations.of(context);
    try {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.microphonePermissionDenied ??
                    'Microphone permission denied',
              ),
            ),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        'rec_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: targetPath,
      );

      setState(() {
        _state = RecordState.recording;
        _secondsRecorded = 0;
        _tempFilePath = targetPath;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _secondsRecorded++);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    try {
      final path = await _recorder.stop();
      setState(() {
        _state = RecordState.recorded;
        if (path != null) _tempFilePath = path;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
      }
    }
  }

  Future<void> _togglePlayback() async {
    if (_tempFilePath == null) return;
    if (_isPlayingPreview) {
      await _playback.stop();
      if (mounted) setState(() => _isPlayingPreview = false);
    } else {
      final file = File(_tempFilePath!);
      if (file.existsSync()) {
        await _playback.playFile(file);
        if (mounted) setState(() => _isPlayingPreview = true);
      }
    }
  }

  Future<void> _insertAndClose() async {
    if (_tempFilePath == null) return;
    final file = File(_tempFilePath!);
    if (!file.existsSync()) return;

    final bytes = await file.readAsBytes();
    final mediaService = ref.read(mediaServiceProvider);

    final mediaData = await mediaService.saveAudioBytes(
      bytes,
      originalFileName: p.basename(_tempFilePath!),
    );

    if (mounted) {
      Navigator.of(context)
          .pop(AudioService.formatSoundTag(mediaData.fileName));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.mic, color: colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(l10n?.recordAudioTitle ?? 'Audio Recording'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              _formatDuration(_secondsRecorded),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _state == RecordState.recording
                    ? colorScheme.error
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            if (_state == RecordState.idle) ...[
              FilledButton.icon(
                key: const Key('start_recording_button'),
                icon: const Icon(
                  Icons.fiber_manual_record,
                  color: Colors.white,
                ),
                label: Text(l10n?.startRecording ?? 'Record'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 48),
                ),
                onPressed: _startRecording,
              ),
            ] else if (_state == RecordState.recording) ...[
              FilledButton.icon(
                key: const Key('stop_recording_button'),
                icon: const Icon(Icons.stop),
                label: Text(l10n?.stopRecording ?? 'Stop'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 48),
                ),
                onPressed: _stopRecording,
              ),
            ] else if (_state == RecordState.recorded) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    key: const Key('toggle_playback_button'),
                    icon: Icon(
                      _isPlayingPreview
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      _isPlayingPreview
                          ? (l10n?.stopPlayback ?? 'Stop')
                          : (l10n?.playRecording ?? 'Listen'),
                    ),
                    onPressed: _togglePlayback,
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    key: const Key('rerecord_button'),
                    tooltip: 'Re-record',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      _playback.stop();
                      setState(() {
                        _state = RecordState.idle;
                        _secondsRecorded = 0;
                        _tempFilePath = null;
                        _isPlayingPreview = false;
                      });
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        if (_state == RecordState.recorded)
          FilledButton.icon(
            key: const Key('confirm_insert_audio_button'),
            icon: const Icon(Icons.check, size: 18),
            label: Text(l10n?.insertAudio ?? 'Insert Audio'),
            onPressed: _insertAndClose,
          ),
      ],
    );
  }
}
