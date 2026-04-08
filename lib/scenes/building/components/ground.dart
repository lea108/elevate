import 'dart:async';

import 'package:elevate/theme/palette.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent {
  @override
  FutureOr<void> onLoad() {
    addAll([
      RectangleComponent()
        ..size = size
        ..setColor(Palette.groundColor),
    ]);

    return super.onLoad();
  }
}
