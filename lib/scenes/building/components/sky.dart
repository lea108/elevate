import 'dart:async';
import 'dart:math';

import 'package:elevate/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Sky extends RectangleComponent with HasGameReference<MyGame> {

  @override
  FutureOr<void> onLoad() {
    setColor(Colors.lightBlue);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    setColor(game.gameState.timeState.skyColor);
    super.update(dt);
  }
}
