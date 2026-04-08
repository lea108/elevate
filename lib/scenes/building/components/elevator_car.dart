import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:elevate/game.dart';
import 'package:elevate/models/agent.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/projection.dart';
import 'package:elevate/models/state/elevator_state.dart';
import 'package:elevate/scenes/building/components/agent_sprite.dart';
import 'package:elevate/scenes/building/components/elevator_full_indicator.dart';
import 'package:elevate/scenes/building/components/elevator_touch_control.dart';
import 'package:elevate/utils/gamepad_callbacks_mixin.dart';
import 'package:elevate/utils/speed.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';

class ElevatorCar extends RectangleComponent
    with GamepadCallbacks, KeyboardHandler, HasGameReference<MyGame> {
  final List<AgentSprite> _sprites = [];

  // depth perspective sides
  PolygonComponent? top;
  PolygonComponent? right;

  PositionComponent? agentSpritesLayer;
  RectangleComponent? foldOutRamp;
  ElevatorFullIndicator? fullIndicator;
  ElevatorTouchControl? touchControl;

  final bool _useOuterPerspective = false;
  final _frontColor = Colors.grey[900]!;
  final _topColor = Color.lerp(Colors.grey[900]!, Colors.white, 0.03)!;
  final _rightColor = Color.lerp(Colors.grey[900]!, Colors.white, 0.01)!;
  final _foldOutColor = Color.lerp(Colors.grey[900]!, Colors.white, 0.05)!;

  @override
  FutureOr<void> onLoad() {
    setColor(_frontColor);

    if (_useOuterPerspective) {
      top = PolygonComponent(topPolygon)..setColor(_topColor);
      right = PolygonComponent(rightPolygon)..setColor(_rightColor);
    }

    agentSpritesLayer = PositionComponent();
    foldOutRamp = RectangleComponent()
      ..setColor(_foldOutColor)
      ..size = Vector2(xScale * 0.5, 3)
      ..position = size;
    fullIndicator = ElevatorFullIndicator();
    touchControl =
        ElevatorTouchControl(
            deadZoneY1: size.y * 1.5,
            deadZoneY2: size.y * 1.5 + size.y,
          )
          ..position = Vector2(-size.x * 0.5, -size.y * 1.5)
          ..size = Vector2(size.x * 2, size.y * 1.5 * 2 + size.y);

    addAll([
      ?right,
      ?top,
      ?agentSpritesLayer,
      ?foldOutRamp,
      ?fullIndicator,
      ?touchControl,
    ]);

    return super.onLoad();
  }

  Vector2 get _depthBackOffset => depthBackOffset * 0.2;

  /// Clip of polygons extending out from the elevator to the right at this x
  /// coordinate.
  double get _xClip =>
      size.x +
      xScale * (GameConsts.elevatorShaftW - GameConsts.elevatorCarW) / 2;

  /// When clipping at _xClip, offset the y with this value.
  double get _xClipYOffset {
    final allowedX =
        (xScale * (GameConsts.elevatorShaftW - GameConsts.elevatorCarW) / 2);
    final xClipRatio =
        (_depthBackOffset.x - allowedX) /
        (xScale * (GameConsts.elevatorShaftW - GameConsts.elevatorCarW) / 2);
    return xClipRatio * _depthBackOffset.y / max(0.001, _depthBackOffset.x);
  }

  List<Vector2> get topPolygon {
    final xClip = _xClip;
    if (_depthBackOffset.x + size.x <= xClip) {
      return [
        Vector2(_depthBackOffset.x, _depthBackOffset.y),
        Vector2(_depthBackOffset.x + size.x, _depthBackOffset.y),
        Vector2(_depthBackOffset.x + size.x, 0.5),
        Vector2(0, 0.5),
      ];
    } else {
      return [
        Vector2(_depthBackOffset.x, _depthBackOffset.y),
        Vector2(xClip, _depthBackOffset.y),
        Vector2(
          xClip,
          _depthBackOffset.y + _xClipYOffset,
        ),
        Vector2(size.x, 0),
        Vector2(0, 0),
      ];
    }
  }

  List<Vector2> get rightPolygon {
    final xClip = _xClip;
    if (_depthBackOffset.x + size.x <= xClip) {
      return [
        Vector2(size.x, 0),
        Vector2(size.x + _depthBackOffset.x, _depthBackOffset.y),
        Vector2(size.x + _depthBackOffset.x, size.y + _depthBackOffset.y),
        Vector2(size.x, size.y),
      ];
    } else {
      final yOffset = _xClipYOffset;
      return [
        Vector2(size.x, 0),
        Vector2(xClip, _depthBackOffset.y + yOffset),
        Vector2(xClip, size.y + _depthBackOffset.y + yOffset),
        Vector2(size.x, size.y),
      ];
    }
  }

  @override
  void onGamepadEvent(NormalizedGamepadEvent event) {
    var gamepadY = game.settingsState.gamepadElevator1UpDownAxis.value
        .readEvent(event);
    if (gamepadY != null) {
      if (gamepadY.abs() < 0.15) {
        gamepadY = 0;
      }
      game.gameState.inputState.inputY.value = gamepadY;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if ([
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.keyS,
    ].contains(event.logicalKey)) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW)) {
        game.gameState.inputState.inputY.value = -1.0;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keysPressed.contains(LogicalKeyboardKey.keyS)) {
        game.gameState.inputState.inputY.value = 1.0;
      } else {
        game.gameState.inputState.inputY.value = 0.0;
      }
      return true;
    }
    return false;
  }

  (double, double) get _snapAccelDecel {
    final es = game.gameState.elevatorState;
    if (es.upgrades.contains(ElevatorUpgrade.snap3)) {
      return (0.1, 0.2);
    } else if (es.upgrades.contains(ElevatorUpgrade.snap2)) {
      return (0.05, 0.10);
    }
    return (0.01, 0.02);
  }

  @override
  void update(double dt) {
    super.update(dt);
    dt = min(dt, 0.05);
    final time = game.gameState.timeState;
    final es = game.gameState.elevatorState;

    const maxVelocity = 0.5;
    const snapVelocity = 0.02;
    const userAccel = 0.1;
    final (snapAccel, snapDecel) = _snapAccelDecel;

    // User control
    final inputY = game.gameState.inputState.inputY.value;
    double userDy = clampDouble(inputY * -0.1, -maxVelocity, maxVelocity);
    if (userDy.abs() < 0.005) {
      userDy = 0.0;
    }

    bool userMove = false;
    bool autoMove = false;
    final double targetY = es.elevatorCarY.roundToDouble();
    final double travelY = targetY - es.elevatorCarY;
    bool stoppedAtLvl = travelY.abs() <= 0.001 && es.dy.abs() <= 0.01;

    if (userDy.abs() >= 0.005) {
      // Use user input if non-zero

      final dyChange = clampDouble(
        userDy - es.dy,
        -dt * userAccel,
        dt * userAccel,
      );
      if (es.dy.abs() < 0.001 && dyChange.abs() > 0.001) {
        _playElevatorAudioEffect(dyChange, es);
      }
      es.dy += dyChange;
      es.lastUserMoveAt = time.t;
      userMove = true;
      stoppedAtLvl = false;
    } else if (time.t > es.lastUserMoveAt + 2.5 && !stoppedAtLvl) {
      // Automatic snap
      //print('elevator car at ${es.elevatorCarY}');
      //if (travelY.abs() > 0.001) {
      autoMove = true;
      double stopDist = brakingDistance(
        currentSpeed: es.dy.abs(),
        targetSpeed: 0,
        decel: snapDecel,
      );
      if (travelY.abs() < 0.005) {
        es.dy = 0;
        es.elevatorCarY = targetY;
      } else {
        //print("auto snap - move");
        if (stopDist > travelY.abs() || (es.dy > 0) != (travelY > 0)) {
          final newDy = clampDouble(
            es.dy + (es.dy > 0 ? -1 : 1) * snapDecel * dt,
            -snapVelocity,
            snapVelocity,
          );
          //print("decel $es.dy => $newDy");
          es.dy = newDy;
        } else {
          final newDy = clampDouble(
            es.dy + (travelY > 0 ? 1 : -1) * snapAccel * dt,
            -snapVelocity,
            snapVelocity,
          );
          //print("acel $es.dy => $newDy");
          es.dy = newDy;
          //es.dy = (travelY > 0 ? 1 : -1) * snapVelocity;
        }
      }
      //}
    }
    // If neither user move or auto move, slow down to still
    if (!userMove && !autoMove) {
      if (es.dy > 0.001) {
        es.dy += clampDouble(-es.dy, -dt * userAccel, 0);
      } else if (es.dy < 0.001) {
        es.dy += clampDouble(-es.dy, 0, dt * userAccel);
      } else {
        es.dy = 0;
      }
    }

    if (es.dy.abs() > 0.0001) {
      es.elevatorCarY = clampDouble(
        es.elevatorCarY + es.dy * dt * (time.paused ? 0 : time.gameSpeed),
        es.elevatorMinFloor.toDouble(),
        es.elevatorMaxFloor.toDouble(),
      );
      //print("elevator car Y: ${es.elevatorCarY}");
    }
    position.y = (GameConsts.maxFloorUp - es.elevatorCarY) * yScale - 50;

    es.doorsOpen = stoppedAtLvl;

    foldOutRamp?.opacity = es.doorsOpen ? 1.0 : 0.0;
    fullIndicator?.opacity = es.occupancy >= es.capacity ? 1.0 : 0.0;

    //    if (autoMove) {
    //      setColor(Colors.purple);
    //    } else if (userMove) {
    //      setColor(Colors.orange);
    //    } else {
    //      setColor(Colors.grey[900]!);
    //    }

    updateSprites();
  }

  void updateSprites() {
    final agents = game.gameState.agentsState;
    final es = game.gameState.elevatorState;

    final onElevator = agents.agentsOnElevator;
    final maxVisibleAgents = GameConsts.elevatorCarW;
    final nVisibleAgents = min(onElevator.length, maxVisibleAgents);

    final List<Component> removeComponents = [];
    final List<Component> addComponents = [];

    while (_sprites.length > nVisibleAgents) {
      final component = _sprites.removeLast();
      removeComponents.add(component);
    }
    while (_sprites.length < nVisibleAgents) {
      final component = AgentSprite(AgentSpriteColor.white)
        ..size = Vector2(xScale, yScale);
      addComponents.add(component);
      _sprites.add(component);
    }

    for (var i = 0; i < _sprites.length; i += 1) {
      final lateness = onElevator[i].lateness ?? AgentLateness.neutral;
      _sprites[i].position = Vector2(i * xScale, 0);
      _sprites[i].color = AgentSpriteColor.fromLateness(lateness, true);
    }

    agentSpritesLayer?.removeAll(removeComponents);
    agentSpritesLayer?.addAll(addComponents);
  }

  void _playElevatorAudioEffect(double dyChange, ElevatorState es) {
    if (dyChange > 0) {
      game.audioEffects.elevatorStartMoveUp(es.elevatorLvl);
    } else {
      game.audioEffects.elevatorStartMoveUp(es.elevatorLvl);
    }
  }
}
