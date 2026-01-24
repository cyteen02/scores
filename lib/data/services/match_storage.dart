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
  
  static const String lastGameNameKey = 'LAST-GAME-NAME';
  static const String lastNumPlayersKey = 'LAST-NUM_PLAYERS';

  //----------------------------------------------------------------

  Future<int> loadLastNumPlayers(String gameName) async {
    debugMsg("MatchStorage loadLastNumPlayers");

    final prefs = await SharedPreferences.getInstance();

    String lastNumPlayersKey = _getNumPlayersStorageKey(gameName);

    debugMsg("loading $lastNumPlayersKey");

    int lastNumPlayers = prefs.getInt(lastNumPlayersKey) ?? 0;

    debugMsg("last game of $gameName had $lastNumPlayers players");

    return lastNumPlayers;
  }

  //----------------------------------------------------------------

  String _getNumPlayersStorageKey(String gameName) {
    return "LAST-$gameName-NUM-PLAYERS";
  }
  //----------------------------------------------------------------

  String _getMatchStorageKey(String gameName, int numPlayers) {
    return "SCORE-$gameName-$numPlayers";
  }
  //----------------------------------------------------------------

  Future<void> saveMatch(Match match) async {
    debugMsg("MatchStorage saveMatch $match");

    final prefs = await SharedPreferences.getInstance();

    //    String lastNumPlayersKey = "LAST-${match.name}-NUM-PLAYERS";
    String lastNumPlayersKey = _getNumPlayersStorageKey(match.name);
    await prefs.setInt(lastNumPlayersKey, match.numPlayers());

    debugMsg("saving $lastNumPlayersKey ${match.numPlayers()}");

    String matchKey = _getMatchStorageKey(match.name, match.numPlayers());
    await prefs.setString(matchKey, jsonEncode(match.toJson()));
  }

  //----------------------------------------------------------------

  Future<Match?> loadMatch(String gameName, int numPlayers) async {

    debugMsg("MatchStorage loadGame game $gameName numPlayers $numPlayers");

    final key = _getMatchStorageKey(gameName, numPlayers);

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
