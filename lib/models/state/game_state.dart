import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:elevate/main.dart';
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

class GameState {
  late final void Function(String overlay, bool active) _setOverlayActive;
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

  final AudioEffects _audioEffects;

  GameState(this._setOverlayActive, this._audioEffects) {
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
        _setOverlayActive(GameOverlay.endOfDayReport.name, true);
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
        _setOverlayActive(GameOverlay.elevatorTutorial.name, false);
        progressionState.buildingProgress = 0;
      }
    }

    lastTutorialStage = tutorialState.stage;
  }

  Map<String, dynamic> toJson() {
    final data = {
      'lastDay': lastDay,
      'lastTutorialStage': lastTutorialStage?.name,
      'time': timeState.toJson(),
      'building': buildingState.toJson(),
      'elevator': elevatorState.toJson(),
      'agents': agentsState.toJson(),
      'tutorial': tutorialState.toJson(),
      'progression': progressionState.toJson(),
      'techTree': techTreeState.toJson(),
    };
    return data;
  }

  bool applyJson(Map<String, dynamic> data, {bool restoreOnFail = true}) {
    final restoreData = restoreOnFail ? toJson() : null;
    try {
      lastDay = data['lastDay'];
      lastTutorialStage = TutorialStage.values.firstWhereOrNull(
        (v) => v.name == data['lastTutorialStage'],
      );
      timeState.applyJson(data['time']);
      inputState.reset();
      buildingState.applyJson(data['building']);
      elevatorState.applyJson(data['elevator']);
      agentsState.applyJson(data['agents']);
      tutorialState.applyJson(data['tutorial']);
      progressionState.applyJson(data['progression']);
      techTreeState.applyJson(data['techTree']);
      return true;
    } catch (e) {
      print('Persist error: $e');
    }

    if (restoreData != null) {
      applyJson(restoreData, restoreOnFail: false);
    } else {
      reset();
    }
    return false;
  }

  void persistAppState() {
    final jsonData = toJson();
    final payload = json.encode(jsonData);
    sharedPreferences.setString('appState', payload);
  }

  bool restoreAppState() {
    final payload = sharedPreferences.getString('appState');
    if (payload != null) {
      final jsonData = json.decode(payload);
      return applyJson(jsonData);
    }
    return false;
  }
}
