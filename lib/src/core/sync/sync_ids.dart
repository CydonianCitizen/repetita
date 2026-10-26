import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Lightweight UUID generator adhering to RFC 9562 (v7) and RFC 4122 (v5).
///
/// Eliminates the need for external UUID packages, ensuring zero bloat.
class SyncIds {
  SyncIds._();

  static final Random _secureRandom = Random.secure();

  /// Generates a time-ordered UUIDv7 (RFC 9562).
  ///
  /// Combines 48 bits of Unix millisecond timestamp with 74 random/counter bits.
  static String uuidV7([DateTime? timestamp, Random? random]) {
    final rng = random ?? _secureRandom;
    final ms = (timestamp ?? DateTime.now().toUtc()).millisecondsSinceEpoch;

    final bytes = Uint8List(16);

    // 48-bit timestamp (big endian)
    bytes[0] = (ms >> 40) & 0xFF;
    bytes[1] = (ms >> 32) & 0xFF;
    bytes[2] = (ms >> 24) & 0xFF;
    bytes[3] = (ms >> 16) & 0xFF;
    bytes[4] = (ms >> 8) & 0xFF;
    bytes[5] = ms & 0xFF;

    // 12 bits random/counter
    bytes[6] = rng.nextInt(256);
    bytes[7] = rng.nextInt(256);
    // Version 7: 0111 in top 4 bits of octet 6
    bytes[6] = (bytes[6] & 0x0F) | 0x70;

    // 62 bits random + variant
    for (int i = 8; i < 16; i++) {
      bytes[i] = rng.nextInt(256);
    }
    // Variant 1: 10 in top 2 bits of octet 8 (0x80..0xBF)
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    return _formatUuid(bytes);
  }

  /// Generates a deterministic name-based UUIDv5 (RFC 4122) using SHA-1.
  ///
  /// Used for deterministic migration of existing numeric IDs into global UUIDs
  /// without introducing non-reproducible random drift.
  static String uuidV5(String namespaceUuid, String name) {
    final nsBytes = _parseUuid(namespaceUuid);
    final nameBytes = utf8.encode(name);

    final digest = sha1.convert([...nsBytes, ...nameBytes]).bytes;
    final bytes = Uint8List.fromList(digest.sublist(0, 16));

    // Version 5: 0101 in top 4 bits of octet 6
    bytes[6] = (bytes[6] & 0x0F) | 0x50;
    // Variant 1: 10 in top 2 bits of octet 8
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    return _formatUuid(bytes);
  }

  /// Generates a unique 16-hex-character device identifier.
  static String generateDeviceId([Random? random]) {
    final rng = random ?? _secureRandom;
    final bytes = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _parseUuid(String uuid) {
    final clean = uuid.replaceAll('-', '').toLowerCase();
    if (clean.length != 32) {
      throw FormatException('Invalid UUID format: $uuid');
    }
    final bytes = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      bytes[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }

  static String _formatUuid(Uint8List bytes) {
    final buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
