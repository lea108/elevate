import 'package:collection/collection.dart';
import 'package:elevate/models/game_consts.dart';

enum AgentLocation {
  outside,
  atRoom,
  waitOnElevator,
  onElevator,
}

enum AgentLateness {
  neutral,
  late,
  veryLate,
}

class AgentData {
  final int roomLvl;
  final int roomIndex;

  int currentLvl = 0;
  double? nextStateChange = 0;
  double? travelStartAt;
  AgentLateness? lateness;

  AgentLocation currentLocation = .outside;
  AgentLocation targetLocation = .outside;
  int targetLvl = 0;

  double? getTravelTime(double t) =>
      travelStartAt != null ? t - travelStartAt! : null;
  AgentLateness getAgentLateness(double t, {bool fastLate = false}) {
    final tt = getTravelTime(t);
    final mod = fastLate ? 0.5 : 1.0;
    if (tt == null || tt < GameConsts.lateMinTime * mod) {
      return .neutral;
    }
    return tt < GameConsts.veryLateMinTime * mod ? .late : .veryLate;
  }

  AgentData(this.roomLvl, this.roomIndex);

  factory AgentData.fromJson(Map<String, dynamic> data) {
    final agentData = AgentData(data['roomLvl'], data['roomIndex']);
    agentData.currentLvl = data['currentLvl'];
    agentData.nextStateChange = data['nextStateChange'];
    agentData.travelStartAt = data['travelStartAt'];
    agentData.lateness = AgentLateness.values.firstWhereOrNull(
      (v) => v.name == data['lateness'],
    );
    agentData.currentLocation = AgentLocation.values.firstWhere(
      (v) => v.name == data['currentLocation'],
    );
    agentData.targetLocation = AgentLocation.values.firstWhere(
      (v) => v.name == data['targetLocation'],
    );
    agentData.targetLvl = data['targetLvl'];
    return agentData;
  }

  Map<String, dynamic> toJson() {
    return {
      'roomLvl': roomLvl,
      'roomIndex': roomIndex,
      'currentLvl': roomLvl,
      'nextStateChange': nextStateChange,
      'travelStartAt': travelStartAt,
      'lateness': lateness?.name,
      'currentLocation': currentLocation.name,
      'targetLocation': targetLocation.name,
      'targetLvl': targetLvl,
    };
  }
}
