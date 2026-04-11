import 'package:elevate/game.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/theme/theme.dart';
import 'package:elevate/utils/brightness_extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gamepads/flutter_gamepads.dart';

FocusNode rootFocusNode = FocusNode();

void main() {
  final theme = appTheme();
  runApp(
    GamepadControl(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: theme.brightness.inverted,
            systemNavigationBarContrastEnforced: false,
          ),
          child: Scaffold(
            body: GameWidget(
              game: MyGame(),
              focusNode: rootFocusNode,
              overlayBuilderMap: overlayBuilderMap,
              initialActiveOverlays: [],
            ),
          ),
        ),
      ),
    ),
  );
}
