import 'dart:math';

import 'package:elevate/game.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/overlays/widgets/double_slider_setting.dart';
import 'package:elevate/overlays/widgets/gamepad_axis_settings.dart';
import 'package:elevate/overlays/widgets/gamepad_button_setting.dart';
import 'package:elevate/utils/dialog_backdrop.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flutter/material.dart';

class SettingsOverlay extends StatelessWidget {
  final MyGame game;

  const SettingsOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    final settings = game.settingsState;

    final windowSize = game.camera.viewport.size;
    return DialogBackdrop(
      onBeforeGamepadIntent: (activator, intent) {
        return false;
      },
      child: AlertDialog(
        title: Text('Settings'),
        content: SizedBox(
          width: min(windowSize.x - mediumPadding * 2, 600),
          height: min(windowSize.y - mediumPadding * 2, 800),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _SectionTitle(child: Text('Audio')),
                    SliderSetting(
                      label: 'Game effects volume',
                      setting: settings.gameFxVolume,
                    ),
                    SliderSetting(
                      label: 'Music volume',
                      setting: settings.musicVolume,
                    ),
                    _SectionTitle(child: Text('Gamepad Controls')),
                    GamepadAxisSetting(
                      label: 'Elevator 1 up/down',
                      setting: settings.gamepadElevator1UpDownAxis,
                    ),
                    //GamepadAxisSetting(
                    //  label: 'Elevator 2 up/down',
                    //  setting: settings.gamepadElevator2UpDownAxis,
                    //),
                    GamepadButtonSetting(
                      label: 'Activate (A)',
                      setting: settings.gamepadActivateButton,
                    ),
                    GamepadButtonSetting(
                      label: 'Deselect (B)',
                      setting: settings.gamepadCancelButton,
                    ),
                    GamepadButtonSetting(
                      label: 'Dpad up',
                      setting: settings.gamepadDpadUp,
                    ),
                    GamepadButtonSetting(
                      label: 'Dpad right',
                      setting: settings.gamepadDpadRight,
                    ),
                    GamepadButtonSetting(
                      label: 'Dpad down',
                      setting: settings.gamepadDpadDown,
                    ),
                    GamepadButtonSetting(
                      label: 'Dpad left',
                      setting: settings.gamepadDpadLeft,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: close, child: Text('Close')),
        ],
      ),
    );
  }

  void close() {
    game.overlays.remove(GameOverlay.settings.name);
  }
}

class _SectionTitle extends StatelessWidget {
  final Widget child;
  const _SectionTitle({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: Theme.of(context).listTileTheme.copyWith(
        titleTextStyle: Theme.of(context).textTheme.titleLarge!,
      ),
      child: ListTile(title: child),
    );
  }
}
