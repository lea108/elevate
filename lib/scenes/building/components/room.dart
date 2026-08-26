import 'dart:async';

import 'package:elevate/game.dart';
import 'package:elevate/models/furniture_defs.dart';
import 'package:elevate/models/state/building_state.dart';
import 'package:elevate/models/room_defs.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:material_ui/material_ui.dart';

class Room extends SpriteComponent with HasGameReference<MyGame> {
  int floor;
  int roomIndex;
  RoomData roomData;
  bool addRoof;
  bool _lightsOn = false;
  Rect _overlayRect = Rect.zero;

  Room(this.floor, this.roomIndex, this.roomData, this.addRoof);

  final Paint roofPaint = Paint()
    ..color = Colors.black87
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(roomData.roomDef.spriteName);
    bleed = 1.1;
    _overlayRect = Rect.fromLTWH(
      -bleed!,
      -bleed!,
      size.x + bleed! * 2,
      size.y + bleed! * 2,
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _lightsOn = switch (roomData.roomDef.roomType) {
      RoomType.empty => true,
      RoomType.office => roomData.nPeopleInRoom > 0,
      RoomType.groundFloor => game.gameState.timeState.timeOfDay > 5 * 3600,
      RoomType.garage =>
        game.gameState.timeState.timeOfDay > 6 * 3600 &&
            game.gameState.timeState.timeOfDay < 23 * 3600,
    };
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (addRoof) {
      canvas.drawLine(
        Offset(-bleed!, -1),
        Offset(size.x + bleed!, -1),
        roofPaint,
      );
    }
    for (var f in roomData.furniture) {
      final sprite = furnitureSprites[f.furniture.furnitureId];
      if (sprite != null) {
        sprite.render(canvas, position: f.offset);
      }
    }
    // Last draw darkness ontop if light is off
    if (!_lightsOn) {
      canvas.drawRect(
        _overlayRect,
        Paint()..color = const Color.fromARGB(150, 0, 0, 0),
      );
    }
  }
}
