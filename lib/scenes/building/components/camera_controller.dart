import 'dart:math';

import 'package:elevate/game.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/projection.dart';
import 'package:flame/components.dart';

/// Updates camera viewfinder location based on current elevator location
class CameraController extends Component with HasGameReference<MyGame> {
  @override
  void update(double dt) {
    super.update(dt);

    final es = game.gameState.elevatorState;
    final elevatorY1 = (GameConsts.maxFloorUp - es.elevatorCarY - 1) * yScale;
    final elevatorY2 = elevatorY1 + yScale;
    var vfCenter = game.camera.viewfinder.position;
    final vpSize = game.camera.viewport.size;

    final zoom = game.camera.viewfinder.zoom;
    final viewY1 = vfCenter.y - vpSize.y / 2 / zoom;
    final viewY2 = vfCenter.y + vpSize.y / 2 / zoom;
    final margin = min(3 * yScale / zoom, (viewY2 - viewY1) * 0.2);

    bool updateCamera = false;
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
}
