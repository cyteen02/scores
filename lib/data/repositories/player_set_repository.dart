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

  PlayerSetRepository();

  static const _name = "PlayerSetRepository";

  //---------------------------------------------------------------------------

  // Insert a new PlayerSet with its players
  Future<int> insert(PlayerSet playerSet) async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;

          return await db.transaction((txn) async {
            // Insert the PlayerSet
            await txn.insert(DatabaseHelper.tablePlayerSet, {
              'id': playerSet.id,
            });

            // Insert all player associations
            for (var player in playerSet.players) {
              await txn.insert(DatabaseHelper.tablePlayerSetPlayers, {
                'player_set_id': playerSet.id,
                'player_id': player.id,
              });
            }

            return playerSet.id!;
          });
        }, context: "$_name.insert") ??
        0;
  }

  //---------------------------------------------------------------------------

  // Update an existing PlayerSet (replaces all player associations)
  Future<int> update(PlayerSet playerSet) async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          return await db.transaction((txn) async {
            // Delete existing player associations
            await txn.delete(
              DatabaseHelper.createTablePlayerSetPlayers,
              where: 'player_set_id = ?',
              whereArgs: [playerSet.id],
            );

            // Insert new player associations
            for (var player in playerSet.players) {
              await txn.insert(DatabaseHelper.tablePlayerSetPlayers, {
                'player_set_id': playerSet.id,
                'player_id': player.id,
              });
            }

            return playerSet.id!;
          });
        }, context: "$_name.update") ??
        0;
  }

  //---------------------------------------------------------------------------

  // Delete a PlayerSet by ID (cascade will delete associations)
  Future<int> delete(int id) async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          return await db.delete(
            DatabaseHelper.tablePlayerSet,
            where: 'id = ?',
            whereArgs: [id],
          );
        }, context: "$_name.delete") ??
        0;
  }

  //---------------------------------------------------------------------------

  // Get a PlayerSet by ID with all its players
  Future<PlayerSet?> getById(int id) async {
    return await dbHelper.safeDbCall(() async {
      final db = await dbHelper.database;
      final playerSetMaps = await db.query(
        DatabaseHelper.tablePlayerSet,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (playerSetMaps.isNotEmpty) {
        // Get associated players
        final playerMaps = await db.rawQuery(
          '''
      SELECT p.*
      FROM ${DatabaseHelper.tablePlayer} p
      INNER JOIN ${DatabaseHelper.tablePlayerSetPlayers} psm ON p.id = psm.player_id
      WHERE psm.player_set_id = ?
    ''',
          [id],
        );

        final players = playerMaps.map((map) => Player.fromJson(map)).toList();

        return PlayerSet(
          id: playerSetMaps.first['id'] as int,
          players: players,
        );
      } else {
        return PlayerSet();
      }
    }, context: "$_name.getById");
  }

  //---------------------------------------------------------------------------

  // Get all PlayerSets with their players
  Future<List<PlayerSet>> getAll() async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          final playerSetMaps = await db.query(DatabaseHelper.tablePlayerSet);

          List<PlayerSet> playerSets = [];
          for (var map in playerSetMaps) {
            final id = map['id'] as int;
            final playerSet = await getById(id);
            if (playerSet != null) {
              playerSets.add(playerSet);
            }
          }
          return playerSets;
        }, context: "$_name.getAll") ??
        []; // Return empty list if it fails
  }

  //---------------------------------------------------------------------------
  // Get all PlayerSets that contain a specific player
  Future<List<PlayerSet>> getPlayerSetsContainingPlayer(int playerId) async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          final playerSetMaps = await db.rawQuery(
            '''
      SELECT ps.*
      FROM ${DatabaseHelper.tablePlayerSet} ps
      INNER JOIN ${DatabaseHelper.tablePlayerSetPlayers} psm ON ps.id = psm.player_set_id
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
        }, context: "$_name.getPlayerSetsContainingPlayer") ??
        []; // Return empty list if it fails
  }

  //---------------------------------------------------------------------------

  // Add a player to a PlayerSet
  Future<void> addPlayerToSet(int playerSetId, int playerId) async {
    await dbHelper.safeDbCall(() async {
      final db = await dbHelper.database;
      await db.insert(
        DatabaseHelper.tablePlayerSetPlayers,
        {'player_set_id': playerSetId, 'player_id': playerId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }, context: "$_name.addPlayerToSet");
  }
  //---------------------------------------------------------------------------

  // Remove a player from a PlayerSet
  Future<int> removePlayerFromSet(int playerSetId, int playerId) async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          return await db.delete(
            DatabaseHelper.tablePlayerSetPlayers,
            where: 'player_set_id = ? AND player_id = ?',
            whereArgs: [playerSetId, playerId],
          );
        }, context: "$_name.removePlayerFromSet") ??
        0;
  }

  //---------------------------------------------------------------------------

  // Get count of PlayerSets
  Future<int> count() async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          final result = await db.rawQuery(
            'SELECT COUNT(*) as count FROM ${DatabaseHelper.tablePlayerSet}',
          );
          return Sqflite.firstIntValue(result) ?? 0;
        }, context: "$_name.count") ??
        0;
  }

  //---------------------------------------------------------------------------

  // Check if a PlayerSet exists
  Future<bool> exists(int id) async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          final maps = await db.query(
            DatabaseHelper.tablePlayerSet,
            where: 'id = ?',
            whereArgs: [id],
            limit: 1,
          );
          return maps.isNotEmpty;
        }, context: "$_name.exists") ??
        false;
  }

  //----------------------------------------------------------------------

  // Check if a PlayerSet contains a specific player
  Future<bool> containsPlayer(int playerSetId, int playerId) async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          final maps = await db.query(
            DatabaseHelper.tablePlayerSetPlayers,
            where: 'player_set_id = ? AND player_id = ?',
            whereArgs: [playerSetId, playerId],
            limit: 1,
          );
          return maps.isNotEmpty;
        }, context: "$_name.containsPlayer") ??
        false;
  }

  //----------------------------------------------------------------------

  // Get count of players in a PlayerSet
  Future<int> getPlayerCount(int playerSetId) async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          final result = await db.rawQuery(
            'SELECT COUNT(*) as count FROM ${DatabaseHelper.tablePlayerSetPlayers} WHERE player_set_id = ?',
            [playerSetId],
          );
          return Sqflite.firstIntValue(result) ?? 0;
        }, context: "$_name.getPlayerCount") ??
        0;
  }

  //----------------------------------------------------------------------

  Future<int> getPlayerSetContainingAllPlayers(List<int> playerIds) async {
    // There should only ever be one playerSet for
    // each combination of player Id's
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;

          final result = await db.rawQuery(
            '''
        SELECT MAX(player_set_id)
          FROM ${DatabaseHelper.tablePlayerSetPlayers}
          WHERE player_id IN (${playerIds.map((_) => '?').join(',')})
          GROUP BY player_set_id
          HAVING COUNT(DISTINCT player_id) = ?
      ''',
            [...playerIds, playerIds.length],
          );

          return Sqflite.firstIntValue(result) ?? 0;
        }, context: "$_name.getPlayerSetContainingAllPlayers") ??
        0;
  }

  //----------------------------------------------------------------------

  // Delete all PlayerSets
  Future<int> deleteAll() async {
    return await dbHelper.safeDbCall(() async {
          final db = await dbHelper.database;
          return await db.delete(DatabaseHelper.tablePlayerSet);
        }, context: "$_name.deleteAll") ??
        0;
  }

  //----------------------------------------------------------------------
}
