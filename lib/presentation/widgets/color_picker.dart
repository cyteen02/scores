/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 08/23/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/presentation/dialogs/pick_color.dart';

Widget colorPickerWidget(
  BuildContext context,
  Color selectedColor,
  GestureTapCallback showColorPicker,
) {
  return InkWell(
    onTap: showColorPicker,
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Colour',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.palette),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(width: 12),
              Text(getColourName(selectedColor)),
            ],
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    ),
  );
}
//----------------------------------------------------------------------------*/

