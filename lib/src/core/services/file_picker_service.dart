import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return const FilePickerService();
});

/// Value object representing a file picked by the user.
class PickedFileResult {
  const PickedFileResult({
    required this.name,
    this.path,
    required this.bytesReader,
  });

  final String name;
  final String? path;
  final Future<Uint8List> Function() bytesReader;

  Future<Uint8List> readBytes() => bytesReader();

  Future<String> readAsString() async {
    final b = await readBytes();
    return utf8.decode(b);
  }
}

/// Service wrapper around native file picker operations.
class FilePickerService {
  const FilePickerService();

  Future<PickedFileResult?> pickImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return null;
    return PickedFileResult(
      name: file.name,
      path: file.path,
      bytesReader: () async {
        if (file.path != null) {
          return File(file.path!).readAsBytes();
        }
        return file.xFile.readAsBytes();
      },
    );
  }

  Future<PickedFileResult?> pickFile({List<String>? allowedExtensions}) async {
    final file = await FilePicker.pickFile(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    if (file == null) return null;
    return PickedFileResult(
      name: file.name,
      path: file.path,
      bytesReader: () async {
        if (file.path != null) {
          return File(file.path!).readAsBytes();
        }
        return file.xFile.readAsBytes();
      },
    );
  }

  Future<String?> saveFile({
    required String dialogTitle,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      bytes: bytes,
    );
    if (uri == null) return null;
    return uri.scheme == 'file' ? uri.toFilePath() : uri.toString();
  }

  Future<String?> pickDirectory({String? dialogTitle}) async {
    return FilePicker.getDirectoryPath(dialogTitle: dialogTitle);
  }
}
