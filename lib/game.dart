import 'dart:async';

import 'package:collection/collection.dart';
import 'package:elevate/main.dart';
import 'package:elevate/models/audio_effects.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/models/music_composer.dart';
import 'package:elevate/models/state/game_state.dart';
import 'package:elevate/models/state/settings_state.dart';
import 'package:elevate/models/state/tutorial_state.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/router.dart';
import 'package:elevate/scenes/scenes.dart';
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

  ValueNotifier<bool> enginePaused = ValueNotifier(false);

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    settingsState = SettingsState();
    audioEffects = AudioEffects();
    gameState = GameState(
      (overlay, active) => overlays.setActive(overlay, active: active),
      audioEffects,
    );
    musicComposer = MusicComposer();
    final initialScene =
        _readPersistedScene() ??
        (GameConsts.skipIntro ? GameScene.building : GameScene.intro);
    router = createRouter(initialRoute: initialScene.route);
    add(router);

    settingsState.musicVolume.addListener(onMusicVolumeChange);
    settingsState.gameFxVolume.addListener(onEffectsVolumeChange);
    onMusicVolumeChange();
    onEffectsVolumeChange();

    _initialized = true;
    // Restore state
    _lifecycleRestore();

    await changeScene(initialScene);
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
  Future<void> lifecycleStateChange(AppLifecycleState state) async {
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
    enginePaused.value = false;
    musicComposer.setVolume(settingsState.musicVolume.value);
    audioEffects.setVolume(settingsState.gameFxVolume.value);
    if (gameState.restoreAppState()) {
      gameState.update(0, hasOpenMenu);
    }
  }

  void _lifecycleClosed() {
    gameState.persistAppState();
    musicComposer.setVolume(0);
    audioEffects.setVolume(0);
    _persistScene();
    enginePaused.value = true;
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

  RouteId? get currentRoute => router.isMounted
      ? RouteId.values.firstWhereOrNull(
          (v) => v.name == router.currentRoute.name,
        )
      : null;

  GameScene? get currentScene => switch (currentRoute) {
    RouteId.building => GameScene.building,
    RouteId.intro => GameScene.intro,
    _ => null,
  };

  @override
  void update(double dt) {
    musicComposer.update(dt, gameState.elevatorState.elevatorFloorRatio);

    if (isBuildingSceneActive) {
      gameState.update(dt, hasOpenMenu);
    }

    super.update(dt);
  }

  Future<void> changeScene(GameScene scene) async {
    final route = scene.route;
    if (router.isMounted && router.currentRoute.name != route.name) {
      router.pushReplacementNamed(route.name);
    }

    overlays.setActive(
      GameOverlay.intro.name,
      active: scene == GameScene.intro,
    );
    overlays.setActive(
      GameOverlay.gameStatusbar.name,
      active: scene == GameScene.building,
    );
    overlays.setActive(
      GameOverlay.touchControl.name,
      active: scene == GameScene.building,
    );
    overlays.setActive(
      GameOverlay.elevatorTutorial.name,
      active:
          scene == GameScene.building &&
          gameState.tutorialState.stage != TutorialStage.done,
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

  void _persistScene() {
    sharedPreferences.setString('appScene', currentScene?.name ?? '');
  }

  GameScene? _readPersistedScene() {
    final persistedScene = sharedPreferences.getString('appScene');
    return GameScene.values.firstWhereOrNull(
      (v) => v.name == persistedScene,
    );
  }
}
