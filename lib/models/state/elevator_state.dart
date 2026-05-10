import 'dart:math';

import 'package:elevate/models/state/agents_state.dart';
import 'package:elevate/models/state/time_state.dart';

enum ElevatorUpgrade {
  snap2,
  snap3,
  gotoFloor,
  inElevatorButtons,
  elevatorMusic,
  upDownButtons,
}

class ElevatorState {
  late int elevatorMinFloor;
  late int elevatorMaxFloor;
  late int capacity;

  /// updated by agents.update
  int occupancy = 0;

  late double elevatorCarY;
  late bool doorsOpen;

  /// acceleration (+/-) in render resolution, but with Y upwards
  late double dy;
  late double lastUserMoveAt;

  late Set<ElevatorUpgrade> upgrades;

  ElevatorState() {
    reset();
  }

  void reset() {
    elevatorCarY = 0.0;
    elevatorMinFloor = -1;
    elevatorMaxFloor = 2;
    capacity = 5;
    doorsOpen = false;
    dy = 0;
    lastUserMoveAt = 0;
    upgrades = {};
  }

  int get elevatorLvl =>
      elevatorCarY.round().clamp(elevatorMinFloor, elevatorMaxFloor);

  /// value [0, 1] denoting where the elevator is in the elevator shaft range.
  double get elevatorFloorRatio =>
      (elevatorCarY - elevatorMinFloor) /
      max(
        1,
        elevatorMaxFloor - elevatorMinFloor,
      );

  int getOccupancy(AgentsState agents) => agents.agentsOnElevator.length;

  void installUpgrade(ElevatorUpgrade upgrade) {
    upgrades.add(upgrade);
  }

  void update(double elapsed, TimeState time) {}

  Map<String, dynamic> toJson() {
    return {
      'elevatorMinFloor': elevatorMinFloor,
      'elevatorMaxFloor': elevatorMaxFloor,
      'capacity': capacity,
      'occupancy': occupancy,
      'elevatorCarY': elevatorCarY,
      'doorsOpen': doorsOpen,
      'dy': dy,
      'lastUserMoveAt': lastUserMoveAt,
      'upgrades': upgrades.map((u) => u.name).toList(),
    };
  }

  void applyJson(Map<String, dynamic> data) {
    elevatorMinFloor = data['elevatorMinFloor'];
    elevatorMaxFloor = data['elevatorMaxFloor'];
    capacity = data['capacity'];
    occupancy = data['occupancy'];
    elevatorCarY = data['elevatorCarY'];
    doorsOpen = data['doorsOpen'];
    dy = data['dy'];
    lastUserMoveAt = data['lastUserMoveAt'];
    upgrades.clear();
    upgrades.addAll(
      Set<ElevatorUpgrade>.from(
        data['upgrades'].map(
          (u) => ElevatorUpgrade.values.firstWhere((v) => v.name == u),
        ),
      ),
    );
  }
}
