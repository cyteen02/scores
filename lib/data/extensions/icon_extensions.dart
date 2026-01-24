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

extension IconDataExtensions on IconData {
  int toInt() => codePoint;
}


extension IntToIconData on int {
  IconData toIcon() => IconData(this, fontFamily: 'MaterialIcons');
}

