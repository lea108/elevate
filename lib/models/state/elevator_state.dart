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
  late int occupancy;

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
    elevatorMinFloor = -2;
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
}
