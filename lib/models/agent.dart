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
}
