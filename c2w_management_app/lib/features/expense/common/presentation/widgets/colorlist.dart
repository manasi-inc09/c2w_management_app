import 'package:flutter/material.dart';

class ColorList {
  static Color generate(int index, {
    double saturation = 0.72,
    double lightness = 0.72,
  }) {
    final hue = (index * 53) % 360;
    return HSLColor.fromAHSL(1, hue.toDouble(), saturation, lightness).toColor();
  }

  Color colorForIndex(
    int index, {
    double saturation = 0.72,
    double lightness = 0.72,
  }) {
    return generate(index, saturation: saturation, lightness: lightness);
  }
}