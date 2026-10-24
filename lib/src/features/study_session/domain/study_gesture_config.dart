import 'dart:convert';

import 'package:flutter/foundation.dart';

enum StudyGestureAction {
  none,
  flipCard,
  rateAgain,
  rateHard,
  rateGood,
  rateEasy,
  undo,
  buryCard,
  suspendCard;

  String get displayName {
    switch (this) {
      case StudyGestureAction.none:
        return 'Nessuna azione';
      case StudyGestureAction.flipCard:
        return 'Mostra risposta (Gira carta)';
      case StudyGestureAction.rateAgain:
        return 'Valuta: Di nuovo (Again)';
      case StudyGestureAction.rateHard:
        return 'Valuta: Difficile (Hard)';
      case StudyGestureAction.rateGood:
        return 'Valuta: Buono (Good)';
      case StudyGestureAction.rateEasy:
        return 'Valuta: Facile (Easy)';
      case StudyGestureAction.undo:
        return 'Annulla ultima recensione';
      case StudyGestureAction.buryCard:
        return 'Seppellisci carta';
      case StudyGestureAction.suspendCard:
        return 'Sospendi carta';
    }
  }
}

@immutable
class StudyGestureConfig {
  const StudyGestureConfig({
    this.enableGestures = true,
    this.swipeLeft = StudyGestureAction.rateAgain,
    this.swipeRight = StudyGestureAction.rateGood,
    this.swipeUp = StudyGestureAction.rateEasy,
    this.swipeDown = StudyGestureAction.flipCard,
    this.doubleTap = StudyGestureAction.flipCard,
  });

  final bool enableGestures;
  final StudyGestureAction swipeLeft;
  final StudyGestureAction swipeRight;
  final StudyGestureAction swipeUp;
  final StudyGestureAction swipeDown;
  final StudyGestureAction doubleTap;

  Map<String, dynamic> toJson() => {
    'enableGestures': enableGestures,
    'swipeLeft': swipeLeft.name,
    'swipeRight': swipeRight.name,
    'swipeUp': swipeUp.name,
    'swipeDown': swipeDown.name,
    'doubleTap': doubleTap.name,
  };

  factory StudyGestureConfig.fromJson(
    Map<String, dynamic> json,
  ) => StudyGestureConfig(
    enableGestures: json['enableGestures'] as bool? ?? true,
    swipeLeft: _parseAction(json['swipeLeft'], StudyGestureAction.rateAgain),
    swipeRight: _parseAction(json['swipeRight'], StudyGestureAction.rateGood),
    swipeUp: _parseAction(json['swipeUp'], StudyGestureAction.rateEasy),
    swipeDown: _parseAction(json['swipeDown'], StudyGestureAction.flipCard),
    doubleTap: _parseAction(json['doubleTap'], StudyGestureAction.flipCard),
  );

  static StudyGestureAction _parseAction(
    dynamic val,
    StudyGestureAction fallback,
  ) {
    if (val is! String) return fallback;
    try {
      return StudyGestureAction.values.byName(val);
    } catch (_) {
      return fallback;
    }
  }

  String encode() => jsonEncode(toJson());

  static StudyGestureConfig decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const StudyGestureConfig();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return StudyGestureConfig.fromJson(decoded);
      }
    } catch (_) {}
    return const StudyGestureConfig();
  }

  StudyGestureConfig copyWith({
    bool? enableGestures,
    StudyGestureAction? swipeLeft,
    StudyGestureAction? swipeRight,
    StudyGestureAction? swipeUp,
    StudyGestureAction? swipeDown,
    StudyGestureAction? doubleTap,
  }) {
    return StudyGestureConfig(
      enableGestures: enableGestures ?? this.enableGestures,
      swipeLeft: swipeLeft ?? this.swipeLeft,
      swipeRight: swipeRight ?? this.swipeRight,
      swipeUp: swipeUp ?? this.swipeUp,
      swipeDown: swipeDown ?? this.swipeDown,
      doubleTap: doubleTap ?? this.doubleTap,
    );
  }
}
