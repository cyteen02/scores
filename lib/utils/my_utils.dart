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

void debugMsg(String msg, [bool box = false]) {
  const String boxLine =
      ">> ----------------------------------------------------------";

  if (box) debugPrint(boxLine);
  debugPrint(">> $msg");
  if (box) debugPrint(boxLine);
}

//----------------------------------------------------------------

void errorMsg(String msg, [bool box = false]) {
  const String boxLine =
      ">>***********************************************************";

  if (box) debugPrint(boxLine);
  debugPrint(">> $msg");
  if (box) debugPrint(boxLine);
}

//----------------------------------------------------------------

void showPopupMessage(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(child: Text(message)),
      action: action,

      backgroundColor: Colors.lightGreen,
      duration: Duration(seconds: 2),
    ),
  );
}
//----------------------------------------------------------------

void showPopupError(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(child: Text(message)),
      action: action,

      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ),
  );
}
//----------------------------------------------------------------


