import 'package:elevate/game.dart';
import 'package:elevate/overlays/elevator_tutorial_overlay.dart';
import 'package:elevate/overlays/end_of_day_report_overlay.dart';
import 'package:elevate/overlays/game_statusbar_overlay.dart';
import 'package:elevate/overlays/in_game_menu_overlay.dart';
import 'package:elevate/overlays/intro_overlay.dart';
import 'package:elevate/overlays/settings_overlay.dart';
import 'package:elevate/overlays/tech_tree_overlay.dart';
import 'package:elevate/overlays/touch_control_overlay.dart';
import 'package:flutter/widgets.dart';

enum GameOverlay {
  intro,
  gameStatusbar,
  elevatorTutorial,
  inGameMenu,
  endOfDayReport,
  techTree,
  settings,
  touchControl,
}

Map<String, Widget Function(BuildContext context, MyGame game)>
overlayBuilderMap = {
  GameOverlay.intro.name: (context, MyGame game) => IntroOverlay(),
  GameOverlay.gameStatusbar.name: (context, MyGame game) =>
      GameStatusbarOverlay(game),
  GameOverlay.elevatorTutorial.name: (context, MyGame game) =>
      ElevatorTutorialOverlay(game),
  GameOverlay.inGameMenu.name: (context, MyGame game) =>
      InGameMenuOverlay(game),
  GameOverlay.settings.name: (context, MyGame game) => SettingsOverlay(game),
  GameOverlay.endOfDayReport.name: (context, MyGame game) =>
      EndOfDayReportOverlay(game),
  GameOverlay.techTree.name: (context, MyGame game) => TechTreeOverlay(game),
  GameOverlay.touchControl.name: (context, MyGame game) =>
      TouchControlOverlay(game),
};
