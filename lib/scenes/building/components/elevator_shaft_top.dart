import 'dart:async';

import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

class ElevatorShaftTop extends RectangleComponent {
  final _frontColor = const Color.fromARGB(255, 84, 84, 84);

  @override
  FutureOr<void> onLoad() {
    setColor(_frontColor);
    return super.onLoad();
  }
}
