/*---------------------------------------------------------------------------

* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/13/2025
*
*----------------------------------------------------------------------------*/

import 'dart:convert';
import 'dart:math';

//import 'package:flutter/material.dart';
import 'package:scores/data/models/player_set.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/player.dart';
import 'package:scores/data/models/round.dart';
import 'package:scores/data/models/game.dart';

// a MATCH is where a group of PLAYERs play a GAME

class Match with MyMixin {
  int id;
  Game game;
  PlayerSet playerSet;
  List<Round> rounds;

  // Constructor
  Match({
    int? id,
    required this.game,
    required this.playerSet,
    List<Round>? rounds
  }) : id = id ?? MyMixin.generateId(),
      rounds = rounds ?? [];
      
  // Match() {
  //   _name = "";
  //   _id = DateTime.now().millisecondsSinceEpoch * 1000 + Random().nextInt(1000);
  // }

  // Match.name(String name) {
  //   _name = name;
  //   _id = DateTime.now().millisecondsSinceEpoch * 1000 + Random().nextInt(1000);
  //   game = Game.name(name);
  // }

  // Match.id(int id) {
  //   id = id;
  // }

  // getters
  String get name => game.name;

  // int get id {
  //   id ??=
  //       DateTime.now().millisecondsSinceEpoch * 100 + Random().nextInt(1000);
  //   return _id!;
  // }

  List<Player> get players => playerSet.players;

  String get playersCsv {
    //    List<int> playerIds = players.map((p) => p.id ?? 0 ).toList();
    //    return listInttoCsv(playerIds);
    return playerSet.toCsv;

    // playerIds.sort();
    // return playerIds.map((id) => id.toString()).join(",");
  }

  void setPlayers(List<Player> newPlayers) {
    debugMsg("Match setPlayers $newPlayers");
    playerSet = PlayerSet(players: newPlayers);
    // playerSet.clearPlayers();
    // players.addAll(newPlayers);
  }

  void setRounds(List<Round> newRounds) {
    debugMsg("Match setRounds $newRounds");
    rounds.clear();
    rounds.addAll(newRounds);
  }

  // set players(List<Player> players) => players = players;

  // set rounds(List<Round> rounds) => rounds = rounds;

  //-----------------------------------------------------------------

  void addPlayer(Player player) {
    playerSet.addPlayer(player);
  }

  //-----------------------------------------------------------------

  // bool playerNameExists(String playerName) {
  //   return players.any((p) => p.name == playerName);
  // }
  // //-----------------------------------------------------------------

  void addPlayers(List<Player> newPlayers) {
    playerSet.addPlayers(newPlayers);
  }

  //-----------------------------------------------------------------

  // void addPlayerByName(String playerName) {
  //   bool playerNameFound = false;
  //   for (Player p in players) {
  //     playerNameFound = playerNameFound | (p.name == playerName);
  //   }

  //   if (!playerNameFound) {
  //     var player = Player.name(playerName);
  //     player.setColor(Colors.black);
  //     addPlayer(player);
  //   }
  // }

  //-----------------------------------------------------------------

  void initFirstRound() {

    Round firstRound = Round();
    if ( game.roundLabels.isNotEmpty) {
      firstRound.roundLabel = game.roundLabels[0];
    }
    firstRound.initPlayerScores(playerSet.players);
    rounds.add(firstRound);
  }

  //-----------------------------------------------------------------

  bool useRoundLabels() {
    return game.roundLabels.isNotEmpty;
  }

  //-----------------------------------------------------------------

  ShowFutureRoundsType showFutureRoundsType() {
    return game.showFutureRoundsType;
  }

  //-----------------------------------------------------------------

  void addRound(Round round) {
    rounds.add(round);
  }

  //-----------------------------------------------------------------

  Player? getPlayerByName(String playerName) {
    return playerSet.players.cast<Player?>().firstWhere(
      (p) => p?.name == playerName,
      orElse: () => null,
    );
  }
  //-----------------------------------------------------------------

  Player? getPlayerById(int playerId) {
    return playerSet.players.cast<Player?>().firstWhere(
      (p) => p?.id == playerId,
      orElse: () => null,
    );
  }

  //-----------------------------------------------------------------

  List<String> getPlayerNames() {
    return playerSet.players.map((p) => p.name).toList();
  }

  //-----------------------------------------------------------------

