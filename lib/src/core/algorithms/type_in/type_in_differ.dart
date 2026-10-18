enum TypeInCharStatus { correct, wrong, missing }

class TypeInDiffSegment {
  const TypeInDiffSegment(this.text, this.status);

  final String text;
  final TypeInCharStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeInDiffSegment &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          status == other.status;

  @override
  int get hashCode => Object.hash(text, status);

  @override
  String toString() => 'TypeInDiffSegment("$text", $status)';
}

class TypeInDiffResult {
  const TypeInDiffResult({
    required this.segments,
    required this.isExactMatch,
    required this.expected,
    required this.actual,
  });

  final List<TypeInDiffSegment> segments;
  final bool isExactMatch;
  final String expected;
  final String actual;
}

class TypeInDiffer {
  const TypeInDiffer._();

  static TypeInDiffResult diff({
    required String expected,
    required String actual,
    bool ignoreCase = true,
  }) {
    final expTrimmed = expected.trim();
    final actTrimmed = actual.trim();

    final isExact = ignoreCase
        ? expTrimmed.toLowerCase() == actTrimmed.toLowerCase()
        : expTrimmed == actTrimmed;

    if (expTrimmed.isEmpty && actTrimmed.isEmpty) {
      return TypeInDiffResult(
        segments: const [],
        isExactMatch: true,
        expected: expected,
        actual: actual,
      );
    }

    if (expTrimmed.isEmpty) {
      return TypeInDiffResult(
        segments: [TypeInDiffSegment(actTrimmed, TypeInCharStatus.wrong)],
        isExactMatch: false,
        expected: expected,
        actual: actual,
      );
    }

    if (actTrimmed.isEmpty) {
      return TypeInDiffResult(
        segments: [TypeInDiffSegment(expTrimmed, TypeInCharStatus.missing)],
        isExactMatch: false,
        expected: expected,
        actual: actual,
      );
    }

    final n = actTrimmed.length;
    final m = expTrimmed.length;

    // LCS Table
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final actChar = ignoreCase
            ? actTrimmed[i - 1].toLowerCase()
            : actTrimmed[i - 1];
        final expChar = ignoreCase
            ? expTrimmed[j - 1].toLowerCase()
            : expTrimmed[j - 1];

        if (actChar == expChar) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] >= dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    // Backtrack to extract diff tokens in reverse
    final rawTokens = <TypeInDiffSegment>[];
    int i = n;
    int j = m;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final actChar = ignoreCase
            ? actTrimmed[i - 1].toLowerCase()
            : actTrimmed[i - 1];
        final expChar = ignoreCase
            ? expTrimmed[j - 1].toLowerCase()
            : expTrimmed[j - 1];

        if (actChar == expChar) {
          rawTokens.add(
            TypeInDiffSegment(expTrimmed[j - 1], TypeInCharStatus.correct),
          );
          i--;
          j--;
          continue;
        }
      }

      if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
        rawTokens.add(
          TypeInDiffSegment(expTrimmed[j - 1], TypeInCharStatus.missing),
        );
        j--;
      } else if (i > 0 && (j == 0 || dp[i][j - 1] < dp[i - 1][j])) {
        rawTokens.add(
          TypeInDiffSegment(actTrimmed[i - 1], TypeInCharStatus.wrong),
        );
        i--;
      }
    }

    final reversed = rawTokens.reversed.toList();

    // Merge adjacent segments with identical status
    final merged = <TypeInDiffSegment>[];
    for (final token in reversed) {
      if (merged.isNotEmpty && merged.last.status == token.status) {
        final previous = merged.removeLast();
        merged.add(
          TypeInDiffSegment(previous.text + token.text, previous.status),
        );
      } else {
        merged.add(token);
      }
    }

    return TypeInDiffResult(
      segments: merged,
      isExactMatch: isExact,
      expected: expected,
      actual: actual,
    );
  }
}
