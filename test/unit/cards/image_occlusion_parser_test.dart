import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/image_occlusion/image_occlusion_box.dart';
import 'package:repetita/src/core/algorithms/image_occlusion/image_occlusion_parser.dart';

void main() {
  group('ImageOcclusionBox Unit Tests', () {
    test('serializes to map and round-trips correctly', () {
      const box = ImageOcclusionBox(
        id: 'box_1',
        x: 0.1234,
        y: 0.5678,
        width: 0.25,
        height: 0.35,
        label: 'Heart Ventricle',
      );

      final map = box.toMap();
      final restored = ImageOcclusionBox.fromMap(map);

      expect(restored.id, 'box_1');
      expect(restored.x, 0.1234);
      expect(restored.y, 0.5678);
      expect(restored.width, 0.25);
      expect(restored.height, 0.35);
      expect(restored.label, 'Heart Ventricle');
      expect(restored, equals(box));
    });

    test('supports copyWith mutation', () {
      const box = ImageOcclusionBox(
        id: 'box_1',
        x: 0.1,
        y: 0.2,
        width: 0.3,
        height: 0.4,
      );

      final modified = box.copyWith(label: 'Updated Label', x: 0.15);
      expect(modified.label, 'Updated Label');
      expect(modified.x, 0.15);
      expect(modified.y, 0.2);
      expect(modified.id, 'box_1');
    });
  });

  group('ImageOcclusionParser Unit Tests', () {
    test('detects valid and invalid image occlusion prompts', () {
      expect(ImageOcclusionParser.isImageOcclusion('Standard front'), isFalse);
      expect(
        ImageOcclusionParser.isImageOcclusion(
          '{{io::media://img.png::box_1::W10=}}',
        ),
        isTrue,
      );
    });

    test('encodes and parses image occlusion round-trip', () {
      final boxes = [
        const ImageOcclusionBox(
          id: 'io_1',
          x: 0.1,
          y: 0.2,
          width: 0.3,
          height: 0.15,
          label: 'Aorta',
        ),
        const ImageOcclusionBox(
          id: 'io_2',
          x: 0.5,
          y: 0.6,
          width: 0.2,
          height: 0.25,
          label: 'Left Ventricle',
        ),
      ];

      final encoded = ImageOcclusionParser.encode(
        mediaReference: 'media://heart_diagram.png',
        activeBoxId: 'io_1',
        boxes: boxes,
      );

      expect(ImageOcclusionParser.isImageOcclusion(encoded), isTrue);

      final data = ImageOcclusionParser.parse(encoded);
      expect(data, isNotNull);
      expect(data!.mediaReference, 'media://heart_diagram.png');
      expect(data.activeBoxId, 'io_1');
      expect(data.boxes.length, 2);
      expect(data.activeBox?.label, 'Aorta');
    });

    test('parses unencoded JSON array syntax as fallback', () {
      const rawPrompt =
          '{{io::media://cell.png::box_1::[{"id":"box_1","x":0.2,"y":0.3,"w":0.4,"h":0.5,"label":"Nucleus"}]}}';

      final data = ImageOcclusionParser.parse(rawPrompt);
      expect(data, isNotNull);
      expect(data!.mediaReference, 'media://cell.png');
      expect(data.activeBoxId, 'box_1');
      expect(data.boxes.first.label, 'Nucleus');
    });
  });
}
