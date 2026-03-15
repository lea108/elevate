import 'dart:async';
import 'dart:ui';

import 'package:elevate/game.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Grass extends PositionComponent with HasGameReference<MyGame> {
  SpriteBatch? _batch;

  @override
  Future<void> onLoad() async {
    final image = await Images().load('grass.png');
    _batch = SpriteBatch(image);

    for (int x = 0; x < size.x; x += image.width) {
      _batch?.add(
        source: Rect.fromLTWH(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        offset: Vector2(x.toDouble(), size.y - image.height),
      );
    }

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final skyColor = game.gameState.timeState.skyColor;
    final double darkness = skyColor.computeLuminance();
    final shade = lerpDouble(0.35, 1.2, darkness)!.clamp(0, 1);

    final paint = Paint()
      ..colorFilter = ColorFilter.mode(
        Color.fromARGB(
          255,
          (255 * shade).round(),
          (255 * shade).round(),
          (255 * shade).round(),
        ),

        BlendMode.modulate,
      );

    _batch?.render(canvas, paint: paint);
  }
}
