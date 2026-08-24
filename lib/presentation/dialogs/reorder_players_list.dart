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
import 'package:scores/data/models/player.dart';
import 'package:scores/presentation/widgets/player_listtile.dart';
import 'package:scores/utils/my_utils.dart';

//---------------------------------------------------------------------------

class ReorderPlayersDialog extends StatefulWidget {
  final List<Player> initialPlayers;

  const ReorderPlayersDialog({
    super.key,
    required this.initialPlayers,
  });

  /// Helper method to trigger the dialog cleanly from anywhere
  static Future<List<Player>?> show(
    BuildContext context, 
    List<Player> players,
  ) {
    return showDialog<List<Player>>(
      context: context,
      builder: (context) => ReorderPlayersDialog(initialPlayers: players),
    );
  }

  @override
  State<ReorderPlayersDialog> createState() => _ReorderPlayersDialogState();
}

//---------------------------------------------------------------------------

class _ReorderPlayersDialogState extends State<ReorderPlayersDialog> {
  late List<Player> _reorderedPlayers;

  @override
  void initState() {
    super.initState();
    // Make a mutable copy of the initial list
    _reorderedPlayers = List.from(widget.initialPlayers);
  }

  void _onReorder(int oldIndex, int newIndex) {
    debugMsg("onReorder oldIndex $oldIndex newIndex $newIndex");
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final player = _reorderedPlayers.removeAt(oldIndex);
      _reorderedPlayers.insert(newIndex, player);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Reorder Players')),
      content: SizedBox(
        width: double.maxFinite,
        child: ReorderableListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: _reorderedPlayers.length,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            final player = _reorderedPlayers[index];
            debugMsg("tile for id ${player.id}");

            return ReorderableDragStartListener(
              index: index,
              key: ValueKey(player.id),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: PlayerListTile(
                  key: ValueKey(player.id),
                  player: player,
                  trailing: const Icon(Icons.drag_handle),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _reorderedPlayers),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
//---------------------------------------------------------------------------

Future<List<Player>?> showReorderPlayersDialogOLD(
  BuildContext context,
  List<Player> players,
) {
  List<Player> reorderedPlayers = List.from(players);

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
    },
  );
}

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
          child: PlayerListTile(
            key: ValueKey(reorderedPlayers[i].id),
            player: reorderedPlayers[i],
            trailing: Icon(Icons.drag_handle),
          ),
        ),
      ),
    );
  }
  return playerListTiles;
}
//---------------------------------------------------------------------------

