class MediaContentRenderer {
  const MediaContentRenderer._();

  static final RegExp markdownImageRegex = RegExp(
    r'!\[(.*?)\]\((media:\/\/[^\s\)]+|[^\s\)]+)\)',
  );
  static final RegExp directMediaRegex = RegExp(
    r'(media:\/\/[a-zA-Z0-9_\-\.]+)',
  );
  static final RegExp imgTagRegex = RegExp(
    r'<img[^>]+src=["'
    ']([^"'
    ']+)["'
    '][^>]*>',
  );

  /// Checks if [text] contains any media reference.
  static bool hasMedia(String text) {
    return markdownImageRegex.hasMatch(text) ||
        directMediaRegex.hasMatch(text) ||
        imgTagRegex.hasMatch(text);
  }

  /// Extracts cleaned media file names (without `media://` scheme).
  static List<String> extractMediaFilenames(String text) {
    return extractMediaReferences(text).map((ref) {
      if (ref.startsWith('media://')) {
        return ref.substring('media://'.length);
      }
      return ref;
    }).toList();
  }

  /// Extracts all media references (e.g. `media://filename.png`) from [text].
  static List<String> extractMediaReferences(String text) {
    final refs = <String>{};
    for (final match in markdownImageRegex.allMatches(text)) {
      final ref = match.group(2);
      if (ref != null && ref.isNotEmpty) refs.add(ref);
    }
    for (final match in directMediaRegex.allMatches(text)) {
      final ref = match.group(1);
      if (ref != null && ref.isNotEmpty) refs.add(ref);
    }
    for (final match in imgTagRegex.allMatches(text)) {
      final ref = match.group(1);
      if (ref != null && ref.isNotEmpty) refs.add(ref);
    }
    return refs.toList();
  }

  /// Removes image embed tags leaving only standard prose text.
  static String stripMediaTags(String text) {
    var result = text.replaceAll(markdownImageRegex, '');
    result = result.replaceAll(imgTagRegex, '');
    result = result.replaceAll(directMediaRegex, '');
    return result.trim();
  }
}
