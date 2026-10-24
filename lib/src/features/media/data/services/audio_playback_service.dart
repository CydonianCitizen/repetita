import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioPlaybackServiceProvider = Provider<AudioPlaybackService>((ref) {
  final service = AudioPlaybackService();
  ref.onDispose(service.dispose);
  return service;
});

class AudioPlaybackService {
  AudioPlaybackService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  String? _currentSource;

  String? get currentSource => _currentSource;
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  Future<void> playFile(File file) async {
    if (!file.existsSync()) return;
    await stop();
    _currentSource = file.path;
    await _player.play(DeviceFileSource(file.path));
  }

  Future<void> playPath(String path) async {
    await stop();
    _currentSource = path;
    await _player.play(DeviceFileSource(path));
  }

  Future<void> stop() async {
    _currentSource = null;
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  void dispose() {
    _currentSource = null;
    _player.dispose();
  }
}
