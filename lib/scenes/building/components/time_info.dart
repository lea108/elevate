import 'dart:async';

import 'package:elevate/game.dart';
import 'package:elevate/utils/format.dart';
import 'package:flame/components.dart';

class TimeInfo extends TextComponent with HasGameReference<MyGame> {
  TimeInfo() : super(text: 'Time: 0, day: 0');

  @override
  void update(double dt) {
    final t = formatTimeOfDay(game.gameState.timeState.timeOfDay);
    text = 'Time $t day: ${game.gameState.timeState.day + 1}';

    super.update(dt);
  }
}
