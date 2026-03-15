import 'dart:async';

import 'package:elevate/models/state/building_state.dart';
import 'package:elevate/models/room_defs.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Room extends SpriteComponent {
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
    _overlay.setColor(
      roomData.roomDef.roomType != RoomType.office || roomData.nPeopleInRoom > 0
          ? Colors.transparent
          : Color.fromARGB(150, 0, 0, 0),
    );
    super.update(dt);
  }
}
