import 'package:flutter/material.dart';


extension IntToColorExtension on int {
  /// Convert integer to Color
  Color toColor() {
    return Color(this);
  }
}
