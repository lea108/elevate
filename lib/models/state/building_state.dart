import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/room_defs.dart';
import 'package:elevate/models/state/elevator_state.dart';
import 'package:elevate/models/state/progression_state.dart';
import 'package:elevate/models/state/time_state.dart';
import 'package:elevate/models/state/tutorial_state.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class RoomData {
  final int startX;
  final RoomDef roomDef;

  bool rented;
  int nEmployees;
  int nPeopleInRoom;

  /// Inclusive end X of the room
  int get endX => startX + roomDef.width - 1;

  RoomData(
    this.startX,
    this.roomDef, {
    this.rented = false,
    this.nEmployees = 0,
    this.nPeopleInRoom = 0,
  });
}

/// Describes a key/locator of a room
class RoomLocation {
  final int lvl;
  final int roomIndex;

  const RoomLocation(this.lvl, this.roomIndex);

  @override
  operator ==(Object other) {
    return other is RoomLocation &&
        other.lvl == lvl &&
        other.roomIndex == roomIndex;
  }

  @override
  int get hashCode => lvl << 16 | roomIndex;
}

class BuildingState extends ChangeNotifier {
  late int nFloorsUp;
  late int nFloorsDown;

  // map from floor level to rooms.
  Map<int, List<RoomData>> rooms = {};

  BuildingState() {
    reset();
  }

  void reset() {
    nFloorsDown = 1;
    nFloorsUp = 3;
    rooms = {};
  }

  /// Get logical size of the building.
  (int, int) get buildingLogicalSize {
    int y = rooms.keys.max - rooms.keys.min + 1;
    int x = rooms.values.fold(0, (maxX, rooms) {
      int w =
          rooms.last.startX + rooms.last.roomDef.width - rooms.first.startX + 1;
      return max(w, maxX);
    });
    return (x, y);
  }

  void createBuilding(TutorialState tutorialState) {
    // Ground level
    final groundRoom = roomDefs[RoomId.groundLevel]!;
    rooms[0] = List<RoomData>.generate(
      (buildingWidth / groundRoom.width).floor(),
      (i) => RoomData(buildingStartX + i * groundRoom.width, groundRoom),
    );

    // Upper levels
    final roomW = roomDefs[RoomId.forRent]!.width;
    for (var lvl = 1; lvl < nFloorsUp; lvl += 1) {
      rooms[lvl] = List<RoomData>.generate((buildingWidth / roomW).floor(), (
        i,
      ) {
        final rented = tutorialState.stage != .done
            ? lvl > 1
            : i > 0 || lvl > 1;
        return generateOffice(rented, i, roomW);
      });
    }

    // Lower levels
    //_buildGarageLevel();

    notifyListeners();
  }

  void tutorialRentOutUnrentedOffices() {
    _rentOutUnrentedOffices(-1);
  }

  /// Rents out offices that has not yet been rented out
  /// to the maximum of [maxCount] offices.
  /// If [maxCount] is -1, there is no limit.
  /// returns the number of offices that was rented out.
  int _rentOutUnrentedOffices(int maxCount, {bool notify = true}) {
    int n = 0;
    for (var lvl in rooms.keys) {
      final levelRooms = rooms[lvl]!;
      rooms[lvl] = levelRooms.mapIndexed((i, r) {
        if (maxCount != -1 && n > maxCount) return r;
        if (!r.rented && r.roomDef.roomType == .office) {
          n += 1;
          return generateOffice(true, i, r.roomDef.width);
        }
        return r;
      }).toList();

      if (maxCount != -1 && n > maxCount) break;
    }

    if (notify) {
      notifyListeners();
    }
    return n;
  }

  int _buildNewRooms(int maxCount, {bool notify = true}) {
    int n = 0;
    var (int w, int h) = buildingLogicalSize;
    final aspectRatio = w / (max(h, 1));
    final targetAspectRatio = 3.0;

    var baseX1 = rooms[0]!.first.startX;
    var baseX2 = rooms[0]!.last.endX;
    final rented = true;

    final groundRoom = roomDefs[RoomId.groundLevel]!;
    final officeRoom = roomDefs[RoomId.office1]!;

    final expand = aspectRatio >= targetAspectRatio ? 'vertical' : 'horizontal';
    if (expand == 'horizontal') {
      // Expand ground floor
      final groundFloor = rooms[0]!;
      groundFloor.addAll(
        List<RoomData>.generate(
          (officeRoom.width / groundRoom.width).round(),
          (i) => RoomData(baseX2 + 1 + i * groundRoom.width, groundRoom),
        ),
      );
      // Add office on first floor
      final firstOfficeFloor = rooms[1]!;
      firstOfficeFloor.add(
        generateOffice(rented, firstOfficeFloor.length, officeRoom.width),
      );
      n += 1;
    }

    // Vertically expand next
    if (n < maxCount) {
      for (var lvl = 1; lvl < GameConsts.maxFloorUp; lvl += 1) {
        // On existing floors, lookout for if the tower has not expanded fully in the
        // last column to the right.
        if (rooms.containsKey(lvl)) {
          final floorRooms = rooms[lvl]!;
          int availableWidth = baseX2 - floorRooms.last.endX;
          if (availableWidth >= officeWidth) {
            floorRooms.add(
              generateOffice(rented, rooms[lvl]!.length, officeWidth),
            );
            n += 1;
          }
        } else {
          // Reached new floor
          final int nGen = min(
            (baseX2 - baseX1 + 1 / officeWidth).floor(),
            maxCount - n,
          );
          final floorRooms = List<RoomData>.generate(nGen, (i) {
            return generateOffice(rented, i, officeWidth);
          });
          rooms[lvl] = floorRooms;
          n += nGen;
        }
        if (n >= maxCount) break;
      }
    }

    if (n > 0 && notify) {
      notifyListeners();
    }
    return n;
  }

