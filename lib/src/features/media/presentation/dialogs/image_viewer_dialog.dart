import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewerDialog extends StatelessWidget {
  const ImageViewerDialog({super.key, required this.imageFile});

  final File imageFile;

  static Future<void> show(BuildContext context, File imageFile) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => ImageViewerDialog(imageFile: imageFile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = imageFile.existsSync() ? imageFile.readAsBytesSync() : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 6.0,
              child: Center(
                child: bytes != null
                    ? Image.memory(bytes, fit: BoxFit.contain)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: IconButton.filled(
              key: const Key('close_image_viewer_button'),
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
