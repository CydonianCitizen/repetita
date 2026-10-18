import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';

part 'timebox_controller.g.dart';

@Riverpod(keepAlive: true)
class TimeboxController extends _$TimeboxController {
  static const _key = 'study_timebox_minutes';

  @override
  int build() {
    _loadFromDb();
    return 0; // 0 = disabled
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final saved = await db.getSetting(_key);
      if (saved != null && ref.mounted) {
        state = int.tryParse(saved) ?? 0;
      }
    } catch (e) {
      debugPrint('Failed to load timebox setting: $e');
    }
  }

  Future<void> setMinutes(int minutes) async {
    state = minutes;
    try {
      await ref.read(databaseProvider).setSetting(_key, minutes.toString());
    } catch (e) {
      debugPrint('Failed to save timebox setting: $e');
    }
  }
}
