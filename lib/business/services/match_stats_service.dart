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

// Calculate  stats based on a completed match

// NOTES on a service class:
// No UI dependencies
// No direct database access (they receive data as parameters)

import 'package:scores/data/models/game.dart';
import 'package:scores/data/models/player.dart';
import 'package:scores/data/models/match.dart';
import 'package:scores/data/models/round.dart';
import 'package:scores/utils/my_utils.dart';

//-------------------------------------------------------------------

Map<String, dynamic> matchStats(Match match) {
  
  final winnersList = getWinningPlayers(match);

/*
In this match:
  list of winning player id's
  min, max,and total score for each player id
*/

  Map<int, int> maxScore = {};
  Map<int, int> totalScore = {};
  Map<int, int> minScore = {};

  int id = 0;

  int playerScore = 0;
  for (Player player in match.players) {
    id = player.id;

    playerScore = totalScoreForPlayerId(match, id);

    if ((maxScore[id] ?? 0) < playerScore) {
      maxScore[id] = playerScore;
    }

    if ((minScore[id] ?? 9999) > playerScore) {
      minScore[id] = playerScore;
    }

    totalScore[id] = (totalScore[id] ?? 0) + playerScore;
  }

  return {
    'winners': winnersList,
    'minScore': minScore,
    'maxScore': maxScore,
    'totalScore': totalScore,
  };
}
  //-------------------------------------------------------------------

  int totalScoreForPlayerId(Match match, int playerId) {
    int totalScore = 0;
    for (Round round in match.rounds) {
      totalScore += round.getScoreById(playerId) ?? 0;
    }
    return totalScore;
  }

  //-----------------------------------------------------------------

  int numRoundsMatchingScore(Match match, int playerId, int score) {
    int numRounds = 0;
    for (Round round in match.rounds) {
      if ((round.getScoreById(playerId) ?? 0) == score) {
        numRounds++;
      }
    }
    return numRounds;
  }

  //-----------------------------------------------------------------

  int maxScoreForPlayerId(Match match, int playerId) {
    int maxScore = 0;
    for (Round round in match.rounds) {
      var playerScore = round.getScoreById(playerId) ?? 0;
      if (playerScore > maxScore) {
        maxScore = playerScore;
      }
    }
    return maxScore;
  }

  //-----------------------------------------------------------------

  int minScoreForPlayerId(Match match, int playerId) {
    // hoping this is a reasonable highest score!
    int minScore = 999999;
    for (Round round in match.rounds) {
      var playerScore = round.getScoreById(playerId) ?? 0;
      if (playerScore < minScore) {
        minScore = playerScore;
      }
    }
    return minScore;
  }

  //-----------------------------------------------------------------

  double avgScoreForPlayerId(Match match, int playerId) {
//    return totalScoreForPlayerId(playerId) / numRoundsPlayed();
    return double.parse((totalScoreForPlayerId(match, playerId) / match.numRoundsPlayed()).toStringAsFixed(2));

  }

  //-----------------------------------------------------------------

  List<int> getTotalScores(Match match) {
    debugMsg("Match getTotalScores");

    Map<int, int> totalScores = {};

    for (Player player in match.players) {
      totalScores[player.id] = totalScoreForPlayerId(match, player.id);
    }

    return totalScores.values.toList();
  }

  //-----------------------------------------------------------------

  int getHighestScore(Match match) {
    return getTotalScores(match).reduce((a, b) => a > b ? a : b);
  }

  //-----------------------------------------------------------------

  int getLowestScore(Match match) {
    return getTotalScores(match).reduce((a, b) => a < b ? a : b);
  }

  //-----------------------------------------------------------------

  Map<int,int> getMaxScoresForPlayers( Match match ) {
    Map<int,int> playerScores = {};
    for ( Player player in match.players ){
      playerScores[player.id] = maxScoreForPlayerId(match, player.id);
    }
    return playerScores;
  }

  //-----------------------------------------------------------------

  Map<int,int> getMinScoresForPlayers( Match match ) {
    Map<int,int> playerScores = {};
    for ( Player player in match.players ){
      playerScores[player.id] = minScoreForPlayerId(match, player.id);
    }
    return playerScores;
  }
  
  //-----------------------------------------------------------------

  Map<int,int> getNumMatchingScoresForPlayers( Match match, int scoreToMatch ) {
    Map<int,int> playerScores = {};
    for ( Player player in match.players ){
      playerScores[player.id] = numRoundsMatchingScore(match, player.id, scoreToMatch);
    }
    return playerScores;
  }
  
  //-----------------------------------------------------------------


  List<Player> getHighestScorePlayers(Match match) {
    // return a list of players who get the winning score

    List<Player> highestScorePlayers = [];
    int highestScore = getHighestScore(match);

    for (Player player in match.players) {
      if (totalScoreForPlayerId(match, player.id) == highestScore) {
        highestScorePlayers.add(player);
      }
    }
    return highestScorePlayers;
  }

  //-----------------------------------------------------------------

  List<Player> getLowestScorePlayers(Match match) {
    // return a list of players who get the lowest score

    List<Player> lowestScorePlayers = [];
    int lowestScore = getLowestScore(match);

    for (Player player in match.players) {
      if (totalScoreForPlayerId(match, player.id) == lowestScore) {
        lowestScorePlayers.add(player);
      }
    }
    return lowestScorePlayers;
  }

  //-----------------------------------------------------------------

  List<Player> getWinningPlayers(Match match) {
    if (match.game.winCondition == WinCondition.highestScore) {
      return getHighestScorePlayers(match);
    } else {
      return getLowestScorePlayers(match);
    }
  }

  //-------------------------------------------------------------------
