/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/17/2025
*
*----------------------------------------------------------------------------*/


import 'package:equatable/equatable.dart';
import 'package:scores/mixin/my_utils.dart';
import 'package:scores/models/player.dart';

class Round extends Equatable with MyUtils{

  final Map<String, int> scores = {};

  Round(List<Player>players) {
     for ( Player p in players ) {
      scores[p.id] = 0;
     }
  }

  Round.blank();

  @override
  List<Object?> get props => [scores];

  int? getScore(Player player) {
    return scores[player.id];
  }

  int? getScoreById(String id) {
    return scores[id];
  }

  void setPlayers(List<Player> players) {
     for ( Player p in players ) {
      scores[p.id] = 0;
     }
  }

  void setScore(Player player, int score) {
    scores[player.id] = score;
  }


  void setScoreById(String id, int score) {
    scores[id] = score;
  }


  List<int> getScores() {
    List<int> scoresList = [];

    scores.forEach((player, score) => scoresList.add(score));

    return scoresList;
  }

  List<String> getPlayerIds() => scores.keys.toList();


  void updatePlayerScore(Player player, int score) {
    debugMsg("updatePlayerScore");
    debugMsg("from ${scores[player.id]} with $score");
    scores[player.id] = ( scores[player.id] ?? 0) + score;
    debugMsg("now ${scores[player.id]}");
  }

 // Convert to JSON
  Map<String, dynamic> toJson() {
    debugMsg("toJson");
    return {
      'scores': scores,
    };
  }

  // Create from JSON
  factory Round.fromJson(Map<String, dynamic> json) {
    Round round = Round.blank();
    if (json['scores'] != null) {
      Map<String, dynamic> scoresMap = json['scores'];
      scoresMap.forEach((key, value) {
        round.scores[key] = value as int;
      });
    }
    return round;
  }

  @override
  String toString() {
    String scoresString = "";
    scores.forEach(
      (playerId, score) =>
          scoresString = '$scoresString PlayerId: $playerId Score: $score',
    );
    return scoresString;
  }
}
