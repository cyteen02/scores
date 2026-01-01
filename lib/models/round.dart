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

//import 'dart:convert';

import 'package:scores/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/models/player.dart';

class Round with MyMixin {
  int? id;
  String roundLabel = "";
  final Map<int, int> scores = {};

  Round();

  Round.players(List<Player> players) {
    for (Player p in players) {
      scores[p.id ?? 0] = 0;
    }
  }

  List<Object?> get props => [scores];

  int? getScore(Player player) {
    return scores[player.id];
  }

  int? getScoreById(int id) {
    return scores[id];
  }

  void setPlayers(List<Player> players) {
    for (Player p in players) {
      scores[p.id ?? 0] = 0;
    }
  }

  void setScore(Player player, int score) {
    scores[player.id ?? 0] = score;
  }

  void setScoreById(int id, int score) {
    scores[id] = score;
  }

  List<int> getScores() {
    List<int> scoresList = [];

    scores.forEach((player, score) => scoresList.add(score));

    return scoresList;
  }

  List<int> getPlayerIds() => scores.keys.toList();

  //----------------------------------------------------------------

  void updatePlayerScore(Player player, int score) {
    debugMsg("updatePlayerScore");
    debugMsg("from ${scores[player.id]} with $score");
    scores[player.id ?? 0] = (scores[player.id] ?? 0) + score;
    debugMsg("now ${scores[player.id]}");
  }

  //----------------------------------------------------------------

  void replacePlayer(Player oldPlayer, Player newPlayer) {
    Map<int, int> oldScores = Map.from(scores);
    scores.clear();
    oldScores.forEach((playerId, score) {
      if (playerId == oldPlayer.id) {
        scores[newPlayer.id ?? 0] = score;
      } else {
        scores[playerId] = score;
      }
    });
  }

  //----------------------------------------------------------------

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round_label': roundLabel,
      'scores': scores.map(
        (k, v) => MapEntry(k.toString(), v),
      ), // No jsonEncode needed
    };
  }

  //----------------------------------------------------------------

  // For JSON serialization
  Map<String, dynamic> toJson() => toMap();

  //----------------------------------------------------------------

  // Create from Map when reading from SQLite
  factory Round.fromMap(Map<String, dynamic> map) {
    final round = Round()
      ..id = map['id']
      ..roundLabel = map['round_label'];

    // It's already a Map - no jsonDecode needed
    final decodedScores = map['scores'] as Map<String, dynamic>;
    decodedScores.forEach((key, value) {
      round.scores[int.parse(key.toString())] = value as int;
    });

    return round;
  }

  //----------------------------------------------------------------

  // Create from JSON
  factory Round.fromJson(Map<String, dynamic> json) => Round.fromMap(json);

  //----------------------------------------------------------------

  // Convert to JSON
  Map<String, dynamic> toJsonOld() {
    debugMsg("toJson");
    return {'id': id, 'scores': scores};
  }

  //----------------------------------------------------------------

  // Create from JSON
  factory Round.fromJsonOld(Map<String, dynamic> json) {
    Round round = Round();
    round.id = json['id'] ?? '';
    if (json['scores'] != null) {
      Map<int, dynamic> scoresMap = json['scores'];
      scoresMap.forEach((key, value) {
        round.scores[key] = value as int;
      });
    }
    return round;
  }

  //----------------------------------------------------------------

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
