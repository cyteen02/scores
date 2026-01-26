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

import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/match_history.dart';
import 'package:scores/data/repositories/database_helper.dart';
import 'package:scores/data/repositories/location_repository.dart';
import 'package:scores/data/repositories/match_history_repository.dart';

import 'package:scores/data/repositories/match_player_stats_repository.dart';
import 'package:scores/data/repositories/match_stats_repository.dart';
import 'package:scores/data/repositories/player_set_repository.dart';
//import 'package:scores/data/models/match_player_stats.dart';
//import 'package:scores/data/models/match_stats.dart';
import 'package:scores/utils/my_utils.dart';
//import 'package:sqflite/sqflite.dart';

class MatchRepository {
  final dbHelper = DatabaseHelper.instance;

  final PlayerSetRepository playerSetRepository;
  final LocationRepository locationRepository;
  final MatchHistoryRepository matchHistoryRepository;
  final MatchStatsRepository matchStatsRepository;
  final MatchPlayerStatsRepository matchPlayerStatsRepository;

  MatchRepository(
    this.playerSetRepository,
    this.locationRepository,
    this.matchHistoryRepository,
    this.matchStatsRepository,
    this.matchPlayerStatsRepository,
  );

  //--------------------------------------------------------------

  // Save a completed match to the database
  Future<int> saveMatch(Match match) async {
    // Save match-level stats

    debugMsg("matchRepository saveMatch matchId ${match.id}");

    // Save the player set

    int playerSetId;
    if (!await playerSetRepository.exists(match.playerSet.id ?? 0)) {
      playerSetId = await playerSetRepository.insert(match.playerSet);
    } else {
      playerSetId = match.playerSet.id ?? 0;
    }

    matchHistoryRepository.insert(
      MatchHistory(
        matchId: match.id,
        gameId: match.game.id ?? 0,
        playerSetId: playerSetId,
      ),
    );

    matchStatsRepository.saveStats(match);

    //    await _saveMatchStats(matchId, match);

    // Calculate and save player stats
    //    await _savePlayerStats(matchId, match);

    return match.id;
  }

  //--------------------------------------------------------------

  // // Save match-level information to match_stats table
  // Future<void> _saveMatchStats(int matchId, Match match) async {
  //   // Save match name
  //   await matchStatsRepository.insert(MatchStats(
  //     matchId: matchId,
  //     stat: 'NAME',
  //     value: match.name,
  //   ));

  //   // Save match date (for cleanup purposes)
  //   final today = DateTime.now().toIso8601String().substring(0, 10);
  //   await matchStatsRepository.insert(MatchStats(
  //     matchId: matchId,
  //     stat: 'DATE',
  //     value: today,
  //   ));
  // }

  //--------------------------------------------------------------

  // // Calculate and save player statistics
  // Future<void> _savePlayerStats(int matchId, Match match) async {
  //   // Calculate stats for each player
  //   for (final player in match.players) {
  //     final playerId = player.id!;

  //     int totalScore = 0;
  //     int roundCount = 0;

  //     // Sum up scores across all rounds
  //     for (final round in match.rounds) {
  //       if (round.scores.containsKey(playerId)) {
  //         totalScore += round.scores[playerId]!;
  //         roundCount++;
  //       }
  //     }

  //     // Save total score
  //     await matchPlayerStatsRepository.insert(MatchPlayerStats(
  //       matchId: matchId,
  //       playerId: playerId,
  //       stat: 'TOTAL SCORE',
  //       value: totalScore.toString(),
  //     ));

  //     // Save number of rounds
  //     await matchPlayerStatsRepository.insert(MatchPlayerStats(
  //       matchId: matchId,
  //       playerId: playerId,
  //       stat: 'NUMBER OF ROUNDS',
  //       value: roundCount.toString(),
  //     ));
  //   }
  // }

  //--------------------------------------------------------------

  // Load a match from the database (optional - if you need to retrieve)
  Future<Map<String, dynamic>> loadMatchOLD(int matchId) async {
    // Get match stats
    final matchStats = await matchStatsRepository.getByMatchId(matchId);

    // Get player stats
    final playerStats = await matchPlayerStatsRepository.getByMatchId(matchId);

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

  //--------------------------------------------------------------

  // Delete a match and all its associated data
  Future<void> deleteMatch(int matchId) async {
    // Delete player stats (will happen automatically with CASCADE, but explicit is clearer)
    final db = await dbHelper.database;

    await db.delete(
      'match_player_stats',
      where: 'match_id = ?',
      whereArgs: [matchId],
    );

    // Delete match stats

    await db.delete('match_stats', where: 'match_id = ?', whereArgs: [matchId]);
  }

  //--------------------------------------------------------------
}
