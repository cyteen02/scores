/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/15/2026
*
*----------------------------------------------------------------------------*/

import 'package:scores/data/models/player.dart';
import 'package:scores/data/models/player_set.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:sqflite/sqflite.dart';
//import 'dart:convert';

//import 'package:sqflite/sqflite.dart';

class PlayerSetRepository {
  final dbHelper = DatabaseHelper.instance;

  static const String tablePlayerSets = 'player_set';
  static const String tablePlayerSetMembers = 'player_set_players';

  // Table creation SQL
  static const String createPlayerSetsTableSQL =
      '''
    CREATE TABLE $tablePlayerSets (
      id INTEGER PRIMARY KEY
    )
  ''';

  static const String createPlayerSetMembersTableSQL =
      '''
    CREATE TABLE $tablePlayerSetMembers (
      player_set_id INTEGER NOT NULL,
      player_id INTEGER NOT NULL,
      PRIMARY KEY (player_set_id, player_id),
      FOREIGN KEY (player_set_id) REFERENCES $tablePlayerSets(id) ON DELETE CASCADE,
      FOREIGN KEY (player_id) REFERENCES player(id) ON DELETE CASCADE
    )
  ''';

  PlayerSetRepository();

//---------------------------------------------------------------------------

  // Insert a new PlayerSet with its players
  Future<int> insert(PlayerSet playerSet) async {
    final db = await dbHelper.database;

    return await db.transaction((txn) async {
      // Insert the PlayerSet
      await txn.insert(tablePlayerSets, {'id': playerSet.id});

      // Insert all player associations
      for (var player in playerSet.players) {
        await txn.insert(tablePlayerSetMembers, {
          'player_set_id': playerSet.id,
          'player_id': player.id,
        });
      }

      return playerSet.id!;
    });
  }

//---------------------------------------------------------------------------
  // Update an existing PlayerSet (replaces all player associations)
  Future<int> update(PlayerSet playerSet) async {
    final db = await dbHelper.database;
    return await db.transaction((txn) async {
      // Delete existing player associations
      await txn.delete(
        tablePlayerSetMembers,
        where: 'player_set_id = ?',
        whereArgs: [playerSet.id],
      );

      // Insert new player associations
      for (var player in playerSet.players) {
        await txn.insert(tablePlayerSetMembers, {
          'player_set_id': playerSet.id,
          'player_id': player.id,
        });
      }

      return playerSet.id!;
    });
  }

//---------------------------------------------------------------------------
  // Delete a PlayerSet by ID (cascade will delete associations)
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(tablePlayerSets, where: 'id = ?', whereArgs: [id]);
  }

//---------------------------------------------------------------------------
  // Get a PlayerSet by ID with all its players
  Future<PlayerSet?> getById(int id) async {
    final db = await dbHelper.database;
    final playerSetMaps = await db.query(
      tablePlayerSets,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (playerSetMaps.isEmpty) {
      return null;
    }

    // Get associated players
    final playerMaps = await db.rawQuery(
      '''
      SELECT p.*
      FROM player p
      INNER JOIN $tablePlayerSetMembers psm ON p.id = psm.player_id
      WHERE psm.player_set_id = ?
    ''',
      [id],
    );

    final players = playerMaps.map((map) => Player.fromJson(map)).toList();

    return PlayerSet(id: playerSetMaps.first['id'] as int, players: players);
  }

//---------------------------------------------------------------------------
  // Get all PlayerSets with their players
  Future<List<PlayerSet>> getAll() async {
    final db = await dbHelper.database;
    final playerSetMaps = await db.query(tablePlayerSets);

    List<PlayerSet> playerSets = [];
    for (var map in playerSetMaps) {
      final id = map['id'] as int;
      final playerSet = await getById(id);
      if (playerSet != null) {
        playerSets.add(playerSet);
      }
    }

    return playerSets;
  }

//---------------------------------------------------------------------------
  // Get all PlayerSets that contain a specific player
  Future<List<PlayerSet>> getPlayerSetsContainingPlayer(int playerId) async {
    final db = await dbHelper.database;
    final playerSetMaps = await db.rawQuery(
      '''
      SELECT ps.*
      FROM $tablePlayerSets ps
      INNER JOIN $tablePlayerSetMembers psm ON ps.id = psm.player_set_id
      WHERE psm.player_id = ?
    ''',
      [playerId],
    );

    List<PlayerSet> playerSets = [];
    for (var map in playerSetMaps) {
      final id = map['id'] as int;
      final playerSet = await getById(id);
      if (playerSet != null) {
        playerSets.add(playerSet);
      }
    }

    return playerSets;
  }

  //---------------------------------------------------------------------------

  // Add a player to a PlayerSet
  Future<void> addPlayerToSet(int playerSetId, int playerId) async {
    final db = await dbHelper.database;
    await db.insert(tablePlayerSetMembers, {
      'player_set_id': playerSetId,
      'player_id': playerId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  //---------------------------------------------------------------------------

  // Remove a player from a PlayerSet
  Future<int> removePlayerFromSet(int playerSetId, int playerId) async {
    final db = await dbHelper.database;
    return await db.delete(
      tablePlayerSetMembers,
      where: 'player_set_id = ? AND player_id = ?',
      whereArgs: [playerSetId, playerId],
    );
  }

  //---------------------------------------------------------------------------

  // Get count of PlayerSets
  Future<int> count() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tablePlayerSets',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //---------------------------------------------------------------------------

  // Check if a PlayerSet exists
  Future<bool> exists(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tablePlayerSets,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  //----------------------------------------------------------------------

  // Check if a PlayerSet contains a specific player
  Future<bool> containsPlayer(int playerSetId, int playerId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      tablePlayerSetMembers,
      where: 'player_set_id = ? AND player_id = ?',
      whereArgs: [playerSetId, playerId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  //----------------------------------------------------------------------

  // Get count of players in a PlayerSet
  Future<int> getPlayerCount(int playerSetId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tablePlayerSetMembers WHERE player_set_id = ?',
      [playerSetId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //----------------------------------------------------------------------

  Future<int> getPlayerSetContainingAllPlayers(List<int> playerIds) async {
    // There should only ever be one playerSet for
    // each combination of player Id's
    final db = await dbHelper.database;

    final result = await db.rawQuery(
      '''
        SELECT MAX(player_set_id)
          FROM $tablePlayerSetMembers
          WHERE player_id IN (${playerIds.map((_) => '?').join(',')})
          GROUP BY player_set_id
          HAVING COUNT(DISTINCT player_id) = ?
      ''',
      [...playerIds, playerIds.length],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  //----------------------------------------------------------------------

  // Delete all PlayerSets
  Future<int> deleteAll() async {
    final db = await dbHelper.database;
    return await db.delete(tablePlayerSets);
  }

  //----------------------------------------------------------------------
}
