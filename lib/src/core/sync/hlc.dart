import 'dart:math';

/// Hybrid Logical Clock (HLC) implementation.
///
/// Combines physical wall-clock time with a monotonic logical counter
/// and a node ID to guarantee strict total ordering across distributed nodes
/// without reliance on perfectly synchronized clocks.
class Hlc implements Comparable<Hlc> {
  const Hlc({
    required this.millis,
    required this.counter,
    required this.nodeId,
  });

  /// Maximum allowed physical clock drift into the future (1 minute).
  static const int maxDriftMs = 60 * 1000;

  final int millis;
  final int counter;
  final String nodeId;

  /// Parses a serialized HLC string in the format:
  /// `000179296434000:00001:node_id`
  factory Hlc.parse(String value) {
    final parts = value.split(':');
    if (parts.length < 3) {
      throw FormatException('Invalid HLC format: $value');
    }
    final millis = int.parse(parts[0]);
    final counter = int.parse(parts[1]);
    final nodeId = parts.sublist(2).join(':');
    return Hlc(millis: millis, counter: counter, nodeId: nodeId);
  }

  /// Parses an HLC string or returns null if invalid.
  static Hlc? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return Hlc.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Creates a fresh initial HLC for a local node.
  factory Hlc.initial(String nodeId, [DateTime? now]) {
    final wallMs = (now ?? DateTime.now().toUtc()).millisecondsSinceEpoch;
    return Hlc(millis: wallMs, counter: 0, nodeId: nodeId);
  }

  /// Advances the clock when a local event is generated.
  Hlc send([DateTime? now]) {
    final wallMs = (now ?? DateTime.now().toUtc()).millisecondsSinceEpoch;
    if (wallMs > millis) {
      return Hlc(millis: wallMs, counter: 0, nodeId: nodeId);
    }
    return Hlc(millis: millis, counter: counter + 1, nodeId: nodeId);
  }

  /// Merges a remote HLC on incoming sync, updating the local clock
  /// to ensure causality (Lamport condition: local > remote).
  Hlc receive(Hlc remote, [DateTime? now]) {
    final wallMs = (now ?? DateTime.now().toUtc()).millisecondsSinceEpoch;

    // Check drift guard: if remote time is excessively ahead of physical time,
    // we clamp the physical advance to wallMs + maxDriftMs to prevent clock sabotage.
    final effectiveRemoteMs = (remote.millis - wallMs > maxDriftMs)
        ? wallMs + maxDriftMs
        : remote.millis;

    final maxMs = max(wallMs, max(millis, effectiveRemoteMs));

    int newCounter;
    if (maxMs == millis && maxMs == effectiveRemoteMs) {
      newCounter = max(counter, remote.counter) + 1;
    } else if (maxMs == millis) {
      newCounter = counter + 1;
    } else if (maxMs == effectiveRemoteMs) {
      newCounter = remote.counter + 1;
    } else {
      newCounter = 0;
    }

    return Hlc(millis: maxMs, counter: newCounter, nodeId: nodeId);
  }

  /// Serializes the HLC to a zero-padded string so that lexicographical
  /// string comparison exactly matches chronological ordering in SQLite and Dart.
  String pack() {
    final m = millis.toString().padLeft(15, '0');
    final c = counter.toString().padLeft(5, '0');
    return '$m:$c:$nodeId';
  }

  @override
  String toString() => pack();

  @override
  int compareTo(Hlc other) {
    if (millis != other.millis) {
      return millis.compareTo(other.millis);
    }
    if (counter != other.counter) {
      return counter.compareTo(other.counter);
    }
    return nodeId.compareTo(other.nodeId);
  }

  bool operator <(Hlc other) => compareTo(other) < 0;
  bool operator <=(Hlc other) => compareTo(other) <= 0;
  bool operator >(Hlc other) => compareTo(other) > 0;
  bool operator >=(Hlc other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hlc &&
          runtimeType == other.runtimeType &&
          millis == other.millis &&
          counter == other.counter &&
          nodeId == other.nodeId;

  @override
  int get hashCode => millis.hashCode ^ counter.hashCode ^ nodeId.hashCode;
}
