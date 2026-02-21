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
//import 'package:scores/data/models/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scores/presentation/mixin/my_mixin.dart';
import 'package:scores/utils/my_utils.dart';

import 'package:scores/data/models/match.dart';

//------------------------------------------------------------------

class MatchStorage with MyMixin {
  
  static const String lastGameIdKey = 'LAST-GAME-ID';
  static const String lastNumPlayersKey = 'LAST-NUM_PLAYERS';

  //----------------------------------------------------------------

  Future<int> loadLastNumPlayers(int gameId) async {
    debugMsg("MatchStorage loadLastNumPlayers");

    final prefs = await SharedPreferences.getInstance();

    String lastNumPlayersKey = _getNumPlayersStorageKey(gameId);

    debugMsg("loading $lastNumPlayersKey");

    int lastNumPlayers = prefs.getInt(lastNumPlayersKey) ?? 0;

    debugMsg("last game of $gameId had $lastNumPlayers players");

    return lastNumPlayers;
  }

  //----------------------------------------------------------------

  String _getNumPlayersStorageKey(int gameId) {
    return "LAST-$gameId-NUM-PLAYERS";
  }
  //----------------------------------------------------------------

  String _getMatchStorageKey(int gameId, int numPlayers) {
    return "SCORE-$gameId-$numPlayers";
  }
  //----------------------------------------------------------------

  Future<void> saveMatch(Match match) async {
    debugMsg("MatchStorage saveMatch $match");

    final prefs = await SharedPreferences.getInstance();

    //    String lastNumPlayersKey = "LAST-${match.name}-NUM-PLAYERS";
    String lastNumPlayersKey = _getNumPlayersStorageKey(match.gameId);
    await prefs.setInt(lastNumPlayersKey, match.numPlayers());

    debugMsg("saving $lastNumPlayersKey ${match.numPlayers()}");

    String matchKey = _getMatchStorageKey(match.gameId, match.numPlayers());
    await prefs.setString(matchKey, jsonEncode(match.toJson()));
  }

  //----------------------------------------------------------------

  Future<Match?> loadMatch(int gameId, int numPlayers) async {

    debugMsg("MatchStorage loadGame game $gameId numPlayers $numPlayers");

    final key = _getMatchStorageKey(gameId, numPlayers);

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);

    debugMsg("MatchStorage jsonString $jsonString");

    Match? match;
    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      match = Match.fromJson(jsonMap);
    }
    debugMsg("loaded match $match");
    return match;
  }

  //----------------------------------------------------------------

  // Future<void> clearTasks() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(_key);
  // }

  Future<void> resetStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
