import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/type_in/type_in_differ.dart';

void main() {
  group('TypeInDiffer Unit Tests', () {
    test('exact match returns isExactMatch true and single correct segment', () {
      final res = TypeInDiffer.diff(expected: 'Paris', actual: 'Paris');
      expect(res.isExactMatch, isTrue);
      expect(res.segments, hasLength(1));
      expect(res.segments.first.status, equals(TypeInCharStatus.correct));
      expect(res.segments.first.text, equals('Paris'));
    });

    test('case-insensitive match matches when ignoreCase is true', () {
      final res = TypeInDiffer.diff(
        expected: 'Paris',
        actual: 'paris',
        ignoreCase: true,
      );
      expect(res.isExactMatch, isTrue);
      expect(res.segments, hasLength(1));
      expect(res.segments.first.status, equals(TypeInCharStatus.correct));
    });

    test('missing letter in input shows missing segment', () {
      final res = TypeInDiffer.diff(expected: 'apple', actual: 'aple');
      expect(res.isExactMatch, isFalse);
      expect(
        res.segments.any(
          (s) => s.status == TypeInCharStatus.missing && s.text == 'p',
        ),
        isTrue,
      );
    });

    test('extra letter in input shows wrong segment', () {
      final res = TypeInDiffer.diff(expected: 'apple', actual: 'applee');
      expect(res.isExactMatch, isFalse);
      expect(
        res.segments.any(
          (s) => s.status == TypeInCharStatus.wrong && s.text == 'e',
        ),
        isTrue,
      );
    });

    test('substitution shows wrong and missing segments', () {
      final res = TypeInDiffer.diff(expected: 'cat', actual: 'cut');
      expect(res.isExactMatch, isFalse);
      expect(
        res.segments.any((s) => s.status == TypeInCharStatus.correct && s.text == 'c'),
        isTrue,
      );
      expect(
        res.segments.any((s) => s.status == TypeInCharStatus.correct && s.text == 't'),
        isTrue,
      );
      expect(res.segments.any((s) => s.status == TypeInCharStatus.wrong), isTrue);
      expect(res.segments.any((s) => s.status == TypeInCharStatus.missing), isTrue);
    });

    test('empty inputs handled cleanly', () {
      final res1 = TypeInDiffer.diff(expected: '', actual: '');
      expect(res1.isExactMatch, isTrue);
      expect(res1.segments, isEmpty);

      final res2 = TypeInDiffer.diff(expected: 'hello', actual: '');
      expect(res2.isExactMatch, isFalse);
      expect(res2.segments, [const TypeInDiffSegment('hello', TypeInCharStatus.missing)]);

      final res3 = TypeInDiffer.diff(expected: '', actual: 'hello');
      expect(res3.isExactMatch, isFalse);
      expect(res3.segments, [const TypeInDiffSegment('hello', TypeInCharStatus.wrong)]);
    });

    test('whitespace trimming works before diffing', () {
      final res = TypeInDiffer.diff(expected: '  Rome  ', actual: 'Rome');
      expect(res.isExactMatch, isTrue);
    });
  });
}
