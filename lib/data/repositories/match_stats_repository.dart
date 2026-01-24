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

//import 'package:intl/intl.dart';
import 'package:scores/business/services/match_stats_service.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/data/repositories/match_player_stats_repository.dart';
import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/match_stats.dart';
import 'package:scores/data/models/player.dart';
import 'package:sqflite/sqflite.dart';

class MatchStatsRepository {
  final dbHelper = DatabaseHelper.instance;

  //  MatchStatsRepository(this.db);

  static const String tableName = 'match_stats';

  //-----------------------------------------------------------------

  // Create table
  Future<void> createTable(Database db) async {
    final db = await dbHelper.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_id INTEGER NOT NULL,
        stat TEXT NOT NULL,
        value TEXT NOT NULL
      )
    ''');
  }

  //-----------------------------------------------------------------

  void saveStats(Match match) {
    MatchPlayerStatsRepository matchPlayerStatsRepository =
        MatchPlayerStatsRepository();

//    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    saveStat(match.id, "ROUNDS", match.rounds.length.toString());

    // List<int> playerIds = getWinningPlayers(match)
    //     .map((p) => p.id)
    //     .toList();
        
    for (Player p in getWinningPlayers(match)){
      matchPlayerStatsRepository.savePlayerStat(
        match.id,
        p.id,
        "WINNER",
        "1"
      );

    }     
    // match.;    
    // saveStat(match.id, "WINNING_PLAYERS", listInttoCsv(playerIds));

    for (Player p in match.playerSet.players) {
      matchPlayerStatsRepository.savePlayerStat(
        match.id,
        p.id,
        "SCORE",
        totalScoreForPlayerId(match, p.id).toString(),
      );
      matchPlayerStatsRepository.savePlayerStat(
        match.id,
        p.id,
        "MAX_ROUND_SCORE",
        maxScoreForPlayerId(match, p.id).toString(),
      );
      matchPlayerStatsRepository.savePlayerStat(
        match.id,
        p.id,
        "AVG_ROUND_SCORE",
        avgScoreForPlayerId(match, p.id).toString(),
      );
      matchPlayerStatsRepository.savePlayerStat(
        match.id,
        p.id,
        "ROUNDS_SCORING_ZERO",
        numRoundsMatchingScore(match, p.id, 0).toString(),
      );
    }
  }

  //-----------------------------------------------------------------

  void saveStat(int matchId, String stat, String value) {
    insert(MatchStats(matchId: matchId, stat: stat, value: value));
  }

  //-----------------------------------------------------------------
  // Insert a new match stat
  Future<int> insert(MatchStats matchStat) async {
    final db = await dbHelper.database;
    return await db.insert(
      tableName,
      matchStat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //-----------------------------------------------------------------

  // Update an existing match stat
  Future<int> update(MatchStats matchStat) async {
    if (matchStat.id == null) {
      throw ArgumentError('Cannot update MatchStats without an id');
    }
    final db = await dbHelper.database;
    return await db.update(
      tableName,
      matchStat.toMap(),
      where: 'id = ?',
      whereArgs: [matchStat.id],
    );
  }

  //-----------------------------------------------------------------

  // Delete a match stat by id
  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  //-----------------------------------------------------------------

  // Get all stats for a specific match
  Future<List<MatchStats>> getByMatchId(int matchId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'match_id = ?',
      whereArgs: [matchId],
    );
    return List.generate(maps.length, (i) => MatchStats.fromMap(maps[i]));
  }

  //-----------------------------------------------------------------

  // Get all stats for a specific game name and player list
  // ie all Rummy matches for Paul & Jane

  Future<List<int>> getMatchIdsByGameStatValue(
    String gameName,
    String stat,
    String value,
  ) async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
        SELECT DISTINCT m1.match_id 
          FROM match_stats m1
          INNER JOIN match_stats m2 ON m1.match_id = m2.match_id
            WHERE m1.stat = 'NAME' AND m1.value = ?
              AND m2.stat = ? AND m2.value = ?
      ''',
      [gameName, stat, value],
    );

    return results.map((row) => row['match_id'] as int).toList();
  }

  //-----------------------------------------------------------------

  Future<List<String>> getWinnersByGamePlayers(
    String gameName,
    String players,
  ) async {
    final db = await dbHelper.database;

    final results = await db.rawQuery(
      '''
        SELECT m.value as winners
          FROM game_players_view gp
          INNER JOIN match_stats m ON gp.match_id = m.match_id
            WHERE gp.game_name = ? 
              AND gp.PLAYERS = ?
              AND m.stat = 'WINNING_PLAYERS'
      ''',
      [gameName, players],
    );

    return results.map((row) => row['winners'] as String).toList();
  }

  //-----------------------------------------------------------------

  // Get a single stat by id
  Future<MatchStats?> getById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return MatchStats.fromMap(maps.first);
  }

  //-----------------------------------------------------------------

  // Get a single value by matchId and by stat
  Future<String?> getByMatchIdAndStat(int matchId, String stat) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      columns: ['value'],
      tableName,
      where: 'matchId = ? AND stat = ?',
      whereArgs: [matchId, stat],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  //-----------------------------------------------------------------

  // Get all match stats
  Future<List<MatchStats>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => MatchStats.fromMap(maps[i]));
  }

  //-----------------------------------------------------------------

  // Delete all records for matches older than the cutoff date

  // call using:
  // Delete matches older than 90 days
  // final cutoff = DateTime.now().subtract(Duration(days: 90));
  // int deletedCount = await repo.deleteOldMatches(cutoff);
  // print('Deleted $deletedCount records');

  Future<int> deleteOldMatches(DateTime cutoffDate) async {
    final cutoffString = cutoffDate.toIso8601String().substring(0, 10);
    final db = await dbHelper.database;
    return await db.delete(
      tableName,
      where:
          '''match_id IN (
        SELECT match_id FROM $tableName 
        WHERE stat = ? AND value < ?
      )''',
      whereArgs: ['DATE', cutoffString],
    );
  }

  //-----------------------------------------------------------------
}
