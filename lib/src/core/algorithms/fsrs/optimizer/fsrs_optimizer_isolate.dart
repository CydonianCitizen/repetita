import 'dart:async';
import 'dart:isolate';

import '../models/fsrs_parameters.dart';
import 'fsrs_optimizer.dart';
import 'fsrs_optimizer_models.dart';

class _OptimizerIsolateConfig {
  const _OptimizerIsolateConfig({
    required this.sendPort,
    required this.histories,
    required this.initialWeights,
    required this.maxIterations,
    required this.learningRate,
  });

  final SendPort sendPort;
  final List<CardReviewHistory> histories;
  final List<double> initialWeights;
  final int maxIterations;
  final double learningRate;
}

/// Top-level isolate worker entry point.
void _optimizerWorker(_OptimizerIsolateConfig config) {
  final optimizer = FsrsOptimizer(
    maxIterations: config.maxIterations,
    learningRate: config.learningRate,
  );

  final result = optimizer.optimize(
    config.histories,
    initialWeights: config.initialWeights,
    onProgress: (progress) {
      config.sendPort.send(progress);
    },
  );

  config.sendPort.send(result);
}

/// Executes FSRS parameter optimization in a background Dart Isolate
/// to prevent any UI thread jank or frame dropping.
Future<OptimizationResult> optimizeInIsolate(
  List<CardReviewHistory> histories, {
  List<double> initialWeights = FsrsParameters.defaultWeights,
  int maxIterations = 40,
  double learningRate = 0.04,
  void Function(OptimizationProgress)? onProgress,
}) async {
  final receivePort = ReceivePort();
  final completer = Completer<OptimizationResult>();

  final isolate = await Isolate.spawn(
    _optimizerWorker,
    _OptimizerIsolateConfig(
      sendPort: receivePort.sendPort,
      histories: histories,
      initialWeights: initialWeights,
      maxIterations: maxIterations,
      learningRate: learningRate,
    ),
  );

  StreamSubscription<dynamic>? sub;
  sub = receivePort.listen(
    (message) {
      if (message is OptimizationProgress) {
        onProgress?.call(message);
      } else if (message is OptimizationResult) {
        sub?.cancel();
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);
        completer.complete(message);
      }
    },
    onError: (Object error, StackTrace stackTrace) {
      sub?.cancel();
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
      completer.completeError(error, stackTrace);
    },
  );

  return completer.future;
}
