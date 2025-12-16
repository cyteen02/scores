import 'package:flutter/material.dart';


extension ColorExtension on Color {
int toInt() {
    return (a * 255).round() << 24 | 
           (r * 255).round() << 16 | 
           (g * 255).round() << 8 | 
           (b * 255).round();
  }  
  /// Convert Color to hex string (e.g., "#FFFF5722")
  String toHex() {
    return '#${toInt().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
  
  /// Check if color is dark (useful for choosing text color)
  bool get isDark {
    return (r * 0.299 + g * 0.587 + b * 0.114) < 128;
  }
  
  /// Get contrasting color for text
  Color get contrastingColor {
    return isDark ? Colors.white : Colors.black;
  }
}

extension IntToColorExtension on int {
  /// Convert integer to Color
  Color toColor() {
    return Color(this);
  }
}

extension StringToColorExtension on String {
  /// Convert hex string to Color (e.g., "#FFFF5722" or "FFFF5722")
  Color toColor() {
    String hexColor = replaceFirst('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';  // Add alpha if not present
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
