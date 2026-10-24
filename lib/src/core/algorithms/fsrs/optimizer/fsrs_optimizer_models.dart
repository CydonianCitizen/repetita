import 'package:flutter/foundation.dart';

@immutable
class ReviewHistoryItem {
  const ReviewHistoryItem({required this.rating, required this.elapsedDays});

  /// Rating given by user: 1 = Again, 2 = Hard, 3 = Good, 4 = Easy.
  final int rating;

  /// Elapsed days since the previous review (0 for initial review).
  final double elapsedDays;

  Map<String, dynamic> toJson() => {
    'rating': rating,
    'elapsedDays': elapsedDays,
  };

  factory ReviewHistoryItem.fromJson(Map<String, dynamic> json) =>
      ReviewHistoryItem(
        rating: json['rating'] as int,
        elapsedDays: (json['elapsedDays'] as num).toDouble(),
      );
}

@immutable
class CardReviewHistory {
  const CardReviewHistory({required this.cardId, required this.reviews});

  final int cardId;
  final List<ReviewHistoryItem> reviews;

  Map<String, dynamic> toJson() => {
    'cardId': cardId,
    'reviews': reviews.map((r) => r.toJson()).toList(),
  };

  factory CardReviewHistory.fromJson(Map<String, dynamic> json) =>
      CardReviewHistory(
        cardId: json['cardId'] as int,
        reviews: (json['reviews'] as List<dynamic>)
            .map((e) => ReviewHistoryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

@immutable
class OptimizationProgress {
  const OptimizationProgress({
    required this.iteration,
    required this.totalIterations,
    required this.currentLoss,
    required this.bestLoss,
  });

  final int iteration;
  final int totalIterations;
  final double currentLoss;
  final double bestLoss;

  double get progressPercentage =>
      totalIterations > 0 ? (iteration / totalIterations).clamp(0.0, 1.0) : 0.0;
}

@immutable
class OptimizationResult {
  const OptimizationResult({
    required this.weights,
    required this.initialLoss,
    required this.finalLoss,
    required this.improvementPercentage,
    required this.sampleCount,
    required this.iterationCount,
  });

  final List<double> weights;
  final double initialLoss;
  final double finalLoss;
  final double improvementPercentage;
  final int sampleCount;
  final int iterationCount;

  Map<String, dynamic> toJson() => {
    'weights': weights,
    'initialLoss': initialLoss,
    'finalLoss': finalLoss,
    'improvementPercentage': improvementPercentage,
    'sampleCount': sampleCount,
    'iterationCount': iterationCount,
  };

  factory OptimizationResult.fromJson(Map<String, dynamic> json) =>
      OptimizationResult(
        weights: (json['weights'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
        initialLoss: (json['initialLoss'] as num).toDouble(),
        finalLoss: (json['finalLoss'] as num).toDouble(),
        improvementPercentage: (json['improvementPercentage'] as num)
            .toDouble(),
        sampleCount: json['sampleCount'] as int,
        iterationCount: json['iterationCount'] as int,
      );
}
