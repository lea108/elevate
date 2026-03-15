
import 'dart:async';

import 'package:elevate/models/agent.dart';
import 'package:flame/components.dart';

class Agent extends SpriteComponent {

  AgentData data;

  Agent(this.data);


  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('agent1.png');
    super.onLoad();
  }

  @override
  void update(double dt) {

    final visible = [AgentLocation.atRoom, AgentLocation.outside, AgentLocation.onElevator].contains(data.currentLocation);

    opacity = visible ? 0 : 1;
    if (visible) {
    }


    super.update(dt);
  }

}