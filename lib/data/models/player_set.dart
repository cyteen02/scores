/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/15/2026
*
*----------------------------------------------------------------------------*/

import 'dart:math';
import 'package:scores/data/models/player.dart';
import 'package:scores/utils/my_utils.dart';

class PlayerSet {
  int? id;
  List<Player> players = <Player>[];

  // Constructor
  PlayerSet({int? id, List<Player>? players}) {
    this.id = id ?? _generateId();
    this.players = players ?? <Player>[];
  }

  // Generate unique ID
  int _generateId() {
    return DateTime.now().millisecondsSinceEpoch * 1000 +
        Random().nextInt(1000);
  }

  // Setters

  //---------------------------------------------------------------

  // JSON conversion methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'players': players.map((player) => player.toJson()).toList(),
    };
  }

  factory PlayerSet.fromJson(Map<String, dynamic> json) {
    return PlayerSet(
      id: json['id'] as int?,
      players: (json['players'] as List<dynamic>?)
          ?.map(
            (playerJson) => Player.fromJson(playerJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  //---------------------------------------------------------------

  // Utility methods
  void addPlayer(Player player) {
    players.add(player);
  }

  //---------------------------------------------------------------

  void addPlayers(List<Player> players) {
    for (Player player in players) {
      players.add(player);
    }
  }

  //---------------------------------------------------------------

  void removePlayer(Player player) {
    players.remove(player);
  }

  //---------------------------------------------------------------

  void clearPlayers() {
    players.clear();
  }

  //---------------------------------------------------------------

  bool nameExists(String playerName) {
    return players.any((p) => p.name == playerName);
  }

  //---------------------------------------------------------------

  int get playerCount => players.length;

  //---------------------------------------------------------------

  int get numPlayers => players.length;

  //---------------------------------------------------------------

  void replacePlayer(Player oldPlayer, Player newPlayer) {
    int index = players.indexWhere((player) => player.name == oldPlayer.name);
    players[index] = newPlayer;
  }

  //---------------------------------------------------------------

  void replacePlayers(List<Player> newPlayers) {
    for (int i = 0; i<newPlayers.length ; i++) {
      players[i] = Player.copyFrom(newPlayers[i]);
    }
  }

  //---------------------------------------------------------------

  String get toCsv {
    List<int> playerIds = players.map((p) => p.id).toList();
    return listInttoCsv(playerIds);
  }

  //---------------------------------------------------------------

  @override
  String toString() {
    return 'PlayerSet{id: $id, playerCount: ${players.length}}';
  }

  //---------------------------------------------------------------
}
