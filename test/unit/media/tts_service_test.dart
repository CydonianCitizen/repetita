import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/media/data/services/tts_service.dart';

class FakeTtsEngine implements TtsEngine {
  String? lastSpoken;
  String? currentLanguage;
  double currentRate = 0.5;
  double currentPitch = 1.0;
  bool isStopped = false;

  VoidCallback? startHandler;
  VoidCallback? completionHandler;
  VoidCallback? cancelHandler;
  void Function(dynamic message)? errorHandler;

  @override
  Future<void> speak(String text) async {
    lastSpoken = text;
    isStopped = false;
    startHandler?.call();
  }

  @override
  Future<void> stop() async {
    isStopped = true;
    cancelHandler?.call();
  }

  @override
  Future<void> setLanguage(String language) async {
    currentLanguage = language;
  }

  @override
  Future<List<String>> getLanguages() async {
    return ['en-US', 'it-IT', 'fr-FR', 'de-DE', 'es-ES'];
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    currentRate = rate;
  }

  @override
  Future<void> setPitch(double pitch) async {
    currentPitch = pitch;
  }

  @override
  void setStartHandler(VoidCallback callback) {
    startHandler = callback;
  }

  @override
  void setCompletionHandler(VoidCallback callback) {
    completionHandler = callback;
  }

  @override
  void setCancelHandler(VoidCallback callback) {
    cancelHandler = callback;
  }

  @override
  void setErrorHandler(void Function(dynamic message) callback) {
    errorHandler = callback;
  }
}

void main() {
  group('TtsService Text Sanitization Tests', () {
    test('cleanTextForSpeech strips audio [sound:...] tags', () {
      const input = 'Word [sound:sample.mp3] pronunciation [sound:alt.wav]';
      expect(
        TtsService.cleanTextForSpeech(input),
        equals('Word pronunciation'),
      );
    });

    test('cleanTextForSpeech strips Markdown images and unwraps links', () {
      const input =
          'See ![anatomy](media://heart.png) and [read study](https://example.com)';
      expect(
        TtsService.cleanTextForSpeech(input),
        equals('See and read study'),
      );
    });

    test('cleanTextForSpeech strips HTML tags', () {
      const input =
          '<div><b>Important</b>: <span>Cellular respiration</span></div>';
      expect(
        TtsService.cleanTextForSpeech(input),
        equals('Important : Cellular respiration'),
      );
    });

    test('cleanTextForSpeech extracts visible text from Cloze syntax', () {
      const input =
          'The capital is {{c1::Rome::capital}} and region is {{c2::Lazio}}';
      expect(
        TtsService.cleanTextForSpeech(input),
        equals('The capital is Rome and region is Lazio'),
      );
    });

    test('cleanTextForSpeech strips LaTeX math delimiters', () {
      const input = r'Formula $$E=mc^2$$ with $x \in \mathbb{R}$ and \(y > 0\)';
      expect(
        TtsService.cleanTextForSpeech(input),
        equals(r'Formula E=mc^2 with x \in \mathbb{R} and y > 0'),
      );
    });

    test(
      'cleanTextForSpeech handles empty, whitespace-only and mixed text',
      () {
        expect(TtsService.cleanTextForSpeech('   '), isEmpty);
        expect(TtsService.cleanTextForSpeech(''), isEmpty);
        const mixed = '  [sound:a.mp3]   Hello   world!  <br>  ';
        expect(TtsService.cleanTextForSpeech(mixed), equals('Hello world!'));
      },
    );
  });

  group('TtsService Engine Interaction Tests', () {
    late FakeTtsEngine engine;
    late TtsService service;

    setUp(() {
      engine = FakeTtsEngine();
      service = TtsService(engine: engine);
    });

    tearDown(() {
      service.dispose();
    });

    test(
      'speak sanitizes text and triggers engine speak and startHandler',
      () async {
        await service.speak('Question: [sound:q.mp3] What is DNA?');
        expect(engine.lastSpoken, equals('Question: What is DNA?'));
        expect(service.isSpeaking, isTrue);
      },
    );

    test('stop halts engine and updates speaking state', () async {
      await service.speak('Testing speech');
      expect(service.isSpeaking, isTrue);

      await service.stop();
      expect(engine.isStopped, isTrue);
      expect(service.isSpeaking, isFalse);
    });

    test('engine completion and error handlers reset isSpeaking', () async {
      await service.speak('Sentence to speak');
      expect(service.isSpeaking, isTrue);

      engine.completionHandler?.call();
      expect(service.isSpeaking, isFalse);

      await service.speak('Second sentence');
      expect(service.isSpeaking, isTrue);

      engine.errorHandler?.call('error');
      expect(service.isSpeaking, isFalse);
    });

    test('setLanguage, getLanguages, and setSpeechRate configure engine parameters', () async {
      final langs = await service.getLanguages();
      expect(langs, contains('it-IT'));

      await service.setLanguage('it-IT');
      expect(engine.currentLanguage, equals('it-IT'));

      await service.setSpeechRate(0.8);
      expect(engine.currentRate, equals(0.8));

      await service.setPitch(1.2);
      expect(engine.currentPitch, equals(1.2));
    });
  });
}
