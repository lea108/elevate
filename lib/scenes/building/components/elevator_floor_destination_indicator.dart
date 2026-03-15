import 'dart:async';

import 'package:collection/collection.dart';
import 'package:elevate/game.dart';
import 'package:elevate/models/agent.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:flame/components.dart';

class ElevatorFloorDestinationIndicator extends PositionComponent
    with HasGameReference<MyGame> {
  final int level;

  ElevatorFloorDestinationIndicator({required this.level});

  late final SpriteComponent _plate;
  late final SpriteComponent _indicator;

  @override
  Future<void> onLoad() async {
    final [plateSprite, indicatorSprite] = await [
      Sprite.load('ind_floor_plate.png'),
      Sprite.load('ind_floor_indicator.png'),
    ].wait;

    _plate = SpriteComponent()
      ..sprite = plateSprite
      ..position = Vector2(0.852, 19.230)
      ..size = plateSprite.srcSize;
    _indicator = SpriteComponent()
      ..sprite = indicatorSprite
      ..position = Vector2(0.861, 19.114)
      ..size = indicatorSprite.srcSize;

    addAll([_plate, _indicator]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    final goHere =
        game.gameState.agentsState.agents.firstWhereOrNull(
          (a) =>
              a.currentLocation == AgentLocation.onElevator &&
              a.targetLvl == level,
        ) !=
        null;

    _indicator.opacity = goHere ? 1.0 : GameConsts.indicatorOffOpacity;

    super.update(dt);
  }
}
