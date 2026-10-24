import 'package:path/path.dart' as p;

/// Utility service for audio file detection and Anki [sound:...] tag operations.
abstract final class AudioService {
  static const Set<String> supportedExtensions = {
    '.mp3',
    '.m4a',
    '.wav',
    '.ogg',
    '.aac',
    '.flac',
    '.opus',
    '.wma',
  };

  static final RegExp _soundTagRegex = RegExp(r'\[sound:(.*?)\]');

  /// Determines if [fileName] has a recognized audio extension.
  static bool isAudioFile(String fileName) {
    if (fileName.trim().isEmpty) return false;
    final ext = p.extension(fileName).toLowerCase();
    return supportedExtensions.contains(ext);
  }

  /// Extracts all audio filenames embedded in [sound:...] tags from [text].
  static List<String> extractSoundTags(String text) {
    if (text.isEmpty) return const [];
    return _soundTagRegex
        .allMatches(text)
        .map((m) => m.group(1)?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Wraps [fileName] in Anki-compatible [sound:filename] format.
  static String formatSoundTag(String fileName) {
    return '[sound:$fileName]';
  }

  /// Strips all [sound:...] tags from [text], returning text without audio markers.
  static String stripSoundTags(String text) {
    return text.replaceAll(_soundTagRegex, '');
  }
}
