import 'dart:async';

import 'package:elevate/game.dart';
import 'package:elevate/scenes/scenes.dart';
import 'package:elevate/utils/gamepad_callbacks_mixin.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';

class IntroScene extends World
    with
        HasGameReference<MyGame>,
        GamepadCallbacks,
        TapCallbacks,
        KeyboardHandler {
  @override
  FutureOr<void> onLoad() {
    final canvasSize = game.camera.viewport.virtualSize;

    addAll([
      TextComponent(
        text: 'Settings',
        position: Vector2(canvasSize.x / 2, canvasSize.y * 0.1),
        anchor: Anchor.center,
      ),
    ]);

    return super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    game.camera.viewfinder.anchor = Anchor.topLeft;
    game.camera.viewfinder.zoom = 1;
    game.camera.stop();
    game.camera.moveTo(Vector2(0, 0));
    final viewportSize = game.camera.viewport.size;
    game.camera.setBounds(
      Rectangle.fromLTRB(0, 0, viewportSize.x, viewportSize.y),
    );
  }

  @override
  void onGamepadEvent(GamepadEvent event) {
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

