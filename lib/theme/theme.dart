import 'package:elevate/theme/palette.dart';
import 'package:flutter/material.dart';

const narrowPadding = 6.0;
const mediumPadding = 10.0;

const focusedBorderSide = BorderSide(width: 3, color: Colors.orange);
const unfocusedBorderSide = BorderSide(width: 3, color: Colors.transparent);

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
    dialogTheme: DialogThemeData(
      //backgroundColor: Palette.c1,
      elevation: 20,
      shadowColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(15),
      ),
      insetPadding: EdgeInsets.all(10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Palette.tutorialCardBg),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        shape: WidgetStateProperty.resolveWith((state) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(mediumPadding),
            side: state.contains(WidgetState.focused)
                ? focusedBorderSide
                : unfocusedBorderSide,
          );
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.resolveWith((state) {
          return StadiumBorder(
            side: state.contains(WidgetState.focused)
                ? focusedBorderSide
                : unfocusedBorderSide,
          );
        }),
      ),
    ),
  );
}