  List<int> getPlayerIds() {
    return playerSet.players.map((p) => p.id).toList();
  }

  //-----------------------------------------------------------------

  int numPlayers() {
    return playerSet.numPlayers;
  }

  //-----------------------------------------------------------------

  void replacePlayer(Player oldPlayer, Player newPlayer) {
    playerSet.replacePlayer(oldPlayer, newPlayer);
    // relpace player in all the rounds as well
    for (Round round in rounds) {
      round.replacePlayer(oldPlayer, newPlayer);
    }
  }
  //-----------------------------------------------------------------

  int numRoundsPlayed() {
    return rounds.length;
  }
  //-----------------------------------------------------------------

  //   int totalScoreForPlayerId(int playerId) {
  //     int totalScore = 0;
  //     for (Round round in rounds) {
  //       totalScore += round.getScoreById(playerId) ?? 0;
  //     }
  //     return totalScore;
  //   }

  //   //-----------------------------------------------------------------

  //   int numRoundsMatchingScore(int playerId, int score) {
  //     int numRounds = 0;
  //     for (Round round in rounds) {
  //       if ((round.getScoreById(playerId) ?? 0) == score) {
  //         numRounds++;
  //       }
  //     }
  //     return numRounds;
  //   }

  //   //-----------------------------------------------------------------

  //   int maxScoreForPlayerId(int playerId) {
  //     int maxScore = 0;
  //     for (Round round in rounds) {
  //       var playerScore = round.getScoreById(playerId) ?? 0;
  //       if (playerScore > maxScore) {
  //         maxScore = playerScore;
  //       }
  //     }
  //     return maxScore;
  //   }

  //   //-----------------------------------------------------------------

  //   int minScoreForPlayerId(int playerId) {
  //     // hoping this is a reasonable highest score!
  //     int minScore = 999999;
  //     for (Round round in rounds) {
  //       var playerScore = round.getScoreById(playerId) ?? 0;
  //       if (playerScore < minScore) {
  //         minScore = playerScore;
  //       }
  //     }
  //     return minScore;
  //   }

  //   //-----------------------------------------------------------------

  //   double avgScoreForPlayerId(int playerId) {
  // //    return totalScoreForPlayerId(playerId) / numRoundsPlayed();
  //     return double.parse((totalScoreForPlayerId(playerId) / numRoundsPlayed()).toStringAsFixed(2));

  //   }

  //   //-----------------------------------------------------------------

  //   List<int> getTotalScores() {
  //     debugMsg("Match getTotalScores");

  //     Map<int, int> totalScores = {};

  //     for (Player player in players) {
  //       totalScores[player.id ?? 0] = totalScoreForPlayerId(player.id ?? 0);
  //     }

  //     return totalScores.values.toList();
  //   }

  //   //-----------------------------------------------------------------

  //   int getHighestScore() {
  //     return getTotalScores().reduce((a, b) => a > b ? a : b);
  //   }

  //   //-----------------------------------------------------------------

  //   int getLowestScore() {
  //     return getTotalScores().reduce((a, b) => a < b ? a : b);
  //   }

  //   //-----------------------------------------------------------------

  //   List<Player> getHighestScorePlayers() {
  //     // return a list of players who get the winning score

  //     List<Player> highestScorePlayers = [];
  //     int highestScore = getHighestScore();

  //     for (Player player in players) {
  //       if (totalScoreForPlayerId(player.id ?? 0) == highestScore) {
  //         highestScorePlayers.add(player);
  //       }
  //     }
  //     return highestScorePlayers;
  //   }

  //   //-----------------------------------------------------------------

  //   List<Player> getLowestScorePlayers() {
  //     // return a list of players who get the lowest score

  //     List<Player> lowestScorePlayers = [];
  //     int lowestScore = getLowestScore();

  //     for (Player player in players) {
  //       if (totalScoreForPlayerId(player.id ?? 0) == lowestScore) {
  //         lowestScorePlayers.add(player);
  //       }
  //     }
  //     return lowestScorePlayers;
  //   }

  //   //-----------------------------------------------------------------

  //   List<Player> getWinningPlayers() {
  //     if (game.winCondition == WinCondition.highestScore) {
  //       return getHighestScorePlayers();
  //     } else {
  //       return getLowestScorePlayers();
  //     }
  //   }
  //   //-----------------------------------------------------------------

