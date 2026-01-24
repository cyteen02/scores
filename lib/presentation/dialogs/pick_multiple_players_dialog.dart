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
import 'package:scores/data/models/player.dart';

Future<List<Player>> pickMultiplePlayersDialog(
  BuildContext context,
  List<Player> allPlayers,
  int numPlayersRequired,
) async {

  List<Player> selectedPlayers = [];

  return await showDialog<List<Player>>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final canConfirm = selectedPlayers.length == numPlayersRequired;

              return AlertDialog(
                title: Text('Select $numPlayersRequired Players'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected: ${selectedPlayers.length} / $numPlayersRequired',
                      style: TextStyle(
                        color: canConfirm ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: allPlayers.map((player) {
                            final isSelected = selectedPlayers.contains(player);
                            return CheckboxListTile(
                              title: Text(player.name),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedPlayers.add(player);
                                  } else {
                                    selectedPlayers.remove(player);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: (() {
                      selectedPlayers.clear();
                      Navigator.pop(context, selectedPlayers);
                    }),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: canConfirm
                        ? () => Navigator.pop(context, selectedPlayers)
                        : null,
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      ) ??
      [];
}

//---------------------------------------------------------------
