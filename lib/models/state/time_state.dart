import 'dart:math';
import 'dart:ui';

import 'package:elevate/utils/sky_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TimeState extends ChangeNotifier {
  late bool _menuPaused;
  late double gameSpeed;
  late double timeOfDaySpeed;

  /// Accumulated game time
  late double t;

  /// Seconds since midnight
  late double timeOfDay;
  late int day;

  late double lastActiveGamePlay;

  late Color skyColor;

  TimeState() {
    reset();
  }

  void reset() {
    _menuPaused = false;
    gameSpeed = 60.0;
    timeOfDaySpeed = 5 * 60.0;
    t = 0;
    timeOfDay = 0;
    day = 0;
    lastActiveGamePlay = 0;
    skyColor = Colors.transparent;
  }

  bool get paused => _menuPaused;
  bool get fastForward {
    const debugFF = false;
    bool autoFF = debugFF || t > lastActiveGamePlay + 60;

    return autoFF || timeOfDay > 22 * 3600 || timeOfDay < 6 * 3600;
  }

  double resolveTimeOfDaySpeed() {
    if (paused) {
      return 0.0;
    }
    return fastForward ? 60 * 60 : 5 * 60;
  }

  /// [activeGamePlay] is true when there is active simulation or the elevator is in movement
  double update(double dt, bool activeGamePlay, bool menusOpen) {
    _menuPaused = menusOpen;
    if (activeGamePlay) {
      lastActiveGamePlay = t;
    }
    timeOfDaySpeed = resolveTimeOfDaySpeed();
    final elapsed = min(dt * timeOfDaySpeed, 0.1 * timeOfDaySpeed);
    t += elapsed;
    timeOfDay += elapsed;
    if (timeOfDay >= 24 * 3600) {
      timeOfDay = 0;
      day += 1;
    }
    skyColor = resolveSkyColor(timeOfDay);
    timeOfDaySpeed = resolveTimeOfDaySpeed();
    notifyListeners();
    return elapsed;
  }
}
