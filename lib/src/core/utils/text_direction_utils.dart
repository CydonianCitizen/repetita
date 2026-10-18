import 'package:flutter/widgets.dart';

class TextDirectionUtils {
  const TextDirectionUtils._();

  // Arabic, Hebrew, Syriac, Thaana, and Presentation Forms
  static final _rtlRegex = RegExp(
    r'[\u0590-\u05FF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  static final _letterRegex = RegExp(r'\p{L}', unicode: true);

  /// Analyzes the string and returns [TextDirection.rtl] if the first strong
  /// directional character is Arabic/Hebrew/RTL, otherwise [TextDirection.ltr].
  static TextDirection getDirection(String? text) {
    if (text == null || text.trim().isEmpty) {
      return TextDirection.ltr;
    }

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (_rtlRegex.hasMatch(char)) {
        return TextDirection.rtl;
      }
      if (_letterRegex.hasMatch(char)) {
        return TextDirection.ltr;
      }
    }
    return TextDirection.ltr;
  }

  static bool isRtl(String? text) => getDirection(text) == TextDirection.rtl;
}
