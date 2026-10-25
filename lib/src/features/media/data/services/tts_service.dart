import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'audio_service.dart';

/// Abstraction over platform Text-to-Speech engines for testability and portability.
abstract class TtsEngine {
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setLanguage(String language);
  Future<List<String>> getLanguages();
  Future<void> setSpeechRate(double rate);
  Future<void> setPitch(double pitch);
  void setStartHandler(VoidCallback callback);
  void setCompletionHandler(VoidCallback callback);
  void setCancelHandler(VoidCallback callback);
  void setErrorHandler(void Function(dynamic message) callback);
}

/// Production implementation of [TtsEngine] wrapping [FlutterTts].
class FlutterTtsEngine implements TtsEngine {
  FlutterTtsEngine({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  @override
  Future<List<String>> getLanguages() async {
    final dynamic langs = await _tts.getLanguages;
    if (langs is List) {
      return langs.map((e) => e.toString()).toList();
    }
    return const [];
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  @override
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  @override
  void setStartHandler(VoidCallback callback) {
    _tts.setStartHandler(callback);
  }

  @override
  void setCompletionHandler(VoidCallback callback) {
    _tts.setCompletionHandler(callback);
  }

  @override
  void setCancelHandler(VoidCallback callback) {
    _tts.setCancelHandler(callback);
  }

  @override
  void setErrorHandler(void Function(dynamic message) callback) {
    _tts.setErrorHandler(callback);
  }
}

/// Offline Text-to-Speech service utilizing device-native speech synthesis engines.
///
/// Strips markdown formatting, KaTeX math symbols, clozes, and sound tags before speaking.
class TtsService {
  TtsService({TtsEngine? engine}) : _engine = engine ?? FlutterTtsEngine() {
    _engine.setStartHandler(() {
      _isSpeaking = true;
      if (!_speakingController.isClosed) {
        _speakingController.add(true);
      }
    });
    _engine.setCompletionHandler(() {
      _isSpeaking = false;
      if (!_speakingController.isClosed) {
        _speakingController.add(false);
      }
    });
    _engine.setCancelHandler(() {
      _isSpeaking = false;
      if (!_speakingController.isClosed) {
        _speakingController.add(false);
      }
    });
    _engine.setErrorHandler((_) {
      _isSpeaking = false;
      if (!_speakingController.isClosed) {
        _speakingController.add(false);
      }
    });
  }

  final TtsEngine _engine;
  bool _isSpeaking = false;
  final StreamController<bool> _speakingController =
      StreamController<bool>.broadcast();

  bool get isSpeaking => _isSpeaking;
  Stream<bool> get onSpeakingChanged => _speakingController.stream;

  /// Cleans raw flashcard text for speech synthesis:
  /// removes [sound:...] tags, Markdown images/links, HTML tags,
  /// converts Clozes to visible text, and strips LaTeX math delimiters.
  static String cleanTextForSpeech(String rawText) {
    if (rawText.trim().isEmpty) return '';

    // 1. Remove [sound:...] tags
    var text = AudioService.stripSoundTags(rawText);

    // 2. Remove markdown images: ![alt](url)
    text = text.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');

    // 3. Convert markdown links [text](url) -> text
    text = text.replaceAllMapped(
      RegExp(r'\[(.*?)\]\(.*?\)'),
      (m) => m.group(1) ?? '',
    );

    // 4. Remove HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');

    // 5. Convert Cloze syntax: {{c1::answer::hint}} -> answer
    text = text.replaceAllMapped(
      RegExp(r'\{\{c\d+::(.*?)(?:::.*?)?\}\}'),
      (m) => m.group(1) ?? '',
    );

    // 6. Clean LaTeX math delimiters ($$, $, \[, \], \(, \))
    text = text.replaceAll(r'$$', ' ');
    text = text.replaceAll(r'$', ' ');
    text = text.replaceAll(r'\[', ' ');
    text = text.replaceAll(r'\]', ' ');
    text = text.replaceAll(r'\(', ' ');
    text = text.replaceAll(r'\)', ' ');

    // 7. Collapse extra whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  /// Speaks the provided text using the offline TTS engine after sanitization.
  Future<void> speak(
    String rawText, {
    String? language,
    double? speechRate,
  }) async {
    final cleaned = cleanTextForSpeech(rawText);
    if (cleaned.isEmpty) return;

    await stop();

    if (language != null && language.isNotEmpty) {
      await _engine.setLanguage(language);
    }
    if (speechRate != null) {
      await _engine.setSpeechRate(speechRate);
    }

    await _engine.speak(cleaned);
  }

  /// Stops current speech output.
  Future<void> stop() async {
    _isSpeaking = false;
    if (!_speakingController.isClosed) {
      _speakingController.add(false);
    }
    await _engine.stop();
  }

  /// Sets current TTS language (e.g. 'en-US', 'it-IT').
  Future<void> setLanguage(String language) async {
    await _engine.setLanguage(language);
  }

  /// Returns list of available platform TTS language tags.
  Future<List<String>> getLanguages() async {
    return _engine.getLanguages();
  }

  /// Sets speech rate (typically 0.0 to 1.0, 0.5 default on Android).
  Future<void> setSpeechRate(double rate) async {
    await _engine.setSpeechRate(rate);
  }

  /// Sets pitch (0.5 to 2.0, 1.0 default).
  Future<void> setPitch(double pitch) async {
    await _engine.setPitch(pitch);
  }

  void dispose() {
    _engine.stop();
    _speakingController.close();
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});
