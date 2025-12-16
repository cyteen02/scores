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

import 'package:scores/mixin/my_utils.dart';
import 'package:scores/models/player.dart';
import 'package:scores/models/round.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Game with MyUtils {
  String _id = "";
  String _name = "";
  List<Player> _players = <Player>[];
  List<Round> _rounds = <Round>[];

  // Constructor
  Game(String name) {
    _id = uuid.v1();
    _name = name;
  }

  Game.empty() {
    _id = uuid.v1();
  }

  // getters
  String get name => _name;

  List<Player> get players => _players;

  List<Round> get rounds => _rounds;

  // Setters

  set name(String name) => _name = name;

  void setName(String name) {
    _name = name;
  }

  void addPlayer(Player player) {
    _players.add(player);
  }

  void addPlayerByName(String playerName) {
    bool playerNameFound = false;
    for (Player p in players) {
      playerNameFound = playerNameFound | (p.name == playerName);
    }

    if (!playerNameFound) {
      var player = Player(playerName);
      addPlayer(player);
    }
  }

  void addRound(Round round) {
    _rounds.add(round);
  }

  List<String> getPlayerNames() {
    List<String> playersList = [];

    for (var player in _players) {
      playersList.add(player.name);
    }

    return playersList;
  }

  //-----------------------------------------------------------------

  List<int> getTotalScores() {
    debugMsg("Game getTotalScores");

    Map<String, int> totalScores = {};

    for (Round round in rounds) {
      for (String playerName in round.getPlayerNames()) {
        // int prevScore = totalScores[playerName] ?? 0;
        // print(">> prevScore $prevScore");

        int thisScore = round.getScoreByName(playerName) ?? 0;
        // print(">> thisScore $thisScore");

        // int newScore = prevScore + thisScore;

        // print(">> newScore $newScore");

        totalScores[playerName] = (totalScores[playerName] ?? 0) + thisScore;
        //        totalScores.update(playerName, (value) => newScore, ifAbsent: () => 0 );
      }
    }

    return totalScores.values.toList();

    //-----------------------------------------------------------------

    // List<int> totalScoresList = [];

    // totalScores.forEach((player, score) {
    //   totalScoresList.add(totalScores[player] ?? 0);
    // });

    // return totalScoresList;
  }

  //-----------------------------------------------------------------

  void clear() {
    _players.clear();
    _rounds.clear();
  }

  //-----------------------------------------------------------------

  // Convert to JSON
  Map<String, dynamic> toJson() {
    debugMsg("Game toJson");

    Map<String, dynamic> jsonString;

    jsonString = {
      'id': _id,
      'name': _name,
      'players': _players.map((player) => player.toJson()).toList(),
      'rounds': _rounds.map((round) => round.toJson()).toList(),
    };

    debugMsg(jsonString.toString(), true);
    return jsonString;
  }

  //-----------------------------------------------------------------

  // Create from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    Game game = Game.empty();
    game._id = json['id'];
    game._name = json['name'];
    game._players =
        (json['players'] as List?)
            ?.map((playerJson) => Player.fromJson(playerJson))
            .toList() ??
        <Player>[];
    game._rounds =
        (json['rounds'] as List?)
            ?.map((roundJson) => Round.fromJson(roundJson))
            .toList() ??
        <Round>[];

    print("++++++++++++++++++++++++++++++++++++++++");
    print(game.toString());
    print("++++++++++++++++++++++++++++++++++++++++");

    return game;
  }

  //-----------------------------------------------------------------

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();

    buffer.write("Game id $_id name:$_name");

    buffer.write(" Players[");
    for (var player in players) {
      buffer.write(" ");
      buffer.write(player.toString());
    }
    buffer.write("] Rounds[");

    for (var round in rounds) {
      buffer.write(" ");
      buffer.write(round.toString());
    }
    buffer.write("]");
    
    return buffer.toString();
  }

  //-----------------------------------------------------------------
}
