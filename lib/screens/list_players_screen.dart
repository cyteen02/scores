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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scores/database/player_repository.dart';

import 'package:scores/models/player.dart';
import 'package:scores/screens/player_form_screen.dart';
import 'package:scores/utils/my_utils.dart';

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({super.key});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  List<Player> players = [];
  final playerRespository = PlayerRepository();
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

    final loadedPlayers = await playerRespository.getAllPlayers();
    setState(() {
      players = loadedPlayers;
      isLoading = false;
    });
  }

  //  Future<void> _savePlayers() async {
  //   await playerRespository.saveAllPlayers(players);
  // }

  //--------------------------------------------------------------

  void _addPlayer() async {
    // Navigate to PlayerForm to create new player
    final Player? newPlayer = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlayerFormScreen()),
    );

    if (newPlayer != null) {
      setState(() {
        players.add(newPlayer);
      });
      if (mounted) {
        showPopupMessage(context, '${newPlayer.name()} added');
      }
    }
  }

  //--------------------------------------------------------------

  void _editPlayer(int index) async {
    final Player? updatedPlayer = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerFormScreen(player: players[index]),
      ),
    );

    if (updatedPlayer != null) {
      setState(() {
        players[index] = updatedPlayer;
      });
      if (mounted) {
        showPopupMessage(context, '${updatedPlayer.name()} updated');
      }
    }
  }

  //------------------------------------------------------------------

  void _deletePlayer(int index) {
    debugMsg("_deletePlayer index $index");

    final player = players[index];

    // remove from screen
    setState(() {
      players.removeAt(index);
    });
    // remove from database
    playerRespository.deletePlayer(player.id ?? 0);

    showPopupMessage(context, '${player.name()} deleted');
  }

  //------------------------------------------------------------------

  Future<dynamic> _confirmDelete(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Person'),
          content: Text(
            'Are you sure you want to delete ${players[index].name()}?',
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

  // void _showSnackBar(String message, {SnackBarAction? action}) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       action: action,
  //       duration: const Duration(seconds: 3),
  //     ),
  //   );
  // }

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
          : players.isEmpty
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
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Dismissible(
                  key: Key(player.name() + index.toString()),
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
                  // return await showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return AlertDialog(
                  //       title: const Text('Confirm Delete'),
                  //       content: Text(
                  //         'Are you sure you want to delete ${player.name}?',
                  //       ),
                  //       actions: [
                  //         TextButton(
                  //           onPressed: () => Navigator.of(context).pop(false),
                  //           child: const Text('CANCEL'),
                  //         ),
                  //         TextButton(
                  //           onPressed: () => Navigator.of(context).pop(true),
                  //           child: const Text(
                  //             'DELETE',
                  //             style: TextStyle(color: Colors.red),
                  //           ),
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // );
                  // },
                  onDismissed: (direction) {
                    _deletePlayer(index);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: player.photoPath != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(
                                File(player.photoPath!),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: player.color,
                              child: Text(
                                player.name()[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      title: Text(player.name()),
                      subtitle: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: player.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Favourite colour'),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _editPlayer(index),
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

// // class Person {
// //   String name;
// //   Color favouriteColour;
// //   String? photoPath;

// //   Person({required this.name, required this.favouriteColour, this.photoPath});
// // }

// // Placeholder PersonForm widget - use your actual PersonForm here
// class PersonForm extends StatelessWidget {
//   final Person? person;
//   const PersonForm({Key? key, this.person}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(person == null ? 'New Person' : 'Edit Person'),
//       ),
//       body: const Center(child: Text('Person Form Goes Here')),
//     );
//   }
// }