  bool _buildGarageLevel() {
    final int lowestLvl = rooms.keys.min;
    final int newLvl = lowestLvl - 1;

    if (newLvl < -GameConsts.maxFloorDown) {
      return false;
    }

    final garageW = roomDefs[RoomId.garage1]!.width;
    rooms[newLvl] = List<RoomData>.generate((buildingWidth / garageW).floor(), (
      i,
    ) {
      final idx = Random().nextInt(3) > 0 ? 1 : 0;
      final roomId = i == 0
          ? RoomId.garage1
          : [RoomId.garage1, RoomId.garage2][idx];
      final roomDef = roomDefs[roomId]!;
      return RoomData(buildingStartX + i * garageW, roomDef);
    });

    return true;
  }

  /// Evict tenants of [count] offices, keeping at least [minKeep] rented out.
  int _evictOffice(int count, {int minKeep = 1}) {
    int n = 0;
    int rentedOfficeCount = 0;
    for (var floorRooms in rooms.values) {
      for (var room in floorRooms) {
        if (room.roomDef.roomType == RoomType.office && room.rented) {
          rentedOfficeCount += 1;
        }
      }
    }

    if (rentedOfficeCount <= minKeep) {
      return 0;
    }

    List<int> floors = rooms.keys.shuffled().toList();
    for (var floorIndex in floors) {
      if (floorIndex <= 0) continue;
      final floorRooms = rooms[floorIndex]!;
      for (var i = 0; i < floorRooms.length; i += 1) {
        final room = floorRooms[i];
        if (room.roomDef.roomType == RoomType.office) {
          floorRooms[i] = RoomData(room.startX, roomDefs[RoomId.forRent]!);
          n += 1;
          rentedOfficeCount -= 1;

          if (n >= count || rentedOfficeCount <= minKeep) {
            break;
          }
        }
      }
      if (n >= count || rentedOfficeCount <= minKeep) {
        break;
      }
    }

    return n;
  }

  void _processBuildingProgress(
    ProgressionState progress,
    ElevatorState elevator,
  ) {
    bool notify = false;
    var credits = progress.buildingProgress;
    if (credits < 7.0) {
      int n = _evictOffice(min(2, (credits / 7.0).floor()), minKeep: 2);
      credits += n * 7.0;
      notify |= n > 0;
    }
    if (credits > 10.0) {
      int n = _rentOutUnrentedOffices((credits / 10.0).floor(), notify: false);
      credits -= n * 10.0;
      notify |= n > 0;
    }
    if (credits > 10.0 &&
        ((rooms.keys.min == 0 && rooms.keys.max >= 3) ||
            (rooms.keys.min <= -1 &&
                rooms.keys.max >= 2 + 3 * rooms.keys.min.abs()))) {
      int n = _buildGarageLevel() ? 1 : 0;
      credits -= n * 10.0;
      notify |= n > 0;
      elevator.elevatorMinFloor = min(
        elevator.elevatorMinFloor,
        rooms.keys.min,
      );
    }
    if (credits > 25.0) {
      int n = _buildNewRooms(min(3, (credits / 25).floor()));
      credits -= n * 25.0;
      notify |= n > 0;
      elevator.elevatorMaxFloor = rooms.keys.max;
    }
    progress.buildingProgress = credits;
    if (notify) {
      notifyListeners();
    }
  }

  void update(double elapsed, TimeState time) {}

  void newDay(
    int newDay,
    ProgressionState progress,
    ElevatorState elevator,
    TutorialState tutorial,
  ) {
    if ([
      TutorialStage.done,
      TutorialStage.finalNotes,
    ].contains(tutorial.stage)) {
      _processBuildingProgress(progress, elevator);
    }
  }
}

final midX = (GameConsts.worldWidth / 2).floor();
const buildingWidth = 20;
late final buildingStartX = midX - 10;

RoomData generateOffice(bool rented, int roomIndex, int roomW) {
  final idx = rented ? Random().nextInt(3) : 0;
  final roomId = rented
      ? [RoomId.office1, RoomId.office2, RoomId.office3][idx]
      : RoomId.forRent;
  final roomDef = roomDefs[roomId]!;
  return RoomData(
    buildingStartX + roomIndex * roomW,
    roomDef,
    rented: rented,
    nEmployees: rented ? 4 : 0,
  );
}
