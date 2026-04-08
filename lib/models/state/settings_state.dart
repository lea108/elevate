import 'package:flutter/foundation.dart';
import 'package:gamepads/gamepads.dart';

class AxisConfig {
  final GamepadAxis axis;
  final bool flipAxis;

  const AxisConfig(this.axis, this.flipAxis);

  double? readEvent(NormalizedGamepadEvent event) {
    if (event.axis == axis) {
      return flipAxis ? event.value * -1 : event.value;
    }
    return null;
  }
}

class GamepadButtonConfig {
  final GamepadButton button;

  const GamepadButtonConfig(this.button);

  bool? isPressed(NormalizedGamepadEvent event) {
    if (event.button == button) {
      return event.value > 0.9;
    }
    return null;
  }
}

class SettingsState {
  // elevator axises:
  ValueNotifier<AxisConfig> gamepadElevator1UpDownAxis = ValueNotifier(
    AxisConfig(GamepadAxis.leftStickY, true),
  );
  ValueNotifier<AxisConfig> gamepadElevator2UpDownAxis = ValueNotifier(
    AxisConfig(GamepadAxis.rightStickY, true),
  );
  // d-pad:
  ValueNotifier<GamepadButtonConfig> gamepadDpadUp = ValueNotifier(
    GamepadButtonConfig(GamepadButton.dpadUp),
  );
  ValueNotifier<GamepadButtonConfig> gamepadDpadRight = ValueNotifier(
    GamepadButtonConfig(GamepadButton.dpadRight),
  );
  ValueNotifier<GamepadButtonConfig> gamepadDpadDown = ValueNotifier(
    GamepadButtonConfig(GamepadButton.dpadDown),
  );
  ValueNotifier<GamepadButtonConfig> gamepadDpadLeft = ValueNotifier(
    GamepadButtonConfig(GamepadButton.dpadLeft),
  );
  // activate/cancel:
  ValueNotifier<GamepadButtonConfig> gamepadActivateButton = ValueNotifier(
    GamepadButtonConfig(GamepadButton.a),
  );
  ValueNotifier<GamepadButtonConfig> gamepadCancelButton = ValueNotifier(
    GamepadButtonConfig(GamepadButton.b),
  );
  // audio
  ValueNotifier<double> gameFxVolume = ValueNotifier(0.15);
  ValueNotifier<double> musicVolume = ValueNotifier(0.25);
}
