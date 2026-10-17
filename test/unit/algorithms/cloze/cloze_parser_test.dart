import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/cloze/cloze_parser.dart';
import 'package:repetita/src/core/algorithms/cloze/cloze_segment.dart';

void main() {
  group('ClozeParser Unit Tests', () {
    group('isCloze', () {
      test('returns false for plain text', () {
        expect(
          ClozeParser.isCloze('La capitale della Francia è Parigi.'),
          isFalse,
        );
        expect(ClozeParser.isCloze(''), isFalse);
        expect(ClozeParser.isCloze('{{plain}}'), isFalse);
        expect(ClozeParser.isCloze('{c1::Parigi}'), isFalse);
        expect(ClozeParser.isCloze('{{c::Parigi}}'), isFalse);
      });

      test('returns true for valid cloze patterns', () {
        expect(
          ClozeParser.isCloze('La capitale della Francia è {{c1::Parigi}}.'),
          isTrue,
        );
        expect(ClozeParser.isCloze('{{c1::Parigi::capitale}}'), isTrue);
        expect(ClozeParser.isCloze('{{c2::Roma}} e {{c1::Parigi}}'), isTrue);
      });
    });

    group('extractClozeIndices', () {
      test('returns empty set when no cloze blocks exist', () {
        expect(ClozeParser.extractClozeIndices('Testo normale'), isEmpty);
      });

      test('extracts single and multiple indices', () {
        const text = '{{c1::Roma}} è in Italia, {{c2::Parigi}} è in Francia.';
        expect(ClozeParser.extractClozeIndices(text), equals({1, 2}));
      });

      test('deduplicates recurring indices', () {
        const text = '{{c1::Roma}} e {{c1::Milano}} sono in Italia.';
        expect(ClozeParser.extractClozeIndices(text), equals({1}));
      });

      test('handles non-sequential indices', () {
        const text = '{{c5::Tokyo}} e {{c2::Kyoto}}';
        expect(ClozeParser.extractClozeIndices(text), equals({2, 5}));
      });
    });

    group('getNextClozeIndex', () {
      test('returns 1 for plain text', () {
        expect(ClozeParser.getNextClozeIndex('Nessun cloze qui'), equals(1));
      });

      test('increments past highest index', () {
        expect(
          ClozeParser.getNextClozeIndex('{{c1::A}} e {{c2::B}}'),
          equals(3),
        );
        expect(
          ClozeParser.getNextClozeIndex('{{c3::A}} e {{c1::B}}'),
          equals(4),
        );
      });
    });

    group('getPromptSegments & renderClozePrompt', () {
      test('returns single unchanged segment for non-cloze text', () {
        const text = 'Semplice testo senza cloze';
        final segments = ClozeParser.getPromptSegments(text);

        expect(segments, equals([const ClozeSegment(text: text)]));
        expect(ClozeParser.renderClozePrompt(text), equals(text));
      });

      test('masks active cloze without hint with [...]', () {
        const text = 'La capitale della Francia è {{c1::Parigi}}.';
        final segments = ClozeParser.getPromptSegments(text, activeIndex: 1);

        expect(
          segments,
          equals([
            const ClozeSegment(text: 'La capitale della Francia è '),
            const ClozeSegment(
              text: '[...]',
              isCloze: true,
              isActive: true,
              hint: null,
            ),
            const ClozeSegment(text: '.'),
          ]),
        );
        expect(
          ClozeParser.renderClozePrompt(text, activeIndex: 1),
          equals('La capitale della Francia è [...].'),
        );
      });

      test('masks active cloze with hint as [hint]', () {
        const text = 'La capitale è {{c1::Parigi::nome città}}.';
        final segments = ClozeParser.getPromptSegments(text, activeIndex: 1);

        expect(
          segments,
          equals([
            const ClozeSegment(text: 'La capitale è '),
            const ClozeSegment(
              text: '[nome città]',
              isCloze: true,
              isActive: true,
              hint: 'nome città',
            ),
            const ClozeSegment(text: '.'),
          ]),
        );
        expect(
          ClozeParser.renderClozePrompt(text, activeIndex: 1),
          equals('La capitale è [nome città].'),
        );
      });

      test(
        'masks only activeIndex and shows other clozes as normal answer text',
        () {
          const text = '{{c1::Canberra}} è la capitale di {{c2::Australia}}.';

          // When c1 is active
          final prompt1 = ClozeParser.renderClozePrompt(text, activeIndex: 1);
          expect(prompt1, equals('[...] è la capitale di Australia.'));

          final segments1 = ClozeParser.getPromptSegments(text, activeIndex: 1);
          expect(segments1[0].isActive, isTrue);
          expect(segments1[0].text, equals('[...]'));
          expect(segments1[2].isActive, isFalse);
          expect(segments1[2].text, equals('Australia'));

          // When c2 is active
          final prompt2 = ClozeParser.renderClozePrompt(text, activeIndex: 2);
          expect(prompt2, equals('Canberra è la capitale di [...].'));

          final segments2 = ClozeParser.getPromptSegments(text, activeIndex: 2);
          expect(segments2[0].isActive, isFalse);
          expect(segments2[0].text, equals('Canberra'));
          expect(segments2[2].isActive, isTrue);
          expect(segments2[2].text, equals('[...]'));
        },
      );

      test('masks multiple instances of same active index', () {
        const text = '{{c1::A}} e {{c1::B}} sono vocali.';
        final prompt = ClozeParser.renderClozePrompt(text, activeIndex: 1);
        expect(prompt, equals('[...] e [...] sono vocali.'));
      });
    });

    group('getAnswerSegments & renderClozeAnswer', () {
      test('unmasks all text and marks active cloze with isActive true', () {
        const text = 'La capitale è {{c1::Parigi::città}} e non {{c2::Lione}}.';
        final segments = ClozeParser.getAnswerSegments(text, activeIndex: 1);

        expect(
          segments,
          equals([
            const ClozeSegment(text: 'La capitale è '),
            const ClozeSegment(
              text: 'Parigi',
              isCloze: true,
              isActive: true,
              hint: 'città',
            ),
            const ClozeSegment(text: ' e non '),
            const ClozeSegment(
              text: 'Lione',
              isCloze: true,
              isActive: false,
              hint: null,
            ),
            const ClozeSegment(text: '.'),
          ]),
        );

        expect(
          ClozeParser.renderClozeAnswer(text, activeIndex: 1),
          equals('La capitale è Parigi e non Lione.'),
        );
      });
    });

    group('wrapSelectionWithCloze', () {
      test('wraps selected word with next index when index omitted', () {
        const text = 'Canberra è la capitale.';
        final wrapped = ClozeParser.wrapSelectionWithCloze(text, 0, 8);
        expect(wrapped, equals('{{c1::Canberra}} è la capitale.'));
      });

      test('uses next available index automatically', () {
        const text = '{{c1::Canberra}} è la capitale di Australia.';
        final wrapped = ClozeParser.wrapSelectionWithCloze(text, 34, 43);
        expect(
          wrapped,
          equals('{{c1::Canberra}} è la capitale di {{c2::Australia}}.'),
        );
      });

      test('supports explicit index and hint', () {
        const text = 'Roma è in Italia.';
        final wrapped = ClozeParser.wrapSelectionWithCloze(
          text,
          0,
          4,
          index: 3,
          hint: 'città eterna',
        );
        expect(wrapped, equals('{{c3::Roma::città eterna}} è in Italia.'));
      });

      test('handles empty selection at cursor position', () {
        const text = 'Ciao ';
        final wrapped = ClozeParser.wrapSelectionWithCloze(text, 5, 5);
        expect(wrapped, equals('Ciao {{c1::}}'));
      });

      test('safely clamps out of range bounds', () {
        const text = 'Test';
        final wrapped = ClozeParser.wrapSelectionWithCloze(text, -5, 20);
        expect(wrapped, equals('{{c1::Test}}'));
      });
    });

    group('Edge cases', () {
      test('handles multiline text with cloze', () {
        const text = 'Riga 1:\n{{c1::Valore 1}}\nRiga 2:\n{{c2::Valore 2}}';
        expect(ClozeParser.extractClozeIndices(text), equals({1, 2}));
        expect(
          ClozeParser.renderClozePrompt(text, activeIndex: 1),
          equals('Riga 1:\n[...]\nRiga 2:\nValore 2'),
        );
      });

      test('handles colons in hint content cleanly', () {
        const text = 'Formula: {{c1::E=mc^2::m: massa, c: celerità}}';
        final prompt = ClozeParser.renderClozePrompt(text, activeIndex: 1);
        expect(prompt, equals('Formula: [m: massa, c: celerità]'));

        final answer = ClozeParser.renderClozeAnswer(text, activeIndex: 1);
        expect(answer, equals('Formula: E=mc^2'));
      });

      test(
        'ClozeSegment value equality, hashCode, and toString work accurately',
        () {
          const seg1 = ClozeSegment(
            text: 'Paris',
            isCloze: true,
            isActive: true,
            hint: 'city',
          );
          const seg2 = ClozeSegment(
            text: 'Paris',
            isCloze: true,
            isActive: true,
            hint: 'city',
          );
          const seg3 = ClozeSegment(
            text: 'Lyon',
            isCloze: true,
            isActive: false,
          );

          expect(seg1, equals(seg2));
          expect(seg1.hashCode, equals(seg2.hashCode));
          expect(seg1 == seg3, isFalse);
          expect(seg1.toString(), contains('Paris'));
          expect(seg1.toString(), contains('isCloze: true'));
        },
      );
    });
  });
}
