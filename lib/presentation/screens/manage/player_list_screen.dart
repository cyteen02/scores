/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/24/2025
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/repositories/repositories.dart';

import 'package:scores/data/models/player.dart';
import 'package:scores/presentation/screens/manage/player_form_screen.dart';
import 'package:scores/presentation/widgets/player_listtile.dart';
import 'package:scores/utils/my_utils.dart';

//---------------------------------------------------------------------------

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({super.key});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  List<Player> playerList = [];
  bool isLoading = true;

  //--------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  //--------------------------------------------------------------

  Future<void> _loadPlayers() async {
    debugMsg("_PlayersListScreenState _loadPlayers");

    setState(() => isLoading = true);

    final loadedPlayers = await playerRepository.getAllPlayers();
    setState(() {
      playerList = loadedPlayers;
      isLoading = false;
    });
  }

  //--------------------------------------------------------------

  void _addPlayer() async {
    // Navigate to PlayerForm to create new player
    final Player? newPlayer = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlayerFormScreen()),
    );

    if (newPlayer != null) {
      setState(() {
        playerList.add(newPlayer);
      });
      if (mounted) {
        showPopupMessage(context, '${newPlayer.name} added');
      }
    }
  }

  //--------------------------------------------------------------

  void _editPlayer(Player player) async {
    final Player? updatedPlayer = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlayerFormScreen(player: player)),
    );

    if (updatedPlayer != null) {
      setState(() {
        int index = playerList.indexWhere((p) => p.id == player.id);
        playerList[index] = updatedPlayer;
      });
      if (mounted) {
        showPopupMessage(context, '${updatedPlayer.name} updated');
      }
    }
  }

  //------------------------------------------------------------------

  void _deletePlayer(int index) {
    debugMsg("_deletePlayer index $index");

    final player = playerList[index];

    // remove from screen
    setState(() {
      playerList.removeAt(index);
    });
    // remove from database
    playerRepository.deletePlayer(player.id);

    showPopupMessage(context, '${player.name} deleted');
  }

  //------------------------------------------------------------------

  Future<dynamic> _confirmDelete(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Person'),
          content: Text(
            'Are you sure you want to delete ${playerList[index].name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePlayer(index);
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to use'),
                  content: const Text(
                    'Tap a person to edit them.\n\n'
                    'Swipe left to delete a person.\n\n'
                    'Use the + button to add new people.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('GOT IT'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : playerList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No players yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add someone',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: playerList.length,
              itemBuilder: (context, index) {
                final player = playerList[index];
                return Dismissible(
                  key: Key(player.name + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _confirmDelete(index);
                  },

                  onDismissed: (direction) {
                    _deletePlayer(index);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: PlayerListTile(
                      player: player,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: (context, player) => _editPlayer(player),
                    ),


                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
        child: const Icon(Icons.add),
      ),
    );
  }

  //--------------------------------------------------------------
}
