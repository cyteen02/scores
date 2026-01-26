/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/12/2026
*
*----------------------------------------------------------------------------*/

// Calculate historic stats based on data retrived from
// the database

// NOTES on a service class:
// No UI dependencies
// No direct database access (they receive data as parameters)

// for this combination of players
// number of wins
// highest score
//
// for player playing this game, irrespective of who their oponents are
//

import 'package:scores/data/models/match_player_stats.dart';
import 'package:scores/utils/my_utils.dart';

Map<String, dynamic> calcMatchHistoricStats(
  List<MatchPlayerStats> matchPlayerStatsList,
) {
  // eg:
  // maxScores[playerId] = 99
  Map<int, int> numWins = {};
  Map<int, int> maxScores = {};
  Map<int, int> totalScores = {};
  Map<int, int> minScores = {};

  // init values
  List<int> playerIds = matchPlayerStatsList
      .map((stat) => stat.playerId)
      .toSet()
      .toList();
  for (int id in playerIds) {
    numWins[id] = 0;
    totalScores[id] = 0;
    maxScores[id] = 0;
  }

  for (MatchPlayerStats matchPlayerStats in matchPlayerStatsList) {
    var playerId = matchPlayerStats.playerId;
    if (matchPlayerStats.stat == 'SCORE') {
      int score = int.parse(matchPlayerStats.value);

      if ((maxScores[playerId] ?? 0) < score) {
        maxScores[playerId] = score;
      }

      if ((minScores[playerId] ?? 9999) > score) {
        minScores[playerId] = score;
      }

      totalScores[playerId] = ((totalScores[playerId] ?? 0) + score);
    }
    if (matchPlayerStats.stat == 'WINNER') {
      var oldNumWins = numWins[playerId] ?? 0;
      numWins[playerId] = oldNumWins + 1;
      debugMsg(
        "stat ${matchPlayerStats.stat} playerId $playerId numWins ${numWins[playerId]} ",
      );
    }
  }

  return {
    'numWins': numWins,
    'minScores': minScores,
    'maxScores': maxScores,
    'totalScores': totalScores,
  };
}
