import 'dart:math';

import 'package:elevate/game.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/projection.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:flame/components.dart';

/// Updates camera viewfinder location based on current elevator location
class CameraController extends Component with HasGameReference<MyGame> {
  @override
  void update(double dt) {
    super.update(dt);

    bool updateCamera = false;
    var vfCenter = game.camera.viewfinder.position;

    // Update X
    final newX = getTargetCenterX();
    if (newX != vfCenter.y && (newX - vfCenter.y).abs() > 0.01) {
      vfCenter.x = newX;
      updateCamera = true;
    }

    // Update Y
    final es = game.gameState.elevatorState;
    final elevatorY1 = (GameConsts.maxFloorUp - es.elevatorCarY - 1) * yScale;
    final elevatorY2 = elevatorY1 + yScale;

    final vpSize = game.camera.viewport.size;
    final zoom = game.camera.viewfinder.zoom;
    final viewY1 = vfCenter.y - vpSize.y / 2 / zoom;
    final viewY2 = vfCenter.y + vpSize.y / 2 / zoom;
    final margin = min(3 * yScale / zoom, (viewY2 - viewY1) * 0.2);

    if (elevatorY1 < viewY1 + margin) {
      vfCenter.y -= viewY1 + margin - elevatorY1;
      updateCamera = true;
    } else if (elevatorY2 > viewY2 - margin) {
      vfCenter.y += elevatorY2 - (viewY2 - margin);
      updateCamera = true;
    }

    if (updateCamera) {
      game.camera.moveTo(vfCenter);
    }
  }

  double getTargetCenterX() {
    final isTutorialOpen = game.overlays.isActive(
      GameOverlay.elevatorTutorial.name,
    );
    final elevatorX1 = GameConsts.elevatorX * xScale;
    final elevatorX2 = elevatorX1 + GameConsts.elevatorShaftW;
    if (isTutorialOpen) {
      return elevatorX1 + GameConsts.elevatorShaftW / 2;
    }

    final bState = game.gameState.buildingState;
    var x1 = elevatorX1;
    var x2 = elevatorX2;
    if (bState.rooms.containsKey(0) && bState.rooms[0]!.isNotEmpty) {
      final buildingX1 = bState.rooms[0]!.first.startX;
      final buildingX2 = bState.rooms[0]!.last.endX;
      x1 = min(x1, buildingX1 * xScale);
      x2 = max(x2, buildingX2 * xScale);
    }

    return x1 + (x2 - x1) / 2;
  }
}
