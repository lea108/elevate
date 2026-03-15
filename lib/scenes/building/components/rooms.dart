import 'dart:async';

import 'package:elevate/game.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/projection.dart';
import 'package:elevate/scenes/building/components/room.dart';
import 'package:flame/components.dart';

class Rooms extends PositionComponent with HasGameReference<MyGame> {
  final List<Room> _rooms = [];

  @override
  Future<void> onLoad() async {
    await addRooms();
    return super.onLoad();
  }

  Future<void> addRooms() async {
    final b = game.gameState.buildingState;

    for (var lvl in b.rooms.keys) {
      final lvlRooms = b.rooms[lvl]!;
      for (var roomIndex = 0; roomIndex < lvlRooms.length; roomIndex += 1) {
        final roomData = lvlRooms[roomIndex];
        final needRoof =
            !b.rooms.containsKey(lvl + 1) || b.rooms.length <= roomIndex;
        final room = Room(lvl, roomIndex, lvlRooms[roomIndex], needRoof)
          ..position = Vector2(
            roomData.startX * xScale,
            (GameConsts.maxFloorUp - lvl - 1) * yScale,
          )
          ..size = Vector2(roomData.roomDef.width * xScale, yScale);
        _rooms.add(room);
      }
    }

    await addAll(_rooms);
  }

  Future<void> rebuildRooms() async {
    removeAll(_rooms);
    addRooms();
  }
}
