import 'package:flutter/services.dart';

extension BrightnessExtensions on Brightness {
  /// Get the invert brightness.
  Brightness get inverted =>
      this == Brightness.light ? Brightness.dark : Brightness.light;

  /// Get SystemUiOverlayStyle.light/dark corresponding to [this] brightness.
  SystemUiOverlayStyle get systemUiOverlayStyle => this == Brightness.light
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}
