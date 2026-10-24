import 'dart:convert';

import 'image_occlusion_box.dart';

/// Parsed data structure from an Image Occlusion card front.
class ImageOcclusionData {
  const ImageOcclusionData({
    required this.mediaReference,
    required this.activeBoxId,
    required this.boxes,
  });

  /// The media reference (e.g. `media://image.png` or `image.png`).
  final String mediaReference;

  /// The id of the box being tested on this particular card.
  final String activeBoxId;

  /// All occlusion boxes defined for the image.
  final List<ImageOcclusionBox> boxes;

  /// Resolves the currently active box, if found.
  ImageOcclusionBox? get activeBox =>
      boxes.where((b) => b.id == activeBoxId).firstOrNull;
}

/// Parser and serializer for Image Occlusion card definitions.
///
/// Syntax format: `{{io::<mediaRef>::<activeBoxId>::<base64OrJsonBoxes>}}`
class ImageOcclusionParser {
  const ImageOcclusionParser._();

  static final RegExp ioRegex = RegExp(
    r'\{\{io::(.+?)::(.+?)::(.+?)\}\}',
    dotAll: true,
  );

  /// Checks if [text] conforms to an Image Occlusion card syntax.
  static bool isImageOcclusion(String text) {
    return ioRegex.hasMatch(text);
  }

  /// Parses Image Occlusion data from [text], returning `null` if invalid.
  static ImageOcclusionData? parse(String text) {
    final match = ioRegex.firstMatch(text);
    if (match == null) return null;

    final mediaRef = match.group(1)!;
    final activeBoxId = match.group(2)!;
    final rawPayload = match.group(3)!.trim();

    try {
      List<dynamic> list;
      if (rawPayload.startsWith('[')) {
        list = jsonDecode(rawPayload) as List<dynamic>;
      } else {
        final decoded = utf8.decode(base64Decode(rawPayload));
        list = jsonDecode(decoded) as List<dynamic>;
      }

      final boxes = list
          .whereType<Map<String, dynamic>>()
          .map((m) => ImageOcclusionBox.fromMap(m))
          .toList();

      return ImageOcclusionData(
        mediaReference: mediaRef,
        activeBoxId: activeBoxId,
        boxes: boxes,
      );
    } catch (_) {
      return null;
    }
  }

  /// Serializes Image Occlusion configuration into a card prompt string.
  static String encode({
    required String mediaReference,
    required String activeBoxId,
    required List<ImageOcclusionBox> boxes,
  }) {
    final jsonStr = jsonEncode(boxes.map((b) => b.toMap()).toList());
    final encoded = base64Encode(utf8.encode(jsonStr));
    return '{{io::$mediaReference::$activeBoxId::$encoded}}';
  }
}
