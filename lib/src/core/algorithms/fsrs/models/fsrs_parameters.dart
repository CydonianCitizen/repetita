import 'dart:convert';

import 'package:flutter/foundation.dart';

class FsrsParameters {
  const FsrsParameters({
    this.requestRetention = 0.9,
    this.maximumInterval = 36500,
    this.w = defaultWeights,
    this.enableFuzz = false,
  });

  final double requestRetention;
  final int maximumInterval;
  final List<double> w;
  final bool enableFuzz;

  bool get hasCustomWeights => !listEquals(w, defaultWeights);

  static String encodeWeights(List<double> weights) => jsonEncode(weights);

  static List<double>? decodeWeights(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List && decoded.length == 17) {
        return decoded.map((e) => (e as num).toDouble()).toList();
      }
    } catch (_) {}
    return null;
  }

  FsrsParameters copyWith({
    double? requestRetention,
    int? maximumInterval,
    List<double>? w,
    bool? enableFuzz,
  }) {
    return FsrsParameters(
      requestRetention: requestRetention ?? this.requestRetention,
      maximumInterval: maximumInterval ?? this.maximumInterval,
      w: w ?? this.w,
      enableFuzz: enableFuzz ?? this.enableFuzz,
    );
  }

  static const List<double> defaultWeights = <double>[
    0.4,
    0.6,
    2.4,
    5.8,
    4.93,
    0.94,
    0.86,
    0.01,
    1.49,
    0.14,
    0.94,
    2.18,
    0.05,
    0.34,
    1.26,
    0.29,
    2.61,
  ];
}
