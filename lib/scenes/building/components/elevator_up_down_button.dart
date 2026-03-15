import 'dart:async';

import 'package:collection/collection.dart';
import 'package:elevate/game.dart';
import 'package:elevate/models/agent.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:flame/components.dart';

class ElevatorUpDownButton extends PositionComponent
    with HasGameReference<MyGame> {
  final int level;

  ElevatorUpDownButton({required this.level});

  late final SpriteComponent _plate;
  late final SpriteComponent _upButton;
  late final SpriteComponent _downButton;

  @override
  Future<void> onLoad() async {
    final [plateSprite, upSprite, downSprite] = await [
      Sprite.load('ind_up_down_plate.png'),
      Sprite.load('ind_up_button.png'),
      Sprite.load('ind_down_button.png'),
    ].wait;

    _plate = SpriteComponent()
      ..sprite = plateSprite
      ..position = Vector2(0.852, 15.256)
      ..size = plateSprite.srcSize;
    _upButton = SpriteComponent()
      ..sprite = upSprite
      ..position = Vector2(2.497, 16.880)
      ..size = upSprite.srcSize;
    _downButton = SpriteComponent()
      ..sprite = downSprite
      ..position = Vector2(2.497, 25.377)
      ..size = downSprite.srcSize;

    addAll([_plate, _upButton, _downButton]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    final hasGoUp =
        game.gameState.agentsState.agents.firstWhereOrNull(
          (a) =>
              a.currentLvl == level &&
              a.currentLocation == AgentLocation.waitOnElevator &&
              a.targetLvl > level,
        ) !=
        null;
    final hasGoDown =
        game.gameState.agentsState.agents.firstWhereOrNull(
          (a) =>
              a.currentLvl == level &&
              a.currentLocation == AgentLocation.waitOnElevator &&
              a.targetLvl < level,
        ) !=
        null;

    _upButton.opacity = hasGoUp ? 1.0 : GameConsts.indicatorOffOpacity;
    _downButton.opacity = hasGoDown ? 1.0 : GameConsts.indicatorOffOpacity;

    super.update(dt);
  }
}
