import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/services/home_widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.repetita/widget');
  final List<MethodCall> methodCalls = [];

  setUp(() {
    methodCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          methodCalls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('HomeWidgetService updateWidget', () {
    test('invokes method channel on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      const service = HomeWidgetService();

      await service.updateWidget(dueCount: 5, newCount: 3);

      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, 'updateWidget');
      expect(methodCalls.first.arguments, {'dueCount': 5, 'newCount': 3});
    });

    test('does not invoke channel on non-Android platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      const service = HomeWidgetService();

      await service.updateWidget(dueCount: 5, newCount: 3);

      expect(methodCalls, isEmpty);
    });
  });

  group('HomeWidgetService syncWithDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() async {
      await db.close();
    });

    test('accurately counts due review cards and new cards', () async {
      final now = DateTime.now().toUtc();
      final deckId = await db
          .into(db.decks)
          .insert(DecksCompanion.insert(name: 'Test Deck'));

      // 1. New card (state = 0)
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'New Q',
              back: 'New A',
              state: const Value(0),
              due: now.add(const Duration(days: 1)),
            ),
          );

      // 2. Due review card (state = 2, due in past)
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Due Review Q',
              back: 'Due Review A',
              state: const Value(2),
              due: now.subtract(const Duration(hours: 2)),
            ),
          );

      // 3. Future review card (state = 2, due in future)
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Future Review Q',
              back: 'Future Review A',
              state: const Value(2),
              due: now.add(const Duration(days: 3)),
            ),
          );

      // 4. Suspended review card (should be ignored)
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Suspended Q',
              back: 'Suspended A',
              state: const Value(2),
              isSuspended: const Value(true),
              due: now.subtract(const Duration(hours: 2)),
            ),
          );

      // 5. Buried review card (should be ignored)
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Buried Q',
              back: 'Buried A',
              state: const Value(2),
              buriedUntil: Value(now.add(const Duration(hours: 4))),
              due: now.subtract(const Duration(hours: 2)),
            ),
          );

      const service = HomeWidgetService();
      await service.syncWithDatabase(db);

      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, 'updateWidget');
      expect(methodCalls.first.arguments, {'dueCount': 1, 'newCount': 1});
    });
  });
}
