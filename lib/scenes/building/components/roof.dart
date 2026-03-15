import 'dart:async';

import 'package:flame/components.dart';

class Roof extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('roof.png');
    size = sprite!.srcSize;
    return super.onLoad();
  }
}
