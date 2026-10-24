import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/algorithms/fsrs/optimizer/fsrs_optimizer_isolate.dart';
import '../../../../core/algorithms/fsrs/optimizer/fsrs_optimizer_models.dart';
import '../../../../core/database/database_provider.dart';
import 'fsrs_parameters_controller.dart';

part 'fsrs_optimizer_controller.g.dart';

@immutable
class FsrsOptimizerState {
  const FsrsOptimizerState({
    this.reviewCount = 0,
    this.isOptimizing = false,
    this.progress = 0.0,
    this.lastResult,
    this.error,
  });

  final int reviewCount;
  final bool isOptimizing;
  final double progress;
  final OptimizationResult? lastResult;
  final String? error;

  bool get canOptimize => reviewCount >= 500 && !isOptimizing;

  FsrsOptimizerState copyWith({
    int? reviewCount,
    bool? isOptimizing,
    double? progress,
    OptimizationResult? lastResult,
    String? error,
  }) {
    return FsrsOptimizerState(
      reviewCount: reviewCount ?? this.reviewCount,
      isOptimizing: isOptimizing ?? this.isOptimizing,
      progress: progress ?? this.progress,
      lastResult: lastResult ?? this.lastResult,
      error: error,
    );
  }
}

@riverpod
class FsrsOptimizerController extends _$FsrsOptimizerController {
  @override
  FutureOr<FsrsOptimizerState> build() async {
    final statsDao = ref.watch(statsDaoProvider);
    final count = await statsDao.getTotalReviewsCount();
    return FsrsOptimizerState(reviewCount: count);
  }

  Future<void> refreshReviewCount() async {
    final statsDao = ref.read(statsDaoProvider);
    final count = await statsDao.getTotalReviewsCount();
    final current = state.value ?? const FsrsOptimizerState();
    state = AsyncData(current.copyWith(reviewCount: count));
  }

  Future<OptimizationResult?> startOptimization({
    int maxIterations = 40,
    double learningRate = 0.04,
  }) async {
    final current = state.value ?? const FsrsOptimizerState();
    if (current.isOptimizing) return null;

    final statsDao = ref.read(statsDaoProvider);
    final histories = await statsDao.getCardReviewHistories();

    if (histories.isEmpty) {
      state = AsyncData(
        current.copyWith(
          error: 'No review history found for optimization',
        ),
      );
      return null;
    }

    final currentWeights = ref.read(fsrsParametersControllerProvider).w;

    state = AsyncData(
      current.copyWith(
        isOptimizing: true,
        progress: 0.0,
        error: null,
      ),
    );

    try {
      final result = await optimizeInIsolate(
        histories,
        initialWeights: currentWeights,
        maxIterations: maxIterations,
        learningRate: learningRate,
        onProgress: (p) {
          if (ref.mounted) {
            final val = state.value ?? current;
            state = AsyncData(
              val.copyWith(
                progress: p.progressPercentage,
              ),
            );
          }
        },
      );

      await ref
          .read(fsrsParametersControllerProvider.notifier)
          .setCustomWeights(result.weights);

      if (ref.mounted) {
        final val = state.value ?? current;
        state = AsyncData(
          val.copyWith(
            isOptimizing: false,
            progress: 1.0,
            lastResult: result,
            error: null,
          ),
        );
      }
      return result;
    } catch (e) {
      if (ref.mounted) {
        final val = state.value ?? current;
        state = AsyncData(
          val.copyWith(
            isOptimizing: false,
            error: e.toString(),
          ),
        );
      }
      return null;
    }
  }

  Future<void> resetToDefaults() async {
    await ref
        .read(fsrsParametersControllerProvider.notifier)
        .resetWeightsToDefault();
    final current = state.value ?? const FsrsOptimizerState();
    state = AsyncData(current.copyWith(lastResult: null));
  }
}
