import 'package:flutter/material.dart';

class SliderSetting extends StatelessWidget {
  final String label;
  final double min;
  final double max;
  final ValueNotifier<double> setting;
  const SliderSetting({
    required this.label,
    required this.setting,
    this.min = 0.0,
    this.max = 1.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: ValueListenableBuilder(
        valueListenable: setting,
        builder: (context, value, child) {
          return Slider(
            value: setting.value,
            onChanged: changed,
          );
        },
      ),
    );
  }

  void changed(double? value) {
    if (value != null) {
      setting.value = value;
    }
  }
}
