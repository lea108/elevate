import 'package:flutter/services.dart';

extension ColorExtensions on Color {
  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'r': r,
      'b': b,
      'g': g,
    };
  }
}

Color colorFromJson(Map<String, dynamic> data) {
  return Color.from(
    alpha: data['a'],
    red: data['r'],
    green: data['g'],
    blue: data['b'],
  );
}
