import 'dart:async';

import 'package:elevate/models/state/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

class GamepadButtonSetting extends StatefulWidget {
  final String label;
  final ValueNotifier<GamepadButtonConfig> setting;
  const GamepadButtonSetting({
    required this.label,
    required this.setting,
    super.key,
  });

  @override
  State<GamepadButtonSetting> createState() => _GamepadButtonSettingState();
}

class _GamepadButtonSettingState extends State<GamepadButtonSetting> {
  bool edit = false;
  final List<StreamSubscription> _unsubscribe = [];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.label),
      trailing: buildTrailing(context),
      subtitle: edit
          ? Text('Press the desired button to record it')
          : Text(widget.setting.value.button.name),
    );
  }

  Widget buildTrailing(BuildContext context) {
    return edit
        ? ElevatedButton(
            onPressed: stopEdit,
            child: Text('Cancel'),
          )
        : ElevatedButton(
            onPressed: startEdit,
            child: Text('Select'),
          );
  }

  void startEdit() {
    setState(() => edit = true);
    _unsubscribe.add(Gamepads.normalizedEvents.listen(onGamepadEvent));
  }

  void stopEdit() {
    setState(() => edit = false);
    for (var u in _unsubscribe) {
      u.cancel();
    }
  }

  void onGamepadEvent(NormalizedGamepadEvent event) {
    if (edit && event.button != null && event.value > 0.5) {
      widget.setting.value = GamepadButtonConfig(event.button!);
      stopEdit();
    }
  }
}
