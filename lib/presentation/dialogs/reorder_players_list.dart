/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/25/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/extensions/int_extensions.dart';
import 'package:scores/data/models/player.dart';
import 'package:scores/utils/my_utils.dart';

// /// Flutter code sample for [ReorderableListView].

// void main() => runApp(const ReorderableApp());

// class ReorderableApp extends StatelessWidget {
//   const ReorderableApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('ReorderableListView Sample')),
//         body: const ReorderableExample(),
//       ),
//     );
//   }
// }

// class ReorderableExample extends StatefulWidget {
//   const ReorderableExample({super.key});

//   @override
//   State<ReorderableExample> createState() => _ReorderableListViewExampleState();
// }

// class _ReorderableListViewExampleState extends State<ReorderableExample> {
//   final List<int> _items = List<int>.generate(50, (int index) => index);

//   @override
//   Widget buildxxx(BuildContext context) {
//     final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
//     final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

//     return ReorderableListView(
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       children: <Widget>[
//         for (int index = 0; index < _items.length; index += 1)
//           ListTile(
//             key: Key('$index'),
//             tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
//             title: Text('Item ${_items[index]}'),
//           ),
//       ],
//       onReorder: (int oldIndex, int newIndex) {
//         setState(() {
//           if (oldIndex < newIndex) {
//             newIndex -= 1;
//           }
//           final int item = _items.removeAt(oldIndex);
//           _items.insert(newIndex, item);
//         });
//       },
//     );
//   }
// }

Future<List<Player>?> showReorderPlayersDialog(
  BuildContext context,
  List<Player> players,
) {
  List<Player> reorderedPlayers = List.from(players);

  List<Widget> playerListTiles = [];

  for (int i = 0; i < reorderedPlayers.length; i++) {
    debugMsg("tile for id ${reorderedPlayers[i].id}");
    playerListTiles.add(
      ReorderableDragStartListener(
        index: i,
        key: ValueKey(reorderedPlayers[i].id),

        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            key: ValueKey(reorderedPlayers[i].id),

            leading: CircleAvatar(
              backgroundColor: reorderedPlayers[i].color.toColor(),
              child: Text(
                (reorderedPlayers[i].name)[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(reorderedPlayers[i].name),
            trailing: Icon(Icons.drag_handle),
          ),
        ),
      ),
    );
  }

  return showDialog<List<Player>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Center(child: Text('Reorder Players')),
            content: SizedBox(
              width: double.maxFinite,
              child: ReorderableListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: getPlayerListTiles(reorderedPlayers),
                onReorder: (oldIndex, newIndex) {
                  debugMsg("onReorder oldIndex $oldIndex newIndex $newIndex");
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final player = reorderedPlayers.removeAt(oldIndex);
                    reorderedPlayers.insert(newIndex, player);
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, reorderedPlayers),
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    });}

  //---------------------------------------------------------------------------
  
  List<Widget> getPlayerListTiles(List<Player> reorderedPlayers) {

  List<Widget> playerListTiles = [];

  for (int i = 0; i < reorderedPlayers.length; i++) {
    debugMsg("tile for id ${reorderedPlayers[i].id}");
    playerListTiles.add(
      ReorderableDragStartListener(
        index: i,
        key: ValueKey(reorderedPlayers[i].id),

        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            key: ValueKey(reorderedPlayers[i].id),

            leading: CircleAvatar(
              backgroundColor: reorderedPlayers[i].color.toColor(),
              child: Text(
                (reorderedPlayers[i].name)[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(reorderedPlayers[i].name),
            trailing: Icon(Icons.drag_handle),
          ),
        ),
      ),
    );
  }
  return playerListTiles;

}
