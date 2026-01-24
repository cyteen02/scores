/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/17/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';

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
