import 'dart:convert';

/// Represents an occlusion mask rectangle positioned over an image using relative coordinates [0.0, 1.0].
class ImageOcclusionBox {
  const ImageOcclusionBox({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.label,
  });

  /// Unique identifier of the box within the image (e.g. "io_1", "io_2")
  final String id;

  /// Relative X coordinate in range [0.0, 1.0]
  final double x;

  /// Relative Y coordinate in range [0.0, 1.0]
  final double y;

  /// Relative width in range [0.0, 1.0]
  final double width;

  /// Relative height in range [0.0, 1.0]
  final double height;

  /// Optional label or answer hint for this specific occlusion box
  final String? label;

  Map<String, dynamic> toMap() => {
    'id': id,
    'x': double.parse(x.toStringAsFixed(4)),
    'y': double.parse(y.toStringAsFixed(4)),
    'w': double.parse(width.toStringAsFixed(4)),
    'h': double.parse(height.toStringAsFixed(4)),
    if (label != null && label!.trim().isNotEmpty) 'label': label!.trim(),
  };

  factory ImageOcclusionBox.fromMap(Map<String, dynamic> map) {
    return ImageOcclusionBox(
      id: map['id']?.toString() ?? '',
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      width: (map['w'] as num?)?.toDouble() ?? 0.0,
      height: (map['h'] as num?)?.toDouble() ?? 0.0,
      label: map['label'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ImageOcclusionBox.fromJson(String source) =>
      ImageOcclusionBox.fromMap(jsonDecode(source) as Map<String, dynamic>);

  ImageOcclusionBox copyWith({
    String? id,
    double? x,
    double? y,
    double? width,
    double? height,
    String? label,
  }) {
    return ImageOcclusionBox(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageOcclusionBox &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          label == other.label;

  @override
  int get hashCode => Object.hash(id, x, y, width, height, label);

  @override
  String toString() =>
      'ImageOcclusionBox(id: $id, x: $x, y: $y, w: $width, h: $height, label: $label)';
}
