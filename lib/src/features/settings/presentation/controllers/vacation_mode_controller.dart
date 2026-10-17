import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';

part 'vacation_mode_controller.g.dart';

@Riverpod(keepAlive: true)
class VacationModeController extends _$VacationModeController {
  @override
  FutureOr<bool> build() async {
    final service = ref.watch(vacationModeServiceProvider);
    return service.isVacationActive();
  }

  Future<void> toggleVacation() async {
    final service = ref.read(vacationModeServiceProvider);
    final current = state.value ?? false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (current) {
        await service.endVacation();
        return false;
      } else {
        await service.startVacation();
        return true;
      }
    });
  }
}
