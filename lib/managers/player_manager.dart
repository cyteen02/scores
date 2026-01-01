// /*---------------------------------------------------------------------------
// *
// * Copyright (c) 2025 Paul Graves
// * All Rights Reserved.
// *
// * You may not use, distribute and modify this code under any circumstances
// *
// * Created: 12/24/2025
// *
// *----------------------------------------------------------------------------*/


// import 'package:scores/database/database_helper.dart';
// import 'package:scores/database/player_repository.dart';
// import 'package:scores/models/player.dart';

// class PlayerManager {
// final dbHelper = DatabaseHelper.instance;

//   // Save players to database
//   Future<void> savePlayers(List<Player> players) async {
//     await dbHelper.deleteAllPlayers(); // Clear existing
//     await dbHelper.insertPlayers(players); // Insert new list
//   }

//   // Load players from database when app starts
//   Future<List<Player>> loadPlayers() async {
//     return await dbHelper.getAllPlayers();
//   }

//   // Add a single player
//   Future<void> addPlayer(Player player) async {
//     await dbHelper.insertPlayer(player);
//   }

//   // Update a player
//   Future<void> updatePlayer(Player player) async {
//     await dbHelper.updatePlayer(player);
//   }

//   // Remove a player
//   Future<void> removePlayer(String id) async {
//     await dbHelper.deletePlayer(id);
//   }
// }