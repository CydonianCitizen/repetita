import '../../../core/database/app_database.dart';
import '../data/decks_dao.dart';

/// A node in the deck hierarchy tree representing either a concrete deck or a virtual parent.
class DeckNode {
  DeckNode({
    required this.deckWithCounts,
    required this.fullPath,
    required this.shortName,
    required this.depth,
    this.isVirtual = false,
    List<DeckNode>? children,
  }) : children = children ?? [];

  final DeckWithCounts deckWithCounts;
  final String fullPath;
  final String shortName;
  final int depth;
  final bool isVirtual;
  final List<DeckNode> children;

  int _aggregateTotal = 0;
  int _aggregateDue = 0;

  int get aggregateTotalCards => _aggregateTotal;
  int get aggregateDueCards => _aggregateDue;

  bool get hasSubdecks => children.isNotEmpty;

  void computeAggregates() {
    int total = isVirtual ? 0 : deckWithCounts.totalCards;
    int due = isVirtual ? 0 : deckWithCounts.dueCards;

    for (final child in children) {
      child.computeAggregates();
      total += child.aggregateTotalCards;
      due += child.aggregateDueCards;
    }

    _aggregateTotal = total;
    _aggregateDue = due;
  }
}

/// A flattened representation of a DeckNode for sequential rendering in list views.
class FlattenedDeckNode {
  const FlattenedDeckNode({required this.node, required this.isCollapsed});

  final DeckNode node;
  final bool isCollapsed;
}

/// Utility class for decomposing `::` delimited deck names into trees and flattening them.
class DeckHierarchyHelper {
  /// Builds a hierarchical tree from a flat list of [decks].
  static List<DeckNode> buildTree(List<DeckWithCounts> decks) {
    if (decks.isEmpty) return [];

    // Map by normalized fullPath
    final deckMap = <String, DeckWithCounts>{};
    for (final d in decks) {
      deckMap[d.deck.name.trim()] = d;
    }

    // Build intermediate path structure
    final allPaths = <String>{};
    for (final name in deckMap.keys) {
      final parts = name
          .split('::')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      String current = '';
      for (int i = 0; i < parts.length; i++) {
        current = current.isEmpty ? parts[i] : '$current::${parts[i]}';
        allPaths.add(current);
      }
    }

    // Create DeckNodes
    final nodeMap = <String, DeckNode>{};
    for (final path in allPaths) {
      final parts = path.split('::');
      final shortName = parts.last;
      final depth = parts.length - 1;

      final existingDeckWithCounts = deckMap[path];
      if (existingDeckWithCounts != null) {
        nodeMap[path] = DeckNode(
          deckWithCounts: existingDeckWithCounts,
          fullPath: path,
          shortName: shortName,
          depth: depth,
          isVirtual: false,
        );
      } else {
        // Synthesize virtual node
        final now = DateTime.now().toUtc();
        final virtualDeck = Deck(
          id: -path.hashCode.abs(),
          name: path,
          createdAt: now,
          updatedAt: now,
        );
        nodeMap[path] = DeckNode(
          deckWithCounts: DeckWithCounts(
            deck: virtualDeck,
            totalCards: 0,
            dueCards: 0,
          ),
          fullPath: path,
          shortName: shortName,
          depth: depth,
          isVirtual: true,
        );
      }
    }

    // Connect parents and children
    final rootNodes = <DeckNode>[];
    for (final path in allPaths) {
      final node = nodeMap[path]!;
      final lastIndex = path.lastIndexOf('::');
      if (lastIndex == -1) {
        rootNodes.add(node);
      } else {
        final parentPath = path.substring(0, lastIndex);
        final parentNode = nodeMap[parentPath];
        if (parentNode != null) {
          parentNode.children.add(node);
        } else {
          rootNodes.add(node);
        }
      }
    }

    // Sort children and roots alphabetically
    void sortNode(DeckNode n) {
      n.children.sort(
        (a, b) =>
            a.shortName.toLowerCase().compareTo(b.shortName.toLowerCase()),
      );
      for (final child in n.children) {
        sortNode(child);
      }
    }

    // Order root nodes by original list encounter order
    final rootOrder = <String, int>{};
    for (int i = 0; i < decks.length; i++) {
      final rootPart = decks[i].deck.name.split('::').first.trim();
      rootOrder.putIfAbsent(rootPart, () => i);
    }
    rootNodes.sort(
      (a, b) => (rootOrder[a.shortName] ?? 9999).compareTo(
        rootOrder[b.shortName] ?? 9999,
      ),
    );

    for (final root in rootNodes) {
      sortNode(root);
      root.computeAggregates();
    }

    return rootNodes;
  }

  /// Flattens the hierarchy tree into a list of [FlattenedDeckNode] honoring [collapsedDeckNames].
  static List<FlattenedDeckNode> flatten(
    List<DeckNode> rootNodes, {
    required Set<String> collapsedDeckNames,
  }) {
    final result = <FlattenedDeckNode>[];

    void traverse(DeckNode node) {
      final isCollapsed = collapsedDeckNames.contains(node.fullPath);
      result.add(FlattenedDeckNode(node: node, isCollapsed: isCollapsed));

      if (!isCollapsed) {
        for (final child in node.children) {
          traverse(child);
        }
      }
    }

    for (final root in rootNodes) {
      traverse(root);
    }

    return result;
  }
}
