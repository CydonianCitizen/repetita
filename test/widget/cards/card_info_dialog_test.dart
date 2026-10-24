import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/cards/domain/card_entity.dart';
import 'package:repetita/src/features/cards/presentation/dialogs/card_info_dialog.dart';

void main() {
  group('CardInfoDialog Widget Tests', () {
    testWidgets('renders all card metadata and retrievability curve painter', (
      tester,
    ) async {
      final now = DateTime.utc(2026, 10, 24, 12, 0);
      final card = CardEntity(
        id: 42,
        deckId: 1,
        front: 'Front prompt test',
        back: 'Back answer test',
        state: 2, // Review
        stability: 18.5,
        difficulty: 4.8,
        due: now.add(const Duration(days: 10)),
        lastReview: now.subtract(const Duration(days: 8)),
        reps: 5,
        lapses: 1,
        createdAt: now.subtract(const Duration(days: 30)),
        isSuspended: false,
        flag: 1, // Red
        noteId: 101,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardInfoDialog(card: card, deckName: 'Biology 101'),
          ),
        ),
      );

      expect(find.byKey(const Key('card_info_dialog')), findsOneWidget);
      expect(find.text('Card Info'), findsOneWidget);
      expect(find.textContaining('#42'), findsOneWidget);
      expect(find.textContaining('Biology 101'), findsOneWidget);
      expect(find.text('18.5 d'), findsOneWidget); // Stability
      expect(find.text('4.8 / 10'), findsOneWidget); // Difficulty
      expect(find.text('5'), findsOneWidget); // Reps
      expect(find.text('1'), findsOneWidget); // Lapses
      expect(
        find.byKey(const Key('retrievability_curve_canvas')),
        findsOneWidget,
      );
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
