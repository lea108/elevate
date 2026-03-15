import 'package:collection/collection.dart';
import 'package:elevate/models/action_result.dart';
import 'package:elevate/models/state/agents_state.dart';
import 'package:elevate/models/state/elevator_state.dart';
import 'package:elevate/models/state/progression_state.dart';
import 'package:elevate/models/state/tutorial_state.dart';
import 'package:flutter/foundation.dart';

enum TechId {
  snapSpeed2,
  snapSpeed3,
  gotoFloor,
  capacity2,
  capacity3,
  capacity4,

  /// buttons in elevator to ask which level to go to, so you know where ppl want to go off
  inElevatorCarButtons,

  /// buttons for ppl to call if they want to go up/down
  levelUpDownButtons,

  /// makes ppl lateness progress slower while in the elevator
  elevatorMusic,
  extraCar1,

  /// Encourage ppl to drive less => fewer people will arrive via cars
  carFreePolicy,
}

const _capacity2 = 10;
const _capacity3 = 16;
const _capacity4 = 24;

class TechData {
  final TechId id;

  final String name;
  final String description;
  final String spriteName;

  final int cost;

  const TechData(
    this.id,
    this.name,
    this.spriteName,
    this.cost,
    this.description,
  );
}

class TechTreeState extends ChangeNotifier {
  final List<List<TechData>> techCatalog = [];

  final Set<TechId> activated = {};

  TechTreeState() {
    reset();
  }

  // dart format off
  void reset() {
    techCatalog.addAll([
      [
        TechData(TechId.inElevatorCarButtons,'In-elevator buttons', 'tech_in_elevator_buttons.png', 1, 'Add floor level buttons in the elevator so people can indicate which level they want to go to.'),
       // TechData(TechId.elevatorMusic,'Elevator music', 'tech_music.png', 2, 'Play music in the elevator to make people slower get late while in the elevator')
        TechData(TechId.levelUpDownButtons,'Up/down buttons', 'tech_up_down_buttons.png', 1, 'Add buttons on each floor to call the elevator and indicate if you want to go up or down.')
      ],
      [
        TechData(TechId.capacity2, 'Medium elevator', 'tech_capacity2.png', 3, 'Increase elevator car capacity to $_capacity2 ppl'),
        TechData(TechId.capacity3,'Large elevator', 'tech_capacity3.png', 10, 'Increase elevator car capacity to $_capacity3 ppl'),
        TechData(TechId.capacity4,'XL elevator', 'tech_capacity4.png', 20, 'Increase elevator car capacity to $_capacity4 ppl'),
      ],
      [
        TechData(TechId.snapSpeed2, 'Snap-2', 'tech_snap2.png', 2, 'Quicker snap to current level when you stop the elevator a bit off'),
        TechData(TechId.snapSpeed3, 'Snap-3', 'tech_snap3.png', 4, 'Even stronger snap to current level when you stop the elevator a bit off'),
        //TechData(TechId.gotoFloor, 'GoTo-Floor 3000', 'tech_goto.png', 4, 'Upgrade elevator control so you can tell which floor to goto and it will obey your orders.'),
      ],
      [TechData(TechId.carFreePolicy,'Car free policy', 'tech_car_free_policy.png', 5, 'Implement a car free policy causing fewer people to arrive by car.')],
      //[TechData(TechId.extraCar1,'+1 elevator car', 'tech_extra_car1.png', 8, 'Add another elevator car')],
    ]);
    activated.clear();
  }
  // dart format on

  TechData? resolveTechData(TechId? id) {
    for (var techLane in techCatalog) {
      for (var tech in techLane) {
        if (tech.id == id) {
          return tech;
        }
      }
    }
    return null;
  }

  bool isActivated(TechId id) {
    return activated.contains(id);
  }

  /// Check if tech items before given id in the same tech lane has been activated.
  bool canActivate(TechId id) {
    if (activated.contains(id)) {
      return false;
    }
    final techLane = techCatalog.firstWhereOrNull(
      (l) => l.firstWhereOrNull((t) => t.id == id) != null,
    );
    if (techLane == null) return false;
    final techIndex = techLane.indexWhere((t) => t.id == id);
    if (techIndex == -1) {
      return false;
    }
    final beforeActivated = techLane.foldIndexed<bool>(
      true,
      (i, prev, t) => prev && (i >= techIndex || activated.contains(t.id)),
    );
    return beforeActivated;
  }

  ActionResult activateTech(
    TechId id,
    ProgressionState progress,
    ElevatorState elevator,
    AgentsState agents,
    TutorialState tutorial,
  ) {
    final techLane = techCatalog.firstWhereOrNull(
      (l) => l.firstWhereOrNull((t) => t.id == id) != null,
    );
    if (techLane == null) {
      return ActionResult(false, 'Tech not found');
    }
    final techIndex = techLane.indexWhere((t) => t.id == id);
    if (techIndex == -1) {
      return ActionResult(false, 'Tech not found');
    }
    final unlocked = canActivate(id);
    if (!unlocked) {
      return ActionResult(false, 'Tech items before not activated');
    }
    final tech = techLane[techIndex];

    if (progress.techCoins < tech.cost) {
      return ActionResult(
        false,
        'Not enough tech coins earned to pay ${tech.cost}',
      );
    }

    final installResult = _installTech(tech, elevator, agents);
    if (installResult.success) {
      progress.techCoins -= tech.cost;
      activated.add(id);
      tutorial.recordTechUpgrade(id);
    }
    return installResult;
  }

  ActionResult _installTech(
    TechData tech,
    ElevatorState elevator,
    AgentsState agents,
  ) {
    try {
      switch (tech.id) {
        case TechId.snapSpeed2:
          elevator.installUpgrade(ElevatorUpgrade.snap2);
          return ActionResult(true);
        case TechId.snapSpeed3:
          elevator.installUpgrade(ElevatorUpgrade.snap3);
          return ActionResult(true);
        case TechId.gotoFloor:
          elevator.installUpgrade(ElevatorUpgrade.gotoFloor);
          return ActionResult(true);
        case TechId.capacity2:
          elevator.capacity = _capacity2;
          return ActionResult(true);
        case TechId.capacity3:
          elevator.capacity = _capacity3;
          return ActionResult(true);
        case TechId.capacity4:
          elevator.capacity = _capacity4;
          return ActionResult(true);
        case TechId.inElevatorCarButtons:
          elevator.installUpgrade(ElevatorUpgrade.inElevatorButtons);
          return ActionResult(true);
        case TechId.levelUpDownButtons:
          elevator.installUpgrade(ElevatorUpgrade.upDownButtons);
          return ActionResult(true);
        case TechId.elevatorMusic:
          elevator.installUpgrade(ElevatorUpgrade.elevatorMusic);
          return ActionResult(true);
        case TechId.extraCar1:
          throw UnimplementedError();
        case TechId.carFreePolicy:
          agents.installUpgrade(AgentUpgrade.carFreePolicy);
          return ActionResult(true);
      }
    } catch (_) {
      return ActionResult(false, 'Failed to install ${tech.name}');
    }
  }

  void update(double elapsed) {}
}
