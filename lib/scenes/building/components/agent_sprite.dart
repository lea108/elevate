import 'dart:async';

import 'package:elevate/models/agent.dart';
import 'package:flame/components.dart';

enum AgentSpriteColor {
  black,
  white,
  orange,
  red
  ;

  factory AgentSpriteColor.fromLateness(AgentLateness lateness, bool invertNeutralColor) {
    return switch (lateness) {
      AgentLateness.neutral => invertNeutralColor ? AgentSpriteColor.white : AgentSpriteColor.black,
      AgentLateness.late => AgentSpriteColor.orange,
      AgentLateness.veryLate => AgentSpriteColor.red,
    };
  }
}

class AgentSprite extends SpriteComponent {
  AgentSpriteColor _color;
  AgentSprite([this._color = AgentSpriteColor.black]);

  set color(AgentSpriteColor value) {
    _color = value;
    updateSprite();
  }

  @override
  Future<void> onLoad() async {
    await updateSprite();
    super.onLoad();
  }

  Future<void> updateSprite() async {
    sprite = await Sprite.load('agent${_color.index + 1}.png');
  }
}
