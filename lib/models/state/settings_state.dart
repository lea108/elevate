import 'dart:convert';

import 'package:elevate/main.dart';
import 'package:flutter/foundation.dart';
import 'package:gamepads/gamepads.dart';

class GamepadAxisConfig {
  final GamepadAxis axis;
  final bool flipAxis;

  const GamepadAxisConfig(this.axis, this.flipAxis);

  factory GamepadAxisConfig.fromJson(Map<String, dynamic> data) {
    return GamepadAxisConfig(
      GamepadAxis.values.firstWhere((v) => v.name == data['a']),
      data['f'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'a': axis.name,
      'f': flipAxis,
    };
  }

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

  factory GamepadButtonConfig.fromJson(Map<String, dynamic> data) {
    return GamepadButtonConfig(
      GamepadButton.values.firstWhere((v) => v.name == data['a']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'b': button.name,
    };
  }

  bool? isPressed(NormalizedGamepadEvent event) {
    if (event.button == button) {
      return event.value > 0.9;
    }
    return null;
  }
}

class SettingsState {
  // elevator axises:
  ValueNotifier<GamepadAxisConfig> gamepadElevator1UpDownAxis = ValueNotifier(
    GamepadAxisConfig(GamepadAxis.leftStickY, true),
  );
  ValueNotifier<GamepadAxisConfig> gamepadElevator2UpDownAxis = ValueNotifier(
    GamepadAxisConfig(GamepadAxis.rightStickY, true),
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

  SettingsState() {
    _load();
    _settingsMap.forEach((key, state) {
      state.addListener(onChange);
    });
  }

  void onChange() {
    _persist();
  }

  late final _settingsMap = {
    'gamepadElevator1UpDown': gamepadElevator1UpDownAxis,
    'gamepadElevator2UpDown': gamepadElevator2UpDownAxis,
    'gamepadDpadUp': gamepadDpadUp,
    'gamepadDpadRight': gamepadDpadRight,
    'gamepadDpadDown': gamepadDpadDown,
    'gamepadDpadLeft': gamepadDpadLeft,
    'gamepadActivateButton': gamepadActivateButton,
    'gamepadCancelButton': gamepadCancelButton,
    'gameFxVolume': gameFxVolume,
    'musicVolume': gameFxVolume,
  };

  void _load() {
    final payload = sharedPreferences.getString('settings');
    if (payload == null) {
      return;
    }
    final data = json.decode(payload);
    _settingsMap.forEach((key, state) {
      switch (state) {
        case ValueNotifier<GamepadAxisConfig> axisConfig:
          axisConfig.value = GamepadAxisConfig.fromJson(data[key]);
          break;
        case ValueNotifier<GamepadButtonConfig> buttonConfig:
          buttonConfig.value = GamepadButtonConfig.fromJson(data[key]);
          break;
        case ValueNotifier<double> doubleConfig:
          doubleConfig.value = data[key];
      }
    });
  }

  void _persist() {
    Map<String, dynamic> data = {};
    _settingsMap.forEach((key, state) {
      switch (state) {
        case ValueNotifier<GamepadAxisConfig> axisConfig:
          data[key] = axisConfig.value.toJson();
          break;
        case ValueNotifier<GamepadButtonConfig> buttonConfig:
          data[key] = buttonConfig.value.toJson();
          break;
        case ValueNotifier<double> doubleConfig:
          data[key] = doubleConfig;
          break;
      }
    });
    sharedPreferences.setString('settings', json.encode(data));
  }
}
