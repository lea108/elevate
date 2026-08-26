import 'package:elevate/game.dart';
import 'package:elevate/models/furniture_defs.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/theme/theme.dart';
import 'package:elevate/utils/brightness_extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gamepads/flutter_gamepads.dart';
import 'package:shared_preferences/shared_preferences.dart';

FocusNode rootFocusNode = FocusNode();

late final SharedPreferencesWithCache sharedPreferences;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferencesWithCache.create(
    cacheOptions: .new(),
  );
  final theme = appTheme();

  // Load furniture sprites
  furnitureDefs.forEach((fid, fdef) {
    Sprite.load(fdef.spriteName).then((s) {
      furnitureSprites[fid] = s;
    });
  });

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
