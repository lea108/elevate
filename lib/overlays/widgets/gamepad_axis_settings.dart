import 'dart:async';

import 'package:elevate/models/state/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

class GamepadAxisSetting extends StatefulWidget {
  final String label;
  final ValueNotifier<AxisConfig> setting;
  const GamepadAxisSetting({
    required this.label,
    required this.setting,
    super.key,
  });

  @override
  State<GamepadAxisSetting> createState() => _GamepadAxisSettingState();
}

class _GamepadAxisSettingState extends State<GamepadAxisSetting> {
  bool edit = false;
  final List<StreamSubscription> _unsubscribe = [];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.label),
      trailing: buildTrailing(context),
      subtitle: edit
          ? Text('Drag the desired stick upwards to record the axis correctly.')
          : Text(
              '${widget.setting.value.axis.name} - ${widget.setting.value.flipAxis ? 'flip' : 'no flip'}',
            ),
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
    // require a high value to not use cross axis false positive
    if (edit && event.axis != null && event.value.abs() > 0.7) {
      widget.setting.value = AxisConfig(event.axis!, event.value > 0);
      stopEdit();
    }
  }
}
