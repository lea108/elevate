import 'package:elevate/theme/palette.dart';
import 'package:flutter/material.dart';

const mediumPadding = 10.0;

ThemeData appTheme() {
  var theme = ThemeData.from(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepOrange[600]!,
      primary: Colors.deepOrange[400]!,
      surface: Colors.grey[600]!,
      //Color.lerp(Colors.purple[900]!, Colors.grey[800], 0.7)!,
      brightness: Brightness.dark,
    ),
  );
  return theme.copyWith(
    visualDensity: VisualDensity.comfortable,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Palette.c2),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(mediumPadding),
          ),
        ),
      ),
    ),
  );
}
