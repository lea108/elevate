import 'package:flutter/material.dart';

class InputState {
  final ValueNotifier<double> inputY = ValueNotifier<double>(0.0);

  reset() {
    inputY.value = 0;
  }
}
