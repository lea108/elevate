import 'package:elevate/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class ElevatorTouchControl extends PositionComponent
    with HasGameReference<MyGame>, TapCallbacks {
  final double deadZoneY1;
  final double deadZoneY2;

  ElevatorTouchControl({required this.deadZoneY1, required this.deadZoneY2});

  bool hold = false;
  double? holdX;
  double? holdY;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    hold = true;
    holdX = event.localPosition.x;
    holdY = event.localPosition.y;

    game.gameState.inputState.inputY.value = inputY;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    hold = false;
    holdX = null;
    holdY = null;

    game.gameState.inputState.inputY.value = inputY;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    hold = false;
    holdX = null;
    holdY = null;

    game.gameState.inputState.inputY.value = inputY;
  }

  double get inputY {
    if (!hold || holdY == null) {
      return 0.0;
    }
    if (holdY! < deadZoneY1 && holdY! > 0) {
      return -1.0;
    }
    if (holdY! > deadZoneY2 && holdY! < size.y) {
      return 1.0;
    }
    return 0.0;
  }
}
