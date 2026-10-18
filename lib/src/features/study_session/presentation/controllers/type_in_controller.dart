import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';

part 'type_in_controller.g.dart';

@Riverpod(keepAlive: true)
class TypeInPracticeController extends _$TypeInPracticeController {
  static const _key = 'type_in_answer_enabled';

  @override
  bool build() {
    _loadFromDb();
    return false;
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final saved = await db.getSetting(_key);
      if (saved != null && ref.mounted) {
        state = saved == 'true';
      }
    } catch (e) {
      debugPrint('Failed to load type-in setting: $e');
    }
  }

  Future<void> toggle() async {
    final newValue = !state;
    state = newValue;
    try {
      await ref.read(databaseProvider).setSetting(_key, newValue.toString());
    } catch (e) {
      debugPrint('Failed to save type-in setting: $e');
    }
  }

  Future<void> setValue(bool value) async {
    state = value;
    try {
      await ref.read(databaseProvider).setSetting(_key, value.toString());
    } catch (e) {
      debugPrint('Failed to save type-in setting: $e');
    }
  }
}
