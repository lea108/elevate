import 'dart:async';
import 'dart:math';

import 'package:elevate/game.dart';
import 'package:elevate/models/agent.dart';
import 'package:elevate/models/projection.dart';
import 'package:elevate/scenes/building/components/agent.dart';
import 'package:elevate/scenes/building/components/agent_sprite.dart';
import 'package:flame/components.dart';

class ElevatorQueue extends PositionComponent with HasGameReference<MyGame> {
  final int lvl;
  final List<AgentData> _queue = [];
  final List<AgentSprite> _sprites = [];

  ElevatorQueue(this.lvl);

  set queue(List<AgentData> value) {
    if (value != _queue) {
      _queue.replaceRange(0, _queue.length, value);

      final List<Component> removeComponents = [];
      final List<Component> addComponents = [];

      while (_sprites.length > _queue.length) {
        final component = _sprites.removeLast();
        removeComponents.add(component);
      }
      while (_sprites.length < _queue.length) {
        final component = AgentSprite()..size = Vector2(xScale, yScale);
        addComponents.add(component);
        _sprites.add(component);
      }

      for (var i = 0; i < _sprites.length; i += 1) {
        final lateness = _queue[i].lateness ?? AgentLateness.neutral;
        _sprites[i].position = Vector2((1 + i) * xScale, 0);
        _sprites[i].color = AgentSpriteColor.fromLateness(lateness, false);
      }

      removeAll(removeComponents);
      addAll(addComponents);
    }
  }

  @override
  FutureOr<void> onLoad() {
    return super.onLoad();
  }

  @override
  void update(double dt) {
    final newQueue = game.gameState.agentsState.agents
        .where(
          (a) =>
              a.currentLvl == lvl &&
              a.currentLocation == AgentLocation.waitOnElevator,
        )
        .toList();
    newQueue.sort(
      (a, b) => (b.lateness?.index ?? 0) - (a.lateness?.index ?? 0),
    );
    queue = newQueue;

    super.update(dt);
  }
}
