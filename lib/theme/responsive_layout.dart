import 'package:material_ui/material_ui.dart';

bool narrowLayout(BuildContext context) {
  final mqSize = MediaQuery.sizeOf(context);
  return mqSize.width < 500;
}
