import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// A rich flashcard content renderer supporting:
/// - Offline LaTeX math via KaTeX (inline `$...$` or `\(...\)`, display `$$...$$` or `\[...\]`)
/// - Markdown formatting (bold `**`, italic `*`, inline code `` ` ``, strikethrough `~~`)
/// - Automatic fallback to styled plain text when no math or markdown is detected
class CardContentRenderer extends StatelessWidget {
  const CardContentRenderer({
    super.key,
    required this.content,
    this.textStyle,
    this.textAlign = TextAlign.start,
  });

  final String content;
  final TextStyle? textStyle;
  final TextAlign textAlign;

  static final _hasMathOrMarkdown = RegExp(r'(\$|\\\(|\\\[|\*\*|\*|`|~~)');
  static final _displayMathRegex = RegExp(
    r'(\$\$([\s\S]*?)\$\$|\\\[([\s\S]*?)\\\])',
  );
  static final _inlineMathRegex = RegExp(
    r'(\\\(([\s\S]*?)\\\)|\$([^\$\n]+?)\$)',
  );
  static final _markdownInlineRegex = RegExp(
    r'(\*\*([^*]+)\*\*|\*([^*]+)\*|`([^`]+)`|~~([^~]+)~~)',
  );

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle =
        textStyle ?? theme.textTheme.bodyLarge ?? const TextStyle();

    // Fast path: pure plain text without math or markdown
    if (!_hasMathOrMarkdown.hasMatch(content)) {
      return Text(content, style: baseStyle, textAlign: textAlign);
    }

    // Check if content contains display math blocks
    final displayMatches = _displayMathRegex.allMatches(content).toList();
    if (displayMatches.isNotEmpty) {
      return _buildDisplayLayout(
        context,
        baseStyle,
        colorScheme,
        displayMatches,
      );
    }

    // Only inline math / markdown
    final spans = _buildInlineSpans(content, baseStyle, colorScheme);
    return Text.rich(TextSpan(children: spans), textAlign: textAlign);
  }

  Widget _buildDisplayLayout(
    BuildContext context,
    TextStyle baseStyle,
    ColorScheme colorScheme,
    List<RegExpMatch> matches,
  ) {
    final widgets = <Widget>[];
    var lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        final textBefore = content.substring(lastIndex, match.start).trim();
        if (textBefore.isNotEmpty) {
          final spans = _buildInlineSpans(textBefore, baseStyle, colorScheme);
          widgets.add(
            Text.rich(TextSpan(children: spans), textAlign: textAlign),
          );
        }
      }

      // Group 2 is for $$...$$, Group 3 is for \[...\]
      final mathCode = (match.group(2) ?? match.group(3) ?? '').trim();
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                mathCode,
                mathStyle: MathStyle.display,
                textStyle: baseStyle,
                onErrorFallback: (err) => Text(
                  '\$\$$mathCode\$\$',
                  style: baseStyle.copyWith(color: Colors.red.shade400),
                ),
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < content.length) {
      final textAfter = content.substring(lastIndex).trim();
      if (textAfter.isNotEmpty) {
        final spans = _buildInlineSpans(textAfter, baseStyle, colorScheme);
        widgets.add(Text.rich(TextSpan(children: spans), textAlign: textAlign));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  List<InlineSpan> _buildInlineSpans(
    String text,
    TextStyle baseStyle,
    ColorScheme colorScheme,
  ) {
    final spans = <InlineSpan>[];
    final mathMatches = _inlineMathRegex.allMatches(text).toList();

    var lastIndex = 0;
    for (final match in mathMatches) {
      if (match.start > lastIndex) {
        final plainText = text.substring(lastIndex, match.start);
        spans.addAll(_buildMarkdownSpans(plainText, baseStyle, colorScheme));
      }

      // Group 2 is \(...\), Group 3 is $...$
      final mathCode = (match.group(2) ?? match.group(3) ?? '').trim();
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Math.tex(
              mathCode,
              mathStyle: MathStyle.text,
              textStyle: baseStyle,
              onErrorFallback: (err) => Text(
                '\$$mathCode\$',
                style: baseStyle.copyWith(color: Colors.red.shade400),
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      final plainText = text.substring(lastIndex);
      spans.addAll(_buildMarkdownSpans(plainText, baseStyle, colorScheme));
    }

    return spans;
  }

  List<InlineSpan> _buildMarkdownSpans(
    String text,
    TextStyle baseStyle,
    ColorScheme colorScheme,
  ) {
    final spans = <InlineSpan>[];
    final matches = _markdownInlineRegex.allMatches(text).toList();

    var lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      if (match.group(2) != null) {
        // **bold**
        spans.add(
          TextSpan(
            text: match.group(2),
            style: baseStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(3) != null) {
        // *italic*
        spans.add(
          TextSpan(
            text: match.group(3),
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(4) != null) {
        // `code`
        spans.add(
          TextSpan(
            text: match.group(4),
            style: baseStyle.copyWith(
              fontFamily: 'monospace',
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.7,
              ),
            ),
          ),
        );
      } else if (match.group(5) != null) {
        // ~~strikethrough~~
        spans.add(
          TextSpan(
            text: match.group(5),
            style: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return spans;
  }
}
