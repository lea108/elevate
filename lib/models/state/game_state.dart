import 'dart:math';

import 'package:elevate/models/audio_effects.dart';
import 'package:elevate/models/state/agents_state.dart';
import 'package:elevate/models/state/building_state.dart';
import 'package:elevate/models/state/elevator_state.dart';
import 'package:elevate/models/state/input_state.dart';
import 'package:elevate/models/state/progression_state.dart';
import 'package:elevate/models/state/tech_tree_state.dart';
import 'package:elevate/models/state/time_state.dart';
import 'package:elevate/models/state/tutorial_state.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:flame/game.dart';
import 'package:flame/src/game/overlay_manager.dart';

class GameState {
  late OverlayManager _overlays;
  late TimeState timeState;
  late InputState inputState;
  late BuildingState buildingState;
  late ElevatorState elevatorState;
  late AgentsState agentsState;
  late TutorialState tutorialState;
  late ProgressionState progressionState;
  late TechTreeState techTreeState;

  TutorialStage? lastTutorialStage;
  late int lastDay;

  AudioEffects _audioEffects;

  GameState(this._overlays, this._audioEffects) {
    reset();
  }

  void reset() {
    timeState = TimeState();
    inputState = InputState();
    buildingState = BuildingState();
    elevatorState = ElevatorState();
    agentsState = AgentsState();
    tutorialState = TutorialState();
    progressionState = ProgressionState();
    techTreeState = TechTreeState();

    buildingState.createBuilding(tutorialState);
    agentsState.createAgents(buildingState, timeState);

    lastDay = timeState.day;
  }

  void update(double dt, bool hasOpenMenu) {
    final active = agentsState.activeGamePlay || !elevatorState.doorsOpen;
    final elapsed = timeState.update(dt, active, hasOpenMenu);
    buildingState.update(elapsed, timeState);
    elevatorState.update(elapsed, timeState);
    agentsState.update(
      elapsed,
      timeState,
      elevatorState,
      buildingState,
      tutorialState,
      progressionState,
    );
    tutorialState.update(elapsed);
    progressionState.update(elapsed);
    techTreeState.update(elapsed);

    if (timeState.day != lastDay) {
      progressionState.newDay(lastDay);
      buildingState.newDay(
        lastDay,
        progressionState,
        elevatorState,
        tutorialState,
      );
      agentsState.createAgents(buildingState, timeState);
      lastDay = timeState.day;
    }

    if (progressionState.endOfDayReport != null) {
      if ([
        TutorialStage.done,
        TutorialStage.finalNotes,
      ].contains(tutorialState.stage)) {
        _overlays.add(GameOverlay.endOfDayReport.name);
      } else {
        // just ignore the report during tutorial
        progressionState.endOfDayReport = null;
      }
    }
    if (tutorialState.stage != lastTutorialStage) {
      if (tutorialState.stage == .elevators3TechTree) {
        progressionState.tutorialEnsureAtLeastOneTechCoin();
      }
      if (tutorialState.stage == .elevators4Destinations) {
        // Get the upgrade even if user skipped
        if (!techTreeState.activated.contains(TechId.inElevatorCarButtons)) {
          progressionState.tutorialEnsureAtLeastOneTechCoin();
          techTreeState.activateTech(
            TechId.inElevatorCarButtons,
            progressionState,
            elevatorState,
            agentsState,
            tutorialState,
          );
        }
        // After tutorial stage 3 was accomplished, find tenants
        // for the "for rent" offices.
        buildingState.tutorialRentOutUnrentedOffices();
        agentsState.createAgents(buildingState, timeState);
        agentsState.tutorialPrepForTutorialStepBothFloors(
          timeState,
          buildingState,
        );
      }
      if (tutorialState.stage == .finalNotes) {
        // People can forget to close the tutorial, so the actual game mechanics starts at the final notes step
        progressionState.buildingProgress = 25;
      }
      if (tutorialState.stage == .done) {
        _overlays.remove(GameOverlay.elevatorTutorial.name);
        progressionState.buildingProgress = 0;
      }
    }

    lastTutorialStage = tutorialState.stage;
  }
}
