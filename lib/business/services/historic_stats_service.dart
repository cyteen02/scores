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

Map<String, dynamic> calcMatchHistoricStats(List<MatchPlayerStats> matchPlayerStatsList) {
  // eg:
  // maxScores[playerId] = 99
    Map<int, int> numWins = {};
  Map<int, int> maxScores = {};
  Map<int, int> totalScores = {};
  Map<int, int> minScores = {};

  for ( MatchPlayerStats matchPlayerStats in matchPlayerStatsList) {
    var playerId = matchPlayerStats.playerId;
    if ( matchPlayerStats.stat == 'SCORE') {
      int score = int.parse(matchPlayerStats.value);

    if ((maxScores[playerId] ?? 0) < score) {
      maxScores[playerId] = score;
    }

    if ((minScores[playerId] ?? 9999) > score) {
      minScores[playerId] = score;
    }

    totalScores[playerId] = ((totalScores[playerId]??0) + score);
    }
    if ( matchPlayerStats.stat == 'WINNER') {
       numWins[playerId] = numWins[playerId]??0 + 1;
    }
  }

  return {
    'numWins': numWins,
    'minScores': minScores,
    'maxScores': maxScores,
    'totalScores': totalScores,
  };
}
