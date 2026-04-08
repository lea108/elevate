import 'package:elevate/game.dart';
import 'package:elevate/scenes/scenes.dart';
import 'package:elevate/utils/gamepad_callbacks_mixin.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';

/// Text content for this scene is in [IntroOverlay]
class IntroScene extends World
    with
        HasGameReference<MyGame>,
        GamepadCallbacks,
        TapCallbacks,
        KeyboardHandler {
  @override
  void onGamepadEvent(NormalizedGamepadEvent event) {
    if (event.value > 0) {
      goNext();
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.isNotEmpty) {
      goNext();
      return false;
    }
    return true;
  }

  @override
  void onTapDown(TapDownEvent event) {
    goNext();
    super.onTapDown(event);
  }

  void goNext() {
    game.changeScene(GameScene.building);
  }
}
