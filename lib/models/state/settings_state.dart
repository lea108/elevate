import 'package:flutter/foundation.dart';
import 'package:gamepads_platform_interface/api/gamepad_event.dart';

enum ControlsPreset {
  web,
  windows,
}

class AxisConfig {
  final String keyName;
  final bool flipAxis;

  const AxisConfig(this.keyName, this.flipAxis);

  double? readEvent(GamepadEvent event) {
    if (event.type == .analog && event.key == keyName) {
      return flipAxis ? event.value * -1 : event.value;
    }
    return null;
  }
}

class GamepadButtonConfig {
  final String keyName;

  const GamepadButtonConfig(this.keyName);

  bool? isPressed(GamepadEvent event) {
    if (event.type == .button && event.key == keyName) {
      return event.value > 0.9;
    }
    return null;
  }
}

class SettingsState {
  // elevator axises:
  ValueNotifier<AxisConfig> gamepadElevator1UpDownAxis = ValueNotifier(
    AxisConfig('analog 1', false),
  );
  ValueNotifier<AxisConfig> gamepadElevator2UpDownAxis = ValueNotifier(
    AxisConfig('analog 3', false),
  );
  // d-pad:
  ValueNotifier<GamepadButtonConfig> gamepadDpadUp = ValueNotifier(
    GamepadButtonConfig('button 1'),
  );
  ValueNotifier<GamepadButtonConfig> gamepadDpadRight = ValueNotifier(
    GamepadButtonConfig('button 2'),
  );
  ValueNotifier<GamepadButtonConfig> gamepadDpadDown = ValueNotifier(
    GamepadButtonConfig('button 3'),
  );
  ValueNotifier<GamepadButtonConfig> gamepadDpadLeft = ValueNotifier(
    GamepadButtonConfig('button 4'),
  );
  // activate/cancel:
  ValueNotifier<GamepadButtonConfig> gamepadActivateButton = ValueNotifier(
    GamepadButtonConfig('button 5'),
  );
  ValueNotifier<GamepadButtonConfig> gamepadCancelButton = ValueNotifier(
    GamepadButtonConfig('button 6'),
  );
  // audio
  ValueNotifier<double> gameFxVolume = ValueNotifier(0.15);
  ValueNotifier<double> musicVolume = ValueNotifier(0.25);

  void applyControlsPreset(ControlsPreset preset) {
    switch (preset) {
      case .windows:
        gamepadElevator1UpDownAxis.value = AxisConfig('leftThumbstickY', true);
        gamepadElevator2UpDownAxis.value = AxisConfig('rightThumbstickY', true);
        gamepadDpadUp.value = GamepadButtonConfig('dpadUp');
        gamepadDpadRight.value = GamepadButtonConfig('dpadRight');
        gamepadDpadDown.value = GamepadButtonConfig('dpadDown');
        gamepadDpadLeft.value = GamepadButtonConfig('dpadLeft');
        gamepadActivateButton.value = GamepadButtonConfig('a');
        gamepadCancelButton.value = GamepadButtonConfig('b');
        break;
      case .web:
        gamepadElevator1UpDownAxis.value = AxisConfig('analog 1', false);
        gamepadElevator2UpDownAxis.value = AxisConfig('analog 3', false);
        gamepadDpadUp.value = GamepadButtonConfig('button 12');
        gamepadDpadRight.value = GamepadButtonConfig('button 15');
        gamepadDpadDown.value = GamepadButtonConfig('button 13');
        gamepadDpadLeft.value = GamepadButtonConfig('button 14');
        gamepadActivateButton.value = GamepadButtonConfig('button 0');
        gamepadCancelButton.value = GamepadButtonConfig('button 1');
        break;
    }
  }
}
