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

import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/data/models/player.dart';
import 'package:sqflite/sqflite.dart';

class PlayerRepository {
  final dbHelper = DatabaseHelper.instance;

  // Insert a player
  Future<void> insertPlayer(Player player) async {
    final db = await dbHelper.database;
    final id = await db.insert(
      'player',
      player.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    player.id = id;
  }

  //----------------------------------------------------------------

  // Insert multiple players
  Future<void> insertPlayers(List<Player> players) async {
    final db = await dbHelper.database;
    final batch = db.batch();

    for (var player in players) {
      batch.insert(
        'player',
        player.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  //----------------------------------------------------------------

  // Get all players
  Future<List<Player>> getAllPlayers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'player',
      orderBy: 'name',
    );

    return List.generate(maps.length, (i) {
      return Player.fromMap(maps[i]);
    });
  }

  //----------------------------------------------------------------

  Future<bool> nameExists(String playerName) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM player WHERE name = ?',
      [playerName],
    );

    return (result.first['count'] as int > 0);
  }

  //----------------------------------------------------------------

  // Update a player
  Future<void> updatePlayer(Player player) async {
    final db = await dbHelper.database;
    await db.update(
      'player',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  //----------------------------------------------------------------

  // Delete a player
  Future<void> deletePlayer(int id) async {
    final db = await dbHelper.database;
    await db.delete('player', where: 'id = ?', whereArgs: [id]);
  }

  //----------------------------------------------------------------

  // Delete all players
  Future<void> deleteAllPlayers() async {
    final db = await dbHelper.database;
    await db.delete('player');
  }
}
