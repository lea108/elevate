import 'dart:async';

import 'package:elevate/game.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/projection.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/scenes/building/components/elevator_car.dart';
import 'package:elevate/scenes/building/components/elevator_indicators.dart';
import 'package:elevate/scenes/building/components/elevator_shaft.dart';
import 'package:elevate/scenes/building/components/elevator_shaft_top.dart';
import 'package:elevate/scenes/building/components/grass.dart';
import 'package:elevate/scenes/building/components/ground.dart';
import 'package:elevate/scenes/building/components/rooms.dart';
import 'package:elevate/scenes/building/components/sky.dart';
import 'package:elevate/scenes/building/components/time_info.dart';
import 'package:elevate/utils/gamepad_callbacks_mixin.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';

class BuildingScene extends World
    with HasGameReference<MyGame>, GamepadCallbacks, KeyboardHandler {
  late final Sky _sky;
  late final Ground _ground;
  late final TimeInfo _timeInfo;
  late final Grass _grass;
  late final Rooms _rooms;
  late final ElevatorShaft _elevatorShaft;
  late final ElevatorCar _elevatorCar;
  late final ElevatorShaftTop _elevatorShaftTop;

  @override
  FutureOr<void> onLoad() {
    final canvasSize = game.camera.viewport.virtualSize;
    final worldSize = Vector2(
      GameConsts.worldWidth * xScale,
      (GameConsts.maxFloorUp + GameConsts.maxFloorDown) * yScale,
    );
    final es = game.gameState.elevatorState;

    final elevatorTopSize = Vector2(xScale * GameConsts.elevatorShaftW, yScale);

    _sky = Sky()..size = worldSize;
    _ground = Ground()
      ..position = Vector2(0, GameConsts.maxFloorUp * yScale)
      ..size = Vector2(worldSize.x, GameConsts.maxFloorDown * yScale);
    _grass = Grass()
      ..position = Vector2(0, (GameConsts.maxFloorUp - 1) * yScale + 0.5)
      ..size = Vector2(worldSize.x, yScale);
    _rooms = Rooms()..size = worldSize;
    _elevatorShaft = ElevatorShaft()..updatePosSize(es);
    _elevatorCar = ElevatorCar()
      ..position = Vector2(
        (GameConsts.elevatorX +
                (GameConsts.elevatorShaftW - GameConsts.elevatorCarW) / 2) *
            xScale,
        (GameConsts.maxFloorUp - es.elevatorCarY) * yScale - 50,
      )
      ..size = Vector2((GameConsts.elevatorCarW) * xScale, 46);
    _elevatorShaftTop = ElevatorShaftTop()
      ..size = elevatorTopSize
      ..position = _elevatorShaft.position - Vector2(0, elevatorTopSize.y - 1);
    _timeInfo = TimeInfo()
      ..position = Vector2(canvasSize.x - mediumPadding, mediumPadding)
      ..anchor = Anchor.topRight
      ..scale = Vector2.all(0.8);

    addAll([
      _sky,
      _ground,
      _grass,
      _rooms,
      _elevatorShaft,
      _elevatorCar,
      _elevatorShaftTop,
      _timeInfo,
    ]);

    return super.onLoad();
  }

  @override
  void onMount() {
    final zoom = 1.0;
    game.camera.viewfinder.anchor = Anchor.center;
    game.camera.viewfinder.zoom = zoom;
    game.camera.setBounds(
      Rectangle.fromLTRB(
        0,
        0,
        GameConsts.worldWidth * xScale,
        (GameConsts.maxFloorUp + GameConsts.maxFloorDown) * yScale,
      ),
      considerViewport: true,
    );
    //game.camera.moveTo(Vector2(GameConsts.elevatorX * xScale, GameConsts.maxFloorUp * yScale + 100));
    game.camera.follow(_elevatorCar, snap: true);

    game.gameState.buildingState.addListener(onBuildingChange);
    super.onMount();
  }

  @override
  void onRemove() {
    game.camera.stop();
    game.gameState.buildingState.removeListener(onBuildingChange);
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    final canvasSize = game.camera.viewport.virtualSize;
    _timeInfo.position = Vector2(canvasSize.x - mediumPadding, mediumPadding);

    super.onGameResize(size);
  }

  @override
  void onGamepadEvent(GamepadEvent event) {
    if (!game.hasOpenMenu) {
      final escape = game.settingsState.gamepadCancelButton.value.isPressed(
        event,
      );
      if (escape == true) {
        game.overlays.add(GameOverlay.inGameMenu.name);
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!game.hasOpenMenu && keysPressed.contains(LogicalKeyboardKey.keyM)) {
      game.overlays.add(GameOverlay.inGameMenu.name);
      return true;
    }
    return false;
  }

  Future<void> onBuildingChange() async {
    await _rooms.rebuildRooms();
  }

  @override
  void update(double dt) {
    _elevatorShaftTop.position =
        _elevatorShaft.position - Vector2(0, _elevatorShaftTop.height - 1);
    super.update(dt);
  }
}
