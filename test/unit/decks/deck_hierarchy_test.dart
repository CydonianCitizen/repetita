import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/decks/data/decks_dao.dart';
import 'package:repetita/src/features/decks/domain/deck_hierarchy.dart';

void main() {
  Deck makeDeck(int id, String name) {
    final now = DateTime.now().toUtc();
    return Deck(id: id, name: name, createdAt: now, updatedAt: now);
  }

  DeckWithCounts makeDeckCounts(int id, String name, int total, int due) {
    return DeckWithCounts(
      deck: makeDeck(id, name),
      totalCards: total,
      dueCards: due,
    );
  }

  group('DeckHierarchyHelper', () {
    test('builds single root nodes when no :: delimiter exists', () {
      final decks = [
        makeDeckCounts(1, 'History', 10, 5),
        makeDeckCounts(2, 'Biology', 20, 8),
      ];

      final tree = DeckHierarchyHelper.buildTree(decks);

      expect(tree.length, equals(2));
      expect(tree[0].shortName, equals('History'));
      expect(tree[0].depth, equals(0));
      expect(tree[0].aggregateTotalCards, equals(10));
      expect(tree[0].aggregateDueCards, equals(5));
      expect(tree[0].children, isEmpty);

      expect(tree[1].shortName, equals('Biology'));
      expect(tree[1].aggregateTotalCards, equals(20));
      expect(tree[1].aggregateDueCards, equals(8));
    });

    test(
      'builds nested tree for decks with :: delimiters and aggregates counts',
      () {
        final decks = [
          makeDeckCounts(1, 'Medicine', 5, 2),
          makeDeckCounts(2, 'Medicine::Anatomy', 15, 6),
          makeDeckCounts(3, 'Medicine::Anatomy::Heart', 30, 10),
          makeDeckCounts(4, 'Languages', 12, 4),
        ];

        final tree = DeckHierarchyHelper.buildTree(decks);

        expect(tree.length, equals(2)); // Medicine and Languages

        final medNode = tree.firstWhere((n) => n.shortName == 'Medicine');
        expect(medNode.depth, equals(0));
        // Medicine total = 5 + 15 + 30 = 50
        expect(medNode.aggregateTotalCards, equals(50));
        // Medicine due = 2 + 6 + 10 = 18
        expect(medNode.aggregateDueCards, equals(18));
        expect(medNode.children.length, equals(1)); // Anatomy

        final anatomyNode = medNode.children.first;
        expect(anatomyNode.shortName, equals('Anatomy'));
        expect(anatomyNode.depth, equals(1));
        // Anatomy total = 15 + 30 = 45
        expect(anatomyNode.aggregateTotalCards, equals(45));
        expect(anatomyNode.aggregateDueCards, equals(16));
        expect(anatomyNode.children.length, equals(1)); // Heart

        final heartNode = anatomyNode.children.first;
        expect(heartNode.shortName, equals('Heart'));
        expect(heartNode.depth, equals(2));
        expect(heartNode.aggregateTotalCards, equals(30));
        expect(heartNode.aggregateDueCards, equals(10));
        expect(heartNode.children, isEmpty);
      },
    );

    test('handles missing intermediate parent decks by synthesizing virtual nodes or attaching cleanly', () {
      final decks = [
        makeDeckCounts(10, 'Physics::Quantum::Superposition', 8, 3),
      ];

      final tree = DeckHierarchyHelper.buildTree(decks);
      expect(tree.length, equals(1));
      expect(tree[0].shortName, equals('Physics'));
      expect(tree[0].isVirtual, isTrue);
      expect(tree[0].aggregateTotalCards, equals(8));
      expect(tree[0].aggregateDueCards, equals(3));

      final quantum = tree[0].children.first;
      expect(quantum.shortName, equals('Quantum'));
      expect(quantum.isVirtual, isTrue);

      final superposition = quantum.children.first;
      expect(superposition.shortName, equals('Superposition'));
      expect(superposition.isVirtual, isFalse);
      expect(superposition.deckWithCounts.deck.id, equals(10));
    });

    test('flattens tree into ordered list with expansion state support', () {
      final decks = [
        makeDeckCounts(1, 'A', 1, 1),
        makeDeckCounts(2, 'A::B', 2, 2),
      ];

      final tree = DeckHierarchyHelper.buildTree(decks);
      final flattenedExpanded = DeckHierarchyHelper.flatten(
        tree,
        collapsedDeckNames: {},
      );
      expect(flattenedExpanded.length, equals(2));
      expect(flattenedExpanded[0].node.shortName, equals('A'));
      expect(flattenedExpanded[1].node.shortName, equals('B'));

      final flattenedCollapsed = DeckHierarchyHelper.flatten(
        tree,
        collapsedDeckNames: {'A'},
      );
      expect(flattenedCollapsed.length, equals(1));
      expect(flattenedCollapsed[0].node.shortName, equals('A'));
    });
  });
}
