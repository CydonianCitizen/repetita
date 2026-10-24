import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/media/data/services/audio_service.dart';

void main() {
  group('AudioService Unit Tests', () {
    test('isAudioFile identifies standard audio extensions correctly', () {
      expect(AudioService.isAudioFile('test.mp3'), isTrue);
      expect(AudioService.isAudioFile('audio.M4A'), isTrue);
      expect(AudioService.isAudioFile('recording.wav'), isTrue);
      expect(AudioService.isAudioFile('sound.ogg'), isTrue);
      expect(AudioService.isAudioFile('voice.aac'), isTrue);
      expect(AudioService.isAudioFile('sample.flac'), isTrue);
      expect(AudioService.isAudioFile('track.opus'), isTrue);

      // Non-audio files
      expect(AudioService.isAudioFile('image.png'), isFalse);
      expect(AudioService.isAudioFile('doc.pdf'), isFalse);
      expect(AudioService.isAudioFile('archive.apkg'), isFalse);
      expect(AudioService.isAudioFile(''), isFalse);
    });

    test('extractSoundTags extracts Anki sound tags from text', () {
      const text = 'Hello [sound:pronunciation.mp3] world and [sound:example.m4a]!';
      final sounds = AudioService.extractSoundTags(text);
      expect(sounds, equals(['pronunciation.mp3', 'example.m4a']));

      const noSounds = 'Plain text without audio';
      expect(AudioService.extractSoundTags(noSounds), isEmpty);
    });

    test('formatSoundTag wraps filename in Anki sound tag format', () {
      expect(
        AudioService.formatSoundTag('audio.mp3'),
        equals('[sound:audio.mp3]'),
      );
    });

    test('stripSoundTags removes all sound tags from text', () {
      const text = 'Question? [sound:audio.mp3] More details.';
      expect(
        AudioService.stripSoundTags(text),
        equals('Question?  More details.'),
      );
    });
  });
}
