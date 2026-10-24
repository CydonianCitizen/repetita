import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/media/utils/media_content_renderer.dart';

void main() {
  group('MediaContentRenderer Unit Tests', () {
    test('extracts markdown image references', () {
      const text =
          'Look at this diagram: ![diagram](media://diagram_123.png) What is part A?';
      final refs = MediaContentRenderer.extractMediaReferences(text);

      expect(refs, ['media://diagram_123.png']);
      expect(
        MediaContentRenderer.stripMediaTags(text),
        'Look at this diagram:  What is part A?',
      );
    });

    test('extracts Anki img tag references', () {
      const text =
          'Question <img src="media://anki_anatomy.jpg" /> explain function.';
      final refs = MediaContentRenderer.extractMediaReferences(text);

      expect(refs, ['media://anki_anatomy.jpg']);
      expect(
        MediaContentRenderer.stripMediaTags(text),
        'Question  explain function.',
      );
    });

    test('extracts direct media protocol references', () {
      const text = 'media://solo_image.webp';
      final refs = MediaContentRenderer.extractMediaReferences(text);

      expect(refs, ['media://solo_image.webp']);
      expect(MediaContentRenderer.stripMediaTags(text), '');
    });
  });
}
