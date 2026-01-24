
/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/22/2025
*
*----------------------------------------------------------------------------*/



import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/player.dart';
import 'package:scores/utils/my_utils.dart';

Future<bool> changePlayerColour(    BuildContext context, Player player) async {

    debugMsg("changePlayerColour $player");

    Color? newColour = await showColorPickerDialog(
      context,
      initialColor: player.color.toColor(),
    );

    return ( newColour != null );

    // debugMsg("newColor $newColour");
    // if (newColour != null) {
    //   setState(() {
    //     player.setColor(newColour);
    //   });

    //   final GameStorage storage = GameStorage();
    //   try {
    //     debugMsg("_ListScreenState changePlayerColour saving game");
    //     storage.saveGame(widget.game);
    //   } catch (e) {
    //     debugMsg("_ListScreenState changePlayerColour ${e.toString()}", true);
    //   }
    // }
  }

  //---------------------------------------------------------------

  Future<Color?> showColorPickerDialog(
    BuildContext context, {
    Color initialColor = Colors.blue,
  }) async {
    Color selectedColor = initialColor;

    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              //              paletteType: PaletteType.hsv,
              displayThumbColor: false,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedColor),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }