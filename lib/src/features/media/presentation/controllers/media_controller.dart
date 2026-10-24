import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';

final mediaFileProvider = FutureProvider.family<File, String>((ref, reference) {
  final mediaService = ref.watch(mediaServiceProvider);
  return mediaService.getMediaFile(reference);
});
