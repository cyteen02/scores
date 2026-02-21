/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/31/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';


extension IntToColorExtension on int {
  /// Convert integer to Color
  Color toColor() {
    return Color(this);  
  }
}

//---------------------------------------------------------------------------
