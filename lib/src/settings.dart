import 'package:flutter/material.dart';

class Settings {
  final TextStyle labelStyle;

  final Color edgeColor;

  final TextStyle iDStyle;

  final double edgeWidth;

  Settings(
      {this.edgeColor = Colors.redAccent,
      this.labelStyle = const TextStyle(color: Colors.green),
      this.iDStyle = const TextStyle(color: Colors.blue),
      this.edgeWidth = 1.0});
}