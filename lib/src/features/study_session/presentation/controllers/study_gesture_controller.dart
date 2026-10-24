import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/study_gesture_config.dart';

part 'study_gesture_controller.g.dart';

@Riverpod(keepAlive: true)
class StudyGestureController extends _$StudyGestureController {
  static const _settingKey = 'study_gestures_config';

  Future<void>? _loadFuture;

  Future<void> ensureLoaded() => _loadFuture ??= _loadFromDb();

  @override
  StudyGestureConfig build() {
    ensureLoaded();
    return const StudyGestureConfig();
  }

  Future<void> _loadFromDb() async {
    final db = ref.read(databaseProvider);
    final raw = await db.getSetting(_settingKey);
    if (raw != null) {
      final config = StudyGestureConfig.decode(raw);
      if (ref.mounted) {
        state = config;
      }
    }
  }

  Future<void> setConfig(StudyGestureConfig config) async {
    state = config;
    try {
      await ref.read(databaseProvider).setSetting(_settingKey, config.encode());
    } catch (_) {}
  }

  Future<void> toggleEnabled() async {
    await setConfig(state.copyWith(enableGestures: !state.enableGestures));
  }

  Future<void> updateAction({
    StudyGestureAction? swipeLeft,
    StudyGestureAction? swipeRight,
    StudyGestureAction? swipeUp,
    StudyGestureAction? swipeDown,
    StudyGestureAction? doubleTap,
  }) async {
    await setConfig(
      state.copyWith(
        swipeLeft: swipeLeft,
        swipeRight: swipeRight,
        swipeUp: swipeUp,
        swipeDown: swipeDown,
        doubleTap: doubleTap,
      ),
    );
  }
}
