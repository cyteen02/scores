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
import 'package:scores/utils/my_utils.dart';

Future<int?> pickNumPlayers(BuildContext context) async {
  return showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Number of players'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 8,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${index + 1}'),
                onTap: () {
                  debugMsg("onTap index $index");
                  Navigator.of(context).pop(index + 1);
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

//---------------------------------------------------------------
