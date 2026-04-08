import 'dart:ui';

import 'package:flutter/material.dart';

class Palette {
  static final c1 = Color.lerp(
    Colors.brown[900],
    Color.fromARGB(255, 20, 20, 20),
    0.8,
  )!;
  static final c2 = Color.lerp(
    Color.lerp(Colors.orange[700], Colors.brown, 0.3),
    Colors.black,
    0.6,
  )!;
  static final c3 = Color.lerp(
    Color.lerp(Colors.orange[700], Colors.brown, 0.8),
    Colors.black,
    0.75,
  )!;
  static final c4 = Color.fromARGB(255, 81, 73, 71);
  static final selectedTechBorder = Color.lerp(
    Colors.orange,
    Colors.white60,
    0.6,
  )!;

  static final tutorialCardBg = Colors.brown[800]!;

  static final groundColor = Colors.brown[900]!;
}
