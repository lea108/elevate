import 'dart:async';

import 'package:flame/components.dart';

class ElevatorFullIndicator extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ind_elevator_full.png');
    size = sprite!.srcSize;

    return super.onLoad();
  }
}
