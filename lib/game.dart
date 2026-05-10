import 'dart:async';

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
import 'package:flutter/widgets.dart';

class MyGame extends FlameGame
    with TapCallbacks, HasKeyboardHandlerComponents, WidgetsBindingObserver {
  bool _initialized = false;
  late final RouterComponent router;
  late final GameState gameState;
  late final SettingsState settingsState;
  late final MusicComposer musicComposer;
  late final AudioEffects audioEffects;

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    settingsState = SettingsState();
    audioEffects = AudioEffects();
    gameState = GameState(overlays, audioEffects);
    musicComposer = MusicComposer();
    router = createRouter();
    add(router);

    settingsState.musicVolume.addListener(onMusicVolumeChange);
    settingsState.gameFxVolume.addListener(onEffectsVolumeChange);
    onMusicVolumeChange();
    onEffectsVolumeChange();

    changeScene(GameConsts.skipIntro ? GameScene.building : GameScene.intro);

    _initialized = true;
    _lifecycleRestore();
  }

  @override
  Future<void> onRemove() async {
    await musicComposer.dispose();
    super.onRemove();
  }

  @override
  void onDispose() {
    settingsState.musicVolume.removeListener(onMusicVolumeChange);
    super.onDispose();
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    if (!_initialized) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _lifecycleRestore();
    } else {
      _lifecycleClosed();
    }
  }

  void _lifecycleRestore() {
    resumeEngine();
    musicComposer.setVolume(settingsState.musicVolume.value);
    audioEffects.setVolume(settingsState.gameFxVolume.value);
    if (gameState.restoreAppState()) {
      gameState.update(0, hasOpenMenu);
      if (router.isMounted && !isBuildingSceneActive) {
        changeScene(GameScene.building);
      }
    }
  }

  void _lifecycleClosed() {
    gameState.persistAppState();
    musicComposer.setVolume(0);
    audioEffects.setVolume(0);
    pauseEngine();
  }

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

  bool get isBuildingSceneActive =>
      router.isMounted && router.currentRoute.name == RouteId.building.name;

  @override
  void update(double dt) {
    musicComposer.update(dt, gameState.elevatorState.elevatorFloorRatio);

    if (isBuildingSceneActive) {
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
      GameOverlay.touchControl.name,
      scene == GameScene.building,
    );
    overlays.setVisible(
      GameOverlay.elevatorTutorial.name,
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
