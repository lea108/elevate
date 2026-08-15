import 'package:material_ui/material_ui.dart';

class InputState {
  final ValueNotifier<double> inputY = ValueNotifier<double>(0.0);

  void reset() {
    inputY.value = 0;
  }
}
