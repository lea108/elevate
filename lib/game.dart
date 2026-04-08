import 'dart:async';
import 'dart:math';

import 'package:elevate/models/audio_effects.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/music_composer.dart';
import 'package:elevate/models/state/game_state.dart';
import 'package:elevate/models/state/settings_state.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/router.dart';
import 'package:elevate/scenes/scenes.dart';
import 'package:elevate/utils/overlay_manager_extension.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:gamepads/gamepads.dart';

class MyGame extends FlameGame with TapCallbacks, HasKeyboardHandlerComponents {
  late final RouterComponent router;
  late final GameState gameState;
  late final SettingsState settingsState;
  late final MusicComposer musicComposer;
  late final AudioEffects audioEffects;
  final List<StreamSubscription> unsubscribe = [];

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    settingsState = SettingsState();
    settingsState.applyControlsPreset(
      kIsWeb ? ControlsPreset.web : ControlsPreset.windows,
    );
    audioEffects = AudioEffects();
    gameState = GameState(overlays, audioEffects);
    musicComposer = MusicComposer();
    router = createRouter();
    add(router);

    unsubscribe.add(Gamepads.events.listen(onGamepadEvent));
    settingsState.musicVolume.addListener(onMusicVolumeChange);
    settingsState.gameFxVolume.addListener(onEffectsVolumeChange);
    onMusicVolumeChange();
    onEffectsVolumeChange();

    changeScene(GameConsts.skipIntro ? GameScene.building : GameScene.intro);
  }

  @override
  Future<void> onRemove() async {
    await musicComposer.dispose();
    super.onRemove();
  }

  @override
  void onDispose() {
    settingsState.musicVolume.removeListener(onMusicVolumeChange);
    for (var u in unsubscribe) {
      u.cancel();
    }
    super.onDispose();
  }

  void onGamepadEvent(GamepadEvent event) {}

  bool get hasOpenMenu {
    final activeOverlays = overlays.activeOverlays.toSet();
    final menuOverlays = {
      GameOverlay.endOfDayReport.name,
      GameOverlay.inGameMenu.name,
      GameOverlay.settings.name,
      GameOverlay.techTree.name,
    };
    return activeOverlays.intersection(menuOverlays).isNotEmpty;
  }

  @override
  void update(double dt) {
    musicComposer.update(dt, gameState.elevatorState.elevatorFloorRatio);

    if (router.isMounted && router.currentRoute.name == RouteId.building.name) {
      gameState.update(dt, hasOpenMenu);
    }

    super.update(dt);
  }

  Future<void> changeScene(GameScene scene) async {
    final route = switch (scene) {
      GameScene.intro => RouteId.intro,
      GameScene.building => RouteId.building,
    };

    if (router.isMounted) {
      router.pushReplacementNamed(route.name);
    }

    overlays.setVisible(GameOverlay.intro.name, scene == GameScene.intro);
    overlays.setVisible(
      GameOverlay.gameStatusbar.name,
      scene == GameScene.building,
    );
    overlays.setVisible(
      GameOverlay.elevatorTutorial.name,
      scene == GameScene.building,
    );
    overlays.setVisible(
      GameOverlay.touchControl.name,
      scene == GameScene.building,
    );

    if (scene != GameScene.building) {
      overlays.remove(GameOverlay.gameStatusbar.name);
      overlays.remove(GameOverlay.endOfDayReport.name);
      overlays.remove(GameOverlay.techTree.name);
      overlays.remove(GameOverlay.inGameMenu.name);
      overlays.remove(GameOverlay.settings.name);
    }
  }

  void restart() {
    changeScene(GameScene.intro);
    gameState.reset();
  }

  void onMusicVolumeChange() {
    musicComposer.setVolume(settingsState.musicVolume.value);
  }

  void onEffectsVolumeChange() {
    audioEffects.setVolume(settingsState.gameFxVolume.value);
  }
}
