import 'dart:async';
import 'dart:math';

import 'package:elevate/game.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/projection.dart';
import 'package:elevate/models/state/elevator_state.dart';
import 'package:elevate/scenes/building/components/elevator_floor_destination_indicator.dart';
import 'package:elevate/scenes/building/components/elevator_indicators.dart';
import 'package:elevate/scenes/building/components/elevator_queue.dart';
import 'package:elevate/scenes/building/components/elevator_up_down_button.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ElevatorShaft extends RectangleComponent with HasGameReference<MyGame> {
  final Map<int, ElevatorQueue> _elevatorQueues = {};
  final Map<int, ElevatorUpDownButton> _upDownButtons = {};
  final Map<int, ElevatorFloorDestinationIndicator> _floorIndicators = {};

  // left/bottom depth shadow polygons
  PolygonComponent? left;
  PolygonComponent? bottom;

  // cables in the back
  RectangleComponent? leftCable;
  RectangleComponent? rightCable;

  final _backColor = Color.fromARGB(255, 105, 105, 105);
  final _leftColor = const Color.fromARGB(255, 92, 92, 92);
  final _bottomColor = const Color.fromARGB(255, 84, 84, 84);
  final _cableColor = Colors.black26;

  @override
  FutureOr<void> onLoad() {
    setColor(_backColor);

    leftCable = RectangleComponent()
      ..position = Vector2(depthBackOffset.x + size.x * 0.3, 0)
      ..size = Vector2(2, size.y + depthBackOffset.y)
      ..setColor(_cableColor);
    rightCable = RectangleComponent()
      ..position = Vector2(depthBackOffset.x + size.x * 0.6, 0)
      ..size = Vector2(2, size.y + depthBackOffset.y)
      ..setColor(_cableColor);
    addAll([leftCable!, rightCable!]);

    return super.onLoad();
  }

  void updatePosSize(ElevatorState es) {
    final topMargin = 0.1;

    final newPosition = Vector2(
      GameConsts.elevatorX * xScale,
      (GameConsts.maxFloorUp - es.elevatorMaxFloor - 1 - topMargin) * yScale,
    );
    final newSize = Vector2(
      GameConsts.elevatorShaftW * xScale,
      (es.elevatorMaxFloor - es.elevatorMinFloor + 1 + topMargin) * yScale,
    );

    if (newPosition != position || newSize != size) {
      position = newPosition;
      size = newSize;

      for (var entry in _elevatorQueues.entries) {
        final lvl = entry.key;
        final queue = entry.value;
        queue.position = Vector2(
          GameConsts.elevatorShaftW * xScale,
          (es.elevatorMaxFloor - lvl) * yScale,
        );
      }

      leftCable?.size = Vector2(2, size.y + depthBackOffset.y);
      rightCable?.size = Vector2(2, size.y + depthBackOffset.y);

      if (left != null) remove(left!);
      if (bottom != null) remove(bottom!);

      left = PolygonComponent(leftPolygon)..setColor(_leftColor);
      bottom = PolygonComponent(bottomPolygon)..setColor(_bottomColor);
      addAll([left!, bottom!]);
    }
  }

  List<Vector2> get leftPolygon {
    return [
      Vector2(0, 0),
      Vector2(depthBackOffset.x, 0),
      Vector2(depthBackOffset.x, size.y + depthBackOffset.y),
      Vector2(0, size.y),
    ];
  }

  List<Vector2> get bottomPolygon {
    return [
      Vector2(0, size.y),
      Vector2(depthBackOffset.x, size.y + depthBackOffset.y),
      Vector2(size.x, size.y + depthBackOffset.y),
      Vector2(size.x, size.y),
    ];
  }

  @override
  void update(double dt) {
    final es = game.gameState.elevatorState;
    final nElevatorFloors = max(
      0,
      es.elevatorMaxFloor - es.elevatorMinFloor + 1,
    );

    int targetNIndicators =
        es.upgrades.contains(ElevatorUpgrade.inElevatorButtons)
        ? nElevatorFloors
        : 0;
    int targetNUpDownButtons =
        es.upgrades.contains(ElevatorUpgrade.upDownButtons)
        ? nElevatorFloors
        : 0;

    updatePosSize(es);
    //_updateQueues(es, nElevatorFloors);

    List<PositionComponent> removeComponents = [];
    List<PositionComponent> addComponents = [];
    _addRemove(
      es,
      _elevatorQueues,
      nElevatorFloors,
      (lvl) {
        return ElevatorQueue(lvl)
          ..position = Vector2(
            GameConsts.elevatorShaftW * xScale,
            (es.elevatorMaxFloor - lvl) * yScale,
          );
      },
      addComponents,
      removeComponents,
    );
    _addRemove(
      es,
      _upDownButtons,
      targetNUpDownButtons,
      (lvl) {
        return ElevatorUpDownButton(level: lvl)
          ..position = Vector2(
            (GameConsts.elevatorShaftW - 0.5) * xScale,
            (es.elevatorMaxFloor - lvl) * yScale,
          );
      },
      addComponents,
      removeComponents,
    );
    _addRemove(
      es,
      _floorIndicators,
      targetNIndicators,
      (lvl) {
        return ElevatorFloorDestinationIndicator(level: lvl)
          ..position = Vector2(
            -xScale / 2,
            (es.elevatorMaxFloor - lvl) * yScale,
          );
      },
      addComponents,
      removeComponents,
    );

    super.update(dt);
  }

  void _addRemove(
    ElevatorState es,
    Map<int, PositionComponent> map,
    int targetLength,
    PositionComponent Function(int lvl) builder,
    List<PositionComponent> addComponents,
    List<PositionComponent> removeComponents,
  ) {
    if (map.length != targetLength) {
      // if (targetLength == 0) {
      //   removeComponents.addAll(map.values);
      //   map.clear();
      //   return;
      // } else {
      //   map.removeWhere((lvl, component) {
      //     bool outOfRange =
      //         lvl < es.elevatorMinFloor || lvl > es.elevatorMaxFloor;
      //     if (outOfRange) {
      //       removeComponents.add(component);
      //     }
      //     return outOfRange;
      //   });
      // }
      removeComponents.addAll(map.values);
      map.clear();
      if (targetLength == 0) {
        return;
      }

      for (
        var lvl = es.elevatorMinFloor;
        lvl <= es.elevatorMaxFloor;
        lvl += 1
      ) {
        if (!map.containsKey(lvl)) {
          final component = builder(lvl);
          map[lvl] = component;
          addComponents.add(component);
        }
      }
      removeAll(removeComponents);
      addAll(addComponents);
    }
  }
}
