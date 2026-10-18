import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/utils/text_direction_utils.dart';

void main() {
  group('TextDirectionUtils Unit Tests', () {
    test('returns LTR for empty or null strings', () {
      expect(TextDirectionUtils.getDirection(null), equals(TextDirection.ltr));
      expect(TextDirectionUtils.getDirection(''), equals(TextDirection.ltr));
      expect(TextDirectionUtils.getDirection('   '), equals(TextDirection.ltr));
    });

    test('returns LTR for Latin, digits, and punctuation', () {
      expect(
        TextDirectionUtils.getDirection('Hello world'),
        equals(TextDirection.ltr),
      );
      expect(
        TextDirectionUtils.getDirection('12345'),
        equals(TextDirection.ltr),
      );
      expect(
        TextDirectionUtils.getDirection('Bonjour! Comment ça va?'),
        equals(TextDirection.ltr),
      );
      expect(TextDirectionUtils.isRtl('Ciao'), isFalse);
    });

    test('returns RTL for Arabic text', () {
      expect(
        TextDirectionUtils.getDirection('مرحبا بكم'),
        equals(TextDirection.rtl),
      );
      expect(
        TextDirectionUtils.getDirection('السلام عليكم'),
        equals(TextDirection.rtl),
      );
      expect(TextDirectionUtils.isRtl('شكرا'), isTrue);
    });

    test('returns RTL for Hebrew text', () {
      expect(
        TextDirectionUtils.getDirection('שלום עולם'),
        equals(TextDirection.rtl),
      );
      expect(TextDirectionUtils.isRtl('תודה'), isTrue);
    });

    test('determines direction by first strong letter', () {
      // Leading punctuation or numbers followed by Arabic
      expect(
        TextDirectionUtils.getDirection('... مرحبا'),
        equals(TextDirection.rtl),
      );
      // Leading punctuation followed by English
      expect(
        TextDirectionUtils.getDirection('... Hello'),
        equals(TextDirection.ltr),
      );
    });
  });
}
