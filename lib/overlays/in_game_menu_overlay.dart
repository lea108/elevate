import 'package:collection/collection.dart';
import 'package:elevate/game.dart';
import 'package:elevate/models/game_consts.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/overlays/widgets/overlay_gamepad_control.dart';
import 'package:elevate/theme/palette.dart';
import 'package:elevate/utils/dialog_backdrop.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InGameMenuOverlay extends StatelessWidget {
  final MyGame game;

  const InGameMenuOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return DialogBackdrop(
      child: Align(
        alignment: .center,
        child: OverlayGamepadControl(
          game: game,
          overlay: GameOverlay.inGameMenu,
          child: AlertDialog(
            title: Center(child: Text('Menu')),
            actionsAlignment: MainAxisAlignment.center,
            content: Column(
              mainAxisSize: .min,
              children:
                  [
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: techTree,
                          child: Text('Tech tree'),
                        ),
                        TextButton(
                          onPressed: settings,
                          child: Text('Settings'),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: restartGame,
                          child: Text('Restart Game'),
                        ),
                        TextButton(
                          onPressed: github,
                          child: Text('GitHub'),
                        ),
                      ]
                      .mapIndexed(
                        (i, btn) => i > 0
                            ? Padding(
                                padding: EdgeInsetsGeometry.only(
                                  top: mediumPadding,
                                ),
                                child: btn,
                              )
                            : btn,
                      )
                      .toList(),
            ),
            actions: [
              TextButton(onPressed: () => close(), child: Text('Close')),
            ],
          ),
        ),
      ),
    );
  }

  void settings() {
    game.overlays.add(GameOverlay.settings.name);
    close();
  }

  void techTree() {
    game.overlays.add(GameOverlay.techTree.name);
    close();
  }

  void restartGame() {
    game.restart();
    close();
  }

  void github() {
    launchUrlString(GameConsts.githubUrl);
  }

  void close() {
    game.overlays.remove(GameOverlay.inGameMenu.name);
  }
}
