import 'package:flutter/material.dart';

bool narrowLayout(BuildContext context) {
  final mqSize = MediaQuery.sizeOf(context);
  return mqSize.width < 500;
}
