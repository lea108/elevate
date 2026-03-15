import 'dart:async';

import 'package:elevate/game.dart';
import 'package:elevate/models/state/building_state.dart';
import 'package:elevate/models/room_defs.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Room extends SpriteComponent with HasGameReference<MyGame> {
  int floor;
  int roomIndex;
  RoomData roomData;
  late RectangleComponent _overlay;

  Room(this.floor, this.roomIndex, this.roomData);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(roomData.roomDef.spriteName);
    bleed = 1.0;

    _overlay = RectangleComponent()
      ..position = Vector2(-bleed!, -bleed!)
      ..size = size + Vector2(bleed! * 2, bleed! * 2);
    await add(_overlay);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    final lightsOn = switch (roomData.roomDef.roomType) {
      RoomType.empty => true,
      RoomType.office => roomData.nPeopleInRoom > 0,
      RoomType.groundFloor => game.gameState.timeState.timeOfDay > 5 * 3600,
      RoomType.garage =>
        game.gameState.timeState.timeOfDay > 6 * 3600 &&
            game.gameState.timeState.timeOfDay < 23 * 3600,
    };
    _overlay.setColor(
      lightsOn ? Colors.transparent : Color.fromARGB(150, 0, 0, 0),
    );
    super.update(dt);
  }
}
