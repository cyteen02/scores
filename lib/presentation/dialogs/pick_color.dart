/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 07/13/2026
*
*----------------------------------------------------------------------------*/

//----------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:scores/data/extensions/color_extensions.dart';
import 'package:scores/utils/my_utils.dart';

//---------------------------------------------------------------------------

Future<Color?> showColorPicker2(
  BuildContext context,
  Color? previousColor,
) async {
  Color? pickedColor = await showDialog<Color>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: const Text('Choose Colour')),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                  Colors.black,
                ].map((color) {
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop(color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: previousColor == color
                              ? Colors.white
                              : Colors.grey.shade300,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    },
  );

  return pickedColor;
}

//---------------------------------------------------------------------------
String getColourName(Color color) {
  final colorInt = color.toInt();
  debugMsg("getColourName colorInt $colorInt");

  if (colorInt == Colors.red.toInt()) return 'Red';
  if (colorInt == Colors.pink.toInt()) return 'Pink';
  if (colorInt == Colors.purple.toInt()) return 'Purple';
  if (colorInt == Colors.deepPurple.toInt()) return 'Deep Purple';
  if (colorInt == Colors.indigo.toInt()) return 'Indigo';
  if (colorInt == Colors.blue.toInt()) return 'Blue';
  if (colorInt == Colors.lightBlue.toInt()) return 'Light Blue';
  if (colorInt == Colors.cyan.toInt()) return 'Cyan';
  if (colorInt == Colors.teal.toInt()) return 'Teal';
  if (colorInt == Colors.green.toInt()) return 'Green';
  if (colorInt == Colors.lightGreen.toInt()) return 'Light Green';
  if (colorInt == Colors.lime.toInt()) return 'Lime';
  if (colorInt == Colors.yellow.toInt()) return 'Yellow';
  if (colorInt == Colors.amber.toInt()) return 'Amber';
  if (colorInt == Colors.orange.toInt()) return 'Orange';
  if (colorInt == Colors.deepOrange.toInt()) return 'Deep Orange';
  if (colorInt == Colors.brown.toInt()) return 'Brown';
  if (colorInt == Colors.grey.toInt()) return 'Grey';
  if (colorInt == Colors.blueGrey.toInt()) return 'Blue Grey';
  if (colorInt == Colors.black.toInt()) return 'Black';
  return 'Custom';
}
  //---------------------------------------------------------------------------
  

