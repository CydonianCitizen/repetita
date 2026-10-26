/// Abstract storage interface for File-Based Zero-Cloud Sync.
///
/// Enables seamless operation over standard desktop file systems (`dart:io`),
/// external USB drives, and mobile Android SAF (`DocumentFile`).
abstract class SyncStorageAdapter {
  /// Returns the node IDs of all peers found in `nodes/`.
  Future<List<String>> listPeerNodeIds();

  /// Reads lines from a peer's `events.jsonl` starting at [fromByteOffset].
  ///
  /// Returns a record with the successfully read lines and the new byte offset
  /// aligned to the last complete trailing `\n`.
  Future<({List<String> lines, int newByteOffset})> readPeerEvents(
    String peerNodeId, {
    required int fromByteOffset,
  });

  /// Returns the size in bytes of a peer's `events.jsonl` file.
  Future<int> getPeerFileSize(String peerNodeId);

  /// Appends a single JSON event line with trailing `\n` to own `events.jsonl`.
  Future<void> appendOwnEvent(String eventLine);

  /// Rewrites own `events.jsonl` with an Epoch header and optional event lines.
  ///
  /// Used during initial setup and self-compaction.
  Future<void> rewriteOwnFile(
    String epochHeaderLine, [
    List<String> eventLines = const [],
  ]);

  /// Returns the size in bytes of own `events.jsonl` file.
  Future<int> getOwnFileSize();
}
