import 'package:flutter/material.dart';

/// Maps card flag integer (0: none, 1: red, 2: orange, 3: green, 4: blue) to UI color.
Color getCardFlagColor(int flag) {
  switch (flag) {
    case 1:
      return Colors.red;
    case 2:
      return Colors.orange;
    case 3:
      return Colors.green;
    case 4:
      return Colors.blue;
    default:
      return Colors.transparent;
  }
}
