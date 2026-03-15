import 'package:elevate/game.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

FocusNode rootFocusNode = FocusNode();

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: Scaffold(
        body: GameWidget(
          game: MyGame(),
          focusNode: rootFocusNode,
          overlayBuilderMap: overlayBuilderMap,
          initialActiveOverlays: [],
        ),
      ),
    ),
  );
}
