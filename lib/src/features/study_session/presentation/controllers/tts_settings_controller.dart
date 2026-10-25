import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';

part 'tts_settings_controller.g.dart';

class TtsSettingsState {
  const TtsSettingsState({
    this.autoTtsEnabled = false,
    this.speechRate = 0.5,
    this.language,
  });

  final bool autoTtsEnabled;
  final double speechRate;
  final String? language;

  TtsSettingsState copyWith({
    bool? autoTtsEnabled,
    double? speechRate,
    String? language,
  }) {
    return TtsSettingsState(
      autoTtsEnabled: autoTtsEnabled ?? this.autoTtsEnabled,
      speechRate: speechRate ?? this.speechRate,
      language: language ?? this.language,
    );
  }
}

@Riverpod(keepAlive: true)
class TtsSettingsController extends _$TtsSettingsController {
  static const _keyEnabled = 'tts_auto_enabled';
  static const _keyRate = 'tts_speech_rate';
  static const _keyLang = 'tts_language';

  @override
  TtsSettingsState build() {
    _loadFromDb();
    return const TtsSettingsState();
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final enabledStr = await db.getSetting(_keyEnabled);
      final rateStr = await db.getSetting(_keyRate);
      final langStr = await db.getSetting(_keyLang);

      if (ref.mounted) {
        state = state.copyWith(
          autoTtsEnabled: enabledStr == 'true',
          speechRate: double.tryParse(rateStr ?? '') ?? 0.5,
          language: (langStr != null && langStr.isNotEmpty) ? langStr : null,
        );
      }
    } catch (e) {
      debugPrint('Failed to load TTS settings: $e');
    }
  }

  Future<void> toggleAutoTts() async {
    final newValue = !state.autoTtsEnabled;
    state = state.copyWith(autoTtsEnabled: newValue);
    try {
      await ref
          .read(databaseProvider)
          .setSetting(_keyEnabled, newValue.toString());
    } catch (e) {
      debugPrint('Failed to save auto TTS setting: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    state = state.copyWith(speechRate: rate);
    try {
      await ref.read(databaseProvider).setSetting(_keyRate, rate.toString());
    } catch (e) {
      debugPrint('Failed to save TTS speech rate: $e');
    }
  }

  Future<void> setLanguage(String? language) async {
    state = state.copyWith(language: language);
    try {
      await ref.read(databaseProvider).setSetting(_keyLang, language ?? '');
    } catch (e) {
      debugPrint('Failed to save TTS language: $e');
    }
  }
}
