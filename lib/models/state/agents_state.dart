import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:elevate/models/agent.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/state/building_state.dart';
import 'package:elevate/models/state/elevator_state.dart';
import 'package:elevate/models/state/progression_state.dart';
import 'package:elevate/models/state/time_state.dart';
import 'package:elevate/models/state/tutorial_state.dart';
import 'package:flame/extensions.dart';

enum AgentUpgrade {
  carFreePolicy,
}

class AgentsState {
  final List<AgentData> agents = [];

  final Set<AgentUpgrade> upgrades = {};

  AgentsState() {
    reset();
  }

  void reset() {
    agents.clear();
    upgrades.clear();
  }

  /// Are any agent in active game play?
  bool get activeGamePlay =>
      agents.firstWhereOrNull(
        (a) => [
          AgentLocation.waitOnElevator,
          AgentLocation.onElevator,
        ].contains(a.currentLocation),
      ) !=
      null;

  List<AgentData> get agentsOnElevator => agents
      .where((a) => a.currentLocation == AgentLocation.onElevator)
      .toList();

  void createAgents(BuildingState building, TimeState time) {
    final dayOffset =
        time.day * 24 * 3600 +
        (time.timeOfDay > GameConsts.officeHoursStartFrom ? 24 * 3600 : 0);

    final roomsWithAgents = agents
        .map((a) => RoomLocation(a.roomLvl, a.roomIndex))
        .toSet();

    for (var lvl in building.rooms.keys) {
      final lvlRooms = building.rooms[lvl]!;
      for (var roomIndex = 0; roomIndex < lvlRooms.length; roomIndex += 1) {
        final room = lvlRooms[roomIndex];

        final roomHasAgents = roomsWithAgents.contains(
          RoomLocation(lvl, roomIndex),
        );
        // Remove agents from rooms that are no longer rented out
        if (!room.rented && roomHasAgents) {
          agents.removeWhere(
            (a) => a.roomLvl == lvl && a.roomIndex == roomIndex,
          );
        }

        // skip adding agents to rooms that already have agents
        if (roomHasAgents) {
          continue;
        }
        agents.addAll(
          List<AgentData>.generate(
            room.nEmployees,
            (i) => AgentData(lvl, roomIndex)
              ..nextStateChange =
                  dayOffset +
                  Random().nextDoubleBetween(
                    GameConsts.officeHoursStartFrom,
                    GameConsts.officeHoursStartTo,
                  ),
          ),
        );
      }
    }
  }

  void update(
    double elapsed,
    TimeState time,
    ElevatorState elevator,
    BuildingState building,
    TutorialState tutorial,
    ProgressionState progress,
  ) {
    for (var a in agents) {
      // Is it time for nextStateChange?
      if (a.nextStateChange != null && time.t >= a.nextStateChange!) {
        switch (a.currentLocation) {
          case AgentLocation.outside:
            a.currentLvl = outsideLevel(a, building, tutorial);
            a.currentLocation = AgentLocation.waitOnElevator;
            a.targetLocation = AgentLocation.atRoom;
            a.targetLvl = a.roomLvl;
            a.nextStateChange = scheduleNextDeparture(time);
            a.travelStartAt = time.t;
            print('agent => elevator Queue (level ${a.currentLvl})');
            break;
          case AgentLocation.atRoom:
            final room = building.rooms[a.roomLvl]![a.roomIndex];
            room.nPeopleInRoom -= 1;
            a.currentLvl = a.roomLvl;
            a.currentLocation = AgentLocation.waitOnElevator;
            a.targetLocation = AgentLocation.outside;
            a.targetLvl = outsideLevel(a, building, tutorial);
            a.nextStateChange = scheduleNextArrival(time);
            a.travelStartAt = time.t;
            print('agent => elevator Queue (room level)');
            break;
          default:
            break;
        }
      }
      // In elevator that is on target floor with open doors?
      if (a.currentLocation == AgentLocation.onElevator &&
          elevator.doorsOpen &&
          a.targetLvl == elevator.elevatorLvl) {
        // Leave elevator
        print('agent => agent leaves elevator');
        tutorial.recordTransported(
          a.lateness ?? AgentLateness.neutral,
          a.targetLvl,
        );
        progress.recordTransported(a.lateness ?? AgentLateness.neutral);
        a.currentLocation = a.targetLocation;
        a.currentLvl = a.targetLvl;
        a.travelStartAt = null;
        if (a.nextStateChange != null) {
          a.nextStateChange = max(
            time.t + Random().nextDoubleBetween(10 * 60, 60 * 60),
            a.nextStateChange!,
          );
        }
        if (a.targetLocation == AgentLocation.atRoom) {
          final room = building.rooms[a.roomLvl]![a.roomIndex];
          room.nPeopleInRoom += 1;
        }
      }
    }
    // Process all agents to leave elevator before processing all
    // to enter elevator.
    int occupancy = agentsOnElevator.length;
    for (var a in agents) {
      bool elevatorFull = occupancy >= elevator.capacity;
      if (elevatorFull) {
        break;
      }
      if (a.currentLocation == AgentLocation.waitOnElevator &&
          elevator.doorsOpen &&
          a.currentLvl == elevator.elevatorLvl) {
        // Enter elevator
        print('agent => agent enters elevator');
        a.currentLocation = AgentLocation.onElevator;
        occupancy += 1;
      }
    }
    elevator.occupancy = occupancy;
    // Update lateness
    for (var a in agents) {
      a.lateness = switch (tutorial.stage) {
        TutorialStage.elevators1Controls => AgentLateness.neutral,
        TutorialStage.elevators2Transport10 => AgentLateness.neutral,
        TutorialStage.elevators4Destinations => AgentLateness.neutral,
        TutorialStage.elevators5Late => a.getAgentLateness(
          time.t,
          fastLate: true,
        ),
        _ => a.getAgentLateness(time.t),
      };
    }
  }

