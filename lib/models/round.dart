import 'package:equatable/equatable.dart';
import 'package:scores/mixin/my_utils.dart';
import 'package:scores/models/player.dart';

class Round extends Equatable with MyUtils{


  final Map<String, int> scores = {};

  Round(List<Player>players) {
     for ( Player p in players ) {
      scores[p.name] = 0;
     }
  }

  Round.blank();

  @override
  List<Object?> get props => [scores];

  int? getScore(Player player) {
    return scores[player.name];
  }


  int? getScoreByName(String playerName) {
    return scores[playerName];
  }

  void setPlayers(List<Player> players) {
     for ( Player p in players ) {
      scores[p.name] = 0;
     }
  }

  void setScore(Player player, int score) {
    scores[player.name] = score;
  }


  void setScoreByName(String playerName, int score) {
    scores[playerName] = score;
  }


  List<int> getScores() {
    List<int> scoresList = [];

    scores.forEach((player, score) => scoresList.add(score));

    return scoresList;
  }

  List<String> getPlayerNames() => scores.keys.toList();


  void updatePlayerScore(Player player, int score) {
    debugMsg("updatePlayerScore");
    debugMsg("from ${scores[player.name]} with $score");
    scores[player.name] = ( scores[player.name] ?? 0) + score;
    debugMsg("now ${scores[player.name]}");
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
      (playerName, score) =>
          scoresString = '$scoresString PlayerName: $playerName Score: $score',
    );
    return scoresString;
  }
}
