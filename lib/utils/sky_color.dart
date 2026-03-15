
import 'package:flutter/material.dart';

class SkyColor {
  final double t;
  final Color color;

  const SkyColor(this.t, this.color);
}

  const skyGradient = [
    SkyColor(1.00, Color.fromARGB(255, 38, 41, 53)), // night
    SkyColor(0.20, Color.fromARGB(255, 46, 54, 80)), // night
    SkyColor(0.25, Color.fromARGB(255, 153, 87, 99)), // twilight
    SkyColor(0.30, Color.fromARGB(255, 157, 216, 240)), // morning
    SkyColor(0.50, Color.fromARGB(255, 201, 231, 243)), // morning
    SkyColor(0.70, Color.fromARGB(255, 154, 206, 226)), // day
    SkyColor(0.75, Color.fromARGB(255, 85, 156, 184)), // day
    SkyColor(0.80, Color.fromARGB(255, 136, 87, 98)), // sunset
    SkyColor(0.85, Color.fromARGB(255, 32, 46, 90)), // night
    SkyColor(1.00, Color.fromARGB(255, 38, 41, 53)), // night
  ];

Color resolveSkyColor(double timeOfDay) {
    const dayLen = 3600 * 24;
    final t = timeOfDay / dayLen; // [0, 1]

    for (int i = 0; i < skyGradient.length - 1; i += 1) {
      final a = skyGradient[i];
      final b = skyGradient[i + 1];
      if (t >= a.t && t <= b.t) {
        final localT = (t - a.t) / (b.t - a.t);
        return Color.lerp(a.color, b.color, localT)!;
      }
    }

    return skyGradient.last.color;
}