  // List<int> totalScoresList = [];

  // totalScores.forEach((player, score) {
  //   totalScoresList.add(totalScores[player] ?? 0);
  // });

  // return totalScoresList;
  // }

  //-----------------------------------------------------------------

  // void record() {
  //   debugMsg("Match record");
  // }

  //-----------------------------------------------------------------

  void resetScores() {
    debugMsg("Match resetScores");
    rounds.clear();
  }

  //-----------------------------------------------------------------

  void clear() {
    debugMsg("Match clear");

    rounds.clear();
    // generate a new id
    id = DateTime.now().millisecondsSinceEpoch * 1000 + Random().nextInt(1000);
  }

  //-----------------------------------------------------------------

  bool matchFinished() {
    final finished =
        (rounds.isNotEmpty && rounds.length == game.roundLabels.length);

    debugMsg("matchFinished finished $finished");

    return finished;
  }

  //-----------------------------------------------------------------
  // Convert to Map for SQLite
  // note match is never recorded in the database.
  // its in local storage during play
  // then match_history and _stats is recorded after

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'game_type_id': game.id, // Store foreign key
      'players': jsonEncode(playerSet.players.map((p) => p.toMap()).toList()),
      'rounds': jsonEncode(rounds.map((r) => r.toMap()).toList()),
    };
  }

  //-----------------------------------------------------------------
  // For JSON serialization (calls toMap)
  //  Map<String, dynamic> toJson() => toMap();
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game': game.toJson(),
      'playerSet': playerSet.toJson(),
      'game_type_id': game.id, // Store foreign key
      'rounds': jsonEncode(rounds.map((r) => r.toMap()).toList()),
    };
  }

  //-----------------------------------------------------------------

  // Convert to JSON
  Map<String, dynamic> toJsonOld() {
    debugMsg("Match toJson");

    Map<String, dynamic> jsonString;

    jsonString = {
      'id': id,
      'game': game.toJson(),
      'playerSet': playerSet.toJson(),
      'rounds': rounds.map((round) => round.toJson()).toList(),
    };

    debugMsg(jsonString.toString(), true);
    return jsonString;
  }

  //-----------------------------------------------------------------

  // Create from JSON
  factory Match.fromJson(Map<String, dynamic> json) {
    int id = json['id'];

    Game game = Game(name: "");
    if (json.containsKey('game')) {
      game = Game.fromJson(json['game']);
    }

    PlayerSet playerSet = PlayerSet();
    if (json.containsKey('playerSet')) {
      playerSet = PlayerSet.fromJson(json['playerSet']);
    }

    // if (json.containsKey('players')) {
    //   List<Player> players = json['players'] != null
    //       ? (jsonDecode(json['players']) as List)
    //           .map((playerJson) => Player.fromJson(playerJson))
    //           .toList()
    //     : <Player>[];

    //   match.playerSet = PlayerSet(players: players);
    // }

    // Decode the JSON string first, then map
    List<Round> rounds;

    rounds = json['rounds'] != null
        ? (jsonDecode(json['rounds']) as List)
              .map((roundJson) => Round.fromJson(roundJson))
              .toList()
        : <Round>[];

    Match match = Match(
      id: id,
      game: game,
      playerSet: playerSet,
      rounds: rounds,
    );

    debugMsg("++++++++++++++++++++++++++++++++++++++++");
    debugMsg(match.toString());
    debugMsg("++++++++++++++++++++++++++++++++++++++++");

    return match;
  }

  //---------------------------------------------------------------------------
  // Create a copy with optional field updates
  Match copyWith({
    int? id,
    Game? game,
    PlayerSet? playerSet,
    List<Round>? rounds,
  }) {
    return Match(
      id: id ?? this.id,
      game: game ?? this.game,
      playerSet: playerSet ?? this.playerSet,
      rounds: rounds ?? this.rounds,
    );
  }

  //-----------------------------------------------------------------

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();

    buffer.write("id $id game $game");

    buffer.write(" players[");
    for (var player in playerSet.players) {
      buffer.write(" ");
      buffer.write(player.toString());
    }
    buffer.write("] rounds[");

    for (var round in rounds) {
      buffer.write(" ");
      buffer.write(round.toString());
    }
    buffer.write("]");

        return buffer.toString();
  }

  //-----------------------------------------------------------------
}
