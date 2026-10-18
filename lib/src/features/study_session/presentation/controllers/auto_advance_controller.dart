import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';

part 'auto_advance_controller.g.dart';

@Riverpod(keepAlive: true)
class AutoAdvanceController extends _$AutoAdvanceController {
  static const _key = 'study_auto_advance_seconds';

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
      debugPrint('Failed to load auto advance setting: $e');
    }
  }

  Future<void> setSeconds(int seconds) async {
    state = seconds;
    try {
      await ref.read(databaseProvider).setSetting(_key, seconds.toString());
    } catch (e) {
      debugPrint('Failed to save auto advance setting: $e');
    }
  }
}
