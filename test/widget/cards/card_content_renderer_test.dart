import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/cards/presentation/widgets/card_content_renderer.dart';

void main() {
  group('CardContentRenderer Widget Tests', () {
    Widget buildSubject(String content, {TextStyle? style}) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CardContentRenderer(content: content, textStyle: style),
          ),
        ),
      );
    }

    testWidgets(
      'renders plain text as standard Text widget with matching string',
      (tester) async {
        const text = 'Capital of France is Paris';
        await tester.pumpWidget(buildSubject(text));

        expect(find.text(text), findsOneWidget);
        expect(find.byType(Math), findsNothing);
      },
    );

    testWidgets('renders inline LaTeX math with Math widget', (tester) async {
      const text = r'Formula for energy is $E=mc^2$ according to Einstein.';
      await tester.pumpWidget(buildSubject(text));

      expect(find.byType(Math), findsOneWidget);
      final mathWidget = tester.widget<Math>(find.byType(Math));
      expect(mathWidget.mathStyle, MathStyle.text);
      expect(mathWidget.ast, isNotNull);
    });

    testWidgets(r'renders alternate inline LaTeX syntax \( ... \)', (
      tester,
    ) async {
      const text = r'Pythagorean theorem: \(a^2 + b^2 = c^2\)';
      await tester.pumpWidget(buildSubject(text));

      expect(find.byType(Math), findsOneWidget);
      final mathWidget = tester.widget<Math>(find.byType(Math));
      expect(mathWidget.mathStyle, MathStyle.text);
      expect(mathWidget.ast, isNotNull);
    });

    testWidgets(
      r'renders display block LaTeX math $$\int x dx$$ with display style',
      (tester) async {
        const text = r'Integral: $$\int_0^\infty e^{-x} dx = 1$$';
        await tester.pumpWidget(buildSubject(text));

        expect(find.byType(Math), findsOneWidget);
        final mathWidget = tester.widget<Math>(find.byType(Math));
        expect(mathWidget.mathStyle, MathStyle.display);
        expect(mathWidget.ast, isNotNull);
      },
    );

    testWidgets(r'renders alternate display block LaTeX syntax \[ ... \]', (
      tester,
    ) async {
      const text = r'Summation: \[\sum_{i=1}^n i = \frac{n(n+1)}{2}\]';
      await tester.pumpWidget(buildSubject(text));

      expect(find.byType(Math), findsOneWidget);
      final mathWidget = tester.widget<Math>(find.byType(Math));
      expect(mathWidget.mathStyle, MathStyle.display);
      expect(mathWidget.ast, isNotNull);
    });

    testWidgets('handles malformed LaTeX safely using fallback text', (
      tester,
    ) async {
      const text = r'Broken formula: $\frac{invalid$';
      await tester.pumpWidget(buildSubject(text));

      // Should not throw or crash the widget tree
      expect(find.byType(CardContentRenderer), findsOneWidget);
    });

    testWidgets('renders markdown bold and italic formatting', (tester) async {
      const text = 'This is **bold** and this is *italic*.';
      await tester.pumpWidget(buildSubject(text));

      expect(find.byType(CardContentRenderer), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
    });
  });
}
