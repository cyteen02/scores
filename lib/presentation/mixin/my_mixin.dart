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
import 'dart:math';

mixin MyMixin {

  //----------------------------------------------------------------

  static int generateId() {
    return DateTime.now().millisecondsSinceEpoch * 100 + Random().nextInt(1000).toInt();
  }

  //---------------------------------------------------------------------------
  
  static Future<int> showDialogBox(
    BuildContext context,
    String title,
    String text1,
    String text2,
  ) async {
    int? textNumPressed = 0;

    debugPrint('>>MyUtils.showDialogBox');

    // display an AlertDialog
    textNumPressed = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(title)),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            OutlinedButton(
              child: Text(text1),
              onPressed: () {
                debugPrint(">> text1 pressed");
                textNumPressed = 1;
                Navigator.pop(context, 1);
              },
            ),
            OutlinedButton(
              child: Text(text2),
              onPressed: () {
                debugPrint(">> text2 pressed");
                textNumPressed = 2;
                Navigator.pop(context, 2);
              },
            ),
          ],
        );
      },
    );

    debugPrint('end of showDialogBox _textNumPressed=$textNumPressed');

    return textNumPressed ?? 0;
  }

  //----------------------------------------------------------------

  static Future<void> showOkBox(
    BuildContext context,
    String title,
    String alertMessage,
  ) async {

    debugPrint('>>MyUtils.showOkBox');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(title)),
          content: Text(alertMessage),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            OutlinedButton(
              child: Text("Ok"),
              onPressed: () {
                debugPrint(">> Ok pressed");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    debugPrint('end of showOkBox');
  }
  //----------------------------------------------------------------

}
