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

import 'package:intl/intl.dart';
import 'package:scores/database/database_helper.dart';
import 'package:scores/database/match_player_stats_repository.dart';
import 'package:scores/models/match.dart';
import 'package:scores/models/match_stats.dart';
import 'package:scores/models/player.dart';
import 'package:sqflite/sqflite.dart';

class MatchStatsRepository {
  final dbHelper = DatabaseHelper.instance;

  //  MatchStatsRepository(this.db);

  static const String tableName = 'match_stats';

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

    MatchPlayerStatsRepository matchPlayerStatsRepository = MatchPlayerStatsRepository();

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      saveStat(match.id,"DATE", today);    
      saveStat(match.id,"NAME", match.game.name);

      for ( Player p in match.players ) {
        saveStat(match.id,"PLAYER", p.id.toString());        
        matchPlayerStatsRepository.savePlayerStat(match.id, p.id??0, "SCORE", match.totalScoreForPlayerId(p.id??0).toString());
        matchPlayerStatsRepository.savePlayerStat(match.id, p.id??0, "MAX_ROUND_SCORE", match.maxScoreForPlayerId(p.id??0).toString());
        matchPlayerStatsRepository.savePlayerStat(match.id, p.id??0, "AVG_ROUND_SCORE", match.avgScoreForPlayerId(p.id??0).toString());
        matchPlayerStatsRepository.savePlayerStat(match.id, p.id??0, "ROUNDS_SCORING_ZERO", match.numRoundsMatchingScore(p.id??0, 0).toString());

      }

      for ( Player p in match.getWinningPlayers() ) {
        saveStat(match.id,"WINNING_PLAYERS", p.id.toString());        
      }
  }

  //-----------------------------------------------------------------

  void saveStat(int matchId, String stat, String value ) {
    insert(MatchStats(matchId: matchId, stat: stat, value: value ));
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
