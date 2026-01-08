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

import 'package:scores/models/match.dart';

import 'package:scores/database/match_player_stats_repository.dart';
import 'package:scores/database/match_stats_repository.dart';
import 'package:scores/models/match_player_stats.dart';
import 'package:scores/models/match_stats.dart';
import 'package:sqflite/sqflite.dart';

class MatchRepository {
  
  final Database db;
  final MatchStatsRepository matchStatsRepo;
  final MatchPlayerStatsRepository playerStatsRepo;

  MatchRepository(this.db, this.matchStatsRepo, this.playerStatsRepo);

  // Save a complete match to the database
  Future<int> saveMatch(Match match) async {
    // Generate a unique match_id using timestamp
    final matchId = DateTime.now().millisecondsSinceEpoch;

    // Save match-level stats
    await _saveMatchStats(matchId, match);

    // Calculate and save player stats
    await _savePlayerStats(matchId, match);

    return matchId;
  }

  // Save match-level information to match_stats table
  Future<void> _saveMatchStats(int matchId, Match match) async {
    // Save match name
    await matchStatsRepo.insert(MatchStats(
      matchId: matchId,
      stat: 'NAME',
      value: match.name,
    ));

    // Save match date (for cleanup purposes)
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await matchStatsRepo.insert(MatchStats(
      matchId: matchId,
      stat: 'DATE',
      value: today,
    ));
  }

  // Calculate and save player statistics
  Future<void> _savePlayerStats(int matchId, Match match) async {
    // Calculate stats for each player
    for (final player in match.players) {
      final playerId = player.id!;
      
      int totalScore = 0;
      int roundCount = 0;

      // Sum up scores across all rounds
      for (final round in match.rounds) {
        if (round.scores.containsKey(playerId)) {
          totalScore += round.scores[playerId]!;
          roundCount++;
        }
      }

      // Save total score
      await playerStatsRepo.insert(MatchPlayerStats(
        matchId: matchId,
        playerId: playerId,
        stat: 'TOTAL SCORE',
        value: totalScore.toString(),
      ));

      // Save number of rounds
      await playerStatsRepo.insert(MatchPlayerStats(
        matchId: matchId,
        playerId: playerId,
        stat: 'NUMBER OF ROUNDS',
        value: roundCount.toString(),
      ));
    }
  }

  // Load a match from the database (optional - if you need to retrieve)
  Future<Map<String, dynamic>> loadMatch(int matchId) async {
    // Get match stats
    final matchStats = await matchStatsRepo.getByMatchId(matchId);
    
    // Get player stats
    final playerStats = await playerStatsRepo.getByMatchId(matchId);

    // Organize the data
    String matchName = '';
    String matchDate = '';

    for (final stat in matchStats) {
      if (stat.stat == 'NAME') matchName = stat.value;
      if (stat.stat == 'DATE') matchDate = stat.value;
    }

    // Group player stats by player
    final Map<int, Map<String, String>> playerData = {};
    for (final stat in playerStats) {
      if (!playerData.containsKey(stat.playerId)) {
        playerData[stat.playerId] = {};
      }
      playerData[stat.playerId]![stat.stat] = stat.value;
    }

    return {
      'matchId': matchId,
      'name': matchName,
      'date': matchDate,
      'players': playerData,
    };
  }

  // Delete a match and all its associated data
  Future<void> deleteMatch(int matchId) async {
    // Delete player stats (will happen automatically with CASCADE, but explicit is clearer)
    await db.delete('match_player_stats', where: 'match_id = ?', whereArgs: [matchId]);
    
    // Delete match stats
    await db.delete('match_stats', where: 'match_id = ?', whereArgs: [matchId]);
  }
}