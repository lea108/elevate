
import 'dart:async';

import 'package:flame/components.dart';

class GamepadView extends PositionComponent {

  late SpriteComponent base;
  late SpriteComponent leftStick;
  late SpriteComponent rightStick;
  late SpriteComponent dpad;
  late SpriteComponent aButton;
  late SpriteComponent bButton;
  late SpriteComponent xButton;
  late SpriteComponent yButton;

  @override
  Future<void> onLoad() async {
    final [
      baseSprite,
      stickSprite,
      dpadSprite,
      abxyBtnSprite,
    ] = await [
      Sprite.load('gamepad_base.png'),
      Sprite.load('gamepad_stick.png'),
      Sprite.load('gamepad_dpad.png'),
      Sprite.load('gamepad_xyz_btn.png'),
    ].wait;

    base = SpriteComponent(sprite: baseSprite);
    leftStick = SpriteComponent(sprite: stickSprite);
    rightStick = SpriteComponent(sprite: stickSprite);
    dpad = SpriteComponent(sprite: dpadSprite);
    aButton = SpriteComponent(sprite: abxyBtnSprite);
    bButton = SpriteComponent(sprite: abxyBtnSprite);
    xButton = SpriteComponent(sprite: abxyBtnSprite);
    yButton = SpriteComponent(sprite: abxyBtnSprite);

    return super.onLoad();
  }


}