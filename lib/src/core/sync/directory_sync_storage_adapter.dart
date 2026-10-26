import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'sync_storage_adapter.dart';

/// Filesystem directory implementation of [SyncStorageAdapter] for desktop,
/// USB drives, SMB mounts, and Syncthing folders.
class DirectorySyncStorageAdapter implements SyncStorageAdapter {
  DirectorySyncStorageAdapter({
    required this.rootDir,
    required this.ownDeviceId,
  });

  final Directory rootDir;
  final String ownDeviceId;

  Directory get _nodesDir => Directory(p.join(rootDir.path, 'nodes'));
  Directory get _ownDir => Directory(p.join(_nodesDir.path, ownDeviceId));
  File get _ownFile => File(p.join(_ownDir.path, 'events.jsonl'));

  File _peerFile(String peerNodeId) =>
      File(p.join(_nodesDir.path, peerNodeId, 'events.jsonl'));

  @override
  Future<List<String>> listPeerNodeIds() async {
    if (!await _nodesDir.exists()) return [];

    final entities = await _nodesDir.list().toList();
    final peerIds = <String>[];
    for (final entity in entities) {
      if (entity is Directory) {
        final nodeName = p.basename(entity.path);
        if (nodeName != ownDeviceId) {
          final file = _peerFile(nodeName);
          if (await file.exists()) {
            peerIds.add(nodeName);
          }
        }
      }
    }
    return peerIds;
  }

  @override
  Future<int> getPeerFileSize(String peerNodeId) async {
    final file = _peerFile(peerNodeId);
    if (!await file.exists()) return 0;
    return file.length();
  }

  @override
  Future<({List<String> lines, int newByteOffset})> readPeerEvents(
    String peerNodeId, {
    required int fromByteOffset,
  }) async {
    final file = _peerFile(peerNodeId);
    if (!await file.exists()) {
      return (lines: <String>[], newByteOffset: fromByteOffset);
    }

    final raf = await file.open(mode: FileMode.read);
    try {
      final totalLength = await raf.length();
      if (fromByteOffset >= totalLength) {
        return (lines: <String>[], newByteOffset: totalLength);
      }

      await raf.setPosition(fromByteOffset);
      final remainingBytes = totalLength - fromByteOffset;
      final buffer = await raf.read(remainingBytes);

      // Find the last newline '\n' (0x0A) to prevent processing truncated tail lines
      int lastNewlineIdx = -1;
      for (int i = buffer.length - 1; i >= 0; i--) {
        if (buffer[i] == 10) {
          lastNewlineIdx = i;
          break;
        }
      }

      if (lastNewlineIdx == -1) {
        // No complete line found yet; wait for future sync
        return (lines: <String>[], newByteOffset: fromByteOffset);
      }

      final validBytes = buffer.sublist(0, lastNewlineIdx);
      final text = utf8.decode(validBytes, allowMalformed: true);
      final rawLines = text.split('\n');

      final lines = rawLines
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      final newByteOffset = fromByteOffset + lastNewlineIdx + 1;
      return (lines: lines, newByteOffset: newByteOffset);
    } finally {
      await raf.close();
    }
  }

  @override
  Future<int> getOwnFileSize() async {
    if (!await _ownFile.exists()) return 0;
    return _ownFile.length();
  }

  @override
  Future<void> appendOwnEvent(String eventLine) async {
    if (!await _ownDir.exists()) {
      await _ownDir.create(recursive: true);
    }

    final lineWithNewline = eventLine.endsWith('\n')
        ? eventLine
        : '$eventLine\n';
    final bytes = utf8.encode(lineWithNewline);

    // Append atomically with short retry for file-lock contention on Windows
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final raf = await _ownFile.open(mode: FileMode.append);
        try {
          await raf.writeFrom(bytes);
          await raf.flush();
        } finally {
          await raf.close();
        }
        return;
      } on FileSystemException {
        if (attempt == 2) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  @override
  Future<void> rewriteOwnFile(
    String epochHeaderLine, [
    List<String> eventLines = const [],
  ]) async {
    if (!await _ownDir.exists()) {
      await _ownDir.create(recursive: true);
    }

    final tmpFile = File(p.join(_ownDir.path, 'events.jsonl.tmp'));
    final sink = tmpFile.openWrite();
    try {
      sink.writeln(epochHeaderLine.trim());
      for (final line in eventLines) {
        sink.writeln(line.trim());
      }
      await sink.flush();
    } finally {
      await sink.close();
    }

    // Atomic replacement with retry
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        if (await _ownFile.exists()) {
          await _ownFile.delete();
        }
        await tmpFile.rename(_ownFile.path);
        return;
      } on FileSystemException {
        if (attempt == 2) {
          // Fallback: copy bytes and delete tmp
          await tmpFile.copy(_ownFile.path);
          if (await tmpFile.exists()) await tmpFile.delete();
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }
  }
}
