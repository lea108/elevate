
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent {

  @override
  FutureOr<void> onLoad() {
    addAll([
      RectangleComponent()
      ..size = size
      ..setColor(Colors.brown[900]!)
    ]);

    return super.onLoad();
  }


}