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

import 'package:flutter/material.dart';
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
    _id = uuid.v1().substring(0,8);
    _name = name;
  }

  Game.empty() {
    _id = uuid.v1().substring(0,8);
  }

  // getters
  String get name => _name;

  List<Player> get players => _players;

  List<Round> get rounds => _rounds;

  // Setters

  set name(String name) => _name = name;

  void setPlayers(List<Player> players ) {
    debugMsg("Game setPlayers $players");
    for (int p = 0 ; p < players.length ; p ++) {
      _players.add(players[p]);
    }
  }

  void setRounds(List<Round> rounds ) {
    debugMsg("Game setRounds $rounds");    
    for (int r = 0 ; r < rounds.length ; r ++) {
      _rounds.add(rounds[r]);
    }
  }

  set players(List<Player> players) => _players = players;

  set rounds(List<Round> rounds) => _rounds = rounds;

  void setName(String name) {
    _name = name;
  }

  //-----------------------------------------------------------------

  void addPlayer(Player player) {
    _players.add(player);
  }

  //-----------------------------------------------------------------

  bool playerNameExists(String playerName) {
    return players.any((p) => p.name == playerName);
  }
  //-----------------------------------------------------------------

  void addPlayerByName(String playerName) {
    bool playerNameFound = false;
    for (Player p in players) {
      playerNameFound = playerNameFound | (p.name == playerName);
    }

    if (!playerNameFound) {
      var player = Player(playerName);
      player.setColor(Colors.black);
      addPlayer(player);
    }
  }

  //-----------------------------------------------------------------

  void initFirstRound() {
    Round firstRound = Round.blank();
    firstRound.setPlayers(players);
    _rounds.add(firstRound);
  }


  //-----------------------------------------------------------------

  void addRound(Round round) {
    _rounds.add(round);
  }

  //-----------------------------------------------------------------

  Player? getPlayerByName(String playerName) {
    return players.cast<Player?>().firstWhere(
      (p) => p?.name == playerName,
      orElse: () => null,
    );
  }
  //-----------------------------------------------------------------

  Player? getPlayerById(String playerId) {
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

  List<String> getPlayerIds() {
    return players.map((p) => p.id).toList();
  }

  //-----------------------------------------------------------------

  int numPlayers() {
    return players.length;
  }

  //-----------------------------------------------------------------

  List<int> getTotalScores() {
    debugMsg("Game getTotalScores");

    Map<String, int> totalScores = {};

    for (Round round in rounds) {
      for (String playerId in round.getPlayerIds()) {
        // int prevScore = totalScores[playerName] ?? 0;
        // print(">> prevScore $prevScore");

        int thisScore = round.getScoreById(playerId) ?? 0;
        // print(">> thisScore $thisScore");

        // int newScore = prevScore + thisScore;

        // print(">> newScore $newScore");

        totalScores[playerId] = (totalScores[playerId] ?? 0) + thisScore;
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

  void record(){
    debugMsg("game record");    
  }
  
  //-----------------------------------------------------------------

  void resetScores() {
    debugMsg("game resetScores");
    _rounds.clear();
  }

  //-----------------------------------------------------------------

  void clear() {
    debugMsg("game clear");
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