  int outsideLevel(
    AgentData agent,
    BuildingState building,
    TutorialState tutorial,
  ) {
    if (![
      TutorialStage.done,
      TutorialStage.finalNotes,
    ].contains(tutorial.stage)) {
      return 0;
    }
    final carLevels = [];
    for (var lvl in building.rooms.keys) {
      if (building.rooms[lvl]!.firstWhereOrNull(
            (r) => r.roomDef.roomType == .garage,
          ) !=
          null) {
        carLevels.add(lvl);
      }
    }

    if (carLevels.isEmpty) {
      return 0;
    }

    // Probability to use car (if possible)
    double carRate = upgrades.contains(AgentUpgrade.carFreePolicy) ? 0.05 : 0.4;

    final List<int> choices = [0, ...carLevels];
    final List<double> weights = [
      1 - carRate,
      ...List<double>.generate(carLevels.length, (i) => 1 / carLevels.length),
    ];

    return randomChoice(choices, weights);
  }

  double scheduleNextArrival(TimeState time) {
    return (time.day + 1) * (24 * 3600) +
        Random().nextDoubleBetween(
          GameConsts.officeHoursStartFrom,
          GameConsts.officeHoursStartTo,
        );
  }

  double scheduleNextDeparture(TimeState time) {
    return (time.day) * (24 * 3600) +
        Random().nextDoubleBetween(
          GameConsts.officeHoursEndFrom,
          GameConsts.officeHoursEndTo,
        );
  }

  void installUpgrade(AgentUpgrade upgrade) {
    upgrades.add(upgrade);
  }

  /// Forcefully make one agent for each floor wait at the elevator.
  void tutorialPrepForTutorialStepBothFloors(
    TimeState time,
    BuildingState building,
  ) {
    final a1 = agents.firstWhereOrNull(
      ((a) => a.roomLvl == 1 && a.currentLocation != .onElevator),
    );
    final a2 = agents.firstWhereOrNull(
      ((a) => a.roomLvl == 2 && a.currentLocation != .onElevator),
    );

    final timeSpeed = time.timeOfDaySpeed;
    final delay = [5.0 * timeSpeed, 0.7 * timeSpeed];
    for (var a in [?a1, ?a2]) {
      if (a.currentLocation == .atRoom) {
        building.rooms[a.roomLvl]![a.roomIndex].nPeopleInRoom -= 1;
      }
      a.currentLocation = .outside;
      a.currentLvl = 0;
      a.targetLocation = .atRoom;
      a.targetLvl = a.roomLvl;
      a.nextStateChange = time.t + delay.removeLast();
    }
  }
}
