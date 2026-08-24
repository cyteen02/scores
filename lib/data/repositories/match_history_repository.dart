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

import 'package:scores/data/models/match_history.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/utils/my_utils.dart';
import 'package:sqflite/sqflite.dart';

class MatchHistoryRepository {
  final dbHelper = DatabaseHelper.instance;

  MatchHistoryRepository();

  //---------------------------------------------------------------------------

  // Insert a new match history record

  Future<int> insert(MatchHistory matchHistory) async {
    debugMsg("MatchHistoryRepository insert matchHistory $matchHistory");
    try {
      final db = await dbHelper.database;
      return await db.insert(
        DatabaseHelper.tableMatchHistory,
        matchHistory.toMap(),
      );
    } on Exception catch (e) {
      debugMsg("ERROR inserting match history: $e");
      rethrow; // Let the caller handle it
    }
  }

  //---------------------------------------------------------------------------

  // Update an existing match history record
  Future<int> update(MatchHistory matchHistory) async {
    final db = await dbHelper.database;
    return await db.update(
      DatabaseHelper.tableMatchHistory,
      matchHistory.toMap(),
      where: 'match_id = ?',
      whereArgs: [matchHistory.matchId],
    );
  }

  //---------------------------------------------------------------------------

  // Delete a match history record by ID
  Future<int> delete(int matchId) async {
    final db = await dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableMatchHistory,
      where: 'match_id = ?',
      whereArgs: [matchId],
    );
  }

  //---------------------------------------------------------------------------

  // Get a match history record by ID
  Future<MatchHistory?> getByMatchId(int matchId) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      where: 'match_id = ?',
      whereArgs: [matchId],
    );

    if (maps.isEmpty) {
      return null;
    }

    return MatchHistory.fromMap(maps.first);
  }

  //---------------------------------------------------------------------------

  // Get all match history records
  Future<List<MatchHistory>> getAll() async {
    final db = await dbHelper.database;

    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      orderBy: 'match_date DESC',
    );
    return maps.map((map) => MatchHistory.fromMap(map)).toList();
  }
  //---------------------------------------------------------------------------

  // Get all matches for a specific game
  Future<List<MatchHistory>> getByGameId(int gameId) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'match_date DESC',
    );
    return maps.map((map) => MatchHistory.fromMap(map)).toList();
  }

  //---------------------------------------------------------------------------

  // Get all matches for a specific player set
  Future<List<MatchHistory>> getByPlayerSetId(int playerSetId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      where: 'player_set_id = ?',
      whereArgs: [playerSetId],
      orderBy: 'match_date DESC',
    );
    return maps.map((map) => MatchHistory.fromMap(map)).toList();
  }

  //---------------------------------------------------------------------------

  // Get matches within a date range
  Future<List<MatchHistory>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      where: 'match_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'match_date DESC',
    );
    return maps.map((map) => MatchHistory.fromMap(map)).toList();
  }

  //---------------------------------------------------------------------------

  // Get matches for a specific game and player set
  Future<List<MatchHistory>> getByGameAndPlayerSet(
    int gameId,
    int playerSetId,
  ) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      where: 'game_id = ? AND player_set_id = ?',
      whereArgs: [gameId, playerSetId],
      orderBy: 'match_date DESC',
    );
    return maps.map((map) => MatchHistory.fromMap(map)).toList();
  }

  //---------------------------------------------------------------------------

  // Get most recent N matches
  Future<List<MatchHistory>> getRecent(int limit) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      orderBy: 'match_date DESC',
      limit: limit,
    );
    return maps.map((map) => MatchHistory.fromMap(map)).toList();
  }

  //---------------------------------------------------------------------------

  // Get most recent match for a specific game
  Future<MatchHistory?> getMostRecentForGame(int gameId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'match_date DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return MatchHistory.fromMap(maps.first);
  }

  //---------------------------------------------------------------------------

  // Count total matches
  Future<int> count() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $DatabaseHelper.tableMatchHistory',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //---------------------------------------------------------------------------

  // Count matches for a specific game
  Future<int> countByGameId(String gameId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $DatabaseHelper.tableMatchHistory WHERE game_id = ?',
      [gameId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //---------------------------------------------------------------------------

  // Count matches for a specific player set
  Future<int> countByPlayerSetId(int playerSetId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $DatabaseHelper.tableMatchHistory WHERE player_set_id = ?',
      [playerSetId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //---------------------------------------------------------------------------

  // Get all unique game IDs
  Future<List<int>> getAllGameIds() async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT game_id FROM $DatabaseHelper.tableMatchHistory ORDER BY game_id',
    );
    return maps.map((map) => map['game_id'] as int).toList();
  }

  //---------------------------------------------------------------------------

  // Get all unique player set IDs
  Future<List<int>> getAllPlayerSetIds() async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT player_set_id FROM $DatabaseHelper.tableMatchHistory ORDER BY player_set_id',
    );
    return maps.map((map) => map['player_set_id'] as int).toList();
  }

  //---------------------------------------------------------------------------

  // Check if a match exists
  Future<bool> exists(int matchId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableMatchHistory,
      where: 'match_id = ?',
      whereArgs: [matchId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  //---------------------------------------------------------------------------

  // Delete all matches for a specific game
  Future<int> deleteByGameId(int gameId) async {
    final db = await dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableMatchHistory,
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
  }
  //---------------------------------------------------------------------------

  // Delete all matches for a specific player set
  Future<int> deleteByPlayerSetId(int playerSetId) async {
    final db = await dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableMatchHistory,
      where: 'player_set_id = ?',
      whereArgs: [playerSetId],
    );
  }
  //---------------------------------------------------------------------------

  // Delete all match history records
  Future<int> deleteAll() async {
    final db = await dbHelper.database;
    return await db.delete(DatabaseHelper.tableMatchHistory);
  }

  //---------------------------------------------------------------------------
}
