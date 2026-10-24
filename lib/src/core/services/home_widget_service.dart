import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return const HomeWidgetService();
});

class HomeWidgetService {
  const HomeWidgetService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.example.repetita/widget');

  final MethodChannel _channel;

  /// Updates the native Android widget with [dueCount] (review cards due) and [newCount] (new cards).
  Future<void> updateWidget({
    required int dueCount,
    required int newCount,
  }) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod<bool>('updateWidget', {
          'dueCount': dueCount,
          'newCount': newCount,
        });
      } catch (_) {
        // Ignored in test environment or unsupported runtime
      }
    }
  }

  /// Calculates due and new counts directly from [db] and pushes them to the widget.
  Future<void> syncWithDatabase(AppDatabase db) async {
    try {
      final now = DateTime.now().toUtc();

      final activeFilter = db.cards.isSuspended.equals(false) &
          (db.cards.buriedUntil.isNull() |
              db.cards.buriedUntil.isSmallerOrEqualValue(now));

      final countExpr = db.cards.id.count();

      final dueQuery = db.selectOnly(db.cards)
        ..addColumns([countExpr])
        ..where(
          activeFilter &
              db.cards.state.isBiggerThanValue(0) &
              db.cards.due.isSmallerOrEqualValue(now),
        );
      final dueCount =
          await dueQuery.map((row) => row.read(countExpr)).getSingleOrNull() ?? 0;

      final newQuery = db.selectOnly(db.cards)
        ..addColumns([countExpr])
        ..where(activeFilter & db.cards.state.equals(0));
      final newCount =
          await newQuery.map((row) => row.read(countExpr)).getSingleOrNull() ?? 0;

      await updateWidget(dueCount: dueCount, newCount: newCount);
    } catch (_) {
      // Ignore errors if database is closing or in mock test environment
    }
  }
}
