/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/03/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/player.dart';
import 'package:scores/utils/my_utils.dart';

Future<int?> pickOnePlayer(
  BuildContext context,
  List<Player> playersList,
) async {
  return showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Pick a player'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playersList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  playersList[index].name,
                  style: TextStyle(color: playersList[index].color.toColor()),
                ),
                onTap: () {
                  debugMsg("showPlayerPicker onTap index $index");
                  Navigator.of(context).pop(index);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
