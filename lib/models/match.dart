/*---------------------------------------------------------------------------
*
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

import 'package:flutter/material.dart';

import 'package:scores/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';
import 'package:scores/models/game.dart';

// a MATCH is where a group of PLAYERs play a GAME

class Match with MyMixin {
  int? _id;
  late String _name;
  Game game = Game();
  List<Player> players = <Player>[];
  List<Round> rounds = <Round>[];

  // Constructor
  Match() {
    _name = "";
    _id = DateTime.now().millisecondsSinceEpoch * 1000 + Random().nextInt(1000);
  }

  Match.name(String name) {
    _name = name;
    _id = DateTime.now().millisecondsSinceEpoch * 1000 + Random().nextInt(1000);
    game = Game.name(name);
  }

  // Match.id(int id) {
  //   id = id;
  // }

  // getters
  String get name => _name;

  int get id {
    _id ??= DateTime.now().millisecondsSinceEpoch * 100 + Random().nextInt(1000);
    return _id!;
  }
  //  GameType3 get gameType => gameType;

  //  List<Player> get players => players;

  //  List<Round> get rounds => rounds;

  // Setters

  // set named(String value) => name = value;
  // set name(String name) {
  //   name = name;
  //   gameType = GameType(name);
  // }

  void setPlayers(List<Player> newPlayers) {
    debugMsg("Match setPlayers $newPlayers");
    players.clear();
    players.addAll(newPlayers);
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
    players.add(player);
  }

  //-----------------------------------------------------------------

  bool playerNameExists(String playerName) {
    return players.any((p) => p.name == playerName);
  }
  //-----------------------------------------------------------------

  void addPlayers(List<Player> newPlayers) {
    for (Player p in newPlayers) {
      players.add(p);
    }
  }

  //-----------------------------------------------------------------

  void addPlayerByName(String playerName) {
    bool playerNameFound = false;
    for (Player p in players) {
      playerNameFound = playerNameFound | (p.name == playerName);
    }

    if (!playerNameFound) {
      var player = Player.name(playerName);
      player.setColor(Colors.black);
      addPlayer(player);
    }
  }

  //-----------------------------------------------------------------

  void initFirstRound() {
    Round firstRound = Round();
    firstRound.setPlayers(players);
    firstRound.roundLabel = game.roundList[0];
    rounds.add(firstRound);
  }

  //-----------------------------------------------------------------

  bool useRoundLabels() {
    return game.roundList.isNotEmpty;
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
    return players.cast<Player?>().firstWhere(
      (p) => p?.name == playerName,
      orElse: () => null,
    );
  }
  //-----------------------------------------------------------------

  Player? getPlayerById(int playerId) {
    return players.cast<Player?>().firstWhere(
      (p) => p?.id == playerId,
      orElse: () => null,
    );
  }

  //-----------------------------------------------------------------

  List<String> getPlayerNames() {
    return players.map((p) => p.name).toList();
  }

  //-----------------------------------------------------------------

  List<int> getPlayerIds() {
    return players.map((p) => p.id ?? 0).toList();
  }

  //-----------------------------------------------------------------

  int numPlayers() {
    return players.length;
  }

  //-----------------------------------------------------------------

  void replacePlayer(Player oldPlayer, Player newPlayer) {
    int index = players.indexWhere((player) => player.name == oldPlayer.name);
    players[index] = newPlayer;

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

  int totalScoreForPlayerId(int playerId) {
    int totalScore = 0;
    for (Round round in rounds) {
      totalScore += round.getScoreById(playerId) ?? 0;
    }
    return totalScore;
  }

//-----------------------------------------------------------------

  int numRoundsMatchingScore(int playerId, int score) {
    int numRounds = 0;
    for (Round round in rounds) {
      if ( ( round.getScoreById(playerId) ?? 0 ) == score ){
          numRounds++;
      }
    }
    return numRounds;
  }

  //-----------------------------------------------------------------

  int maxScoreForPlayerId(int playerId) {
    int maxScore = 0;
    for (Round round in rounds) {
      var playerScore = round.getScoreById(playerId) ?? 0;
      if ( playerScore > maxScore ) {
        maxScore = playerScore;
      }
    }
    return maxScore;
  }

  //-----------------------------------------------------------------

  int minScoreForPlayerId(int playerId) {
    // hoping this is a reasonable highest score!
    int minScore = 999999;
    for (Round round in rounds) {
      var playerScore = round.getScoreById(playerId) ?? 0;
      if ( playerScore < minScore ) {
        minScore = playerScore;
      }
    }
    return minScore;
  }

  //-----------------------------------------------------------------

  double avgScoreForPlayerId(int playerId) {
    return totalScoreForPlayerId(playerId) / numRoundsPlayed();
  }


  //-----------------------------------------------------------------

  List<int> getTotalScores() {
    debugMsg("Match getTotalScores");

    Map<int, int> totalScores = {};

    for (Player player in players) {
      totalScores[player.id ?? 0] = totalScoreForPlayerId(player.id ?? 0);
    }

    return totalScores.values.toList();
  }

  //-----------------------------------------------------------------

  int getHighestScore() {
    return getTotalScores().reduce((a, b) => a > b ? a : b);
  }

  //-----------------------------------------------------------------

  int getLowestScore() {
    return getTotalScores().reduce((a, b) => a < b ? a : b);
  }

  //-----------------------------------------------------------------

  List<Player> getHighestScorePlayers() {
    // return a list of players who get the winning score

    List<Player> highestScorePlayers = [];
    int highestScore = getHighestScore();

    for (Player player in players) {
      if (totalScoreForPlayerId(player.id ?? 0) == highestScore) {
        highestScorePlayers.add(player);
      }
    }
    return highestScorePlayers;
  }

  //-----------------------------------------------------------------

  List<Player> getLowestScorePlayers() {
    // return a list of players who get the lowest score

    List<Player> lowestScorePlayers = [];
    int lowestScore = getLowestScore();

    for (Player player in players) {
      if (totalScoreForPlayerId(player.id ?? 0) == lowestScore) {
        lowestScorePlayers.add(player);
      }
    }
    return lowestScorePlayers;
  }

  //-----------------------------------------------------------------

  List<Player> getWinningPlayers() {
    if (game.winCondition == WinCondition.highestScore) {
      return getHighestScorePlayers();
    } else {
      return getLowestScorePlayers();
    }
  }
  //-----------------------------------------------------------------

  // List<int> totalScoresList = [];

  // totalScores.forEach((player, score) {
  //   totalScoresList.add(totalScores[player] ?? 0);
  // });

  // return totalScoresList;
  // }

  //-----------------------------------------------------------------

  void record() {
    debugMsg("Match record");
  }

  //-----------------------------------------------------------------

  void resetScores() {
    debugMsg("Match resetScores");
    rounds.clear();
  }

  //-----------------------------------------------------------------

  void clear() {
    debugMsg("Match clear");
    rounds.clear();
  }

  //-----------------------------------------------------------------

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'game_type_id': game.id, // Store foreign key
      'players': jsonEncode(players.map((p) => p.toMap()).toList()),
      'rounds': jsonEncode(rounds.map((r) => r.toMap()).toList()),
    };
  }

  //-----------------------------------------------------------------
  // For JSON serialization (calls toMap)
  Map<String, dynamic> toJson() => toMap();

  //-----------------------------------------------------------------

  // Convert to JSON
  Map<String, dynamic> toJsonOld() {
    debugMsg("Match toJson");

    Map<String, dynamic> jsonString;

    jsonString = {
      'id': _id,
      'name': _name,
      'players': players.map((player) => player.toJson()).toList(),
      'rounds': rounds.map((round) => round.toJson()).toList(),
    };

    debugMsg(jsonString.toString(), true);
    return jsonString;
  }

  //-----------------------------------------------------------------

  // Create from JSON
  factory Match.fromJson(Map<String, dynamic> json) {
    Match match = Match.name(json['name']);
    match._id = json['id'];

    // Decode the JSON string first, then map
    match.players = json['players'] != null
        ? (jsonDecode(json['players']) as List)
              .map((playerJson) => Player.fromJson(playerJson))
              .toList()
        : <Player>[];

    match.rounds = json['rounds'] != null
        ? (jsonDecode(json['rounds']) as List)
              .map((roundJson) => Round.fromJson(roundJson))
              .toList()
        : <Round>[];
        
    debugMsg("++++++++++++++++++++++++++++++++++++++++");
    debugMsg(match.toString());
    debugMsg("++++++++++++++++++++++++++++++++++++++++");

    return match;
  }

  //-----------------------------------------------------------------

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();

    buffer.write("id $id name:$_name");

    buffer.write(" players[");
    for (var player in players) {
      buffer.write(" ");
      buffer.write(player.toString());
    }
    buffer.write("] rounds[");

    for (var round in rounds) {
      buffer.write(" ");
      buffer.write(round.toString());
    }
    buffer.write("] ");

    buffer.write(game);

    return buffer.toString();
  }

  //-----------------------------------------------------------------
}
