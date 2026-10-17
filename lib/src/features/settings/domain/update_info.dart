class UpdateInfo {
  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.releaseUrl,
    this.releaseNotes,
    this.publishedAt,
  });

  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String releaseUrl;
  final String? releaseNotes;
  final DateTime? publishedAt;

  static bool isRemoteNewer(String current, String remote) {
    try {
      final cleanCurrent = current.trim().replaceFirst(RegExp(r'^[vV]'), '');
      final cleanRemote = remote.trim().replaceFirst(RegExp(r'^[vV]'), '');

      final currentParts = cleanCurrent
          .split('.')
          .map((p) => int.parse(p.split(RegExp(r'[-+]'))[0]))
          .toList();
      final remoteParts = cleanRemote
          .split('.')
          .map((p) => int.parse(p.split(RegExp(r'[-+]'))[0]))
          .toList();

      while (currentParts.length < 3) {
        currentParts.add(0);
      }
      while (remoteParts.length < 3) {
        remoteParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (remoteParts[i] > currentParts[i]) return true;
        if (remoteParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
