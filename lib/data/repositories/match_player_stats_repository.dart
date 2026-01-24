/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/05/2026
*
*----------------------------------------------------------------------------*/

import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/data/models/match_player_stats.dart';
import 'package:sqflite/sqflite.dart';

class MatchPlayerStatsRepository {
  final dbHelper = DatabaseHelper.instance;

  //  MatchPlayerStatsRepository(this.db);

  static const String tableName = 'match_player_stats';

  // Create table with foreign key reference to match_stats
  Future<void> createTable(Database db) async {
    final db = await dbHelper.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_id INTEGER NOT NULL,
        player_id INTEGER NOT NULL,
        stat TEXT NOT NULL,
        value TEXT NOT NULL,
        FOREIGN KEY (match_id) REFERENCES match_stats (match_id) ON DELETE CASCADE
      )
    ''');
  }

  //-----------------------------------------------------------------

  void savePlayerStat(int matchId, int playerId, String stat, String value) {
    saveStat(matchId, playerId, stat, value);
  }

  //-----------------------------------------------------------------

  void saveStat(int matchId, int playerId, String stat, String value) {
    insert(
      MatchPlayerStats(
        matchId: matchId,
        playerId: playerId,
        stat: stat,
        value: value,
      ),
    );
  }

  //-----------------------------------------------------------------

  // Check if a match exists in match_stats
  Future<bool> matchExists(int matchId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'match_stats',
      where: 'match_id = ?',
      whereArgs: [matchId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  //-----------------------------------------------------------------

  // Insert a new player stat (validates match exists first)
  Future<int> insert(MatchPlayerStats playerStat) async {
    if (!await matchExists(playerStat.matchId)) {
      throw ArgumentError(
        'Cannot insert player stat: match_id ${playerStat.matchId} does not exist in match_stats',
      );
    }
    final db = await dbHelper.database;
    return await db.insert(
      tableName,
      playerStat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //-----------------------------------------------------------------

  // Update an existing player stat
  Future<int> update(MatchPlayerStats playerStat) async {
    if (playerStat.id == null) {
      throw ArgumentError('Cannot update MatchPlayerStats without an id');
    }
    if (!await matchExists(playerStat.matchId)) {
      throw ArgumentError(
        'Cannot update player stat: match_id ${playerStat.matchId} does not exist in match_stats',
      );
    }
    final db = await dbHelper.database;
    return await db.update(
      tableName,
      playerStat.toMap(),
      where: 'id = ?',
      whereArgs: [playerStat.id],
    );
  }

  //-----------------------------------------------------------------
  // Delete a player stat by id

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  //-----------------------------------------------------------------
  // Get all stats for a specific match

  Future<List<MatchPlayerStats>> getByMatchId(int matchId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'match_id = ?',
      whereArgs: [matchId],
    );
    return List.generate(maps.length, (i) => MatchPlayerStats.fromMap(maps[i]));
  }

  //-----------------------------------------------------------------
  // Get all stats for a specific player

  Future<List<MatchPlayerStats>> getByPlayerId(int playerId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'player_id = ?',
      whereArgs: [playerId],
    );
    return List.generate(maps.length, (i) => MatchPlayerStats.fromMap(maps[i]));
  }

  //-----------------------------------------------------------------
  // Get stats for a specific player in a specific match

  Future<List<MatchPlayerStats>> getByMatchAndPlayer(
    int matchId,
    int playerId,
  ) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'match_id = ? AND player_id = ?',
      whereArgs: [matchId, playerId],
    );
    return List.generate(maps.length, (i) => MatchPlayerStats.fromMap(maps[i]));
  }

  //-----------------------------------------------------------------
  // Get stats for all players in a game & player set

  Future<Map<int, String>> getStatByGameIdAndPlayerSet(
    int gameId,
    int playerSetId,
    String stat,
  ) async {
    final db = await dbHelper.database;

    final results = await db.rawQuery(
      '''
        SELECT s.player_id, s.value 
          FROM match_player_stats s
          INNER JOIN match_history m on m.match_id = s.match_id
          WHERE s.stat = ? AND
                m.game_id = s.match_id AND
                m.game_id = ? AND
                m.player_set_id = ?
      ''',
      [stat, gameId, playerSetId],
    );

    Map<int, String> resultMap = {
      for (var row in results) row['player_id'] as int: row['value'] as String,
    };

    return resultMap;
  }

  //-----------------------------------------------------------------
  // Get stats for a specific player in a game & player set

  Future<List<MatchPlayerStats>> getByGameIdAndPlayerSet(
    int gameId,
    int playerSetId,
  ) async {
    final db = await dbHelper.database;

    final results = await db.rawQuery(
      '''
        SELECT s.id,
              s.match_id, 
              s.player_id,
              s.stat,
              s.value
        FROM match_player_stats s
        JOIN match_history h ON s.match_id = h.match_id
        JOIN player_set_players p ON h.player_set_id = p.player_set_id 
                          AND p.player_id = s.player_id
              AND h.game_id = ? 
              AND h.player_set_id = ?                    
      ''',
      [gameId, playerSetId ],
    );

    return List.generate(results.length, (i) => MatchPlayerStats.fromMap(results[i]));
  }

  //-----------------------------------------------------------------
  // Get a single stat by id
  Future<MatchPlayerStats?> getById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return MatchPlayerStats.fromMap(maps.first);
  }

  //-----------------------------------------------------------------
  // Get all player stats

  Future<List<MatchPlayerStats>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => MatchPlayerStats.fromMap(maps[i]));
  }

  //-----------------------------------------------------------------
  // Delete all records for matches older than the cutoff date
  Future<int> deleteOldMatches(DateTime cutoffDate) async {
    final cutoffString = cutoffDate.toIso8601String().substring(0, 10);
    final db = await dbHelper.database;
    return await db.delete(
      tableName,
      where: '''match_id IN (
        SELECT match_id FROM match_stats 
        WHERE stat = ? AND value < ?
      )''',
      whereArgs: ['DATE', cutoffString],
    );
  }
}
