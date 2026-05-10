import 'dart:math';

import 'package:elevate/models/agent.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:flutter/foundation.dart';

class EndOfDayReport {
  final int day;
  final int nTransported;
  final int nTransportedLate;
  final int nTransportedVeryLate;

  /// A value [-1, 1] describing how good the building economy is pre end-of-day effects.
  final double buildingEconomy;

  const EndOfDayReport(
    this.day,
    this.nTransported,
    this.nTransportedLate,
    this.nTransportedVeryLate,
    this.buildingEconomy,
  );

  factory EndOfDayReport.fromJson(Map<String, dynamic> data) {
    return EndOfDayReport(
      data['day'],
      data['nTransported'],
      data['nTransportedLate'],
      data['nTransportedVeryLate'],
      data['buildingEconomy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'nTransported': nTransported,
      'nTransportedLate': nTransportedLate,
      'nTransportedVeryLate': nTransportedVeryLate,
      'buildingEconomy': buildingEconomy,
    };
  }
}

class ProgressionState extends ChangeNotifier {
  late bool tutorial;

  late int nTransported;
  late int nTransportedLate;
  late int nTransportedVeryLate;

  late double techCoinProgress;
  late int techCoins;
  late double buildingProgress;

  /// When a new day occurs, stats of the past day is recorded in this report
  EndOfDayReport? endOfDayReport;

  ProgressionState() {
    reset();
  }

  void reset() {
    tutorial = true;

    nTransported = 0;
    nTransportedLate = 0;
    nTransportedVeryLate = 0;

    techCoinProgress = 0;
    techCoins = GameConsts.startTechCoins;

    buildingProgress = 0;
  }

  void recordTransported(AgentLateness lateness) {
    double techCoinValue = 1.0;
    double buildingValue = 1.0;
    nTransported += 1;
    switch (lateness) {
      case AgentLateness.neutral:
        break;
      case AgentLateness.late:
        nTransportedLate += 1;
        techCoinValue = 0.5;
        buildingValue = 0.4;
        break;
      case AgentLateness.veryLate:
        nTransportedVeryLate += 1;
        techCoinValue = -0.5;
        buildingValue = -0.8;
        break;
    }

    techCoinProgress = max(0, techCoinProgress + techCoinValue);
    if (techCoinProgress >= 10.0) {
      techCoins += 1;
      techCoinProgress -= 10.0;
    }

    buildingProgress = max(0, buildingProgress + buildingValue);

    notifyListeners();
  }

  void clearEndOfDayReport() {
    endOfDayReport = null;
    notifyListeners();
  }

  void update(double elapsed) {}

  void newDay(int lastDay) {
    endOfDayReport = EndOfDayReport(
      lastDay,
      nTransported,
      nTransportedLate,
      nTransportedVeryLate,
      _buildingEconomy,
    );
    nTransported = 0;
    nTransportedLate = 0;
    nTransportedVeryLate = 0;
    notifyListeners();
  }

  double get _buildingEconomy {
    final srcMin = -100.0;
    final srcMax = 100.0;

    return (buildingProgress.clamp(srcMin, srcMax) - srcMin) /
            (srcMax - srcMin) *
            2 -
        1;
  }

  void tutorialEnsureAtLeastOneTechCoin() {
    techCoins = max(1, techCoins);
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'tutorial': tutorial,
      'nTransported': nTransported,
      'nTransportedLate': nTransportedLate,
      'nTransportedVeryLate': nTransportedVeryLate,
      'techCoinProgress': techCoinProgress,
      'techCoins': techCoins,
      'buildingProgress': buildingProgress,
      'endOfDayReport': endOfDayReport?.toJson(),
    };
  }

  void applyJson(Map<String, dynamic> data) {
    tutorial = data['tutorial'];
    nTransported = data['nTransported'];
    nTransportedLate = data['nTransportedLate'];
    nTransportedVeryLate = data['nTransportedVeryLate'];
    techCoinProgress = data['techCoinProgress'];
    techCoins = data['techCoins'];
    buildingProgress = data['buildingProgress'];
    endOfDayReport = data['endOfDayReport'] != null
        ? EndOfDayReport.fromJson(data['endOfDayReport'])
        : null;
  }
}
