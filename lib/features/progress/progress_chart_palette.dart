import 'package:flutter/material.dart';

abstract final class ProgressChartPalette {
  static const Color azure = Color(0xFF76A6FF);
  static const Color blue = Color(0xFF2563EB);
  static const Color sky = Color(0xFF96D2F6);
  static const Color navy = Color(0xFF001C58);
  static const Color indigo = Color(0xFF3358AA);

  static const List<Color> colors = [azure, blue, sky, navy, indigo];

  static Color at(int index) => colors[index % colors.length];
}
