/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/13/2025
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';

mixin MyUtils {
  void debugMsg(String msg, [bool box = false]) {
    const String boxLine =
        ">> ----------------------------------------------------------";

    if (box) debugPrint(boxLine);
    debugPrint(">> $msg");
    if (box) debugPrint(boxLine);
  }
}
